local mod = get_mod("Skitarius")

local UiSettings = require("scripts/settings/ui/ui_settings")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")

local Localize = Localize
local Localizer = Localizer
local type = type
local pairs = pairs
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_sub = string.sub
local table_sort = table.sort

local function _clone_options(opts)
    local len = #opts
    local clone = Script.new_array(len)

    for i = 1, len do
        local opt = opts[i]
        clone[i] = { text = opt.text, value = opt.value }
    end

    clone.localize = opts.localize

    return clone
end

local function _mark_loc_key_exists(key)
    local manager = Managers and Managers.localization
    local localizers = manager and manager._localizers

    if not manager or not localizers or type(key) ~= "string" or key == "" then
        return false
    end

    for i = 1, #localizers do
        local localizer = localizers[i]
        local loc_str

        if manager._lookup_with_tag ~= nil and manager._enable_string_tags then
            loc_str = manager:_lookup_with_tag(localizer, key)
        else
            loc_str = Localizer.lookup(localizer, key)
        end

        if loc_str then
            return true
        end
    end

    return (manager._backend_localizations and manager._backend_localizations[key] ~= nil) or false
end

local function _try_localize_loc_key(key)
    if type(key) ~= "string" or key == "" then
        return nil
    end

    if string_sub(key, 1, 4) ~= "loc_" then
        return nil
    end

    if string_sub(key, 1, 16) == "loc_weapon_mark_" and not _mark_loc_key_exists(key) then
        return nil
    end

    local value = Localize(key)

    if type(value) ~= "string" or value == "" then
        return nil
    end

    if value == ("<" .. key .. ">") then
        return nil
    end

    if value == ("<unlocalized \"" .. key .. "\": string not found>") then
        return nil
    end

    if string_find(value, "<unlocalized \"", 1, true) == 1 then
        return nil
    end

    return value
end

local HYBRID_MELEE_WEAPONS = {
    ogryn_gauntlet_p1_m1 = true,
}

local function _weapon_kind_flags(template)
    local keywords = template and template.keywords
    local is_melee = false
    local is_ranged = false

    if not keywords then
        return false, false
    end

    for i = 1, #keywords do
        local keyword = keywords[i]

        if keyword == "melee" then
            is_melee = true
        elseif keyword == "ranged" then
            is_ranged = true
        end
    end

    return is_melee, is_ranged
end

local function _build_weapon_display_name(weapon_name, family_loc_key)
    local mark_loc = _try_localize_loc_key("loc_weapon_mark_" .. weapon_name)

    if not mark_loc then
        return nil
    end

    local pattern_loc = _try_localize_loc_key("loc_weapon_pattern_" .. weapon_name)

    if not pattern_loc then
        pattern_loc = _try_localize_loc_key("loc_weapon_pattern_" .. string_gsub(weapon_name, "_m%d+$", "_m1"))
    end

    local family_loc = _try_localize_loc_key(family_loc_key)

    if pattern_loc and family_loc then
        return string_format("%s %s %s", pattern_loc, mark_loc, family_loc)
    elseif pattern_loc then
        return string_format("%s %s", pattern_loc, mark_loc)
    elseif family_loc then
        return string_format("%s %s", mark_loc, family_loc)
    end

    return mark_loc
end

