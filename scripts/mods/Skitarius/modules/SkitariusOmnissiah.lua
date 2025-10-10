SkitariusOmnissiah = class("SkitariusOmnissiah")

local LAST_SHOT = {
    ADS = 0,
    HIP = 0
}

-- PRAY[current_action][desired_action][queried_input] = required_state
local PRAY = {
    -- SHARED
    idle = {
        idle                 = { action_one_hold = false },
        start_attack         = { action_one_pressed = true, action_one_hold = true },
        light_attack         = { action_one_pressed = true, action_one_hold = true },
        heavy_attack         = { action_one_hold = true },
        push                 = { action_two_hold = true },
        push_follow_up       = { action_two_hold = true },
        block                = { action_two_hold = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = true, action_one_pressed = true },
        charge               = { action_two_hold = true, action_one_pressed = false, action_one_hold = false },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true, action_one_pressed = false, action_one_hold = false, action_two_hold = false },
        special_light_attack = { weapon_extra_hold = true },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true, action_one_pressed = false, action_one_hold = false },
    },
    special_action = {
        idle                 = { action_one_hold = false, action_one_pressed = false },
        start_attack         = { action_one_hold = true },
        light_attack         = { action_one_pressed = true },
        heavy_attack         = { action_one_hold = true },
        push                 = { action_two_hold = true },
        push_follow_up       = { action_two_hold = true },
        block                = { action_two_hold = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = true, action_one_pressed = true },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true },
        special_light_attack = { weapon_extra_hold = true },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true },
    },
    weapon_reload = {
        idle                 = { weapon_reload_hold = false },
        start_attack         = { weapon_reload_hold = false },
        light_attack         = { weapon_reload_hold = false },
        heavy_attack         = { weapon_reload_hold = false },
        push                 = { weapon_reload_hold = true },
        push_follow_up       = { weapon_reload_hold = true },
        block                = { weapon_reload_hold = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = true, action_one_pressed = true },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true },
        special_light_attack = { weapon_extra_hold = true },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true },
    },
    quick_wield = {
        idle                 = { action_one_hold = false },
        start_attack         = { action_one_hold = true },
        light_attack         = { action_one_hold = true },
        heavy_attack         = { action_one_hold = true },
        push                 = { action_two_hold = true },
        push_follow_up       = { action_two_hold = true },
        block                = { action_two_hold = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = true, action_one_pressed = true },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true },
        special_light_attack = { weapon_extra_hold = true },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true },
    },
    -- MELEE
    start_attack = {
        idle                 = { action_one_hold = false },
        start_attack         = { action_one_hold = true },
        light_attack         = { action_one_hold = false },
        heavy_attack         = { action_one_hold = true },
        push                 = { action_two_hold = true },
        push_follow_up       = { action_two_hold = true },
        block                = { action_two_hold = true },
        special_action       = { weapon_extra_pressed = true, action_one_hold = false },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
        shoot                = { action_one_hold = false }
    },
    light_attack = {
        idle                 = { action_one_hold = false },
        start_attack         = { action_one_hold = true },
        light_attack         = { action_one_hold = false },
        heavy_attack         = { action_one_hold = true },
        push                 = { action_one_hold = false },
        push_follow_up       = { action_one_hold = false },
        block                = { action_one_hold = false },
        special_action       = { weapon_extra_pressed = true, action_one_hold = false },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    heavy_attack = {
        idle                 = { action_one_hold = false },
        start_attack         = { action_one_hold = true },
        light_attack         = { action_one_pressed = true },
        heavy_attack         = { action_one_hold = true },
        push                 = { action_one_hold = false },
        push_follow_up       = { action_one_hold = false },
        block                = { action_one_hold = false },
        special_action       = { weapon_extra_pressed = true, action_one_hold = false },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    push = {
        idle                 = { action_one_hold = false },
        start_attack         = { action_one_hold = true },
        light_attack         = { action_one_pressed = false },
        heavy_attack         = { action_one_hold = false },
        push                 = { action_two_hold = true, action_one_hold = true, action_one_pressed = true },
        push_follow_up       = { action_two_hold = true, action_one_hold = true, action_one_pressed = true },
        block                = { action_two_hold = true },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    push_follow_up = {
        idle                 = { action_one_hold = false },
        start_attack         = { action_one_hold = true },
        light_attack         = { action_one_hold = true },
        heavy_attack         = { action_one_hold = true },
        push                 = { action_two_hold = true },
        push_follow_up       = { action_two_hold = true },
        block                = { action_two_hold = true },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    block = {
        idle                 = { action_two_hold = false },
        start_attack         = { action_two_hold = false },
        light_attack         = { action_two_hold = false },
        heavy_attack         = { action_two_hold = false },
        push                 = { action_two_hold = true, action_one_hold = true, action_one_pressed = true },
        push_follow_up       = { action_two_hold = true, action_one_hold = true, action_one_pressed = true },
        block                = { action_two_hold = true },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    -- RANGED
    shoot = {
        idle                 = { action_one_hold = true },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = true, action_one_pressed = true },
        charge               = { action_two_hold = true, action_one_hold = false, action_one_pressed = false },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true },
        special_light_attack = { weapon_extra_hold = true },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    shoot_alt = {
        idle                 = { action_one_hold = false },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = false },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true },
        special_light_attack = { weapon_extra_hold = true },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    charge = {
        idle                 = { action_two_hold = false },
        shoot                = { action_two_hold = true, action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = false },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true },
        special_light_attack = { weapon_extra_hold = true },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    charge_alt = {
        idle                 = { action_one_hold = false },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = false },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true },
        special_light_attack = { weapon_extra_hold = true },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    special_start_attack = {
        idle                 = { weapon_extra_hold = false },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = true, action_one_pressed = true },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = true },
        special_light_attack = { weapon_extra_hold = false },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_hold = false },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    special_light_attack = {
        idle                 = { weapon_extra_hold = false },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = true, action_one_pressed = true },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = false },
        special_light_attack = { weapon_extra_hold = false },
        special_heavy_attack = { weapon_extra_hold = true },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
    special_heavy_attack = {
        idle                 = { weapon_extra_hold = false },
        shoot                = { action_one_hold = true, action_one_pressed = true },
        shoot_alt            = { action_one_hold = true, action_one_pressed = true },
        charge               = { action_two_hold = true },
        charge_alt           = { action_one_hold = true },
        special_start_attack = { weapon_extra_hold = false },
        special_light_attack = { weapon_extra_hold = false },
        special_heavy_attack = { weapon_extra_hold = false },
        special_action       = { weapon_extra_pressed = true },
        quick_wield          = { quick_wield = true },
        weapon_reload        = { weapon_reload_hold = true },
    },
}

