local SkitariusWeaponManager = class("SkitariusWeaponManager")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")

local TRAIT_MAP = {
    thrust="windup_increases_power_child",
    slow_and_steady="toughness_on_hit_based_on_charge_time_visual_stack_count",
    crunch="ogryn_windup_increases_power_parent"
}
local MAX_MAP = {
    thrust=3,
    slow_and_steady=3,
    crunch=4
}

SkitariusWeaponManager.init = function(self, mod)
    self.mod = mod
    self.armoury = mod.armoury
    self.engram = mod.engram
    self.name = "none"
    self.type = "none"
    self.warp = 0
    self.aiming = false
    self.charging = false
    self.pushing = false
    self.firing = false
end

SkitariusWeaponManager.set_bind_manager = function(self, binds)
    self.binds = binds
end

--  ╦ ╦╔═╗╔═╗╔═╗╔═╗╔╗╔  ╔╦╗╔═╗╔╦╗╔═╗
--  ║║║║╣ ╠═╣╠═╝║ ║║║║   ║║╠═╣ ║ ╠═╣
--  ╚╩╝╚═╝╩ ╩╩  ╚═╝╝╚╝  ═╩╝╩ ╩ ╩ ╩ ╩

SkitariusWeaponManager.refresh_weapon = function(self)
    -- Method 1: Visual loadout - most reliable under ideal circumstances, but seems to be confused during desyncs
    local player_manager = Managers and Managers.player
    if player_manager then
        local player = player_manager:local_player_safe(1)
        local player_unit = player and player.player_unit
        local visual_loadout = player_unit and ScriptUnit.has_extension(player_unit, "visual_loadout_system")
        wielded_slot = visual_loadout and visual_loadout._inventory_component and visual_loadout._inventory_component.wielded_slot
        if wielded_slot and wielded_slot == "slot_primary" then
            weapon_name = visual_loadout._inventory_component.__data[1].slot_primary
            weapon_name = weapon_name and weapon_name:match("([^/]+)$")
            if weapon_name then
                self.name = weapon_name
            end
            wielded_slot = "MELEE"
        elseif wielded_slot and (wielded_slot == "slot_secondary" or wielded_slot == "slot_grenade_ability") then
            weapon_name = visual_loadout._inventory_component.__data[1][wielded_slot]
            weapon_name = weapon_name and weapon_name:match("([^/]+)$")
            psyker_nades  = {psyker_throwing_knives = true, psyker_chain_lightning = true}
            if weapon_name and wielded_slot == "slot_secondary" or (wielded_slot == "slot_grenade_ability" and weapon_name and psyker_nades[weapon_name]) then
                self.name = weapon_name
            end
            if wielded_slot == "slot_secondary" or (wielded_slot == "slot_grenade_ability" and weapon_name and psyker_nades[weapon_name]) then
                wielded_slot = "RANGED"
            end
        -- Method 2: Inventory system as failsafe
        elseif not wielded_slot then
            local manager = Managers.player
            if manager and manager:local_player_safe(1) then
                local unit = manager:local_player(1).player_unit
                if unit and ScriptUnit.has_extension(unit, "weapon_system") then
                    local weapon = ScriptUnit.extension(unit, "weapon_system")
                    local inventory = weapon._inventory_component
                    local wielded_weapon = weapon:_wielded_weapon(inventory, weapon._weapons)
                    if wielded_weapon then
                        local weapon_template = wielded_weapon and wielded_weapon.weapon_template
                        local keywords = weapon_template.keywords
                        if keywords then
                            if table.array_contains(keywords, "melee") then
                                wielded_slot = "MELEE"
                            elseif table.array_contains(keywords, "ranged") then
                                wielded_slot = "RANGED"
                            end
                        end
                    end
                end
            end  
        end
    end
    self.type = wielded_slot
end

SkitariusWeaponManager.weapon_name = function(self)
    if not self.name or self.name == "none" then
        self:refresh_weapon()
    end
    return self.name
