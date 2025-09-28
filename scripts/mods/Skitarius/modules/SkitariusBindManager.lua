local SkitariusBindManager = class("SkitariusBindManager")

-- ACTIVE_BINDS: Tracks the state of each bind
local ACTIVE_BINDS = {
    override_primary = false,
    keybind_one_held = false,
    keybind_one_pressed = false,
    keybind_two_held = false,
    keybind_two_pressed = false,
    keybind_three_held = false,
    keybind_three_pressed = false,
    keybind_four_held = false,
    keybind_four_pressed = false,
}

-- MONITORED_ACTIONS: Actions which are monitored for input changes
local MONITORED_ACTIONS = {
    action_one_hold = true,
    action_one_pressed = true,
    action_two_hold = true,
    weapon_extra_pressed = true,
    weapon_extra_hold = true,
    weapon_reload_hold = true,
    quick_wield = true,
}

-- INPUT: The true state of each input (i.e. literal player input), as well as the system setting keybind for each input
local INPUT = {
    action_one_hold = {key,value},
    action_one_pressed = {key,value},
    action_two_hold = {key,value},
    weapon_extra_pressed = {key,value},
    weapon_extra_hold = {key,value},
    weapon_reload_hold = {key,value},
    quick_wield = {key,value},
}

-- BIND_DATA: Contains all sequence data for each keybind
local BIND_DATA = {
    override_primary = {MELEE = {},RANGED = {}},
    keybind_one_held = {MELEE = {},RANGED = {}},
    keybind_one_pressed = {MELEE = {},RANGED = {}},
    keybind_two_held = {MELEE = {},RANGED = {}},
    keybind_two_pressed = {MELEE = {},RANGED = {}},
    keybind_three_held = {MELEE = {},RANGED = {}},
    keybind_three_pressed = {MELEE = {},RANGED = {}},
    keybind_four_held = {MELEE = {},RANGED = {}},
    keybind_four_pressed = {MELEE = {},RANGED = {}},
}

-- MELEE_TEMPLATE: Template and default settings for melee weapons
local MELEE_TEMPLATE = {
    heavy_buff = "none",
    heavy_buff_stacks = 0,
    heavy_buff_special = false,
    special_buff_stacks = 0,
    always_special = false,
    force_heavy_when_special = false,
    sequence_cycle_point = "sequence_step_one",
    sequence_step_one = "none",
    sequence_step_two = "none",
    sequence_step_three = "none",
    sequence_step_four = "none",
    sequence_step_five = "none",
    sequence_step_six = "none",
    sequence_step_seven = "none",
    sequence_step_eight = "none",
    sequence_step_nine = "none",
    sequence_step_ten = "none",
    sequence_step_eleven = "none",
    sequence_step_twelve = "none",
}

-- RANGED_TEMPLATE: Template and default settings for ranged weapons
local RANGED_TEMPLATE = {
    automatic_fire = "none",
    auto_charge_threshold = 100,
    ads_filter = "ads_hip",
    rate_of_fire_hip = 0,
    rate_of_fire_ads = 0,
    automatic_special = false
}

-- SETTINGS: Lookup table for bind settings outside of template settings
local SETTINGS = {
    melee_weapon_selection = true,
    ranged_weapon_selection = true,
    keybind_selection_melee = true,
    keybind_selection_ranged = true,
    current_melee = true,
    current_ranged = true,
    reset_weapon_melee = true,
    reset_all_melee = true,
    reset_weapon_ranged = true,
    reset_all_ranged = true,
}

SkitariusBindManager.init = function(self, mod, engram, weapon_manager)
    self.mod = mod
    self.active_binds = ACTIVE_BINDS
    self.monitored_actions = MONITORED_ACTIONS
    self.input = INPUT
    self.engram = mod.engram
    self.weapon_manager = mod.weapon_manager
    self.bind_data = mod:get("bind_data") ~= nil and mod:get("bind_data") or BIND_DATA
    -- Ensure all binds/weapons with any data do not have any nil data
    for _, value in pairs(self.bind_data) do
        if value then
            if value.MELEE then
                for _, value2 in pairs(value.MELEE) do
                    if value2 then
                        for setting, default in pairs(MELEE_TEMPLATE) do
                            if value2[setting] == nil then
                                value2[setting] = default
                            end
                        end
                    end
                end
            elseif value.RANGED then
                for _, value2 in pairs(value.RANGED) do
                    if value2 then
                        for setting, default in pairs(RANGED_TEMPLATE) do
                            if value2[setting] == nil then
                                value2[setting] = default
                            end
                        end
                    end
                end
            end
        end
    end
    mod:set("bind_data", self.bind_data, false)
end

