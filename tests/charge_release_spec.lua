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

    -- Proposed contract from the tooltip: a lower saved weapon threshold
    -- applies even without a running sequence. Intentionally red until fixed.
    it("releases manual charging at saved weapon 50%, with global at 100%", function()
        local f = fixture("none", 100, 50)
        assert.is_false(f.release_at(0.49))
        assert.is_true(f.release_at(0.50))
    end)
end)