end

SkitariusWeaponManager.weapon_type = function(self)
    if not self.type or self.type == "none" then
        self:refresh_weapon()
    end
    if self.type == "MELEE" or (self.name == "ogryn_gauntlet_p1_m1" and not self:is_aiming()) then
        return "MELEE"
    elseif self.type == "RANGED" or (self.name == "psyker_throwing_knives") then
        return "RANGED"
    end
    return "none"
end

SkitariusWeaponManager.get_equipped = function(self, target)
    local player = Managers.player:local_player(1)
    local player_unit = player and player.player_unit
    local weapon_extension = player_unit and ScriptUnit.has_extension(player_unit, "weapon_system")
    local weapons = weapon_extension and weapon_extension._weapons
    if weapons then
        if target == "MELEE" then
            local weapon = weapons.slot_primary
            local weapon_template = weapon and weapon.weapon_template
            local name = weapon_template and weapon_template.name
            return name
        elseif target == "RANGED" then
            if self.type == "RANGED" then return self.name end
            local weapon = weapons.slot_secondary
            local weapon_template = weapon and weapon.weapon_template
            local name = weapon_template and weapon_template.name
            return name
        end
    end
    return nil
end

SkitariusWeaponManager.current_equipped = function(self)
    if not self.type or self.type == "none" then
        self:refresh_weapon()
    end
    if self.type == "MELEE" then
        return self:get_equipped("MELEE")
    elseif self.type == "RANGED" then
        return self:get_equipped("RANGED")
    end
    return "none"
end

SkitariusWeaponManager.can_reload = function(self)
    local weapon_type = self:weapon_type()
    local weapon_name = self:weapon_name()
    local warp = self.warp or 0
    local armoury = self.armoury
    if weapon_type == "RANGED" then
        if armoury.force_staff[weapon_name] then
            return warp > 0 and true or false
        elseif self:ranged_reload_available() then
            return true
        end
        return true
    elseif armoury.quelling[weapon_name] and warp > 0 then
        return true
    end
    return false
end

-- Returns true if the player's ranged weapon is missing clip ammo and has reserve ammo to reload with - this does not check if the weapon is currently available to be reloaded
SkitariusWeaponManager.ranged_reload_available = function(self)
    local player = Managers.player:local_player_safe(1)
    local player_unit = player and player.player_unit
    local unit_data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")
    local inventory_component = unit_data_extension and unit_data_extension:read_component("slot_secondary")
    if inventory_component then
        local clip_max = inventory_component.max_ammunition_clip or 0
        local clip_ammo = inventory_component.current_ammunition_clip or 0
        local reserve_ammo = inventory_component.current_ammunition_reserve or 0
        if clip_ammo < clip_max and reserve_ammo > 0 then
            return true
        end
    end
end

--  ╦ ╦╔═╗╔═╗╔═╗╔═╗╔╗╔  ╔═╗╔╦╗╔═╗╔╦╗╦ ╦╔═╗
--  ║║║║╣ ╠═╣╠═╝║ ║║║║  ╚═╗ ║ ╠═╣ ║ ║ ║╚═╗
--  ╚╩╝╚═╝╩ ╩╩  ╚═╝╝╚╝  ╚═╝ ╩ ╩ ╩ ╩ ╚═╝╚═╝

