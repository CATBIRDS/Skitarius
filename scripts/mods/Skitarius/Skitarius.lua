-- Written by Norkkom aka "SanctionedPsyker"
local mod = get_mod("Skitarius")
local Engram = mod:io_dofile("Skitarius/scripts/mods/Skitarius/modules/SkitariusEngram")
local Armoury = mod:io_dofile("Skitarius/scripts/mods/Skitarius/modules/SkitariusArmoury")
local Omnissiah = mod:io_dofile("Skitarius/scripts/mods/Skitarius/modules/SkitariusOmnissiah")
local BindManager = mod:io_dofile("Skitarius/scripts/mods/Skitarius/modules/SkitariusBindManager")
local WeaponManager = mod:io_dofile("Skitarius/scripts/mods/Skitarius/modules/SkitariusWeaponManager")
local WidgetManager = mod:io_dofile("Skitarius/scripts/mods/Skitarius/modules/SkitariusWidgetManager")
-- Done early to ensure HUD injection
mod.widget_manager = WidgetManager:new(mod)

--┌───────────────────────┐--
--│ ╔═╗╦  ╔═╗╔╗ ╔═╗╦  ╔═╗ │--
--│ ║ ╦║  ║ ║╠╩╗╠═╣║  ╚═╗ │--
--│ ╚═╝╩═╝╚═╝╚═╝╩ ╩╩═╝╚═╝ │--
--└───────────────────────┘--

mod.settings = {
    maintain_bind = false,
    manual_swap = false,
    always_charge = false,
    always_charge_threshold = 1,
    pushing = false,
    force_heavy_when_special = false,
    interrupt = "none",
    halt_on_interrupt = false,
}

local INITIALIZED = false
local MOD_ENABLED = true
local MAINTAIN_BIND = false
local MANUAL_SWAP = false
local WEENIE_HUT_JR = false

--┌───────────┐--
--│ ╔╦╗╔═╗╔╦╗ │--
--│ ║║║║ ║ ║║ │--
--│ ╩ ╩╚═╝═╩╝ │--
--└───────────┘--

mod.on_enabled = function()
    MOD_ENABLED = true
end

mod.on_disabled = function()
    MOD_ENABLED = false
end

mod.on_game_state_changed = function()
    mod.kill_sequence()
end

mod.on_setting_changed = function(setting_name)
    -- Clear any active engram/bind data
    mod.kill_sequence()
    local bind_manager = mod.bind_manager
    local widget_manager = mod.widget_manager
    -- Keybind settings
    if bind_manager:bind_setting(setting_name) then
        bind_manager:set_bind_setting(setting_name)
    -- HUD settings
    elseif widget_manager:widget_setting(setting_name) then
        widget_manager:set_widget_setting(setting_name)
    -- Mod settings
    elseif setting_name == "always_charge" then
        mod.settings.always_charge = mod:get("always_charge")
    elseif setting_name == "always_charge_threshold" then
        mod.settings.always_charge_threshold = mod:get("always_charge_threshold")
    elseif setting_name == "halt_on_interrupt" then
        mod.halt_on_interrupt = mod:get("halt_on_interrupt")
    elseif setting_name == "interrupt" then
        mod.interrupt = mod:get("interrupt")
    -- Global settings
    elseif setting_name == "overload_protection" then
        WEENIE_HUT_JR = mod:get("overload_protection")
    elseif setting_name == "mod_enable_held" then
        ENABLE_BIND_HELD = mod:get("mod_enable_held")
    elseif setting_name == "mod_enable_pressed" then
        ENABLE_BIND_PRESSED = mod:get("mod_enable_pressed")
    elseif setting_name == "maintain_bind" then
        MAINTAIN_BIND = mod:get("maintain_bind")
    end
end

-- Refresh weapon data and mod settings when mods are loaded
mod.on_all_mods_loaded = function()
    mod.build_modules()
    mod.initialize()
    mod.bind_manager:update_binds()
end

-- Rebuild modules when any settings changes are made, or upon initialization
mod.build_modules = function()
    mod.armoury = Armoury
    mod.engram = Engram:new(mod)
    mod.weapon_manager = WeaponManager:new(mod)
    mod.engram:set_weapon_manager(mod.weapon_manager)
    mod.bind_manager = BindManager:new(mod)
    mod.engram:set_bind_manager(mod.bind_manager)
    mod.omnissiah = Omnissiah:new(mod)
    mod.weapon_manager:set_bind_manager(mod.bind_manager)
    mod.omnissiah:set_bind_manager(mod.bind_manager)
    mod.widget_manager:set_bind_manager(mod.bind_manager)
end

mod.ready = function(self)
    return INITIALIZED and MOD_ENABLED
end