local DO_NOT_PAUSE = {
    action_two_hold = true,
    weapon_extra_pressed = true,
    weapon_extra_hold = true,
    weapon_reload_hold = true,
}

local LAST_DIVINATION = {
    action_one_hold = false,
    action_one_pressed = false,
    action_two_hold = false,
    weapon_extra_pressed = false,
    weapon_extra_hold = false,
    weapon_reload_hold = false,
    quick_wield = false,
}

local INTERRUPTING_ACTIONS = {
    weapon_extra_pressed = "special_action",
    weapon_extra_hold    = "special_action",
    weapon_reload_hold   = "weapon_reload",
}

local SWAP = {
    OCCURRED = false,
    LIMITER = true,
    SNAPSHOT = 0,
    COOLDOWN = 0.2
}

SkitariusOmnissiah.init = function(self, mod)
    self.mod = mod
    self.engram = mod.engram
    self.weapon_manager = mod.weapon_manager
    self.armoury = mod.armoury
    self.sweep = ""
end

SkitariusOmnissiah.set_bind_manager = function(self, bind_manager)
    self.bind_manager = bind_manager
end

--  ╔═╗╔═╗╔╦╗╦╔═╗╔╗╔  ╦ ╦╔═╗╔╗╔╔╦╗╦  ╔═╗╦═╗
--  ╠═╣║   ║ ║║ ║║║║  ╠═╣╠═╣║║║ ║║║  ║╣ ╠╦╝
--  ╩ ╩╚═╝ ╩ ╩╚═╝╝╚╝  ╩ ╩╩ ╩╝╚╝═╩╝╩═╝╚═╝╩╚═