SkitariusWeaponManager.is_charged_melee = function(self, running_action, component, action_settings)
    if not running_action or not component or not action_settings then return false end
    local armoury = self.armoury
    local engram = self.engram
    local weapon_name = self:weapon_name()
    local t = Managers.time:time("gameplay")
	local allowed_chain_actions = action_settings.allowed_chain_actions or {}
    local chain_action = allowed_chain_actions.heavy_attack or allowed_chain_actions.special_action_heavy
    local chain_action_name = chain_action and chain_action.action_name
    if chain_action then
        local start_t = component.start_t
        local current_action_t = t - start_t
        local running_action_state = running_action:running_action_state(t, current_action_t)
        local chain_time = chain_action.chain_time
        chain_time = armoury:validate_chain_time(chain_time, chain_action_name, weapon_name)
        --self.mod:echo("%s, %s", chain_time, chain_action_name) -- DEBUG: View chain time and internal action name
        chain_validated = (chain_time and chain_time < current_action_t or not not chain_until and current_action_t < chain_until) and true
        local running_action_state_requirement = chain_action.running_action_state_requirement
        if running_action_state_requirement and (not running_action_state or not running_action_state_requirement[running_action_state]) then
            chain_validated = false
        end
        local insufficient_stacks = false
        local required_buff = engram:heavy_buff()
        local required_buff_stacks = engram:heavy_buff_stacks()
        local required_buff_special = engram:heavy_buff_special()
        local required_buff_special_stacks = engram:heavy_buff_special_stacks()
        local is_special = component.special_active_at_start
        if is_special then
            -- If the action is special and special stacks are set, use them instead of the heavy stacks
            required_buff_stacks = required_buff_special_stacks
        end
        -- Heavy attack buff handling
        if required_buff and required_buff ~= "none" then
            if not required_buff_special or (required_buff_special and is_special) then
                -- Check that the weapon has the required buff before doing anything
                local search_string = TRAIT_MAP[required_buff]
                -- Thrust string must be unique per-weapon or it will match with crunch
                if required_buff == "thrust" then
                    search_string = string.sub(weapon_name, 1, -3) .. search_string
                end
                if self:has_trait_or_talent(search_string) then
                    -- Compare current stacks to the required stacks
                    local current_stacks = self:fetch_stacks(search_string)
                    -- Handle thrust being offset by 1 internally
                    if required_buff == "thrust" then
                        current_stacks = current_stacks - 1
                        if current_stacks < 0 then
                            current_stacks = 0
                        end
                    end
                    if current_stacks and not (current_stacks >= required_buff_stacks or current_stacks >= MAX_MAP[required_buff]) then
                        insufficient_stacks = true
                    end
                end
            end
        end
        
        local action_is_validated = chain_validated and not insufficient_stacks
        return action_is_validated
    end
    return false
end

SkitariusWeaponManager.is_charged_ranged = function(self, weenie_hut_jr)
    if not self:weapon_type() == "RANGED" then return false end
    local engram = self.engram
    local player = Managers.player:local_player_safe(1)
    local player_unit = player and player.player_unit
    local weapon_extension = player_unit and ScriptUnit.has_extension(player_unit, "weapon_system")
    local unit_data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")
    local fully_charged = false
    if weapon_extension and unit_data_extension then
        local charge_module = weapon_extension._action_module_charge_component
        -- Determine charge status
        local max_charge = charge_module and charge_module.max_charge or 1
        local charge_level = charge_module and charge_module.charge_level or 0
        local engram_threshold = engram:charge_threshold() or 100
        local fully_charged_charge_level = (engram_threshold) / 100
        local always_charge = self.mod.settings.always_charge -- only fetch as necessary
        if always_charge then
            local always_charge_threshold = self.mod.settings.always_charge_threshold
            local charge_threshold = engram_threshold and (math.min(engram_threshold, always_charge_threshold)) or always_charge_threshold
            fully_charged_charge_level = charge_threshold / 100
        end
        local fully_charged_charge_threshold = math.min(fully_charged_charge_level, max_charge)
        
        local generates_peril = self:generates_peril_wrapper()
        -- Fully charged if reached max threshold/level
        if (charge_level and charge_level ~= 0 and ((charge_level >= fully_charged_charge_threshold))) then
            fully_charged = true
        -- Otherwise fully charged if holding it further would be lethal
        elseif weenie_hut_jr and generates_peril and (self.warp >= 0.940 and self.warp < 0.950) then
            fully_charged = true
        end
    end
    return fully_charged
