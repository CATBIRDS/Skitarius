local mod = get_mod("Skitarius")

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
    { text = "none",           value = "none" },
    { text = "light_attack",   value = "light_attack" },
    { text = "heavy_attack",   value = "heavy_attack" },
    { text = "special_action", value = "special_action" },
    { text = "block",          value = "block" },
    { text = "push",           value = "push" },
    { text = "push_attack",    value = "push_attack" },
	{ text = "wield",          value = "wield" },
}

return {
	name         = mod:localize("mod_name"),
	description  = mod:localize("mod_description"),
	is_togglable = true,
	options = {
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
				setting_id = "mod_settings",
				type       = "group",
				sub_widgets = {
					{
						setting_id      = "hud_element",
						tooltip         = "hud_element_tooltip",
						type            = "checkbox",
						default_value   = false,
					},
					{
						setting_id    = "hud_element_type",
						tooltip       = "hud_element_type_tooltip",
						type          = "dropdown",
						default_value = "color",
						options = {
							{text = "hud_element_type_color", value = "color"},
							{text = "hud_element_type_icon",  value = "icon"},
							{text = "hud_element_type_icon_color",  value = "icon_color"},
						}
					},
					{
						setting_id 	  = "hud_element_size",
						type          = "numeric",
						default_value = 50,
						range         = {0, 100},
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
						setting_id      = "overload_protection",
						type            = "checkbox",
						default_value   = false,
						tooltip         = "overload_protection_tooltip",
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
							{text = "interruption_sprint",  value = "interruption_sprint"},
							{text = "interruption_action_one", value = "interruption_action_one"},
							{text = "interruption_action_two", value = "interruption_action_two"},
							{text = "interruption_action_both", value = "interruption_action_both"},
							{text = "interruption_all",   value = "interruption_all"},
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
				setting_id = "melee_settings",
				type       = "group",
				sub_widgets = {
					{
						setting_id = "interrupt",
						type = "dropdown",
						default_value = "none",
						tooltip = "interrupt_tooltip",
						options = {
							{text = "none", value = "none"},
							{text = "reset", value = "reset"},
							{text = "halt", value = "halt"},
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
						options = {
							--[[]]
							-- Global
							{text = "global_melee", value = "global_melee"},
							-- Chainaxe
							{text = "chainaxe_p1_m1", value = "chainaxe_p1_m1"},
							{text = "chainaxe_p1_m2", value = "chainaxe_p1_m2"},
							-- Chainsword
							{text = "chainsword_p1_m1", value = "chainsword_p1_m1"},
							{text = "chainsword_p1_m2", value = "chainsword_p1_m2"},
							-- Eviscerator
							{text = "chainsword_2h_p1_m1", value = "chainsword_2h_p1_m1"},
							{text = "chainsword_2h_p1_m2", value = "chainsword_2h_p1_m2"},
							-- Combat Axe
							{text = "combataxe_p1_m1", value = "combataxe_p1_m1"},
							{text = "combataxe_p1_m2", value = "combataxe_p1_m2"},
							{text = "combataxe_p1_m3", value = "combataxe_p1_m3"},
							-- Tactical Axe
							{text = "combataxe_p2_m1", value = "combataxe_p2_m1"},
							{text = "combataxe_p2_m2", value = "combataxe_p2_m2"},
							{text = "combataxe_p2_m3", value = "combataxe_p2_m3"},
							-- Sapper Shovel
							{text = "combataxe_p3_m1", value = "combataxe_p3_m1"},
							{text = "combataxe_p3_m2", value = "combataxe_p3_m2"},
							{text = "combataxe_p3_m3", value = "combataxe_p3_m3"},
							-- Cleaver
							{text = "ogryn_combatblade_p1_m1", value = "ogryn_combatblade_p1_m1"},
							{text = "ogryn_combatblade_p1_m2", value = "ogryn_combatblade_p1_m2"},
							{text = "ogryn_combatblade_p1_m3", value = "ogryn_combatblade_p1_m3"},
							-- Combat Knife
							{text = "combatknife_p1_m1", value = "combatknife_p1_m1"},
							{text = "combatknife_p1_m2", value = "combatknife_p1_m2"},
							-- Devil's Claw
							{text = "combatsword_p1_m1", value = "combatsword_p1_m1"},
							{text = "combatsword_p1_m2", value = "combatsword_p1_m2"},
							{text = "combatsword_p1_m3", value = "combatsword_p1_m3"},
							-- Heavy Sword
							{text = "combatsword_p2_m1", value = "combatsword_p2_m1"},
							{text = "combatsword_p2_m2", value = "combatsword_p2_m2"},
							{text = "combatsword_p2_m3", value = "combatsword_p2_m3"},
							-- Duelling Sword
							{text = "combatsword_p3_m1", value = "combatsword_p3_m1"},
							{text = "combatsword_p3_m2", value = "combatsword_p3_m2"},
							{text = "combatsword_p3_m3", value = "combatsword_p3_m3"},
							-- Force Sword
							{text = "forcesword_p1_m1", value = "forcesword_p1_m1"},
							{text = "forcesword_p1_m2", value = "forcesword_p1_m2"},
							{text = "forcesword_p1_m3", value = "forcesword_p1_m3"},
							-- Force Greatsword
							{text = "forcesword_2h_p1_m1", value = "forcesword_2h_p1_m1"},
							{text = "forcesword_2h_p1_m2", value = "forcesword_2h_p1_m2"},
							-- Grenadier Gauntlet
							{text = "ogryn_gauntlet_p1_m1", value = "ogryn_gauntlet_p1_m1"},
							-- Latrine Shovel
							{text = "ogryn_club_p1_m1", value = "ogryn_club_p1_m1"},
							{text = "ogryn_club_p1_m2", value = "ogryn_club_p1_m2"},
							{text = "ogryn_club_p1_m3", value = "ogryn_club_p1_m3"},
							-- Bully Club
							{text = "ogryn_club_p2_m1", value = "ogryn_club_p2_m1"},
							{text = "ogryn_club_p2_m2", value = "ogryn_club_p2_m2"},
							{text = "ogryn_club_p2_m3", value = "ogryn_club_p2_m3"},
							-- Pickaxe
							{text = "ogryn_pickaxe_2h_p1_m1", value = "ogryn_pickaxe_2h_p1_m1"},
							{text = "ogryn_pickaxe_2h_p1_m2", value = "ogryn_pickaxe_2h_p1_m2"},
							{text = "ogryn_pickaxe_2h_p1_m3", value = "ogryn_pickaxe_2h_p1_m3"},
							-- Power Maul
							{text = "ogryn_powermaul_p1_m1", value = "ogryn_powermaul_p1_m1"},
							--[[] THESE WEAPONS AREN'T ACCESSIBLE IN-GAME YET
							{text = "ogryn_powermaul_p1_m2", value = "ogryn_powermaul_p1_m2"},
							{text = "ogryn_powermaul_p1_m3", value = "ogryn_powermaul_p1_m3"},
							--]]
							-- Slab Shield
							{text = "ogryn_powermaul_slabshield_p1_m1", value = "ogryn_powermaul_slabshield_p1_m1"},
							-- Shock Maul
							{text = "powermaul_p1_m1", value = "powermaul_p1_m1"},
							{text = "powermaul_p1_m2", value = "powermaul_p1_m2"},
							-- Suppression shields
							{text = "powermaul_shield_p1_m1", value = "powermaul_shield_p1_m1"},
							{text = "powermaul_shield_p1_m2", value = "powermaul_shield_p1_m2"},
							-- Arbites Maul
							{text = "powermaul_p2_m1", value = "powermaul_p2_m1"},
							-- Crusher
							{text = "powermaul_2h_p1_m1", value = "powermaul_2h_p1_m1"},
							-- Power Sword
							{text = "powersword_p1_m1", value = "powersword_p1_m1"},
							{text = "powersword_p1_m2", value = "powersword_p1_m2"},
							-- Power Falchion
                            { text = "powersword_p2_m1",                 value = "powersword_p2_m1" },
                            { text = "powersword_p2_m2",                 value = "powersword_p2_m2" },
							-- Relic Sword
							{text = "powersword_2h_p1_m1", value = "powersword_2h_p1_m1"},
							{text = "powersword_2h_p1_m2", value = "powersword_2h_p1_m2"},
							-- Thunder Hammer
							{text = "thunderhammer_2h_p1_m1", value = "thunderhammer_2h_p1_m1"},
							{text = "thunderhammer_2h_p1_m2", value = "thunderhammer_2h_p1_m2"},
							--]]
						}
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
							{text = "none", value = "none"},
							{text = "thrust", value = "thrust"},
							{text = "slow_and_steady", value = "slow_and_steady"},
							--{text = "crunch", value = "crunch"},
						}
					},
					{
						setting_id = "heavy_buff_stacks",
						type = "numeric",
						default_value = 0,
						range = {0, 3},
						unit_text = "buff_stacks",
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
						range = {0, 3},
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
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_two",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_three",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_four",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_five",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_six",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_seven",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_eight",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_nine",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_ten",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_eleven",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
					},
					{
						setting_id = "sequence_step_twelve",
						type = "dropdown",
						default_value = "none",
						options = table.clone(melee_sequence_options)
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
				setting_id = "ranged_settings",
				type = "group",
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
						range = {0, 100},
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
						options = {
							-- Global
							{text = "global_ranged", value = "global_ranged"},
							-- Stub Revolver
							{text = "stubrevolver_p1_m1", value = "stubrevolver_p1_m1"},
							{text = "stubrevolver_p1_m2", value = "stubrevolver_p1_m2"},
							-- Combat Shotgun
							{text = "shotgun_p1_m1", value = "shotgun_p1_m1"},
							{text = "shotgun_p1_m2", value = "shotgun_p1_m2"},
							{text = "shotgun_p1_m3", value = "shotgun_p1_m3"},
							-- Double Barrel Shotgun
							{text = "shotgun_p2_m1", value = "shotgun_p2_m1"},
							-- Executor Shotgun
							{text = "shotgun_p4_m1", value = "shotgun_p4_m1"},
							{text = "shotgun_p4_m2", value = "shotgun_p4_m2"},
							-- Shotpistol
							{text = "shotpistol_shield_p1_m1", value = "shotpistol_shield_p1_m1"},
							-- Plasma Gun
							{text = "plasmagun_p1_m1", value = "plasmagun_p1_m1"},
							-- Ogryn Thumper
							{text = "ogryn_thumper_p1_m1", value = "ogryn_thumper_p1_m1"},
							{text = "ogryn_thumper_p1_m2", value = "ogryn_thumper_p1_m2"},
							-- Ogryn Rippergun
							{text = "ogryn_rippergun_p1_m1", value = "ogryn_rippergun_p1_m1"},
							{text = "ogryn_rippergun_p1_m2", value = "ogryn_rippergun_p1_m2"},
							{text = "ogryn_rippergun_p1_m3", value = "ogryn_rippergun_p1_m3"},
							-- Ogryn Heavystubber
							{text = "ogryn_heavystubber_p1_m1", value = "ogryn_heavystubber_p1_m1"},
							{text = "ogryn_heavystubber_p1_m2", value = "ogryn_heavystubber_p1_m2"},
							{text = "ogryn_heavystubber_p1_m3", value = "ogryn_heavystubber_p1_m3"},
							-- Ogryn Heavystubber p2
							{text = "ogryn_heavystubber_p2_m1", value = "ogryn_heavystubber_p2_m1"},
							{text = "ogryn_heavystubber_p2_m2", value = "ogryn_heavystubber_p2_m2"},
							{text = "ogryn_heavystubber_p2_m3", value = "ogryn_heavystubber_p2_m3"},
							-- Ogryn Gauntlet
							{text = "ogryn_gauntlet_p1_m1", value = "ogryn_gauntlet_p1_m1"},
							-- Laspistol
							{text = "laspistol_p1_m1", value = "laspistol_p1_m1"},
							--{text = "laspistol_p1_m2", value = "laspistol_p1_m2"},
							{text = "laspistol_p1_m3", value = "laspistol_p1_m3"},
							-- Lasgun
							{text = "lasgun_p1_m1", value = "lasgun_p1_m1"},
							{text = "lasgun_p1_m2", value = "lasgun_p1_m2"},
							{text = "lasgun_p1_m3", value = "lasgun_p1_m3"},
							-- Lasgun p2
							{text = "lasgun_p2_m1", value = "lasgun_p2_m1"},
							{text = "lasgun_p2_m2", value = "lasgun_p2_m2"},
							{text = "lasgun_p2_m3", value = "lasgun_p2_m3"},
							-- Lasgun p3
							{text = "lasgun_p3_m1", value = "lasgun_p3_m1"},
							{text = "lasgun_p3_m2", value = "lasgun_p3_m2"},
							{text = "lasgun_p3_m3", value = "lasgun_p3_m3"},
							-- Forcestaff
							{text = "forcestaff_p1_m1", value = "forcestaff_p1_m1"},
							-- Forcestaff p2
							{text = "forcestaff_p2_m1", value = "forcestaff_p2_m1"},
							-- Forcestaff p3
							{text = "forcestaff_p3_m1", value = "forcestaff_p3_m1"},
							-- Forcestaff p4
							{text = "forcestaff_p4_m1", value = "forcestaff_p4_m1"},
							-- Flamer
							{text = "flamer_p1_m1", value = "flamer_p1_m1"},
							-- Bolter
							{text = "bolter_p1_m1", value = "bolter_p1_m1"},
							-- Boltpistol
							{text = "boltpistol_p1_m1", value = "boltpistol_p1_m1"},
							{text = "boltpistol_p1_m2", value = "boltpistol_p1_m2"},
							-- Autopistol
							{text = "autopistol_p1_m1", value = "autopistol_p1_m1"},
							-- Autogun
							{text = "autogun_p1_m1", value = "autogun_p1_m1"},
							{text = "autogun_p1_m2", value = "autogun_p1_m2"},
							{text = "autogun_p1_m3", value = "autogun_p1_m3"},
							-- Autogun p2
							{text = "autogun_p2_m1", value = "autogun_p2_m1"},
							{text = "autogun_p2_m2", value = "autogun_p2_m2"},
							{text = "autogun_p2_m3", value = "autogun_p2_m3"},
							-- Autogun p3
							{text = "autogun_p3_m1", value = "autogun_p3_m1"},
							{text = "autogun_p3_m2", value = "autogun_p3_m2"},
							{text = "autogun_p3_m3", value = "autogun_p3_m3"},
							-- Assail
							{text = "psyker_throwing_knives", value = "psyker_throwing_knives"},
							-- Smite
							{text = "psyker_chain_lightning", value = "psyker_chain_lightning"},
						},
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
							{text = "none", value = "none"},
							{text = "standard", value = "standard"},
							{text = "charged", value = "charged"},
							{text = "special", value = "special"},
							{text = "special_charged", value = "special_charged"},
							{text = "special_standard", value = "special_standard"},
						}
					},
					{
						setting_id = "auto_charge_threshold",
						type = "numeric",
						default_value = 100,
						range = {0, 100},
						unit_text = "threshold",
					},
					{
						setting_id = "ads_filter",
						type = "dropdown",
						default_value = "ads_hip",
						options = {
							{text = "ads_hip", value = "ads_hip"},
							{text = "ads_only", value = "ads_only"},
							{text = "hip_only", value = "hip_only"},
						}
					},
					{
						setting_id = "rate_of_fire_ads",
						type = "numeric",
						default_value = 0,
						range = {0, 4000},
						unit_text = "rate_of_fire",
						decimals_number = 0
					},
					{
						setting_id = "rate_of_fire_hip",
						type = "numeric",
						default_value = 0,
						range = {0, 4000},
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