--  ╔═╗╔═╗╔╦╗╔╦╗╦╔╗╔╔═╗╔═╗
--  ╚═╗║╣  ║  ║ ║║║║║ ╦╚═╗
--  ╚═╝╚═╝ ╩  ╩ ╩╝╚╝╚═╝╚═╝

SkitariusBindManager.bind_setting = function(self, setting_name)
    local preliminary = SETTINGS[setting_name]
    if preliminary or self:valid_melee_setting(setting_name) or self:valid_ranged_setting(setting_name) then
        return true
    end
end

SkitariusBindManager.set_bind_setting = function(self, setting_name)
    local mod = self.mod
    local weapon_manager = self.weapon_manager
    -- Reset Melee Weapon
    if setting_name == "reset_weapon_melee" then
        self:reset_melee_binds()
    -- Reset Ranged Weapon
    elseif setting_name == "reset_weapon_ranged" then
        self:reset_ranged_binds()
    -- Reset All Melee
    elseif setting_name == "reset_all_melee" then
        self:reset_all_melee_binds()
    -- Reset All Ranged
    elseif setting_name == "reset_all_ranged" then
        self:reset_all_ranged_binds()
    -- Melee Weapon/Keybind Selection
    elseif setting_name == "melee_weapon_selection" or setting_name == "keybind_selection_melee" then
        self:set_melee_weapon_or_keybind()
    -- Melee Settings
    elseif self:valid_melee_setting(setting_name) then
        self:set_melee_setting(setting_name)
    -- Ranged Weapon/Keybind Selection
    elseif setting_name == "ranged_weapon_selection" or setting_name == "keybind_selection_ranged" then
        self:set_ranged_weapon_or_keybind()
    -- Ranged Settings
    elseif self:valid_ranged_setting(setting_name) then
        self:set_ranged_setting(setting_name)
    -- Individual Misc. Settings
    elseif setting_name == "current_melee" then
        local equipped = weapon_manager:get_equipped("MELEE")
        local target = mod:get("melee_weapon_selection") == equipped and "global_melee" or equipped
        if target then
            mod:set("melee_weapon_selection", target, true)
        end
        mod:set("current_melee", false, false)
    elseif setting_name == "current_ranged" then
        local equipped = weapon_manager:get_equipped("RANGED")
        local target = mod:get("ranged_weapon_selection") == equipped and "global_ranged" or equipped
        if target then
            mod:set("ranged_weapon_selection", target, true)
        end
        mod:set("current_ranged", false, false)
    end
end

--  ┌┬┐┌─┐┬  ┌─┐┌─┐
--  │││├┤ │  ├┤ ├┤ 
--  ┴ ┴└─┘┴─┘└─┘└─┘

SkitariusBindManager.valid_melee_setting = function(self, setting_name)
    return MELEE_TEMPLATE[setting_name] ~= nil
end

SkitariusBindManager.set_melee_setting = function(self, setting_name)
    local mod = self.mod
    local temp_bind = mod:get("keybind_selection_melee")
    local temp_weapon = mod:get("melee_weapon_selection")
    if not self.bind_data[temp_bind].MELEE[temp_weapon] then
        self.bind_data[temp_bind].MELEE[temp_weapon] = table.clone(MELEE_TEMPLATE)
        mod:set("bind_data", self.bind_data, false)
    end
    self.bind_data[temp_bind].MELEE[temp_weapon][setting_name] = mod:get(setting_name)
    mod:set("bind_data", self.bind_data, false)
end

SkitariusBindManager.reset_melee_binds = function(self)
    local mod = self.mod
    local temp_weapon = mod:get("melee_weapon_selection")
    mod:set("keybind_selection_melee", "override_primary", false)
    for key, _ in pairs(self.bind_data) do
        if self.bind_data[key].MELEE and self.bind_data[key].MELEE[temp_weapon] then
            self.bind_data[key].MELEE[temp_weapon] = table.clone(MELEE_TEMPLATE)
        end
    end
    mod:set("bind_data", self.bind_data, false)
    for key, value in pairs(MELEE_TEMPLATE) do
        mod:set(tostring(key), value, false)
    end
    mod:set("reset_weapon_melee", false, false)
end

SkitariusBindManager.reset_all_melee_binds = function(self)
    local mod = self.mod
    for key, _ in pairs(self.bind_data) do
        self.bind_data[key].MELEE = {
            global_melee = table.clone(MELEE_TEMPLATE)
        }
    end
    mod:set("melee_weapon_selection", "global_melee", false)
    mod:set("keybind_selection_melee", "override_primary", false)
    mod:set("bind_data", self.bind_data, false)
    for key, value in pairs(MELEE_TEMPLATE) do
        mod:set(tostring(key), value, false)
    end
    mod:set("reset_all_melee", false, false)
