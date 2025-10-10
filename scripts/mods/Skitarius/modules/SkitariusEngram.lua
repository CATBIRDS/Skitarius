local SkitariusEngram = class("SkitariusEngram")

local SEQUENCE_STEPS = {
    "sequence_step_one",
    "sequence_step_two",
    "sequence_step_three",
    "sequence_step_four",
    "sequence_step_five",
    "sequence_step_six",
    "sequence_step_seven",
    "sequence_step_eight",
    "sequence_step_nine",
    "sequence_step_ten",
    "sequence_step_eleven",
    "sequence_step_twelve"
}

local STEP_TO_INDEX = {
    no_repeat=0,
    sequence_step_one=1,
    sequence_step_two=2,
    sequence_step_three=3,
    sequence_step_four=4,
    sequence_step_five=5,
    sequence_step_six=6,
    sequence_step_seven=7,
    sequence_step_eight=8,
    sequence_step_nine=9,
    sequence_step_ten=10,
    sequence_step_eleven=11,
    sequence_step_twelve=12
}

local SUB_SEQUENCE = {
    -- MELEE
    light_attack = {"start_attack", "light_attack", "idle"}, 
    heavy_attack = {"start_attack", "heavy_attack", "idle"},
    block = {"block", "idle"},
    special_action = {"special_action", "idle"},
    push = {"block", "push", "idle"},
    push_attack = {"block", "push", "push_follow_up"},
    wield = {"quick_wield"},
    -- RANGED
    standard = { "shoot", "idle" },
    charged = { "charge", "shoot", "idle" },
    special_attack = { "special_start_attack", "special_light_attack", "idle" },
    special_attack_charged = { "special_start_attack", "special_heavy_attack", "idle" },
    special_standard = { "special_action", "shoot", "idle" },
    -- OTHER
    hold_reload = { "weapon_reload" }
}




-- Initializes the engram state for the SkitariusEngram object
SkitariusEngram.init = function(self, mod)
    self.mod = mod
    self.armoury = mod.armoury
end

SkitariusEngram.set_weapon_manager = function(self, weapon_manager)
    self.weapon_manager = weapon_manager
end

SkitariusEngram.set_bind_manager = function(self, bind_manager)
    self.bind_manager = bind_manager
end

-- Something about this is fucked
SkitariusEngram.new_engram = function(self, bind_name_or_temp_data, temp_or_nil)
    local weapon_manager = self.weapon_manager
    local armoury = self.armoury
    local weapon_type = weapon_manager:weapon_type()
    local weapon_name = weapon_manager:weapon_name()
    local intermediary = self:valid_engram(bind_name_or_temp_data, temp_or_nil)
    if not bind_name_or_temp_data or not intermediary or not weapon_name or not weapon_type then
        self:kill_engram()
        return
    end
    if temp_or_nil then
        return self:build_temp_engram(bind_name_or_temp_data, weapon_name)
    end
    if weapon_type == "MELEE" then
        local command_queue, engram_settings, cycle_index = {}, {}, 1
        for i = 1, #SEQUENCE_STEPS do
            local step = SEQUENCE_STEPS[i]
            if intermediary[step] and intermediary[step] ~= "none" then table.insert(command_queue, intermediary[step]) end
        end
        
        if intermediary.sequence_cycle_point and STEP_TO_INDEX[intermediary.sequence_cycle_point] then
            cycle_index = STEP_TO_INDEX[intermediary.sequence_cycle_point] <= 1 and STEP_TO_INDEX[intermediary.sequence_cycle_point] or 1
            if STEP_TO_INDEX[intermediary.sequence_cycle_point] > 1 then
                for i = 1, STEP_TO_INDEX[intermediary.sequence_cycle_point] - 1 do
                    if SUB_SEQUENCE[command_queue[i]] then cycle_index = cycle_index + #SUB_SEQUENCE[command_queue[i]] end
                end
            end
        end
        engram_settings = {
            CYCLE_INDEX = cycle_index,
            HEAVY_BUFF = intermediary.heavy_buff or "none",
            HEAVY_BUFF_STACKS = intermediary.heavy_buff_stacks or 0,
            SPECIAL_BUFF_STACKS = intermediary.special_buff_stacks or 0,
            HEAVY_BUFF_SPECIAL = intermediary.heavy_buff_special or false,
            ALWAYS_SPECIAL = intermediary.always_special or false,
            FORCE_HEAVY_WHEN_SPECIAL = intermediary.force_heavy_when_special or false,
        }
        local all_wield = true
        for i = 1, #command_queue do if command_queue[i] ~= "wield" then all_wield = false break end end
        if all_wield then return end


        local expanded_queue = {}
        for i = 1, #command_queue do
            local action = command_queue[i]
            local sub_sequence = SUB_SEQUENCE[action]
            
            if sub_sequence then for j = 1, #sub_sequence do table.insert(expanded_queue, sub_sequence[j]) end end
        end

        self.COMMANDS = expanded_queue
        self.SETTINGS = engram_settings
        self.TEMP = false
        self.BIND = bind_name_or_temp_data
        self.ORIGIN = weapon_name
        self.INDEX = 1
        self.TYPE = "MELEE"

    elseif weapon_type == "RANGED" then
        
        local fire_mode = intermediary.automatic_fire
        if fire_mode == "special" then fire_mode = armoury.special_attack[weapon_name] and "special_attack" or "special_action"
        elseif fire_mode == "special_charged" then fire_mode = armoury.special_attack[weapon_name] and "special_attack_charged" or "special_action"
        elseif fire_mode == "charged" and not armoury.charged_ranged[weapon_name] then fire_mode = "standard"
        elseif fire_mode == "special_standard" and not armoury.active_special_ranged[weapon_name] then fire_mode = "standard" end
        local sub_sequence = SUB_SEQUENCE[fire_mode]
        local command_queue = {}
        if sub_sequence then
            for i = 1, #sub_sequence do
                table.insert(command_queue, sub_sequence[i])
            end
        end
        local engram_settings = {
            MODE = fire_mode,
            ALWAYS_SPECIAL = fire_mode ~= "special_standard" and not armoury.active_special_ranged[weapon_name] and true or false,
            ADS_FILTER = intermediary.ads_filter or "none",
            RATE_OF_FIRE_HIP = intermediary.rate_of_fire_hip or 0,
            RATE_OF_FIRE_ADS = intermediary.rate_of_fire_ads or 0,
            CHARGE_THRESHOLD = intermediary.auto_charge_threshold,
            AUTOMATIC_SPECIAL = intermediary.automatic_special or false,
        }

        self.COMMANDS = command_queue
        self.SETTINGS = engram_settings
        self.TEMP = false
        self.BIND = bind_name_or_temp_data
        self.ORIGIN = weapon_name
        self.INDEX = 1
        self.TYPE = "RANGED"
    end