end

SkitariusWeaponManager.is_light_complete = function(self, running_action, component, action_settings)
    if not running_action or not component or not action_settings then return false end
    local t = Managers.time:time("gameplay")
	local allowed_chain_actions = action_settings.allowed_chain_actions or {}
    local chain_action = allowed_chain_actions.start_attack
    if chain_action then
        local start_t = component.start_t
        local current_action_t = t - start_t
        local chain_time = chain_action.chain_time
        chain_validated = (chain_time and chain_time < current_action_t or not not chain_until and current_action_t < chain_until) and true
        return chain_validated
    end
    return false
end

SkitariusWeaponManager.current_charge = function(self)
    local player = Managers.player:local_player_safe(1)
    local player_unit = player and player.player_unit
    local weapon_extension = player_unit and ScriptUnit.has_extension(player_unit, "weapon_system")
    local unit_data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")
    local charge = 0
    if weapon_extension and unit_data_extension then
        local charge_module = weapon_extension._action_module_charge_component
        if charge_module then
            charge = charge_module.charge_level or 0
        end
    end
    return charge
end

SkitariusWeaponManager.is_blocking = function(self)
    local player = Managers.player:local_player_safe(1)
    local player_unit = player and player.player_unit
    local unit_data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")
    local block_component = unit_data_extension and unit_data_extension:read_component("block")
    if block_component then
        return block_component.is_blocking
    end
    return false
end

SkitariusWeaponManager.in_cooldown = function(self)
    local player_manager = Managers and Managers.player
    local player = player_manager:local_player_safe(1)
    local player_unit = player and player.player_unit
    local weapon = player_unit and ScriptUnit.extension(player_unit, "weapon_system")
    if weapon then
        local inventory = weapon._inventory_component
        if inventory then
            local wielded_slot = inventory.wielded_slot
            if not wielded_slot or (wielded_slot ~= "slot_primary" and wielded_slot ~= "slot_secondary") then
                return false
            end
            local wielded_weapon = weapon and weapon:_wielded_weapon(inventory, weapon._weapons)
            local inventory_slot_component = wielded_weapon and wielded_weapon.inventory_slot_component
            local overheat_state = inventory_slot_component and inventory_slot_component.overheat_state
            local special_charges = inventory_slot_component and inventory_slot_component.num_special_charges
            local special_class = wielded_weapon and wielded_weapon.weapon_template and wielded_weapon.weapon_template.weapon_special_class
            -- Riot Shields and Ogryn Power Maul
            if special_charges then
                local weapon_template = wielded_weapon and wielded_weapon.weapon_template
                local tweaker = weapon_template and weapon_template.weapon_special_tweak_data
                if tweaker then
                    local thresholds = tweaker.thresholds
                    -- Riot Shields (flexible charge consumption based on thresholds)
                    if thresholds then
                        local above_threshold = false
                        for threshold_index = #thresholds, 2, -1 do
                            local threshold = thresholds[threshold_index].threshold
                            if threshold <= special_charges then
                                above_threshold = true
                                break
                            end
                        end
                        return not above_threshold
                    elseif special_class and special_class == "WeaponSpecialExplodeOnImpactCooldown" then
                        -- Ogryn Power Maul (single charge consumption)
                        return special_charges == 0
                    end
                end
            end
            -- Relic Blades
            if overheat_state and overheat_state ~= "idle" then
                return true
            end
        end
    end
    return false
end

