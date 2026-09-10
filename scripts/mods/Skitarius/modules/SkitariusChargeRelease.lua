local SkitariusChargeRelease = {}

SkitariusChargeRelease.resolve_threshold = function(options)
    local weapon_percent = options.weapon_percent or 100

    if options.global_enabled then
        return math.min(weapon_percent, options.global_percent)
    end

    return weapon_percent
end

SkitariusChargeRelease.is_ready = function(state)
    local threshold = math.min(state.threshold_percent / 100, state.max_charge)

    return state.charge_level ~= 0 and state.charge_level >= threshold
end

return SkitariusChargeRelease
