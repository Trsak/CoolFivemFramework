local skills = {}
local isSpawned, isDead = false, false

Citizen.CreateThread(
    function()
        for skill, data in pairs(Config.Skills) do
            skills[skill] = data.default
        end

        Citizen.Wait(500)

        exports.chat:addSuggestion("/skills", "Vypíše seznam schopností vaší postavy")
        exports.chat:addSuggestion("/schopnosti", "Vypíše seznam schopností vaší postavy")

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")

            local loadedSkills = exports.data:getCharVar("skills")

            for skill, value in pairs(loadedSkills) do
                changeSkill(skill, true, value, false)
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" then
            if not isSpawned then
                Citizen.CreateThread(
                    function()
                        Citizen.Wait(500)
                        local loadedSkills = exports.data:getCharVar("skills")

                        for skill, value in pairs(loadedSkills) do
                            changeSkill(skill, true, value, true)
                        end
                    end
                )
            end

            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

Citizen.CreateThread(
    function()
        while not isSpawned do
            Citizen.Wait(5000)
        end

        while true do
            Citizen.Wait(Config.ReduceTimer)
            for skill, data in pairs(Config.Skills) do
                changeSkill(skill, false, data.reduce, false)
            end

            TriggerServerEvent("skills:update", skills)
        end
    end
)

function changeSkill(skill, setting, amount, save)
    if Config.Skills[skill] == nil then
        return
    end

    if setting then
        skills[skill] = amount
    else
        local valueBefore = skills[skill]
        if amount < 0 or valueBefore <= 99.5 then
            SendNUIMessage(
                {
                    action = "changeSkill",
                    skillLabel = Config.Skills[skill].label,
                    amount = amount
                }
            )
        end

        skills[skill] = skills[skill] + amount
    end

    if skills[skill] > 100 then
        skills[skill] = 100
    elseif skills[skill] < 0 then
        skills[skill] = 0
    end

    Config.Skills[skill].effect(skills[skill])

    if save then
        TriggerServerEvent("skills:update", skills)
    end
end

RegisterCommand(
    "skills",
    function(source, args)
        printSkills()
    end
)

RegisterCommand(
    "schopnosti",
    function(source, args)
        printSkills()
    end
)

function printSkills()
    local message = ""

    for i, skillName in each(Config.SkillsOder) do
        local data = Config.Skills[skillName]
        message = message .. "<br><strong>" .. data.label .. "</strong>: " .. string.format("%.2f", skills[skillName]) .. "%"
    end

    TriggerEvent(
        "chat:addMessage",
        {
            template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(0, 191, 255, 0.75); border-left: 10px solid rgb(0, 191, 255);"><strong>Schopnosti</strong><br>' .. message .. "</div>",
            args = {}
        }
    )
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(10000)
            local ped = PlayerPedId()

            local change = 0.0

            if IsPedRunning(ped) then
                change = change + 0.2
            end

            if IsPedSprinting(ped) then
                change = change + 0.3
            end

            if IsPedOnAnyBike(ped) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                if DoesEntityExist(vehicle) and IsThisModelABicycle(GetEntityModel(vehicle)) and GetEntitySpeed(vehicle) > 5.0 then
                    change = change + 0.3
                end
            end

            if change > 0 then
                changeSkill("stamina", false, change, true)
            end
        end
    end
)
