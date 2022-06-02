function HACKING_PC(data)
    local inMinigame, ipFinded, lives, clickReturn = false, false, 5, 0
    local scaleform = InitializeScaleform(data)
    while HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
        disableControls()
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        BeginScaleformMovieMethod(scaleform, "SET_CURSOR")
        ScaleformMovieMethodAddParamFloat(GetControlNormal(0, 239))
        ScaleformMovieMethodAddParamFloat(GetControlNormal(0, 240))
        EndScaleformMovieMethod()

        if IsDisabledControlJustPressed(0, 24) then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_SELECT")
            ClickReturn = EndScaleformMovieMethodReturnValue()
            PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
        elseif IsDisabledControlJustPressed(0, 176) and inMinigame then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_SELECT")
            ClickReturn = EndScaleformMovieMethodReturnValue()
            PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
        elseif IsDisabledControlJustPressed(0, 25) and not inMinigame then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_BACK")
            EndScaleformMovieMethod()
            PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
        elseif IsDisabledControlJustPressed(0, 172) and inMinigame then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT")
            PushScaleformMovieFunctionParameterInt(8)
            PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
        elseif IsDisabledControlJustPressed(0, 173) and inMinigame then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT")
            PushScaleformMovieFunctionParameterInt(9)
            PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
        elseif IsDisabledControlJustPressed(0, 174) and inMinigame then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT")
            PushScaleformMovieFunctionParameterInt(10)
            PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
        elseif IsDisabledControlJustPressed(0, 175) and inMinigame then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT")
            PushScaleformMovieFunctionParameterInt(11)
            PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
        end

        if HasScaleformMovieLoaded(scaleform) then
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)

            if IsScaleformMovieMethodReturnValueReady(ClickReturn) then
                clickReturn = GetScaleformMovieMethodReturnValueInt(ClickReturn)
                if not inMinigame and not ipFinded and clickReturn == 82 then
                    BeginScaleformMovieMethod(scaleform, "OPEN_APP")
                    ScaleformMovieMethodAddParamFloat(0.0)
                    EndScaleformMovieMethod()
                    exports.notify:display({
                        type = "info",
                        title = "Notebook",
                        text = "Najdi správnou IP adresu",
                        icon = "fas fa-times",
                        length = 2000
                    })
                    inMinigame = true
                elseif inMinigame and clickReturn == 85 then
                    PlaySoundFrontend(-1, "HACKING_FAILURE", 0, true)
                    BeginScaleformMovieMethod(scaleform, "CLOSE_APP")
                    EndScaleformMovieMethod()
                    exports.notify:display({
                        type = "error",
                        title = "Notebook",
                        text = "Zkus to najít znovu",
                        icon = "fas fa-times",
                        length = 2000
                    })
                    inMinigame = false
                    if data.PoliceReportChange ~= nil then
                        reportPolice(data)
                    end
                elseif inMinigame and clickReturn == 84 then
                    PlaySoundFrontend(-1, "HACKING_SUCCESS", 0, true)
                    BeginScaleformMovieMethod(scaleform, "CLOSE_APP")
                    EndScaleformMovieMethod()
                    exports.notify:display({
                        type = "info",
                        title = "Notebook",
                        text = "Dobrá práce! Otevři BruteForce.exe",
                        icon = "fas fa-times",
                        length = 2000
                    })
                    inMinigame = false
                    ipFinded = true
                elseif not inMinigame and clickReturn == 83 then
                    if ipFinded then
                        lives = 5
                        BeginScaleformMovieMethod(scaleform, "SET_LIVES")
                        ScaleformMovieMethodAddParamInt(lives)
                        ScaleformMovieMethodAddParamInt(5)
                        EndScaleformMovieMethod()

                        BeginScaleformMovieMethod(scaleform, "OPEN_APP")
                        ScaleformMovieMethodAddParamFloat(1.0)
                        EndScaleformMovieMethod()

                        BeginScaleformMovieMethod(scaleform, "SET_ROULETTE_WORD")
                        ScaleformMovieMethodAddParamTextureNameString(
                            Config.RouletteWords[math.random(1, #Config.RouletteWords)])
                        EndScaleformMovieMethod()
                        exports.notify:display({
                            type = "info",
                            title = "Notebook",
                            text = "Najdi správné heslo!",
                            icon = "fas fa-times",
                            length = 2000
                        })
                        inMinigame = true
                    else
                        exports.notify:display({
                            type = "warning",
                            title = "Notebook",
                            text = "Nejdřív zabezpeči spojení!",
                            icon = "fas fa-times",
                            length = 2000
                        })
                    end
                elseif inMinigame and clickReturn == 87 then
                    lives = lives - 1

                    if lives ~= 0 then
                        PlaySoundFrontend(-1, "HACKING_CLICK_BAD", "", false)
                        BeginScaleformMovieMethod(scaleform, "SET_LIVES")
                        ScaleformMovieMethodAddParamInt(lives)
                        ScaleformMovieMethodAddParamInt(5)
                        EndScaleformMovieMethod()
                    else
                        PlaySoundFrontend(-1, "HACKING_FAILURE", "", true)
                        BeginScaleformMovieMethod(scaleform, "CLOSE_APP")
                        EndScaleformMovieMethod()
                        exports.notify:display({
                            type = "error",
                            title = "Notebook",
                            text = "Zkus to znovu a lépe!",
                            icon = "fas fa-times",
                            length = 2000
                        })
                        inMinigame = false
                    end
                elseif clickReturn == 6 then
                    exports.notify:display({
                        type = "info",
                        title = "Notebook",
                        text = "Přestal jsi hackovat!",
                        icon = "fas fa-times",
                        length = 2000
                    })
                    SetScaleformMovieAsNoLongerNeeded(scaleform)
                    DisableControlAction(0, 24, false)
                    DisableControlAction(0, 25, false)
                    local inMinigame, ipFinded, lives, clickReturn = false, false, 5, 0
                    return "exited"
                elseif inMinigame and clickReturn == 86 then
                    PlaySoundFrontend(-1, "HACKING_SUCCESS", 0, true)
                    SetScaleformMovieAsNoLongerNeeded(scaleform)
                    DisableControlAction(0, 24, false)
                    DisableControlAction(0, 25, false)
                    exports.notify:display({
                        type = "success",
                        title = "Notebook",
                        text = "Dobrá práce!",
                        icon = "fas fa-times",
                        length = 2000
                    })
                    local inMinigame, ipFinded, lives, clickReturn = false, false, 5, 0
                    return "successfull"
                end
            end
        end
    end
end

function InitializeScaleform(data)
    local scaleform = nil
    while not HasScaleformMovieLoaded(scaleform) do
        if data.Scaleform == "DATA_CRACK" then
            scaleform = RequestScaleformMovieInteractive("HACKING_PC")
        else
            scaleform = RequestScaleformMovieInteractive(data.Scaleform)
        end
        Citizen.Wait(0)
    end

    if data.Scaleform == "HACKING_PC" then
        local texts = 0

        while HasAdditionalTextLoaded(texts) and not HasThisAdditionalTextLoaded("hack", texts) do
            Citizen.Wait(0)
            texts = texts + 1
        end

        while not HasThisAdditionalTextLoaded("hack", texts) do
            ClearAdditionalText(texts, true)
            RequestAdditionalText("hack", texts)
            Citizen.Wait(0)
        end
        BeginScaleformMovieMethod(scaleform, "SET_LABELS")
        addScaleformAsset("H_ICON_1")
        addScaleformAsset("H_ICON_2")
        addScaleformAsset("H_ICON_3")
        addScaleformAsset("H_ICON_4")
        addScaleformAsset("H_ICON_5")
        addScaleformAsset("H_ICON_6")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND")
        ScaleformMovieMethodAddParamInt(data.Background)
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, "ADD_PROGRAM")
        ScaleformMovieMethodAddParamFloat(1.0)
        ScaleformMovieMethodAddParamFloat(4.0)
        ScaleformMovieMethodAddParamTextureNameString("My Computer")
        EndScaleformMovieMethod()

        if data.PowerOff then
            BeginScaleformMovieMethod(scaleform, "ADD_PROGRAM")
            ScaleformMovieMethodAddParamFloat(6.0)
            ScaleformMovieMethodAddParamFloat(6.0)
            ScaleformMovieMethodAddParamTextureNameString("Power Off")
            EndScaleformMovieMethod()
        end

        BeginScaleformMovieMethod(scaleform, "SET_LIVES")
        ScaleformMovieMethodAddParamInt(lives)
        ScaleformMovieMethodAddParamInt(5)
        EndScaleformMovieMethod()

        local index = 0
        repeat
            BeginScaleformMovieMethod(scaleform, "SET_COLUMN_SPEED")
            ScaleformMovieMethodAddParamInt(index)
            ScaleformMovieMethodAddParamInt(math.random(150, 300))
            index = index + 1
            EndScaleformMovieMethod()
        until index == 8
    elseif data.Scaleform == "DATA_CRACK" then
        while not HasStreamedTextureDictLoaded("hackingNG") do
            RequestStreamedTextureDict("HACKING_PC_desktop_0", false)
            RequestStreamedTextureDict("hackingNG", false)
            Citizen.Wait(0)
        end

        BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND")
        PushScaleformMovieFunctionParameterInt(7)
        EndScaleformMovieMethod()
    end

    return scaleform
end

function addScaleformAsset(text)
    BeginTextCommandScaleformString(text)
    EndTextCommandScaleformString()
end

function disableControls()
    -- Movement
    DisableControlAction(0, 32, true)
    DisableControlAction(0, 34, true)
    DisableControlAction(0, 31, true)
    DisableControlAction(0, 30, true)
    DisableControlAction(0, 22, true)
    DisableControlAction(0, 44, true)
    -- Actions
    DisableControlAction(0, 45, true)
    DisableControlAction(0, 37, true)
    DisableControlAction(0, 23, true)
    -- UI
    DisableControlAction(0, 288, true)
    DisableControlAction(0, 289, true)
    DisableControlAction(0, 170, true)
    DisableControlAction(0, 166, true)
    DisableControlAction(0, 167, true)
    DisableControlAction(0, 168, true)
    DisableControlAction(2, 199, true)
    DisableControlAction(0, 200, true)
    -- Attacks
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)
    DisableControlAction(0, 143, true)
    DisableControlAction(0, 257, true)
    DisableControlAction(0, 263, true)
    DisableControlAction(0, 264, true)
end

function rightPosition(arg1)
    if (Blocks[arg1].currentValue >= 0.51) and (Blocks[arg1].currentValue <= 0.62) then
        return true
    end
    return false
end
function changeValue(currentValue)
    local calculate = Cos(currentValue * 3.14 * 57.29)
    local calculate2 = (1.0 - calculate) * 0.5
    local calculate3 = 0.744 * (1 - calculate2)
    local calculate4 = 0.4 * calculate2 + calculate3
    return calculate4
end
function DATA_CRACK(data)
    local current = 1
    local scaleform = InitializeScaleform(data)
    Blocks = {{
        Used = false,
        startingValue = (0.02 * 0.55),
        currentValue2 = 0,
        val1 = 1,
        canChangeValue = true,
        currentValue = 0.4,
        pos = 0.35
    }, {
        Used = false,
        startingValue = (0.025 * 0.55),
        currentValue2 = 0,
        val1 = 1,
        canChangeValue = true,
        currentValue = 0.4,
        pos = 0.4
    }, {
        Used = false,
        startingValue = (0.03 * 0.55),
        currentValue2 = 0,
        val1 = 1,
        canChangeValue = true,
        currentValue = 0.4,
        pos = 0.45
    }, {
        Used = false,
        startingValue = (0.035 * 0.55),
        currentValue2 = 0,
        val1 = 1,
        canChangeValue = true,
        currentValue = 0.4,
        pos = 0.5
    }, {
        Used = false,
        startingValue = (0.04 * 0.55),
        currentValue2 = 0,
        val1 = 1,
        canChangeValue = true,
        currentValue = 0.4,
        pos = 0.55
    }, {
        Used = false,
        startingValue = (0.045 * 0.55),
        currentValue2 = 0,
        val1 = 1,
        canChangeValue = true,
        currentValue = 0.4,
        pos = 0.6
    }, {
        Used = false,
        startingValue = (0.05 * 0.55),
        currentValue2 = 0,
        val1 = 1,
        canChangeValue = true,
        currentValue = 0.4,
        pos = 0.65
    }}
    Blocks[current].Used = true
    while true do
        disableControls()
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        DrawSprite("hackingNG", "DHMain", 0.50, 0.50, 0.731, 1.306, 0, 255, 255, 255, 255, 0)
        for i = 1, #Blocks, 1 do
            if Blocks[i].val1 == 1 then
                if Blocks[i].currentValue2 < 1.0 then
                    Blocks[i].currentValue2 = Blocks[i].currentValue2 +
                                                  ((Blocks[i].startingValue * Timestep()) * (data.Speed * 10.0))
                else
                    Blocks[i].val1 = 0
                end
            elseif Blocks[i].currentValue2 > 0.0 then
                Blocks[i].currentValue2 = Blocks[i].currentValue2 -
                                              ((Blocks[i].startingValue * Timestep()) * (data.Speed * 10.0))
            else
                Blocks[i].val1 = 1
            end
            if Blocks[i].Used or Blocks[i].canChangeValue then
                Blocks[i].currentValue = changeValue(Blocks[i].currentValue2)
            end
            if not Blocks[i].Used then
                DrawSprite("hackingNG", "DHComp", Blocks[i].pos, Blocks[i].currentValue, 0.4, 0.4, 0, 255, 255, 255,
                    255, 0)
            else
                DrawSprite("hackingNG", "DHCompHi", Blocks[i].pos, Blocks[i].currentValue, 0.4, 0.4, 0, 255, 255, 255,
                    255, 0)
            end
        end
        if IsDisabledControlJustReleased(0, 24) then
            if rightPosition(current) then
                PlaySoundFrontend(-1, "Pin_Good", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
                Blocks[current].Used = false
                Blocks[current].canChangeValue = false
                Blocks[current].currentValue = 0.572
                if current < 7 then
                    Blocks[current + 1].Used = true
                end
                current = current + 1
                if current > 7 then
                    PlaySoundFrontend(-1, "HACKING_SUCCESS", "", true)
                    exports.notify:display({
                        type = "success",
                        title = "DATA CRACK",
                        text = "Dobrá práce!",
                        icon = "fas fa-times",
                        length = 2000
                    })
                    return "successfull"
                end
            else
                if data.PoliceReportChange ~= nil then
                    reportPolice(data)
                end
                PlaySoundFrontend(-1, "Pin_Bad", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
                exports.notify:display({
                    type = "error",
                    title = "DATA CRACK",
                    text = "Zkus to lépe",
                    icon = "fas fa-times",
                    length = 2000
                })
                if current > 1 then
                    Blocks[current].Used = false
                    current = current - 1
                    Blocks[current].Used = true
                    Blocks[current].currentValue = 0.572
                    Blocks[current].canChangeValue = true
                end
            end
        elseif IsDisabledControlJustReleased(0, 25) then
            exports.notify:display({
                type = "info",
                title = "DATA CRACK",
                text = "Přestal jsi hackovat!",
                icon = "fas fa-times",
                length = 2000
            })
            return "exited"
        end
        Citizen.Wait(1)
    end
end
function reportPolice(data)
    local reportChange = math.random(1, 100)
    if reportChange <= data.PoliceReportChange then
        if data.Jewelry then
            TriggerServerEvent("jewelry:alarm")
        elseif data.Powerplant then
            TriggerServerEvent("powerplant:alarm")
        elseif data.Fleeca then
        elseif data.Pacific then
            TriggerServerEvent("rob_pacificbank:alarm")
        end
    end
end
