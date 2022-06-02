-- 3D HINT
local displayingHints = {}

function displayHint(data)
    displayingHints[data.name] = {
        key = data.key,
        text = data.text,
        coords = data.coords
    }
end

function hideHint(data)
    displayingHints[data.name] = nil
end

Citizen.CreateThread(function()
    while true do
        for name, data in pairs(displayingHints) do
            local textEntryName = "key_hint_" .. name

            AddTextEntry(textEntryName, data.key .. " <FONT FACE='AMSANSL'>" .. data.text)
            BeginTextCommandDisplayHelp(textEntryName)
            EndTextCommandDisplayHelp(2, false, false, 1)

            SetFloatingHelpTextWorldPosition(1, data.coords)
            SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
        end

        Citizen.Wait(0)
    end
end)

-- BOTTOM INSTRUCTIONAL HINTS
local displayingBottomHints = {}
local form = nil

function displayBottomHint(data)
    local found = false
    for i, hintData in each(displayingBottomHints) do
        if data.name == hintData.name then
            displayingBottomHints[i] = {
                name = data.name,
                key = data.key,
                keys = data.keys,
                text = data.text,
            }
            found = true
            break
        end
    end

    if not found then
        table.insert(displayingBottomHints, {
            name = data.name,
            key = data.key,
            keys = data.keys,
            text = data.text,
        })
    end
    SetScaleformMovieAsNoLongerNeeded(form)
    form = setupScaleform("instructional_buttons")
end

function hideBottomHint(data)
    for i, hintData in each(displayingBottomHints) do
        if data.name == hintData.name then
            table.remove(displayingBottomHints, i)
            break
        end
    end

    SetScaleformMovieAsNoLongerNeeded(form)
    form = setupScaleform("instructional_buttons")
end

function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    local index = 0
    for _, data in each(displayingBottomHints) do
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(index)
        if data.key then
            Button(data.key)
        elseif data.keys then
            for i, key in each(data.keys) do
                Button(GetControlInstructionalButton(2, key, true))
            end
        end
        ButtonMessage(data.text)
        PopScaleformMovieFunctionVoid()

        index = index + 1
    end

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(109)
    PushScaleformMovieFunctionParameterInt(80)
    PushScaleformMovieFunctionParameterInt(160)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    ScaleformMovieMethodAddParamPlayerNameString(ControlButton)
end

Citizen.CreateThread(function()
    form = setupScaleform("instructional_buttons")
    while true do
        Citizen.Wait(0)

        if next(displayingBottomHints) ~= nil then
            DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local wasActive = false

        while IsPauseMenuActive() do
            Citizen.Wait(50)
            wasActive = true
        end

        if wasActive then
            SetScaleformMovieAsNoLongerNeeded(form)
            form = setupScaleform("instructional_buttons")
        end
    end
end)