end

-- Returns the current engram data for the specified bind alongside the bind name if it is valid, otherwise nil
SkitariusEngram.valid_engram = function(self, bind, temp_or_nil)
    if not bind then return nil, nil end
    local weapon_manager = self.weapon_manager
    local weapon_type = weapon_manager:weapon_type()
    local weapon_name = weapon_manager:weapon_name()
    local engram_data, engram_name
    local bind_data = self.bind_manager:get_bind_data()
    if not bind_data or not bind_data[bind] then
        return nil, nil
    end

    if weapon_type == "RANGED" then
        local ranged = bind_data[bind].RANGED
        
        if not ranged then return nil, nil end
        if ranged[weapon_name] and ranged[weapon_name].automatic_fire and ranged[weapon_name].automatic_fire ~= "none" then
            engram_data, engram_name = ranged[weapon_name], weapon_name
        elseif ranged.global_ranged and ranged.global_ranged.automatic_fire and ranged.global_ranged.automatic_fire ~= "none" then
            engram_data, engram_name = ranged.global_ranged, "global_ranged"
        end
    end

    if weapon_type == "MELEE" then
        local melee = bind_data[bind].MELEE
        if not melee then return nil, nil end
        
        if melee[weapon_name] and melee[weapon_name].sequence_step_one ~= "none" then
            engram_data, engram_name = melee[weapon_name], weapon_name
        elseif melee.global_melee and melee.global_melee.sequence_step_one ~= "none" then
            engram_data, engram_name = melee.global_melee, "global_melee"
        end
    end
    -- If this is a valid ranged engram, check ADS/Hipfire filter before continuing
    if engram_data and engram_name and weapon_type == "RANGED" and engram_data.ads_filter then
        if engram_data.ads_filter == "hip_only" and weapon_manager:is_aiming() then
            return nil, nil
        elseif engram_data.ads_filter == "ads_only" and not weapon_manager:is_aiming() then
            return nil, nil
        end
    end
    return engram_data, engram_name
end

SkitariusEngram.current_command = function(self)
    if not self.COMMANDS or not self.INDEX then
        return nil
    end
    return self.COMMANDS[self.INDEX]
end