mod.initialize = function()
    -- Set up defaults if no data
    WEENIE_HUT_JR = mod:get("overload_protection")
    mod.settings.always_charge = mod:get("always_charge") or false
    mod.settings.always_charge_threshold = mod:get("always_charge_threshold") or 100
    mod.settings.halt_on_interrupt = mod:get("halt_on_interrupt") or false
    mod.settings.interrupt = mod:get("interrupt") or "none"
    MAINTAIN_BIND = mod:get("maintain_bind") or false
    if mod.engram and mod.weapon_manager and mod.omnissiah and mod.bind_manager then
        INITIALIZED = true
    end
end

--┌────────────────────┐--
--│ ╔═╗╦ ╦╔═╗╦═╗╔═╗╔╦╗ │--
--│ ╚═╗╠═╣╠═╣╠╦╝║╣  ║║ │--
--│ ╚═╝╩ ╩╩ ╩╩╚═╚═╝═╩╝ │--
--└────────────────────┘--

-- Clear keybind and engram data; any bind specified as parameter will NOT be cleared
mod.kill_sequence = function(optional_exclusion)
    local engram = mod.engram
    local bind_manager = mod.bind_manager
    local active_binds = bind_manager.active_binds
    -- Clear ACTIVE_BINDS
    for key, _ in pairs(active_binds) do
        if key ~= optional_exclusion then
            active_binds[key] = false
        end
    end
    -- Do not clear engram if it belongs to the specified exclusion
    if engram.BIND == optional_exclusion then
        return
    end
    -- Clear ENGRAM
    engram:kill_engram()
    -- Clear RoF last shot data
    --mod.omnissiah:reset_last_shot()
    mod.weapon_manager:set_firing(false)
end

-- Settings recall to ensure up-to-date values via modules
-- From testing this has no noticeable performance impact, but fetching via get() is still expensive and objectively a poor solution - this should be replaced as soon as possible.
-- The problem specifically is that modules will have outdated references to the parent object once users make changes to settings that are stored to mod.settings via the menus.
-- Currently this impacts Omnissiah/Engram's checking of "halt_on_interrupt", and Omnissiah/WeaponManager's checking of "always_charge"/"always_charge_threshold".
mod.recall_setting = function(setting_name)
    if mod.settings[setting_name] ~= nil then
        if mod:get(setting_name) ~= mod.settings[setting_name] then
            mod.settings[setting_name] = mod:get(setting_name)
        end
        return mod.settings[setting_name]
    end
end

--┌────────────────────┐--
--│ ╦ ╦╔═╗╔╦╗╔═╗╔╦╗╔═╗ │--
--│ ║ ║╠═╝ ║║╠═╣ ║ ║╣  │--
--│ ╚═╝╩  ═╩╝╩ ╩ ╩ ╚═╝ │--
--└────────────────────┘--

mod.update = function()
    mod.widget_manager:update_hud()
    if mod:ready() then
        mod.weapon_manager:update_peril()
        mod.bind_manager:update_binds()
    end
end

--┌────────────────────────┐--
--│ ╦╔═╔═╗╦ ╦╔╗ ╦╔╗╔╔╦╗╔═╗ │--
--│ ╠╩╗║╣ ╚╦╝╠╩╗║║║║ ║║╚═╗ │--
--│ ╩ ╩╚═╝ ╩ ╚═╝╩╝╚╝═╩╝╚═╝ │--
--└────────────────────────┘--

-- Function for mod toggle keybind
mod.mod_enable_toggle = function()
    if not Managers.ui:using_input() then
        MOD_ENABLED = not MOD_ENABLED
    end
end

-- Functions for sequence keybinds
mod.pressed_one = function()
    mod.bind_manager:bind_handler("keybind_one_pressed", true)
end
mod.held_one = function(first)
    mod.bind_manager:bind_handler("keybind_one_held", first)
end
mod.pressed_two = function()
    mod.bind_manager:bind_handler("keybind_two_pressed", true)
end
mod.held_two = function(first)
    mod.bind_manager:bind_handler("keybind_two_held", first)
end
mod.pressed_three = function()
    mod.bind_manager:bind_handler("keybind_three_pressed", true)
end
mod.held_three = function(first)
    mod.bind_manager:bind_handler("keybind_three_held", first)
end
mod.pressed_four = function()
    mod.bind_manager:bind_handler("keybind_four_pressed", true)
end
mod.held_four = function(first)
    mod.bind_manager:bind_handler("keybind_four_held", first)
end

--┌─────────────────┐--
--│ ╦ ╦╔═╗╔═╗╦╔═╔═╗ │--
--│ ╠═╣║ ║║ ║╠╩╗╚═╗ │--
--│ ╩ ╩╚═╝╚═╝╩ ╩╚═╝ │--
--└─────────────────┘--

