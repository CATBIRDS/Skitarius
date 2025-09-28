local SkitariusArmoury = class("SkitariusArmoury")

local ALT_WEAPONS = {
    lasgun_p2_m1 = true,
    lasgun_p2_m2 = true,
    lasgun_p2_m3 = true,
}

local SHOOT_ACTIONS = {
    flamer_gas = true,
    flamer_gas_burst = true,
    spawn_projectile = true,
    chain_lightning = true,
    shoot_hit_scan = true,
    shoot_pellets = true,
    shoot_projectile = true,
}

-- Ranged weapons with special attacks which can be either light or heavy
local SPECIAL_ATTACK = {
    -- Helbores
    lasgun_p2_m1 = true,
    lasgun_p2_m2 = true,
    lasgun_p2_m3 = true,
    -- Force Staffs
    forcestaff_p1_m1 = true,
    forcestaff_p2_m1 = true,
    forcestaff_p3_m1 = true,
    forcestaff_p4_m1 = true,
    -- Double-barrel Shotgun
    shotgun_p2_m1 = true,
    -- Vigilant Autoguns
    autogun_p3_m1 = true,
    autogun_p3_m2 = true,
    autogun_p3_m3 = true,
    -- Shotpistol
    shotpistol_shield_p1_m1 = true
}

-- Ranged weapons which can be charged
local CHARGED_RANGED = {
    -- Helbores
    lasgun_p2_m1 = true,
    lasgun_p2_m2 = true,
    lasgun_p2_m3 = true,
    -- Force Staffs
    forcestaff_p1_m1 = true,
    forcestaff_p2_m1 = true,
    forcestaff_p3_m1 = true,
    forcestaff_p4_m1 = true,
    -- Plasma Gun
    plasmagun_p1_m1 = true,
}

-- Ranged weapons with activated specials
local ACTIVE_SPECIAL_RANGED = {
    -- Combat Shotguns
    shotgun_p1_m1 = true,
    shotgun_p1_m2 = true,
    shotgun_p1_m3 = true,
    -- Executor Shotguns
    shotgun_p4_m1 = true,
    shotgun_p4_m2 = true,
    -- Infantry Autoguns
    autogun_p1_m1 = true,
    autogun_p1_m2 = true,
    autogun_p1_m3 = true,
    -- Autopistol
    autopistol_p1_m1 = true,
    -- Infantry Lasguns
    lasgun_p1_m1 = true,
    lasgun_p1_m2 = true,
    lasgun_p1_m3 = true,
    -- Recon Lasguns
    lasgun_p3_m1 = true,
    lasgun_p3_m2 = true,
    lasgun_p3_m3 = true,
    -- Heavy Stubbers
    ogryn_heavystubber_p2_m1 = true,
    ogryn_heavystubber_p2_m2 = true,
    ogryn_heavystubber_p2_m3 = true,
}

local COMBAT_SHOTGUN = {
    -- Combat Shotgun
    shotgun_p1_m1 = true,
    shotgun_p1_m2 = true,
    shotgun_p1_m3 = true,
}

local FORCE_STAFF = {
    -- Force Staffs
    forcestaff_p1_m1 = true,
    forcestaff_p2_m1 = true,
    forcestaff_p3_m1 = true,
    forcestaff_p4_m1 = true,
}

local QUELLING = {
    forcesword_p1_m1 = true,
    forcesword_p1_m2 = true,
    forcesword_p1_m3 = true,
    forcesword_2h_p1_m1 = true,
    forcesword_2h_p1_m2 = true,
}

-- ASTRONOMICAN: Global data to determine weapons and actions which generate peril (and how they do so)
local ASTRONOMICAN = {
    force_staff = {
        p1 = {
            action_one_hold = true,
            action_one_pressed = true,
            weapon_extra_pressed = false,
        },
        p2 = {
            action_one_hold = true,
            action_one_pressed = true,
            weapon_extra_pressed = false,
        },
        p3 = {
            action_one_hold = true,
            action_one_pressed = true,
            weapon_extra_pressed = false,
        },
        p4 = {
            action_one_hold = true,
            action_one_pressed = true,
            weapon_extra_pressed = false,
        },
    },
    force_sword = {
        p1 = {
            action_one_hold = false,
            action_one_pressed = false,
            weapon_extra_pressed = true,
            push_follow_up = true
        },
        p2 = {
            action_one_hold = false,
            action_one_pressed = false,
            weapon_extra_pressed = true,
            push_follow_up = true
        },
        p3 = {
            action_one_hold = false,
            action_one_pressed = false,
            weapon_extra_pressed = true,
            push_follow_up = true
        },
    },
    combat_sword = {
        p1 = {
            action_one_hold = false,
            action_one_pressed = false,
            weapon_extra_pressed = true,
        },
        p2 = {
            action_one_hold = false,
            action_one_pressed = false,
            weapon_extra_pressed = true,
        },
        p3 = {
            action_one_hold = false,
            action_one_pressed = false,
            weapon_extra_pressed = true,
        }
    },
    psyker_smite = {
        BLITZ = true,
        action_one_hold = true,
        action_one_pressed = true,
        weapon_extra_pressed = false,
    },
    psyker_throwing_knives = {
        BLITZ = true,
        UNIQUE_THRESHOLD = 0.91, -- Shards are lethal if thrown above 92% (91.5% internally), unlike other warp actions
        action_one_hold = true,
        action_one_pressed = true,
        weapon_extra_pressed = false,
    }
}

