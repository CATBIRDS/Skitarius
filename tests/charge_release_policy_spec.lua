local ChargeRelease = dofile("scripts/mods/Skitarius/modules/SkitariusChargeRelease.lua")

describe("charge release policy", function()
    describe("threshold selection", function()
        it("uses the lower weapon threshold", function()
            assert.are.equal(50, ChargeRelease.resolve_threshold({
                weapon_percent = 50, global_percent = 100, global_enabled = true,
            }))
        end)

        it("uses the lower global threshold", function()
            assert.are.equal(25, ChargeRelease.resolve_threshold({
                weapon_percent = 50, global_percent = 25, global_enabled = true,
            }))
        end)

        it("ignores the global slider when auto-release is disabled", function()
            assert.are.equal(50, ChargeRelease.resolve_threshold({
                weapon_percent = 50, global_percent = 25, global_enabled = false,
            }))
        end)

        it("defaults missing weapon settings to 100%", function()
            assert.are.equal(100, ChargeRelease.resolve_threshold({ global_enabled = false }))
            assert.are.equal(75, ChargeRelease.resolve_threshold({
                global_percent = 75, global_enabled = true,
            }))
        end)

        it("preserves a zero weapon threshold", function()
            assert.are.equal(0, ChargeRelease.resolve_threshold({
                weapon_percent = 0, global_percent = 100, global_enabled = true,
            }))
        end)
    end)

    describe("charge readiness", function()
        it("releases at the threshold, but not below it", function()
            assert.is_false(ChargeRelease.is_ready({
                charge_level = 0.49, max_charge = 1, threshold_percent = 50,
            }))
            assert.is_true(ChargeRelease.is_ready({
                charge_level = 0.50, max_charge = 1, threshold_percent = 50,
            }))
        end)

        it("releases at the attainable maximum even if the slider is higher", function()
            assert.is_true(ChargeRelease.is_ready({
                charge_level = 0.8, max_charge = 0.8, threshold_percent = 100,
            }))
        end)

        it("requires charging to start even with a zero threshold", function()
            assert.is_false(ChargeRelease.is_ready({
                charge_level = 0, max_charge = 1, threshold_percent = 0,
            }))
            assert.is_true(ChargeRelease.is_ready({
                charge_level = 0.01, max_charge = 1, threshold_percent = 0,
            }))
        end)
    end)
end)