SkitariusOmnissiah.omnissiah = function(self, queried_input, user_value)
    -- STAGE 0 : MAYBE_FORCE_INTERRUPT
    self:maybe_force_interrupt()
    -- STAGE 1, 2, & 3 : GET_ACTION
    local current_action = self:get_action()
    local desired_action = self.engram:current_command()
    -- Halt automatic firing inputs without altering engram or actions if pausing for RoF etc.
    if self:pause() then return DO_NOT_PAUSE[queried_input] and user_value or false end
    -- Iterate engram and recollect data for new state if the current action satisfies the engram's command, or if should_skip evaluates true
    --self.mod:echo("%s, %s", current_action, desired_action) -- DEBUG: View current action and next desired engram action
    if (current_action == desired_action or (desired_action and current_action == desired_action .. "_alt")) or self:should_skip(current_action, desired_action) then
        -- Weapon swaps are handled within on_slot_wielded hook to avoid an infinite loop, UNLESS via override_primary as that involves player input we need to handle
        if desired_action ~= "quick_wield" or self.bind_manager:override_primary() then
            self.engram:iterate_engram()
            current_action = self:get_action()
            desired_action = self.engram:current_command()
        end
    end
    -- STAGE 4 : MAYBE_CONVERT_DESIRE
    desired_action = self:maybe_convert_desire(current_action, desired_action)
    
    -- Check if engram not initialized OR no binds active - suppress input if waiting for imminenent engram, otherwise do nothing
    if not current_action or not PRAY[current_action] or not PRAY[current_action][desired_action] then
        if self.bind_manager:override_primary() and self.engram:valid_engram("override_primary") and not self.weapon_manager:is_blocking() then
            if queried_input == "action_one_pressed" or queried_input == "action_one_hold" then
                return false
            end
        end
        return self:resolve_conflicts(queried_input, user_value, divine_outcome)
    end
    --self.mod:echo("%s, %s", current_action, desired_action) -- DEBUG: View current action and final desired engram action after potential modifications
    local divine_outcome = PRAY[current_action][desired_action][queried_input]
    
    -- STAGE 5 : RESOLVE_CONFLICTS
    divine_outcome = self:resolve_conflicts(queried_input, user_value, divine_outcome)
    LAST_DIVINATION[queried_input] = divine_outcome
    return divine_outcome
end

--//////////////////////////////////////////////////////////////////////////////--
-- STAGE 0: CREATE A TEMPORARY ENGRAM OR HALT SEQUENCE IF SITUATION REQUIRES IT --
--//////////////////////////////////////////////////////////////////////////////--

SkitariusOmnissiah.maybe_force_interrupt = function(self)
    local engram = self.engram
    local current_command = engram:current_command()
    local input_table = self.bind_manager:get_input_table()
    if not current_command then return end
    -- Do not interrupt if busy with weapon swapping or a pre-existing interruption, or outside of keybind activity
    if engram.BIND == "TEMP" or engram.BIND == "INTERRUPT" or string.find(current_command, "wield") or not self.bind_manager:any_binds() then return end
    -- WeaponManager's interruption check is used for manual player actions which immediately halt any existing activity
    local kill_interruption = self.weapon_manager:interruption()
    if kill_interruption then
        self.mod:kill_sequence()
        return
    end
    -- INTERRUPTING_ACTIONS table check is used for player actions which should REPLACE existing activity
    for input, data in pairs(input_table) do
        if data.value then
            local interruption = INTERRUPTING_ACTIONS[input]
            -- Trigger interruption if not already either in an interruption or about to execute the same action organically
            if interruption and not current_command ~= interruption and engram.TYPE ~= interruption then
                if self.weapon_manager:in_cooldown() and (interruption == "special_action") then return end -- Skip if unable to complete interrupting action
                engram:build_temp_engram(interruption, "INTERRUPT")
                return
            end
        end
    end
    -- If no standard interruptions, check for FORCE_HEAVY_WHEN_SPECIAL criteria, as it also needs to override any existing activity if its criteria is met
    if engram:get_setting("FORCE_HEAVY_WHEN_SPECIAL") and self.weapon_manager:special_active() then
        engram:build_temp_engram("heavy_attack", "FORCE_HEAVY")
        return
    end
end

-- /////////////////////////////////////////////--
-- STAGE 1: COLLECT INITIAL RUNNING ACTION NAME --
-- /////////////////////////////////////////////--

