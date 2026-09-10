-- Lua 5.1 / LuaJIT. Load real modules in an isolated game-like environment.
local function fixture(mode, global_threshold, weapon_threshold)
    local charge = { charge_level = 0, max_charge = 1 }
    local extensions = {
        weapon_system = { _action_module_charge_component = charge },
        unit_data_system = {},
        visual_loadout_system = {
            _inventory_component = {
                wielded_slot = "slot_secondary",
                __data = {{ slot_secondary = "content/items/weapons/player/ranged/forcestaff_p2_m1" }},
            },
        },
    }
    local env = setmetatable({
        -- These modules only need class() to provide a method table at load time.
        class = function() return {} end,
        require = function(name)
            if name == "scripts/settings/equipment/weapon_templates/weapon_templates"
                or name == "scripts/utilities/ammo" then
                return {} -- Neither dependency is used by the exercised methods.
            end
            error("Unexpected game dependency: " .. name)
        end,
        Managers = { player = { local_player_safe = function() return { player_unit = {} } end } },
        ScriptUnit = { has_extension = function(_, name) return extensions[name] end },
    }, { __index = _G })
    local function load_module(name)
        local chunk = assert(loadfile("scripts/mods/Skitarius/modules/" .. name .. ".lua"))
        setfenv(chunk, env)
        return chunk()
    end
    local function instance(methods)
        return setmetatable({}, { __index = methods })
    end
    local mod = {
        settings = { always_charge = true, always_charge_threshold = global_threshold },
        armoury = load_module("SkitariusArmoury"),
    }
    local engram = instance(load_module("SkitariusEngram"))
    local weapon = instance(load_module("SkitariusWeaponManager"))
    local binds = instance(load_module("SkitariusBindManager"))
    local omnissiah = instance(load_module("SkitariusOmnissiah"))
    mod.engram, mod.weapon_manager = engram, weapon
    engram:init(mod)
    weapon:init(mod)
    -- Peril/buffs are outside this test; do not force an emergency release.
    weapon.generates_peril_wrapper = function() return false end
    binds.bind_data = { override_primary = { RANGED = {
        forcestaff_p2_m1 = { automatic_fire = mode, auto_charge_threshold = weapon_threshold },
    } } }
    -- Model the player holding secondary attack to charge, with no reload input.
    binds.input_value = function(_, input) return input == "action_two_hold" end
    weapon:set_bind_manager(binds)
    engram:set_weapon_manager(weapon)
    engram:set_bind_manager(binds)
    engram:kill_engram()
    weapon:refresh_weapon()
    omnissiah.mod, omnissiah.armoury = mod, mod.armoury
    omnissiah.engram, omnissiah.weapon_manager, omnissiah.bind_manager = engram, weapon, binds
    return {
        engram = engram,
        weapon = weapon,
        binds = binds,
        settings = mod.settings,
        release_at = function(level)
            charge.charge_level = level
            -- Observe the actual synthesized fire input, not a copied formula.
            return omnissiah:resolve_conflicts("action_one_pressed", false, nil, "charge", nil) == true
        end,
    }
end

return fixture
