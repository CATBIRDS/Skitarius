local fixture = require("tests.support.charge_release_fixture")

describe("charge release", function()
    it("resolves the equipped flame staff to its weapon settings key", function()
        local f = fixture("charged", 100, 50)
        assert.are.equal("forcestaff_p2_m1", f.weapon:weapon_name())
        assert.are.equal("RANGED", f.weapon:weapon_type())
    end)

    it("releases an active weapon sequence at 50%, with global at 100%", function()
        local f = fixture("charged", 100, 50)
        f.engram:new_engram("override_primary")
        assert.are.equal(50, f.engram:charge_threshold())
        assert.is_false(f.release_at(0.49))
        assert.is_true(f.release_at(0.50))
    end)

    it("uses a lower global threshold over an active weapon sequence", function()
        local f = fixture("charged", 25, 50)
        f.engram:new_engram("override_primary")
        assert.is_false(f.release_at(0.24))
        assert.is_true(f.release_at(0.25))
    end)

    it("releases manual charging at global 100% when weapon is also 100%", function()
        local f = fixture("none", 100, 100)
        assert.is_false(f.release_at(0.50))
        assert.is_true(f.release_at(1))
    end)

    -- A lower saved Primary weapon threshold applies without a running sequence.
    it("releases manual charging at saved weapon 50%, with global at 100%", function()
        local f = fixture("none", 100, 50)
        assert.is_false(f.release_at(0.49))
        assert.is_true(f.release_at(0.50))
    end)

    it("keeps the global threshold when no Primary weapon threshold is saved", function()
        local f = fixture("none", 75, nil)
        f.binds.bind_data = {}
        assert.is_false(f.release_at(0.74))
        assert.is_true(f.release_at(0.75))
    end)

    it("does not auto-release manual charging when global auto-release is disabled", function()
        local f = fixture("none", 100, 50)
        f.settings.always_charge = false
        assert.is_false(f.release_at(0.50))
        assert.is_false(f.release_at(1))
    end)

    it("uses an active keybind's threshold instead of Primary's threshold", function()
        local f = fixture("none", 100, 50)
        f.binds.bind_data.keybind_one_held = { RANGED = {
            forcestaff_p2_m1 = { automatic_fire = "charged", auto_charge_threshold = 75 },
        } }
        f.engram:new_engram("keybind_one_held")
        assert.is_false(f.release_at(0.50))
        assert.is_true(f.release_at(0.75))
    end)

    it("ignores other keybind thresholds when manually charging", function()
        local f = fixture("none", 100, 50)
        f.binds.bind_data.keybind_one_pressed = { RANGED = {
            forcestaff_p2_m1 = { automatic_fire = "charged", auto_charge_threshold = 25 },
        } }
        assert.is_false(f.release_at(0.25))
        assert.is_true(f.release_at(0.50))
    end)
end)