SkitariusOmnissiah.get_action = function(self)
    local player = Managers.player:local_player_safe(1)
    if not player then return nil end
    local player_unit = player and player.player_unit
    local weapon_extension = player_unit and ScriptUnit.has_extension(player_unit, "weapon_system")
    local action_handler = weapon_extension and weapon_extension._action_handler
    local registered_components = action_handler and action_handler._registered_components
    local step_name = weapon_extension and "idle" or nil
    if registered_components then
        for _, handler_data in pairs(registered_components) do
            local running_action = handler_data.running_action
            if running_action then
                local action_settings = running_action:action_settings()
                local action_name = action_settings.name
                self:maybe_update_aim(action_name)
                temp_step_name = self:action_to_step(action_name)
                step_name = self:maybe_convert_action(player_unit, running_action, handler_data, action_settings, temp_step_name, action_name)
            end
        end
    end
    return step_name
end

-- //////////////////////////////////////////////////////////////////////////////////////--
-- STAGE 2: DISTILL ACTION NAMES TO ACTION DATA WHICH CAN BE RECOGNIZED BY THE OMNISSIAH --
-- //////////////////////////////////////////////////////////////////////////////////////--

SkitariusOmnissiah.action_to_step = function(self, action_name)
    local weapon_manager = self.weapon_manager
    local engram = self.engram
    local weapon_name = weapon_manager:weapon_name()
    local weapon_type = weapon_manager:weapon_type()
    if not (string.find(action_name, "push") or string.find(action_name, "find")) then
        weapon_manager:set_pushing(false)
    end
    -- MELEE
    if string.find(action_name, "start") and (not string.find(action_name, "start_special") or string.find(weapon_name, "combatsword_p2")) then
        return "start_attack"
    elseif string.find(action_name, "special") or string.find(action_name, "psyker_push") or string.find(action_name, "flashlight") or string.find(action_name, "whip") then
        if action_name == "action_attack_special_2" and string.find(weapon_name, "combatsword_p2") then
            return "light_attack"
        elseif string.find(action_name, "light") and not string.find(action_name, "flashlight") then
            return "light_attack"
        elseif string.find(action_name, "heavy") then
            return "heavy_attack"
        else
            return "special_action"
        end
    elseif string.find(action_name, "pushfollow") or string.find(action_name, "fling") then
        return "push_follow_up"
    elseif string.find(action_name, "push") or string.find(action_name, "find") then
        weapon_manager:set_pushing(true)
        return "push"
    elseif string.find(action_name, "light") then
        return "light_attack"
    elseif string.find(action_name, "heavy") or string.find(action_name, "special_2") then
        if weapon_type == "MELEE" then
            if string.find(action_name, "combo") then
                if engram:current_command() == "light_attack" or engram:next_engram_action() == "light_attack" then
                    return "light_attack"
                else
                    return "heavy_attack"
                end
            else
                return "heavy_attack"
            end
        else
            return "special_heavy_attack"
        end
    end
    if string.find(action_name, "block") then
        return "block"
    elseif string.find(action_name, "wield") then
        return "quick_wield"
    end
    -- RANGED
    if string.find(action_name, "shoot") or string.find(action_name, "trigger") or action_name == "rapid_left" then
        return "shoot"
    elseif string.find(action_name, "charge") then
        return "charge"
    elseif string.find(action_name, "bash") or string.find(action_name, "stab") then
        return "special_light_attack"
    elseif string.find(action_name, "vent") or string.find(action_name, "reload") then
        return "weapon_reload"
    end
    return "idle"
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////--
-- STAGE 3: ALTER ACTION DATA IF/WHEN THAT DATA DOES NOT ALIGN WITH HOW THE OMNISSIAH SHOULD TREAT IT --
-- ///////////////////////////////////////////////////////////////////////////////////////////////////--

