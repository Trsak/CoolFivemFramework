local Keys = {["H"] = 74, ["SPACE"] = 22, ["DELETE"] = 178}
local canExercise = false
local exercising = false
local procent = 0
local motionProcent = 0
local doingMotion = false
local motionTimesDone = 0
local isShowingExerciseHint = false
local currentNearestExercise = nil
local doingExercise = false
local shouldStop = false

Citizen.CreateThread(
    function()
        for i, coords in each(Config.Blips) do
            local bip =
                createNewBlip(
                {
                    coords = coords,
                    sprite = 311,
                    display = 4,
                    scale = 0.7,
                    colour = 0,
                    isShortRange = true,
                    text = "Posilovna"
                }
            )
        end
    end
)

RegisterCommand(
    "exercise",
    function()
        if currentNearestExercise and not exercising then
            exercising = true
            startExercise(Config.Exercises[currentNearestExercise.Exercise], currentNearestExercise)
        elseif canExercise and procent <= 99 then
            shouldStop = true
        end
    end
)

createNewKeyMapping({command = "exercise", text = "Cvičení (ukončení a spuštění)", key = "H"})

Citizen.CreateThread(
    function()
        while true do
            local coords = GetEntityCoords(PlayerPedId())
            local shouldBeDisplayingHint = false

            for i, exercise in pairs(Config.Locations) do
                local dist = #(vec3(exercise.Coords.x, exercise.Coords.y, exercise.Coords.z) - coords)

                if dist <= 1.2 and not exercising then
                    shouldBeDisplayingHint = true
                    currentNearestExercise = exercise
                    if not isShowingExerciseHint or isShowingExerciseHint ~= exercise.Exercise then
                        isShowingExerciseHint = exercise.Exercise
                        exports.key_hints:displayHint(
                            {
                                name = "exercise",
                                key = "~INPUT_45EE0036~",
                                text = exercise.Exercise,
                                coords = vec3(exercise.Coords.x, exercise.Coords.y, exercise.Coords.z)
                            }
                        )
                    end
                    break
                end
            end

            if not shouldBeDisplayingHint and isShowingExerciseHint then
                currentNearestExercise = nil
                isShowingExerciseHint = false
                exports.key_hints:hideHint({name = "exercise"})
            end

            Citizen.Wait(500)
        end
    end
)

function startExercise(animInfo, pos)
    local playerPed = PlayerPedId()

    LoadDict(animInfo.idleDict)
    LoadDict(animInfo.enterDict)
    LoadDict(animInfo.exitDict)
    LoadDict(animInfo.actionDict)

    if pos.Coords.w ~= 0.0 then
        SetEntityCoords(playerPed, pos.Coords.xyz)
        SetEntityHeading(playerPed, pos.Coords.w)
    end

    TaskPlayAnim(playerPed, animInfo.enterDict, animInfo.enterAnim, 8.0, -8.0, animInfo.enterTime, 0, 0.0, 0, 0, 0)
    Citizen.Wait(animInfo.enterTime)

    canExercise = true
    exercising = true

    Citizen.CreateThread(
        function()
            while exercising do
                Citizen.Wait(1)
                if procent <= 24.99 then
                    color = "~r~"
                elseif procent <= 49.99 then
                    color = "~o~"
                elseif procent <= 74.99 then
                    color = "~b~"
                elseif procent <= 100 then
                    color = "~g~"
                end

                if procent > 100 then
                    procent = 100
                end

                DrawText2D(0.505, 0.925, 1.0, 1.0, 0.33, "Cvičení: " .. color .. procent .. "%", 255, 255, 255, 255)
            end
        end
    )

    Citizen.CreateThread(
        function()
            if canExercise then
                local playercorods = GetEntityCoords(playerPed)

                exports.key_hints:displayBottomHint(
                    {
                        name = "do_exercise",
                        key = "~INPUT_D0DC6B7E~",
                        text = "Provedení cviku"
                    }
                )

                exports.key_hints:displayBottomHint(
                    {
                        name = "exercise",
                        key = "~INPUT_45EE0036~",
                        text = "Zrušit cvičení"
                    }
                )
            end

            while canExercise do
                Citizen.Wait(8)
                local playerCoords = GetEntityCoords(playerPed)
                if procent <= 99 then
                    TaskPlayAnim(playerPed, animInfo.idleDict, animInfo.idleAnim, 8.0, -8.0, -1, 0, 0.0, 0, 0, 0)

                    if doingExercise then
                        TaskPlayAnim(
                            PlayerPedId(),
                            animInfo.actionDict,
                            animInfo.actionAnim,
                            8.0,
                            -8.0,
                            animInfo.actionTime,
                            0,
                            0.0,
                            0,
                            0,
                            0
                        )
                        AddPercent(animInfo.actionProcent, animInfo.actionProcentTimes, animInfo.actionTime - 70)
                        doingExercise = false
                        canExercise = true
                    elseif shouldStop then
                        shouldStop = false
                        ExitTraining(animInfo.exitDict, animInfo.exitAnim, animInfo.exitTime)
                    end
                else
                    ExitTraining(animInfo.exitDict, animInfo.exitAnim, animInfo.exitTime)

                    for skill, amount in pairs(animInfo.skills) do
                        exports.skills:changeSkill(skill, false, amount, true)
                    end
                end
            end
        end
    )
end

RegisterCommand(
    "doexercise",
    function()
        if canExercise and procent <= 99 then
            canExercise = false
            doingExercise = true
        end
    end
)

createNewKeyMapping({command = "doexercise", text = "Provedení cviku", key = "SPACE"})

function ExitTraining(exitDict, exitAnim, exitTime)
    TaskPlayAnim(PlayerPedId(), exitDict, exitAnim, 8.0, -8.0, exitTime, 0, 0.0, 0, 0, 0)
    exports.key_hints:hideBottomHint({name = "do_exercise"})
    exports.key_hints:hideBottomHint({name = "exercise"})
    canExercise = false
    procent = 0
    Citizen.Wait(exitTime)
    exercising = false
end

function AddPercent(amount, amountTimes, time)
    for i = 1, amountTimes do
        Citizen.Wait(time / amountTimes)
        procent = procent + amount
    end
end

function LoadDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
end

local font = RegisterFontId("AMSANSL")

function DrawText2D(x, y, width, height, scale, text, r, g, b, a, outline)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end