SkitariusWeaponManager.special_active = function(self)
    local player_manager = Managers and Managers.player
    local player = player_manager:local_player_safe(1)
    local player_unit = player and player.player_unit
    local weapon = player_unit and ScriptUnit.extension(player_unit, "weapon_system")
    if weapon then
        local inventory = weapon._inventory_component
        if inventory then
            local wielded_slot = inventory.wielded_slot
            if not wielded_slot or (wielded_slot ~= "slot_primary" and wielded_slot ~= "slot_secondary") then
                return false
            end
            local weapons = weapon._weapons
            local wielded_weapon = weapons and weapons[wielded_slot]
            local inventory_slot_component = wielded_weapon and wielded_weapon.inventory_slot_component
            local is_special = inventory_slot_component and inventory_slot_component.special_active
            if is_special then
                return true
            end
        end
    end
    return false
end

SkitariusWeaponManager.is_sprinting = function(self)
    local player = Managers.player:local_player_safe(1)
    local player_unit = player and player.player_unit
    local unit_data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")
    local sprint_component = unit_data_extension and unit_data_extension:read_component("sprint_character_state")
    if sprint_component then
        return sprint_component.is_sprinting
    end
    return false
end

SkitariusWeaponManager.set_aiming = function(self, aiming)
    self.aiming = aiming
end

SkitariusWeaponManager.is_aiming = function(self)
    return self.aiming
end

SkitariusWeaponManager.set_charging = function(self, charging)
    self.charging = charging
end

SkitariusWeaponManager.is_charging = function(self)
    return self.charging
end

SkitariusWeaponManager.set_pushing = function(self, pushing)
    self.pushing = pushing
end

SkitariusWeaponManager.is_pushing = function(self)
    return self.pushing
end

SkitariusWeaponManager.set_firing = function(self, firing)
    self.firing = firing
end

SkitariusWeaponManager.is_firing = function(self)
    return self.firing
end

--  ╔╦╗╔═╗╔╦╗╔═╗  ╔╦╗╔═╗╔╗╔╔═╗╔═╗╔═╗╔╦╗╔═╗╔╗╔╔╦╗
--   ║║╠═╣ ║ ╠═╣  ║║║╠═╣║║║╠═╣║ ╦║╣ ║║║║╣ ║║║ ║ 
--  ═╩╝╩ ╩ ╩ ╩ ╩  ╩ ╩╩ ╩╝╚╝╩ ╩╚═╝╚═╝╩ ╩╚═╝╝╚╝ ╩ 

SkitariusWeaponManager.update_peril = function(self)
    local player_manager = Managers and Managers.player
    if player_manager then
        local player = player_manager:local_player_safe(1)
        local player_unit = player and player.player_unit
        local unit_data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")
        if unit_data_extension then
            local warp_charge_component = unit_data_extension:read_component("warp_charge")
            local current_charge = warp_charge_component and warp_charge_component.current_percentage or 0
            if current_charge then
                self.warp = current_charge
            end
        end
    end
    if not self.warp then
        self.warp = 0
    end
end

--  ╦ ╦╔═╗╦  ╔═╗╔═╗╦═╗  ╔═╗╦ ╦╔╗╔╔═╗╔═╗
--  ╠═╣║╣ ║  ╠═╝║╣ ╠╦╝  ╠╣ ║ ║║║║║  ╚═╗
--  ╩ ╩╚═╝╩═╝╩  ╚═╝╩╚═  ╚  ╚═╝╝╚╝╚═╝╚═╝

-- Getting specific transition times are tricky as they are generally unique per-weapon, so this is a failsafe
-- Needs more work before this should be used in release
SkitariusWeaponManager.firing_chain_time = function(self)
    local weapon_type = self:weapon_type()
    local weapon_name = self:weapon_name()
    if weapon_type ~= "RANGED" then
        return 0
    end
    local weapon_template
    for _, template in pairs(WeaponTemplates) do
        if template.name == weapon_name then
            weapon_template = template
            break
        end
    end
    if weapon_template then
        local actions = {}
        for _, action in pairs(weapon_template.actions) do
            if action.kind and self.armoury.shoot_actions[action.kind] and action.allowed_chain_actions then
                local longest_chain_time = 0
                for _, chain_actions in pairs(action.allowed_chain_actions) do
                    if chain_actions.chain_time and chain_actions.chain_time > longest_chain_time then
                        longest_chain_time = chain_actions.chain_time
                    end
                end
                if longest_chain_time > 0 then
                    actions[action.kind] = longest_chain_time
                end
            end
        end
        local max_chain_time = 0
        for _, chain_time in pairs(actions) do
            if chain_time > max_chain_time then
                max_chain_time = chain_time
            end
        end
        return max_chain_time
    end