--///////////////////////////////////////////////////////////////////////////////////////////////--
-- PlayerUnitWeaponExtension: MONITOR FOR WIELD ACTIONS TO CONTROL ITERATION DURING WEAPON SWAPS --
--///////////////////////////////////////////////////////////////////////////////////////////////--

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, t, skip_wield_action)
    -- Never reset sequence upon wield if executing a weapon swap
    local current_command = mod.engram:current_command()
    if current_command and not string.find(current_command, "wield") then
        -- Reset RoF shot tracking
        mod.omnissiah:reset_last_shot()
        -- Reset if not maintaining binds, if this swap was performed manually
        if not MAINTAIN_BIND and MANUAL_SWAP then
            mod.kill_sequence()
        end
    else
        mod.weapon_manager:refresh_weapon()
        -- Only iterate wield actions if the engram has returned to its starting weapon
        if mod.engram.ORIGIN == mod.weapon_manager:weapon_name() then
            mod.omnissiah:set_swap(true)
            mod.engram:iterate_engram()
        end
    end
    MANUAL_SWAP = false
end)

--/////////////////////////////////////////////////////////////////////////////////////////////////////////--
-- PlayerCharacterStateStunned: MONITOR FOR PLAYER STUNS, AND RESET ENGRAM OR BUILD TEMP ENGRAMS AS NEEDED --
--/////////////////////////////////////////////////////////////////////////////////////////////////////////--

local SELF_INFLICTED_STUNS = {
    thunder_hammer_light = true,
    thunder_hammer_heavy = true,
    thunder_hammer_m2_light = true,
    thunder_hammer_m2_heavy = true,
}

mod:hook_safe(CLASS.PlayerCharacterStateStunned, "on_enter", function (self, unit, dt, t, previous_state, params)
    -- Potentially reset/halt sequence if stunned by a non-self-inflicted source
    if params and params.disorientation_type and not SELF_INFLICTED_STUNS[params.disorientation_type] then
        if not mod.engram.TEMP and mod.interrupt ~= "none" and mod.weapon_manager:weapon_type() == "MELEE" then
            if mod.interrupt == "reset" then
                mod.engram:reset_engram()
            elseif mod.interrupt == "halt" then
                mod.kill_sequence()
            end
        end
    end
end)

--///////////////////////////////////////////////////////////////////////////////////--
-- ActionSweep: TRACK ENTRY AND EXIT OF SWEEP ACTIONS TO DETERMINE COMPLETION STATUS --
--///////////////////////////////////////////////////////////////////////////////////--

mod:hook_safe(CLASS.ActionSweep, "_reset_sweep_component", function(self)
    mod.omnissiah.sweep = "before_damage_window"
end)
mod:hook_safe(CLASS.ActionSweep, "_exit_damage_window", function(self, t, num_hit_enemies, aborted)
    mod.omnissiah.sweep = "after_damage_window"
end)

--/////////////////////////////////////////////////////////////////////////////////////////////////--
-- InputService: CHECK MONITORED ACTIONS AND OVERRIDE INPUT DEPENDENT ON THE WILL OF THE OMNISSIAH --
--/////////////////////////////////////////////////////////////////////////////////////////////////--

mod:hook(CLASS.InputService, "_get", function(func, self, action_name)
    -- Initial universal input collection
    local action_rule = self._actions[action_name]
    local out
	if action_rule.filter then
		out = action_rule.eval_func(action_rule.eval_obj, action_rule.eval_param)
	else
		out = action_rule.default_func()
		local action_type = action_rule.type
		local combiner = InputService.ACTION_TYPES[action_type].combine_func
		for _, cb in ipairs(action_rule.callbacks) do
			out = combiner(out, cb())
		end
    end
    -- Mod interception
    if mod:ready() and not Managers.ui:using_input() then
        -- Manual swap detection
        if type(action_name) == "string" and string.find(action_name, "wield") and out then
            MANUAL_SWAP = true
        end
        -- Input handling
        if mod.bind_manager:monitored_action(action_name) then
            mod.bind_manager:set_input_value(action_name, out)
            mod.omnissiah:maybe_reset_last_shot(action_name, out)
            mod.bind_manager:maybe_update_primary_override(action_name, out)
            --mod.bind_manager:update_binds()
            local omnissiahs_will = mod.omnissiah:omnissiah(action_name, out)
            --mod.maybe_force_interrupt(action_name, out)
            if omnissiahs_will == nil then
                return func(self, action_name)
            elseif not mod.weapon_manager:suicidal(action_name, WEENIE_HUT_JR) then
                return omnissiahs_will
            end
        end
    end
    return func(self, action_name)
end)