local function _append_weapon_option(options, seen, value, text)
    if not text or seen[value] then
        return
    end

    options[#options + 1] = { text = text, value = value }
    seen[value] = true
end

local function _build_weapon_options(kind)
    local global_value = kind == "MELEE" and "global_melee" or "global_ranged"
    local global_text = kind == "MELEE" and mod:localize("global_melee") or mod:localize("global_ranged")
    local options = Script.new_array(1)
    local seen = {
        [global_value] = true,
    }

    options[1] = { text = global_text, value = global_value }

    for family_name, family_data in pairs(UiSettings.weapon_patterns) do
        if string_sub(family_name, 1, 4) ~= "bot_" then
            local marks = family_data.marks

            if marks and #marks > 0 then
                local family_loc_key = family_data.display_name or ("loc_weapon_family_" .. family_name)

                for i = 1, #marks do
                    local weapon_name = marks[i].name
                    local template = WeaponTemplates[weapon_name]

                    if template then
                        local is_melee, is_ranged = _weapon_kind_flags(template)

                        if kind == "MELEE" then
                            if is_melee or HYBRID_MELEE_WEAPONS[weapon_name] then
                                local text = _build_weapon_display_name(weapon_name, family_loc_key)
                                _append_weapon_option(options, seen, weapon_name, text)
                            end
                        elseif is_ranged then
                            local text = _build_weapon_display_name(weapon_name, family_loc_key)
                            _append_weapon_option(options, seen, weapon_name, text)
                        end
                    end
                end
            end
        end
    end

    if kind == "RANGED" then
        _append_weapon_option(
            options,
            seen,
            "psyker_throwing_knives",
            _try_localize_loc_key("loc_ability_psyker_blitz_throwing_knives") or "Assail"
        )

        _append_weapon_option(
            options,
            seen,
            "psyker_chain_lightning",
            _try_localize_loc_key("loc_ability_psyker_chain_lightning") or "Chain Lightning"
        )
    end

    table_sort(options, function(a, b)
        if a.value == global_value then
            return true
        end

        if b.value == global_value then
            return false
        end

        return a.text < b.text
    end)

    options.localize = false

    return options
end

local melee_weapon_options = _build_weapon_options("MELEE")
local ranged_weapon_options = _build_weapon_options("RANGED")

local keybind_selection_options = {
    { value = "override_primary",      text = "override_primary" },
    { value = "keybind_one_held",      text = "keybind_one_held" },
    { value = "keybind_one_pressed",   text = "keybind_one_pressed" },
    { value = "keybind_two_held",      text = "keybind_two_held" },
    { value = "keybind_two_pressed",   text = "keybind_two_pressed" },
    { value = "keybind_three_held",    text = "keybind_three_held" },
    { value = "keybind_three_pressed", text = "keybind_three_pressed" },
    { value = "keybind_four_held",     text = "keybind_four_held" },
    { value = "keybind_four_pressed",  text = "keybind_four_pressed" },
}
local melee_sequence_options = {
    { text = "none",                value = "none" },
    { text = "light_attack",        value = "light_attack" },
    { text = "heavy_attack",        value = "heavy_attack" },
    { text = "special_action",      value = "special_action" },
    { text = "special_heavy",       value = "special_heavy" },
    { text = "special_invert",      value = "special_invert" },
    { text = "block",               value = "block" },
    { text = "push",                value = "push" },
    { text = "push_attack",         value = "push_attack" },
    { text = "wield",               value = "wield" },
    --{ text = "sprint_heavy_attack", value = "sprint_heavy_attack" },
}

return {
    name         = mod:localize("mod_name"),
    description  = mod:localize("mod_description"),
    is_togglable = true,
    options      = {
        widgets = {
            --[[ Debug ]
			{
				setting_id      = "debug",
				type            = "keybind",
				default_value   = {},
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "debugger",
			},
			--]]
            {
                setting_id  = "mod_settings",
                type        = "group",
                sub_widgets = {
                    {
                        setting_id    = "hud_element",
                        tooltip       = "hud_element_tooltip",
                        type          = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id    = "hud_element_type",
                        tooltip       = "hud_element_type_tooltip",
                        type          = "dropdown",
                        default_value = "color",
                        options       = {
                            { text = "hud_element_type_color",      value = "color" },
                            { text = "hud_element_type_icon",       value = "icon" },
                            { text = "hud_element_type_icon_color", value = "icon_color" },
                        }
                    },
                    {
                        setting_id    = "hud_element_size",
                        type          = "numeric",
                        default_value = 50,
                        range         = { 0, 100 },
                    },
                    {
                        setting_id      = "mod_enable_held",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "held",
                        keybind_type    = "function_call",
                        function_name   = "mod_enable_toggle",
                    },
                    {
                        setting_id      = "mod_enable_pressed",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "pressed",
                        keybind_type    = "function_call",
                        function_name   = "mod_enable_toggle",
                    },
                    {
                        setting_id    = "overload_protection",
                        type          = "checkbox",
                        default_value = false,
                        tooltip       = "overload_protection_tooltip",
                    },
                    {
                        setting_id = "halt_on_interrupt",
                        type = "checkbox",
                        default_value = false,
                        tooltip = "halt_on_interrupt_tooltip",
                    },
                    {
                        setting_id = "halt_on_interrupt_types",
                        type = "dropdown",
                        default_value = "interruption_action_both",
                        tooltip = "halt_on_interrupt_types_tooltip",
                        options = {
                            { text = "interruption_sprint",      value = "interruption_sprint" },
                            { text = "interruption_action_one",  value = "interruption_action_one" },
                            { text = "interruption_action_two",  value = "interruption_action_two" },
                            { text = "interruption_action_both", value = "interruption_action_both" },
                            { text = "interruption_all",         value = "interruption_all" },
                        },
                    }
                }
            },

            {
                setting_id  = "keybinds",
                type        = "group",
                sub_widgets = {
                    {
                        setting_id    = "maintain_bind",
                        type          = "checkbox",
                        default_value = false,
                        tooltip       = "maintain_bind_tooltip",
                    },
                    {
                        setting_id      = "keybind_one_pressed",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "pressed",
                        keybind_type    = "function_call",
                        function_name   = "pressed_one",
                    },
                    {
                        setting_id      = "keybind_one_held",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "held",
                        keybind_type    = "function_call",
                        function_name   = "held_one",
                    },
                    {
                        setting_id      = "keybind_two_pressed",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "pressed",
                        keybind_type    = "function_call",
                        function_name   = "pressed_two",
                    },
                    {
                        setting_id      = "keybind_two_held",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "held",
                        keybind_type    = "function_call",
                        function_name   = "held_two",
                    },
                    {
                        setting_id      = "keybind_three_pressed",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "pressed",
                        keybind_type    = "function_call",
                        function_name   = "pressed_three",
                    },
                    {
                        setting_id      = "keybind_three_held",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "held",
                        keybind_type    = "function_call",
                        function_name   = "held_three",
                    },
                    {
                        setting_id      = "keybind_four_pressed",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "pressed",
                        keybind_type    = "function_call",
                        function_name   = "pressed_four",
                    },
                    {
                        setting_id      = "keybind_four_held",
                        type            = "keybind",
                        default_value   = {},
                        keybind_trigger = "held",
                        keybind_type    = "function_call",
                        function_name   = "held_four",
                    },
                }
            },
            {
                setting_id  = "melee_settings",
                type        = "group",
                sub_widgets = {
                    {
                        setting_id = "interrupt",
                        type = "dropdown",
                        default_value = "none",
                        tooltip = "interrupt_tooltip",
                        options = {
                            { text = "none",  value = "none" },
                            { text = "reset", value = "reset" },
                            { text = "halt",  value = "halt" },
                        }
                    },
                    {
                        setting_id = "current_melee",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "melee_weapon_selection",
                        type = "dropdown",
                        default_value = "global_melee",
                        options = _clone_options(melee_weapon_options),
                    },
                    {
                        setting_id = "keybind_selection_melee",
                        type = "dropdown",
                        default_value = "override_primary",
                        options = table.clone(keybind_selection_options)
                    },
                    {
                        setting_id = "heavy_buff",
                        tooltip = "heavy_buff_tooltip",
                        type = "dropdown",
                        default_value = "none",
                        options = {
                            { text = "none",            value = "none" },
                            { text = "thrust",          value = "thrust" },
                            { text = "slow_and_steady", value = "slow_and_steady" },
                            { text = "crunch",          value = "crunch" },
                            { text = "mechsword",       value = "mechsword" },
                        }
                    },
                    {
                        setting_id = "heavy_buff_stacks",
                        type = "numeric",
                        default_value = 0,
                        range = { 0, 4 },
                        unit_text = "buff_stacks",
                        tooltip = "heavy_buff_stacks_tooltip",
                    },
                    {
                        setting_id = "heavy_buff_special",
                        tooltip = "heavy_buff_special_tooltip",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "special_buff_stacks",
                        type = "numeric",
                        default_value = 0,
                        range = { 0, 8 },
                        unit_text = "buff_stacks",
                    },
                    {
                        setting_id = "always_special",
                        tooltip = "always_special_tooltip",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "force_heavy_when_special",
                        type = "checkbox",
                        default_value = false,
                        tooltip = "force_heavy_when_special_tooltip",
                    },
                    {
                        setting_id = "hold_heavy_when_sprinting",
                        type = "checkbox",
                        default_value = false,
                        tooltip = "hold_heavy_when_sprinting_tooltip",
                    },
                    {
                        setting_id = "sequence_cycle_point",
                        tooltip = "sequence_cycle_point_tooltip",
                        type = "dropdown",
                        default_value = "sequence_step_one",
                        options = {
                            { text = "no_repeat",            value = "no_repeat" },
                            { text = "sequence_step_one",    value = "sequence_step_one" },
                            { text = "sequence_step_two",    value = "sequence_step_two" },
                            { text = "sequence_step_three",  value = "sequence_step_three" },
                            { text = "sequence_step_four",   value = "sequence_step_four" },
                            { text = "sequence_step_five",   value = "sequence_step_five" },
                            { text = "sequence_step_six",    value = "sequence_step_six" },
                            { text = "sequence_step_seven",  value = "sequence_step_seven" },
                            { text = "sequence_step_eight",  value = "sequence_step_eight" },
                            { text = "sequence_step_nine",   value = "sequence_step_nine" },
                            { text = "sequence_step_ten",    value = "sequence_step_ten" },
                            { text = "sequence_step_eleven", value = "sequence_step_eleven" },
                            { text = "sequence_step_twelve", value = "sequence_step_twelve" },
                        }
                    },
                    {
                        setting_id = "sequence_step_one",
                        text = "sequence_step_one",
                        title = "sequence_step_one",
                        type = "dropdown",
                        default_value = "none",
                        options = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id = "sequence_step_two",
                        text = "sequence_step_two",
                        title = "sequence_step_two",
                        type = "dropdown",
                        default_value = "none",
                        options = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id = "sequence_step_three",
                        text = "sequence_step_three",
                        title = "sequence_step_three",
                        type = "dropdown",
                        default_value = "none",
                        options = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_four",
                        text          = "sequence_step_four",
                        title         = "sequence_step_four",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_five",
                        text          = "sequence_step_five",
                        title         = "sequence_step_five",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_six",
                        text          = "sequence_step_six",
                        title         = "sequence_step_six",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_seven",
                        text          = "sequence_step_seven",
                        title         = "sequence_step_seven",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_eight",
                        text          = "sequence_step_eight",
                        title         = "sequence_step_eight",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_nine",
                        text          = "sequence_step_nine",
                        title         = "sequence_step_nine",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_ten",
                        text          = "sequence_step_ten",
                        title         = "sequence_step_ten",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_eleven",
                        text          = "sequence_step_eleven",
                        title         = "sequence_step_eleven",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id    = "sequence_step_twelve",
                        text          = "sequence_step_twelve",
                        title         = "sequence_step_twelve",
                        type          = "dropdown",
                        default_value = "none",
                        options       = table.clone(melee_sequence_options)
                    },
                    {
                        setting_id = "reset_weapon_melee",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "reset_all_melee",
                        type = "checkbox",
                        default_value = false,
                    }
                }
            },
            {
                setting_id  = "ranged_settings",
                type        = "group",
                sub_widgets = {
                    {
                        setting_id = "always_charge",
                        type = "checkbox",
                        default_value = false,
                        tooltip = "always_charge_tooltip",
                    },
                    {
                        setting_id = "always_charge_threshold",
                        type = "numeric",
                        default_value = 100,
                        range = { 0, 100 },
                        tooltip = "always_charge_threshold_tooltip",
                    },
                    {
                        setting_id = "current_ranged",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "ranged_weapon_selection",
                        type = "dropdown",
                        default_value = "global_ranged",
                        options = _clone_options(ranged_weapon_options),
                    },
                    {
                        setting_id = "keybind_selection_ranged",
                        type = "dropdown",
                        default_value = "override_primary",
                        options = table.clone(keybind_selection_options)
                    },
                    {
                        setting_id = "automatic_fire",
                        type = "dropdown",
                        default_value = "none",
                        options = {
                            { text = "none",             value = "none" },
                            { text = "standard",         value = "standard" },
                            { text = "charged",          value = "charged" },
                            { text = "special",          value = "special" },
                            { text = "special_charged",  value = "special_charged" },
                            { text = "special_standard", value = "special_standard" },
                        }
                    },
                    {
                        setting_id = "auto_charge_threshold",
                        type = "numeric",
                        default_value = 100,
                        range = { 0, 100 },
                        unit_text = "threshold",
                    },
                    {
                        setting_id = "ads_filter",
                        type = "dropdown",
                        default_value = "ads_hip",
                        options = {
                            { text = "ads_hip",  value = "ads_hip" },
                            { text = "ads_only", value = "ads_only" },
                            { text = "hip_only", value = "hip_only" },
                        }
                    },
                    {
                        setting_id = "rate_of_fire_ads",
                        type = "numeric",
                        default_value = 0,
                        range = { 0, 800 },
                        unit_text = "rate_of_fire",
                        decimals_number = 0
                    },
                    {
                        setting_id = "rate_of_fire_hip",
                        type = "numeric",
                        default_value = 0,
                        range = { 0, 800 },
                        unit_text = "rate_of_fire",
                        decimals_number = 0
                    },
                    {
                        setting_id = "reset_weapon_ranged",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "reset_all_ranged",
                        type = "checkbox",
                        default_value = false,
                    }
                }
            }
        }
    }
}