end

SkitariusWeaponManager.generates_peril_wrapper = function(self, input)
    local armoury = self.armoury
    local scriers = self:fetch_stacks("psyker_overcharge_stance_infinite_casting")
    return armoury:generates_peril(input, scriers)
end

SkitariusWeaponManager.suicidal = function(self, input, weenie_hut_jr)
    if not weenie_hut_jr then return false end
    if (input == "action_one_hold" or input == "action_one_pressed") and self.pushing then
        input = "push_follow_up"
    end
    local generates_peril, max_peril = self:generates_peril_wrapper(input)
    if not max_peril then
        max_peril = 0.945 -- Default peril threshold
    end
    if generates_peril and self.warp >= max_peril then
        return true
    else
        return false
    end
end

-- Any of these interruptions halt active sequences IF "Halt on Interrupt" is enabled
SkitariusWeaponManager.interruption = function(self)
    local halt_on_interrupt = self.mod.settings.halt_on_interrupt
    if not halt_on_interrupt then return false end
    local interruption_type = self.mod.settings.halt_on_interrupt_types
    local sprinting = self:is_sprinting()                                                             -- Sprinting
    local blocking = self.binds:input_value("action_two_hold") and self.binds:waiting_toggles()       -- Manual blocking/aiming/charging
    local attacking = self.binds:input_value("action_one_hold") and self.binds:waiting_toggles()      -- Manual attacking outside of primary override sequence
    -- Double-check to ensure it doesn't mess with intended actions (primarily ranged weaponry)
    if (attacking) and self:is_aiming() or self:is_charging() then
        attacking = false
    end
    local interruption_map = {
        interruption_sprint      = {sprinting=true},
        interruption_action_one  = {attacking=true},
        interruption_action_two  = {blocking=true},
        interruption_action_both = {blocking=true, attacking=true},
        interruption_all         = {sprinting=true, blocking=true, attacking=true}
    }
    local interruption_config = interruption_map[interruption_type]
    if not interruption_config then
        return false -- Settings error failsafe
    end
    -- Allow interruption if it matches the selected setting
    if (sprinting and interruption_config.sprinting) or
       (blocking and interruption_config.blocking) or
       (attacking and interruption_config.attacking) then
        return true
    end
    return false
end

SkitariusWeaponManager.has_trait_or_talent = function(self, trait_or_talent)
    local player = Managers.player:local_player_safe(1)
    local player_unit = player and player.player_unit
    local buff_extension = player_unit and ScriptUnit.has_extension(player_unit, "buff_system")
    local stacking_buffs = buff_extension and buff_extension._stacking_buffs
    if stacking_buffs then
        for buff, _ in pairs(stacking_buffs) do
            if buff and string.find(buff, trait_or_talent) then
                return true
            end
        end
    end
    return false
end

SkitariusWeaponManager.fetch_stacks = function(self, buff_name)
    local player = Managers.player:local_player_safe(1)
    local player_unit = player and player.player_unit
    local buff_extension = player_unit and ScriptUnit.has_extension(player_unit, "buff_system")
    local buffs = buff_extension and buff_extension._buffs
    local stacks = 0
    if buffs then
	    for index, _ in ipairs (buffs) do
            local name = buffs[index]._template.name
            if name and string.find(name, buff_name) ~= nil then
                stacks = buffs[index]._template_context.stack_count
            end
	    end
    end
    return stacks
end

return SkitariusWeaponManager