-- INCORRECT_TIMES: Weapons and actions which have incorrect internal chain timings for heavies
local INCORRECT_TIMES = {
    ogryn_powermaul_slabshield_p1_m1 = {
        action_right_heavy = {
            incorrect = 0.35,
            also_incorrect = 0.4,
            correct = 0.5,
            also_correct = 0.45
        }
    },
    ogryn_club_p2_m3 = {
        action_right_heavy = {
            incorrect = 0.5,
            correct = 0.55,
        }
    },
    combataxe_p2_m3 = {
        action_left_heavy = {
            incorrect = 0.25,
            correct = 0.3,
        }
    },
    powermaul_2h_p1_m1 = {
        action_right_heavy = {
            incorrect = 0.35,
            correct = 0.45,
        }
    },
    combataxe_p2_m1 = {
        action_left_heavy = {
            incorrect = 0.25,
            correct = 0.3,
        }
    }
}

SkitariusArmoury.shoot_actions = SHOOT_ACTIONS
SkitariusArmoury.alt_weapons = ALT_WEAPONS
SkitariusArmoury.special_attack = SPECIAL_ATTACK
SkitariusArmoury.charged_ranged = CHARGED_RANGED
SkitariusArmoury.active_special_ranged = ACTIVE_SPECIAL_RANGED
SkitariusArmoury.combat_shotgun = COMBAT_SHOTGUN
SkitariusArmoury.force_staff = FORCE_STAFF
SkitariusArmoury.quelling = QUELLING
SkitariusArmoury.astronomican = ASTRONOMICAN
SkitariusArmoury.incorrect_times = INCORRECT_TIMES

SkitariusArmoury.validate_chain_time = function(self, chain_time, chain_action_name, weapon_name)
    if not (INCORRECT_TIMES[weapon_name] and INCORRECT_TIMES[weapon_name][chain_action_name]) then
        return chain_time
    end
    -- Weapons with one incorrect time
    local incorrect_time = INCORRECT_TIMES[weapon_name][chain_action_name].incorrect or 0
    local also_incorrect_time = INCORRECT_TIMES[weapon_name][chain_action_name].also_incorrect or 0
    -- Weapons with two incorrect times
    local correct_time = INCORRECT_TIMES[weapon_name][chain_action_name].correct or 0
    local also_correct_time = INCORRECT_TIMES[weapon_name][chain_action_name].also_correct or 0
    -- Weapons with conditionally incorrect times based on previous actions
    local prev_incorrect_time = INCORRECT_TIMES[weapon_name][chain_action_name].prev_incorrect or 0
    local prev_correct_time = INCORRECT_TIMES[weapon_name][chain_action_name].prev_correct or "ignore"
    local prev_action = INCORRECT_TIMES[weapon_name][chain_action_name].prev_action or 0
    -- Weapons with one incorrect time: Tac Axe MkVII, Bully Club MkIIIb
    if chain_time == incorrect_time then
        chain_time = correct_time
    -- Weapons with two incorrect times: Slab Shield
    elseif chain_time == also_incorrect_time then
        chain_time = also_correct_time
    -- Weapons with conditionally incorrect times: Crusher
    elseif previous == prev_action and chain_time == prev_incorrect_time then
        chain_time = prev_correct_time
    end
    return chain_time
end

SkitariusArmoury.generates_peril = function(self, input, scriers)
    if not input then
        input = "action_one_hold"
    end
    local player_manager = Managers and Managers.player
    local player = player_manager and player_manager:local_player_safe(1)
    local player_unit = player and player.player_unit
    local weapon_extension = player_unit and ScriptUnit.has_extension(player_unit, "weapon_system")
    local unit_data_extension = player_unit and ScriptUnit.has_extension(player_unit, "unit_data_system")
    local buff_extension = player_unit and ScriptUnit.has_extension(player_unit, "buff_system")
    if scriers and scriers > 0 then
        local remaining_percentage = 0
        if buff_extension._buffs_by_index then
            for _, buff_instance in pairs(buff_extension._buffs_by_index) do
                if buff_instance then
                    local template = buff_instance:template()
                    if template and template.name == "psyker_overcharge_stance_infinite_casting" then
                        remaining_percentage = buff_instance:duration_progress()
                    end
                end
            end
        end
        if remaining_percentage > 0.05 then
            return false, nil
        end
    end
    if weapon_extension and unit_data_extension then
        local inventory = weapon_extension._inventory_component
        local wielded_weapon = weapon_extension:_wielded_weapon(inventory, weapon_extension._weapons)
        if wielded_weapon then
            local weapon_template = wielded_weapon and wielded_weapon.weapon_template
            local keywords = weapon_template.keywords
            -- Standard weapons
            if keywords and keywords[2] and keywords[3] then
                local family = keywords[2]
                local mark = keywords[3]
                local generates_peril = ASTRONOMICAN[family] and ASTRONOMICAN[family][mark] and ASTRONOMICAN[family][mark][input]
                local unique_threshold = ASTRONOMICAN[family] and ASTRONOMICAN[family][mark] and ASTRONOMICAN[family][mark].UNIQUE_THRESHOLD
                return generates_peril, unique_threshold
            else
                -- Non-family/mark weapons
                local empowered_grenade = buff_extension and buff_extension:has_keyword("psyker_empowered_grenade")
                local name = weapon_template.name
                if ASTRONOMICAN[name] and ASTRONOMICAN[name][input] then
                    if (ASTRONOMICAN[name].BLITZ and empowered_grenade) then
                        return false, nil
                    else
                        return true, ASTRONOMICAN[name].UNIQUE_THRESHOLD
                    end
                end
            end
        end
    end
    return false, nil
end

return SkitariusArmoury