SkitariusOmnissiah.maybe_convert_action = function(self, player_unit, running_action, handler_data, action_settings, action_name, original_name)
    if not action_name then return action_name end
    local weapon_manager = self.weapon_manager
    local engram = self.engram
    local armoury = self.armoury
    local weapon_name = weapon_manager and weapon_manager:weapon_name()
    local start_t = handler_data.component and handler_data.component.start_t
    local current_action_t = Managers.time:time("gameplay") - start_t
    -- Convert to heavy if this is a startup action which has charged enough to trigger a heavy attack
    if string.find(action_name, "start_attack") then
        if weapon_manager:weapon_type() == "RANGED" and string.find(original_name, "stab") or string.find(original_name, "bash") then
            if weapon_manager:is_charged_melee(running_action, handler_data.component, action_settings) then
                return "special_heavy_attack"
            else
                return "special_start_attack"
            end
        end
        if string.find(original_name, "shoot") then
            action_name = "charge"
        elseif weapon_manager:is_charged_melee(running_action, handler_data.component, action_settings) then
            return "heavy_attack"
        else
            return "start_attack"
        end
    end
    -- Convert charge/shoot to _alt versions if applicable for current weapon - do not return here as there may be other conversions
    if action_name == "shoot" or action_name == "charge" then
        if armoury.alt_weapons[weapon_name] then
            action_name = action_name .. "_alt"
        end
    end
    -- Convert to idle if this is an attacking action which has finished its damage window
    if action_settings.kind == "sweep" then
        if self.sweep == "after_damage_window" then
            return "idle"
        elseif action_name == "light_attack" or action_name == "heavy_attack" then
            if weapon_manager:is_light_complete(running_action, handler_data.component, action_settings) then
                return "idle"
            end
        end
    end
    -- Convert to idle if this is a shooting action which has fired
    if action_name == "shoot" or type(action_settings.kind) == "string" and (string.find(action_settings.kind, "shoot") or string.find(action_settings.kind, "projectile") 
    or string.find(action_settings.kind, "burst") or string.find(action_settings.kind, "chain") or string.find(action_settings.kind, "spawn")) then
        -- If this is smite, the game will automatically return to idle for us, so keep firing until either the game forcibly stops the action or the sequence is released by the player
        if weapon_name == "psyker_chain_lightning" then return "shoot" end
        if current_action_t > 0.05 then
            -- Track time of last shoot action for RoF
            if weapon_manager:is_aiming() then
                LAST_SHOT.ADS = Managers.time:time("main")
            else
                LAST_SHOT.HIP = Managers.time:time("main")
            end
            return "idle"
        end
    end
    -- Convert to idle if this is a special action which has finished activation
    if action_name == "special_action" then
        if original_name == "action_melee_start_special" then
            if weapon_manager:is_charged_melee(running_action, handler_data.component, action_settings) then
                return "heavy_attack"
            else
                return "start_attack"
            end
        end
        local data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")
        local block_component = data_extension and data_extension:read_component("block")
        -- Perfect blocking for parries
        local is_perfect = block_component and (block_component.is_blocking and not block_component.is_perfect_blocking)
        -- Special status for others
        local is_special = weapon_manager:special_active()
        if (is_special or is_perfect) and current_action_t > 0.4 then
            
            return "idle"
        else
            return action_name
        end
    end
    -- Treat reloads as special actions if in a temp engram to avoid messing up sequences
    if action_name == "weapon_reload" and engram.TEMP then
        if engram:current_command() == "special_action" or engram:next_engram_action() == "special_action" then
            return "special_action"
        else
            return action_name
        end
    end
    -- End pushes once they initiate, unless they are followed by a follow-up action
    if action_name == "push" and engram:current_command() ~= "push_follow_up" then
        if current_action_t > 0.1 then
            return "idle"
        end
    end
    return action_name
end

-- ////////////////////////////////////////////////////////////////////////////////--
-- STAGE 4: ALTER ENGRAM COMMAND DATA AS NEEDED DEPENDING ON THE CURRENT SITUATION --
-- ////////////////////////////////////////////////////////////////////////////////--

SkitariusOmnissiah.maybe_convert_desire = function(self, current_action, desired_action)
    if not desired_action then return desired_action end
    local weapon_manager = self.weapon_manager
    local armoury = self.armoury
    local engram = self.engram
    local weapon_name = weapon_manager:weapon_name()
    if desired_action == "shoot" or desired_action == "charge"  then
        if armoury.alt_weapons[weapon_name] then
            desired_action = desired_action .. "_alt"
        end
    end
    -- If not running an engram but charging and set to auto-release charges, release the charge
    if not desired_action then
        local always_charge = self.mod.settings.always_charge
        if current_action == "charge" and always_charge and weapon_manager:is_charged_ranged() then
            return "shoot"
        elseif current_action == "charge_alt" and always_charge and weapon_manager:is_charged_ranged() then
            return "shoot_alt"
        else
            return nil
        end
    end
    -- Do not allow engram to continue while charging until max charge is reached
    if current_action and type(current_action) == "string" and string.find(current_action, "charge") and (not desired_action or string.find(desired_action, "shoot")) then
        -- Ignore this logic for other standard fire modes
        if engram:get_setting("MODE") ~= "charged" then
            return desired_action
        end
        if weapon_manager:is_charged_ranged() then
            return desired_action
        else
            return current_action
        end
    end
    return desired_action
