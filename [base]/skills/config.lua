Config = {}

Config.ReduceTimer = 120000

Config.SkillsOder = {"stamina", "strength"}

Config.Skills = {
    ["stamina"] = {
        ["label"] = "Výdrž",
        ["reduce"] = -0.01,
        ["default"] = 25.0,
        ["effect"] = function(value)
            local newValue = 0
            if value > 0 then
                newValue = math.floor(value / 1.25)

                if newValue < 0 then
                    newValue = 0
                end
            end

            StatSetInt(GetHashKey("MP0_STAMINA"), newValue, true)
        end
    },
    ["strength"] = {
        ["label"] = "Síla",
        ["reduce"] = -0.01,
        ["default"] = 25.0,
        ["effect"] = function(value)
            local newValue = 0
            if value > 0 then
                newValue = math.floor(value / 1.25)

                if newValue < 0 then
                    newValue = 0
                end
            end

            StatSetInt(GetHashKey("MP0_STRENGTH"), newValue, true)
        end
    }
}