-- Generate a temporary engram sequence and apply it as the current engram
SkitariusEngram.build_temp_engram = function(self, action, optional_origin)
    if self.TYPE == action or self.BIND == "TEMP" or self.BIND == "INTERRUPT" or self.COMMANDS[self.INDEX] and string.find(self.COMMANDS[self.INDEX], "wield") then
        return
    end
    local weapon_manager = self.weapon_manager
    local sequence = SUB_SEQUENCE[action]
    if sequence then
        self.BIND     = optional_origin or "TEMP" -- Using optional_origin allows for this bind to be overwritten by other temp binds
        replacement_settings = {
            HEAVY_BUFF = self.SETTINGS.HEAVY_BUFF or nil,
            HEAVY_BUFF_STACKS = self.SETTINGS.HEAVY_BUFF_STACKS or nil,
            HEAVY_BUFF_SPECIAL = self.SETTINGS.HEAVY_BUFF_SPECIAL or nil,
        }
        local queue = {}
        for i = 1, #sequence do
            table.insert(queue, sequence[i])
        end
        -- Use current weapon for origin, or fallback to melee
        local weapon = weapon_manager:current_equipped()
        self.COMMANDS = queue
        self.TEMP     = true
        self.TYPE     = action
        self.ORIGIN   = weapon
        self.SETTINGS = replacement_settings
        self.INDEX    = 1
    end
end

-- Move engram to the next index, or reset if it has reached its conclusion
SkitariusEngram.iterate_engram = function(self)
    if self.INDEX + 1 > #self.COMMANDS then
        -- If this is a temp engram then exit to any held binds rather than restarting
        if self.TEMP then
            self.TEMP = false
            self.COMMANDS = {}
            -- If this temp engram was created due to an interruption and HALT_ON_INTERRUPT is enabled, clear keybinds upon its completion
            local halt_on_interrupt = self.mod.settings.halt_on_interrupt
            if halt_on_interrupt and self.BIND == "INTERRUPT" then
                self.mod:kill_sequence()
            end
            self.bind_manager:update_binds()
        else
            -- Cycle index of 0 indicates that the engram should not loop, and should instead end the sequence
            if self.SETTINGS.CYCLE_INDEX == 0 then
                self.mod:kill_sequence()
            else
                self.INDEX = (self.SETTINGS and self.SETTINGS.CYCLE_INDEX) or 1
            end
        end
    else
        self.INDEX = self.INDEX + 1
    end
end

-- Returns the next command after self.INDEX, or further based on the optional addition parameter
SkitariusEngram.next_engram_action = function(self, optional_addition)
    extra = type(optional_addition) == "number" and optional_addition + 1 or 1
    if self.INDEX + extra > #self.COMMANDS then
        local base = self.SETTINGS.CYCLE_INDEX and self.SETTINGS.CYCLE_INDEX - 1 or 0
        local diff = #self.COMMANDS - self.INDEX
        return self.COMMANDS[base + (extra - diff)]
    else
        return self.COMMANDS[self.INDEX + extra]
    end
end

-- Reset the engram sequence to the first action
SkitariusEngram.reset_engram = function(self)
    self.INDEX = 1
end

-- Reset engram to empty state, clearing all data
SkitariusEngram.kill_engram = function(self)
    self.INDEX    = 1
    self.TEMP     = false
    self.TYPE     = "none"
    self.BIND     = "none"
    self.ORIGIN   = "none"
    self.SETTINGS = {}
    self.COMMANDS = {}
end

SkitariusEngram.heavy_buff = function(self)
    if not self.SETTINGS or not self.SETTINGS.HEAVY_BUFF or self.SETTINGS.HEAVY_BUFF == "none" then
        return
    end
    return self.SETTINGS.HEAVY_BUFF
end

SkitariusEngram.heavy_buff_stacks = function(self)
    if not self.SETTINGS or not self.SETTINGS.HEAVY_BUFF_STACKS or self.SETTINGS.HEAVY_BUFF_STACKS < 1 then
        return 0
    end
    return self.SETTINGS.HEAVY_BUFF_STACKS
end

SkitariusEngram.heavy_buff_special = function(self)
    if not self.SETTINGS or not self.SETTINGS.HEAVY_BUFF_SPECIAL then
        return false
    end
    return self.SETTINGS.HEAVY_BUFF_SPECIAL
end

SkitariusEngram.heavy_buff_special_stacks = function(self)
    if not self.SETTINGS or not self.SETTINGS.SPECIAL_BUFF_STACKS or self.SETTINGS.SPECIAL_BUFF_STACKS < 1 then
        return 0
    end
    return self.SETTINGS.SPECIAL_BUFF_STACKS
end

SkitariusEngram.charge_threshold = function(self)
    if not self.SETTINGS or not self.SETTINGS.CHARGE_THRESHOLD or self.SETTINGS.CHARGE_THRESHOLD < 0 then
        return nil
    end
    return self.SETTINGS.CHARGE_THRESHOLD
end

SkitariusEngram.get_setting = function(self, setting_name)
    if not self.SETTINGS or not self.SETTINGS[setting_name] then
        return nil
    end
    return self.SETTINGS[setting_name]
end

return SkitariusEngram