end

--//////////////////////////////////////////////////////////////////////////////--
-- STAGE 5: OVERRIDE OMNISSIAH'S DECISION IF IT CONFLICTS WITH VALID USER INPUT --
--//////////////////////////////////////////////////////////////////////////////--

SkitariusOmnissiah.resolve_conflicts = function(self, input, user, omnissiah)
    local outcome = omnissiah
    local armoury = self.armoury
    local engram = self.engram
    local weapon_manager = self.weapon_manager
    local bind_manager = self.bind_manager
    local weapon_name = weapon_manager:weapon_name()

    -- Actions taken when no engram is active
    if not omnissiah then
        local always_charge = self.mod.settings.always_charge
        if weapon_manager:weapon_type() == "RANGED" and always_charge and weapon_manager:is_charged_ranged() then
            if armoury.charged_ranged[weapon_name] then
                if armoury.alt_weapons[weapon_name] then
                    if bind_manager:input_value("action_two_hold") and input == "action_one_hold" then
                        return false
                    end
                elseif bind_manager:input_value("action_two_hold") and input == "action_one_pressed" then
                    return true
                end
            end
        end
    end
    -- Side with the user if they are attempting to block or quell/reload
    if bind_manager:input_value("weapon_reload_hold") and weapon_manager:can_reload() then
        engram:reset_engram()
        return nil
    end
    if bind_manager:input_value("action_two_hold") and weapon_manager:weapon_type() == "MELEE" then
        return nil
    end
    -- Prevent further holding of action_one if the user has already held it and is attempting a light attack, as chain_time increments even before action transitions
    if LAST_DIVINATION.action_one_hold and not engram.TEMP then
        if engram:current_command() == "light_attack" or engram:next_engram_action() == "light_attack" then
            if input == "action_one_hold" then
                outcome = false
            end
        end
    end
    -- Fix for force staffs getting stuck when at max charge due to trying to release for ALWAYS_CHARGE but unable to release due to max peril
    if input == "action_two_hold" and weapon_manager:weapon_type() == "RANGED" and armoury.force_staff[weapon_name] and weapon_manager:is_charged_ranged() and not engram:current_command() then
        outcome = user
    end
    -- Fix for charge actions not maintaining action_two_hold due to overlap of the "shoot" action with actions that must not hold it
    if input == "action_two_hold" and weapon_manager:weapon_type() == "RANGED" and engram:get_setting("MODE") == "charged" and self.engram:current_command() == "idle" then
        if (armoury.force_staff[weapon_name] and weapon_manager:current_charge() > 0) or weapon_name == "psyker_chain_lightning" then
            return true
        end
    end
    return outcome
end

--  ╦ ╦╔═╗╦  ╔═╗╔═╗╦═╗  ╔═╗╦ ╦╔╗╔╔═╗╔═╗
--  ╠═╣║╣ ║  ╠═╝║╣ ╠╦╝  ╠╣ ║ ║║║║║  ╚═╗
--  ╩ ╩╚═╝╩═╝╩  ╚═╝╩╚═  ╚  ╚═╝╝╚╝╚═╝╚═╝

-- Returns true if the engram should iterate regardless of whether or not the current state matches the desired one
SkitariusOmnissiah.should_skip = function(self, current_action, desired_action)
    local weapon_manager = self.weapon_manager
    local armoury = self.armoury
    local engram = self.engram
    local weapon_name = weapon_manager:weapon_name()
    -- Only check during an engram, excluding temporary engrams
    if engram.TYPE ~= "none" and not engram.TEMP then
        -- If not set to always activate specials and one is already active, skip
        if not engram:get_setting("ALWAYS_SPECIAL") and (weapon_manager:special_active() or weapon_manager:in_cooldown()) and desired_action == "special_action" then
            return true
        end
        -- If the next action is idle, but the action after leads to a heavy, immediately hold attack input by skipping idle to guarantee proper chaining
        if current_action == "light_attack" and desired_action == "idle" and engram:next_engram_action(1) == "heavy_attack" then
            return true
        end
        -- Dumb jank fix for combat shotguns getting stuck repeating shots in Special + Standard mode
        if current_action == "idle" and desired_action == "shoot" and engram:next_engram_action(1) == "special_action" and engram:get_setting("MODE") == "special_standard" then
            if armoury.combat_shotgun[weapon_name] then
                return true
            end
        end
    end
    return false