end

SkitariusBindManager.set_melee_weapon_or_keybind = function(self)
    local mod = self.mod
    local temp_weapon = mod:get("melee_weapon_selection")
    local temp_bind = mod:get("keybind_selection_melee")
    if not self.bind_data[temp_bind].MELEE[temp_weapon] then
        self.bind_data[temp_bind].MELEE[temp_weapon] = table.clone(MELEE_TEMPLATE)
        mod:set("bind_data", self.bind_data, false)
    end
    for key, _ in pairs(MELEE_TEMPLATE) do
        mod:set(tostring(key), self.bind_data[temp_bind].MELEE[temp_weapon][key], false)
    end
end

--  ┬─┐┌─┐┌┐┌┌─┐┌─┐┌┬┐
--  ├┬┘├─┤││││ ┬├┤  ││
--  ┴└─┴ ┴┘└┘└─┘└─┘─┴┘

SkitariusBindManager.valid_ranged_setting = function(self, setting_name)
    return RANGED_TEMPLATE[setting_name] ~= nil
end

SkitariusBindManager.set_ranged_setting = function(self, setting_name)
    local mod = self.mod
    local temp_bind = mod:get("keybind_selection_ranged")
    local temp_weapon = mod:get("ranged_weapon_selection")
    if not self.bind_data[temp_bind].RANGED[temp_weapon] then
        self.bind_data[temp_bind].RANGED[temp_weapon] = table.clone(RANGED_TEMPLATE)
        mod:set("bind_data", self.bind_data, false)
    end
    self.bind_data[temp_bind].RANGED[temp_weapon][setting_name] = mod:get(setting_name)
    mod:set("bind_data", self.bind_data, false)
end

SkitariusBindManager.reset_ranged_binds = function(self)
    local mod = self.mod
    local temp_weapon = mod:get("ranged_weapon_selection")
    mod:set("keybind_selection_ranged", "override_primary", false)
    for key, _ in pairs(self.bind_data) do
        if self.bind_data[key].RANGED and self.bind_data[key].RANGED[temp_weapon] then
            self.bind_data[key].RANGED[temp_weapon] = table.clone(RANGED_TEMPLATE)
        end
    end
    mod:set("bind_data", self.bind_data, false)
    for key, value in pairs(RANGED_TEMPLATE) do
        mod:set(tostring(key), value, false)
    end
    mod:set("reset_weapon_ranged", false, false)
end

SkitariusBindManager.reset_all_ranged_binds = function(self)
    local mod = self.mod
    for key, _ in pairs(self.bind_data) do
        self.bind_data[key].RANGED = {
            global_ranged = table.clone(RANGED_TEMPLATE)
        }
    end
    mod:set("ranged_weapon_selection", "global_ranged", false)
    mod:set("keybind_selection_ranged", "override_primary", false)
    mod:set("bind_data", self.bind_data, false)
    for key, value in pairs(RANGED_TEMPLATE) do
        mod:set(tostring(key), value, false)
    end
    mod:set("reset_all_ranged", false, false)
end

SkitariusBindManager.set_ranged_weapon_or_keybind = function(self)
    local mod = self.mod
    local temp_weapon = mod:get("ranged_weapon_selection")
    local temp_bind = mod:get("keybind_selection_ranged")
    if not self.bind_data[temp_bind].RANGED[temp_weapon] then
        self.bind_data[temp_bind].RANGED[temp_weapon] = table.clone(RANGED_TEMPLATE)
        mod:set("bind_data", self.bind_data, false)
    end
    for key, _ in pairs(RANGED_TEMPLATE) do
        mod:set(tostring(key), self.bind_data[temp_bind].RANGED[temp_weapon][key], false)
    end
end

--  ╔╗ ╦╔╗╔╔╦╗  ╔╦╗╔═╗╔╗╔╔═╗╔═╗╔═╗╔╦╗╔═╗╔╗╔╔╦╗
--  ╠╩╗║║║║ ║║  ║║║╠═╣║║║╠═╣║ ╦║╣ ║║║║╣ ║║║ ║ 
--  ╚═╝╩╝╚╝═╩╝  ╩ ╩╩ ╩╝╚╝╩ ╩╚═╝╚═╝╩ ╩╚═╝╝╚╝ ╩ 

SkitariusBindManager.bind_handler = function(self, bind, first)
    -- Do not allow bind handling while chat is open
    if not Managers.ui:chat_using_input() then
        local active_binds = self.active_binds
        -- Toggle bind tracking
        if string.find(bind, "pressed") then
            local any_toggle_active = false
            for key, _ in pairs(active_binds) do
                if key and string.find(key, "pressed") and active_binds[key] then
                    any_toggle_active = true
                    break
                end
            end
            -- If any toggle bind is active, pressing any toggle button should turn off the old one and turn on the new one.
            if any_toggle_active then
                -- If the bind which is being pressed is active, shut down all binds including this one
                if active_binds[bind] then
                    for key, _ in pairs(active_binds) do
                        if key and string.find(key, "pressed") and active_binds[key] then
                            active_binds[key] = false
                        end
                    end
                -- If this bind is not active, shut down all other binds and activate this one
                else
                    for key, _ in pairs(active_binds) do
                        if key and string.find(key, "pressed") and active_binds[key] then
                            active_binds[key] = false
                        end
                    end
                    active_binds[bind] = Managers.time:time("main")
                end
            -- If no binds are active, activate this one
            else
                active_binds[bind] = Managers.time:time("main")
            end
        -- Held bind tracking
        else
            -- Activation
            if not active_binds[bind] and first then
                active_binds[bind] = Managers.time:time("main")
            -- Deactivation
            else
                active_binds[bind] = false
            end
        end
    end
end

-- Sets override_primary "keybind" if holding or initially pressing action_one
SkitariusBindManager.maybe_update_primary_override = function(self, action_name, out)
    local active_binds = self.active_binds
    if action_name == "action_one_hold" or (action_name == "action_one_pressed" and out) then
        if out and not active_binds.override_primary then
            active_binds.override_primary = Managers.time:time("main")
        elseif not out then
            active_binds.override_primary = false
        end
    end
end

SkitariusBindManager.update_binds = function(self)
    local engram = self.engram
    local current_command = engram:current_command()
    local weapon_manager = self.weapon_manager
    local active_binds = self.active_binds
    -- Never interrupt wield actions to prevent landing on the wrong weapon while updating binds
    if current_command and string.find(current_command, "wield") then
        return
    end
    weapon_manager:refresh_weapon()
    local most_recent = 0
    local most_recent_bind = "none"
    for key, _ in pairs(active_binds) do
        if active_binds[key] then
            if active_binds[key] > most_recent then
                most_recent = active_binds[key]
                most_recent_bind = key
            end
        end
    end
    
    -- Update or clear engram if there is a new value which does not match the current engram's bind, or if the bind is no longer valid
    if most_recent_bind ~= engram.BIND or not engram:valid_engram(most_recent_bind) then
        -- Clear engram if there is no active bind
        
        if most_recent_bind == "none" then
            self.mod:kill_sequence()
        -- Otherwise update, unless currently controlled by a temp engram
        elseif not engram.TEMP then
            engram:new_engram(most_recent_bind)
        end
    end
end

--  ╔╦╗╔═╗╔╦╗╔═╗  ╔╦╗╔═╗╔╗╔╔═╗╔═╗╔═╗╔╦╗╔═╗╔╗╔╔╦╗
--   ║║╠═╣ ║ ╠═╣  ║║║╠═╣║║║╠═╣║ ╦║╣ ║║║║╣ ║║║ ║ 
--  ═╩╝╩ ╩ ╩ ╩ ╩  ╩ ╩╩ ╩╝╚╝╩ ╩╚═╝╚═╝╩ ╩╚═╝╝╚╝ ╩ 

-- Returns true if any binds are currently active; ignores engram state except for override_primary
SkitariusBindManager.any_binds = function(self)
    local active_binds = self.active_binds
    local engram = self.engram
    for key, _ in pairs(active_binds) do
        if active_binds[key] then
            if key == "override_primary" then
                if engram:valid_engram(key) then
                    return true
                end
            else
                return true
            end
        end
    end
    return false
end

SkitariusBindManager.get_bind_data = function(self)
    return self.bind_data
end

SkitariusBindManager.get_input_table = function(self)
    return self.input
end

SkitariusBindManager.input_value = function(self, input_name)
    local input = self.input[input_name]
    if input then
        return input.value
    end
end

SkitariusBindManager.set_input_value = function(self, input_name, value)
    local input = self.input[input_name]
    if input then
        input.value = value
    end
end

SkitariusBindManager.input_key = function(self, input_name)
    local input = self.input[input_name]
    if input then
        return input.key
    end
end

SkitariusBindManager.set_input_key = function(self, input_name, key)
    local input = self.input[input_name]
    if input then
        input.key = key
    end
end

SkitariusBindManager.override_primary = function(self)
    return self.active_binds.override_primary
end

SkitariusBindManager.waiting_toggles = function(self)
    for key, value in pairs(self.active_binds) do
        if string.find(key, "pressed") and value then
            return true
        end
    end
    return false
end

SkitariusBindManager.monitored_action = function(self, action_name)
    return self.monitored_actions[action_name] or false
end

return SkitariusBindManager