end

-- Sets IS_AIMING or IS_CHARGING dependent on aim/charge actions - only for ranged weapons
SkitariusOmnissiah.maybe_update_aim = function(self, action)
    local weapon_manager = self.weapon_manager
    if not action or not weapon_manager:weapon_type() == "RANGED" then weapon_manager:set_aiming(false) weapon_manager:set_charging(false) return end
    -- Aiming if initiated a zoom action, excluding matches for "unzoom"
    if (string.find(action, "zoom") and not string.find(action, "unzoom")) or (string.find(action, "brace") and not string.find(action, "unbrace")) then
        weapon_manager:set_aiming(true)
    -- Any non-shooting action exits aiming
    elseif not string.find(action, "shoot") then
        weapon_manager:set_aiming(false)
    end
    -- Charging if initiated a charge action
    if string.find(action, "charge") then
        weapon_manager:set_charging(true)
    -- Any other action exits charging
    else
        weapon_manager:set_charging(false)
    end
end

-- Returns true if the mod should halt user and mod input and freeze engram; allows user passthrough for actions in DO_NOT_PAUSE table
-- KNOWN BUG: DELAY IS NOT WORKING PROPERLY FOR SOME WEAPONS DUE TO ACTION CHAIN TIMES NOT BEING ACCOUNTED FOR WHEN SETTING DELAYS
SkitariusOmnissiah.pause = function(self)
    local engram = self.engram
    local weapon_manager = self.weapon_manager
    -- Never evaluate pausing unless in a non-temp ranged engram with active keybinds
    if not self.bind_manager:any_binds() or engram.TEMP then return false end
    if not SWAP.LIMITER then SWAP.SNAPSHOT = 0 end
    local delay = 0
    local last = 0
    --local offset = weapon_manager:firing_chain_time() or 0
    -- Ranged Weapon RoF Limiter
    if self.weapon_manager:weapon_type() == "RANGED" and (engram:get_setting("RATE_OF_FIRE_ADS") or engram:get_setting("RATE_OF_FIRE_HIP")) then
        -- Ensure SWAP_LIMITER does not interfere with RoF nor apply to ranged weapons
        SWAP_LIMITER = 0
        if engram:get_setting("RATE_OF_FIRE_ADS") > 0 and weapon_manager:is_aiming() then
            last = LAST_SHOT.ADS or 0
            delay = engram:get_setting("RATE_OF_FIRE_ADS") / 1000
        elseif engram:get_setting("RATE_OF_FIRE_HIP") > 0 and not weapon_manager:is_aiming() then
            last = LAST_SHOT.HIP or 0
            delay = engram:get_setting("RATE_OF_FIRE_HIP") / 1000
        end
    -- If an automated swap took place, mark the time for this iteration only
    elseif SWAP.LIMITER and SWAP.OCCURRED then
        SWAP.SNAPSHOT = Managers.time:time("main")
        SWAP.OCCURRED = false
    end
    -- Re-apply SWAP_LIMITER until the pause has finished
    if SWAP.SNAPSHOT > 0 then
        last = SWAP.SNAPSHOT
        delay = SWAP.COOLDOWN
    end
    
    local t = Managers.time:time("main")
    if t - last < delay then
        return true
    end
    SWAP.SNAPSHOT = 0
    return false
end

SkitariusOmnissiah.set_swap = function(self, occurred)
    SWAP.OCCURRED = occurred
end

SkitariusOmnissiah.reset_last_shot = function(self)
    LAST_SHOT.ADS = 0
    LAST_SHOT.HIP = 0
end

SkitariusOmnissiah.maybe_reset_last_shot = function(self, action, value)
    if action == "action_one_hold" and not value then
        self:reset_last_shot()
    end
end

return SkitariusOmnissiah