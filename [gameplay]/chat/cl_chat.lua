local isRDR = not TerraingridActivate and true or false

local chatInputActive = false
local chatInputActivating = false
local chatLoaded = false
local isSpawned = false
local meChat, doChat, docChat, chatCharName = true, true, false, true
RegisterNetEvent("chatMessage")
RegisterNetEvent("chat:addTemplate")
RegisterNetEvent("chat:addMessage")
RegisterNetEvent("chat:addSuggestion")
RegisterNetEvent("chat:addSuggestions")
RegisterNetEvent("chat:addMode")
RegisterNetEvent("chat:removeMode")
RegisterNetEvent("chat:removeSuggestion")
RegisterNetEvent("chat:clear")
RegisterNetEvent("settings:changed")

-- internal events
RegisterNetEvent("__cfx_internal:serverPrint")

RegisterNetEvent("chat:messageEntered")

--deprecated, use chat:addMessage
AddEventHandler(
    "chatMessage",
    function(author, color, text)
        if not isSpawned then
            return
        end

        local args = {text}
        if author ~= "" then
            table.insert(args, 1, author)
        end
        SendNUIMessage(
            {
                type = "ON_MESSAGE",
                message = {
                    color = color,
                    multiline = true,
                    args = args
                }
            }
        )
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false

            SendNUIMessage(
                {
                    type = "ON_CANCEL_CHAT"
                }
            )

            SendNUIMessage(
                {
                    type = "ON_SCREEN_STATE_CHANGE",
                    shouldHide = true
                }
            )
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
        end

        if status == "dead" then
            SendNUIMessage(
                {
                    type = "ON_CANCEL_CHAT"
                }
            )
        end
    end
)

function starts_with(str, start)
    return str:sub(1, #start) == start
end

AddEventHandler(
    "__cfx_internal:serverPrint",
    function(msg)
        local templateId = "print"
        if (starts_with(msg, "Chyba: ")) then
            templateId = "error"
            msg = string.sub(msg, 7)
        elseif (starts_with(msg, "Úspěch: ")) then
            templateId = "success"
            msg = string.sub(msg, 11)
        elseif (starts_with(msg, "Varování: ")) then
            templateId = "warning"
            msg = string.sub(msg, 10)
        end

        SendNUIMessage(
            {
                type = "ON_MESSAGE",
                message = {
                    templateId = templateId,
                    multiline = false,
                    args = {msg}
                }
            }
        )
    end
)

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

-- addMessage
local addMessage = function(message)
    if not isSpawned then
        return
    end

    if type(message) == "string" then
        message = {
            args = {message}
        }
    end

    if
        message ~= nil and message.args ~= nil and #message.args == 2 and type(message.args[1]) == "string" and
            message.args[1]:find("Broadcast", 1, true)
     then
        message = {
            templateId = "announcement",
            multiline = false,
            args = {string.sub(message.args[1], 13), message.args[2]}
        }
    end

    if message and (message.templateId == "ac" or message.templateId == "report" or message.templateId == "tr" or message.templateId == "report-done") then
        if exports.settings:getSettingValue("streamerMode") then
            return
        end
    end

    SendNUIMessage(
        {
            type = "ON_MESSAGE",
            message = message
        }
    )
end

exports("addMessage", addMessage)
AddEventHandler("chat:addMessage", addMessage)

-- addSuggestion
function addSuggestion(name, help, params)
    SendNUIMessage(
        {
            type = "ON_SUGGESTION_ADD",
            suggestion = {
                name = name,
                help = help,
                params = params or nil
            }
        }
    )
end

exports("addSuggestion", addSuggestion)
AddEventHandler("chat:addSuggestion", addSuggestion)

AddEventHandler(
    "chat:addSuggestions",
    function(suggestions)
        for _, suggestion in each(suggestions) do
            SendNUIMessage(
                {
                    type = "ON_SUGGESTION_ADD",
                    suggestion = suggestion
                }
            )
        end
    end
)

AddEventHandler(
    "chat:removeSuggestion",
    function(name)
        SendNUIMessage(
            {
                type = "ON_SUGGESTION_REMOVE",
                name = name
            }
        )
    end
)

AddEventHandler(
    "chat:addMode",
    function(mode)
        SendNUIMessage(
            {
                type = "ON_MODE_ADD",
                mode = mode
            }
        )
    end
)

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "me" then
            meChat = value
        elseif setting == "do" then
            doChat = value
        elseif setting == "doc" then
            docChat = value
        elseif setting == "chatCharName" then
            chatCharName = value
        elseif setting == "chat" then
            applyChatState(value)
        end
    end
)

AddEventHandler(
    "chat:removeMode",
    function(name)
        SendNUIMessage(
            {
                type = "ON_MODE_REMOVE",
                name = name
            }
        )
    end
)

AddEventHandler(
    "chat:addTemplate",
    function(id, html)
        SendNUIMessage(
            {
                type = "ON_TEMPLATE_ADD",
                template = {
                    id = id,
                    html = html
                }
            }
        )
    end
)

AddEventHandler(
    "chat:clear",
    function(name)
        SendNUIMessage(
            {
                type = "ON_CLEAR"
            }
        )
    end
)

RegisterNUICallback(
    "chatResult",
    function(data, cb)
        chatInputActive = false
        SetNuiFocus(false)

        if not data.canceled then
            local id = PlayerId()

            --deprecated
            local r, g, b = 0, 0x99, 255

            if data.message:sub(1, 1) == "/" then
                ExecuteCommand(data.message:sub(2))
            else
                TriggerServerEvent("chat:messageEntered", GetPlayerName(id), {r, g, b}, data.message, data.mode)
            end
        end

        cb("ok")
    end
)

local function refreshCommands()
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in each(registeredCommands) do
            if IsAceAllowed(("command.%s"):format(command.name)) and command.name ~= "toggleChat" then
                table.insert(
                    suggestions,
                    {
                        name = "/" .. command.name,
                        help = ""
                    }
                )
            end
        end

        TriggerEvent("chat:addSuggestions", suggestions)
    end
end

local function refreshThemes()
    local themes = {}

    for resIdx = 0, GetNumResources() - 1 do
        local resource = GetResourceByFindIndex(resIdx)

        if GetResourceState(resource) == "started" then
            local numThemes = GetNumResourceMetadata(resource, "chat_theme")

            if numThemes > 0 then
                local themeName = GetResourceMetadata(resource, "chat_theme")
                local themeData = json.decode(GetResourceMetadata(resource, "chat_theme_extra") or "null")

                if themeName and themeData then
                    themeData.baseUrl = "nui://" .. resource .. "/"
                    themes[themeName] = themeData
                end
            end
        end
    end

    SendNUIMessage(
        {
            type = "ON_UPDATE_THEMES",
            themes = themes
        }
    )
end

AddEventHandler(
    "onClientResourceStart",
    function(resName)
        Wait(500)

        refreshCommands()
        refreshThemes()
    end
)

AddEventHandler(
    "onClientResourceStop",
    function(resName)
        Wait(500)

        refreshCommands()
        refreshThemes()
    end
)

RegisterNUICallback(
    "loaded",
    function(data, cb)
        TriggerServerEvent("chat:init")

        refreshCommands()
        refreshThemes()

        chatLoaded = true

        cb("ok")
    end
)

local CHAT_HIDE_STATES = {
    ALWAYS_SHOW = 1,
    SHOW_WHEN_ACTIVE = 2,
    ALWAYS_HIDE = 3
}

local kvpEntry = GetResourceKvpString("hideState")
local chatHideState = kvpEntry and tonumber(kvpEntry) or CHAT_HIDE_STATES.SHOW_WHEN_ACTIVE
local isFirstHide = true

function applyChatState(state)
    if state == 1 then
        chatHideState = CHAT_HIDE_STATES.ALWAYS_SHOW
    elseif state == 2 then
        chatHideState = CHAT_HIDE_STATES.SHOW_WHEN_ACTIVE
    elseif state == 3 then
        chatHideState = CHAT_HIDE_STATES.ALWAYS_HIDE
    end

    isFirstHide = false
    SetResourceKvp("hideState", tostring(chatHideState))
end

RegisterNetEvent("chat:close")
AddEventHandler(
    "chat:close",
    function()
        SendNUIMessage(
            {
                type = "ON_CANCEL_CHAT"
            }
        )
    end
)

Citizen.CreateThread(
    function()
        SendNUIMessage(
            {
                type = "ON_SCREEN_STATE_CHANGE",
                shouldHide = true
            }
        )

        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end
        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true

            meChat, doChat, docChat, chatCharName, chatSettings =
                exports.settings:getSettingValue("me"),
                exports.settings:getSettingValue("do"),
                exports.settings:getSettingValue("doc"),
                exports.settings:getSettingValue("chatCharName"),
                exports.settings:getSettingValue("chat")

            if status == "dead" then
                SendNUIMessage(
                    {
                        type = "ON_CANCEL_CHAT"
                    }
                )
            end

            applyChatState(chatSettings)
        end

        Wait(500)
        addSuggestion("/id", "Vypíše tvoje ID", {})

        addSuggestion(
            "/me",
            "ME na vzdálenost 20",
            {
                {name = "text", help = "Text"}
            }
        )

        addSuggestion(
            "/mec",
            "ME na vzdálenost 5",
            {
                {name = "text", help = "Text"}
            }
        )

        addSuggestion(
            "/meh",
            "ME na vzdálenost 20, skryté (nevypíše se do chatu)",
            {
                {name = "text", help = "Text"}
            }
        )

        addSuggestion("/try", "Náhodné DO - Ano / Ne")

        addSuggestion(
            "/do",
            "DO na vzdálenost 20",
            {
                {name = "text", help = "Text"}
            }
        )

        addSuggestion(
            "/docl",
            "DO na vzdálenost 5",
            {
                {name = "text", help = "Text"}
            }
        )

        addSuggestion(
            "/doh",
            "DO na vzdálenost 20, skryté (nevypíše se do chatu)",
            {
                {name = "text", help = "Text"}
            }
        )

        addSuggestion(
            "/doc",
            "DOC odpočet",
            {
                {name = "hodnota", help = "Počet vteřin"}
            }
        )

        addSuggestion("/money", "Vypíše, kolik máš u sebe hotovosti")
        addSuggestion("/penize", "Vypíše, kolik máš u sebe hotovosti")
        addSuggestion("/hotovost", "Vypíše, kolik máš u sebe hotovosti")
        addSuggestion("/jobs", "Vypíše tvoje aktuální práce")
        addSuggestion("/prace", "Vypíše tvoje aktuální práce")
        addSuggestion("/clear", "Vymaže obsah chatu")

        addSuggestion(
            "/pol",
            "Policejní hlášení",
            {
                {name = "text", help = "Text hlášení"}
            }
        )

        addSuggestion(
            "/ooc",
            "Odešle zprávu do globálního OOC chatu",
            {
                {name = "text", help = "Text zprávy"}
            }
        )

        addSuggestion(
            "/announce",
            "A-Team oznámení",
            {
                {name = "text", help = "Text zprávy"}
            }
        )

        addSuggestion("/tag", "A-Team tag v chatu")
    end
)

RegisterCommand(
    "clear",
    function(source, args)
        TriggerEvent("chat:clear")
    end
)

Citizen.CreateThread(
    function()
        SetTextChatEnabled(false)
        SetNuiFocus(false)

        local lastChatHideState = -1
        local origChatHideState = -1

        while true do
            Wait(0)

            if not chatInputActive then
                if IsControlPressed(0, 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
                    chatInputActive = true
                    chatInputActivating = true

                    SendNUIMessage(
                        {
                            type = "ON_OPEN"
                        }
                    )
                end
            end

            if chatInputActivating then
                if not IsControlPressed(0, 245) then
                    SetNuiFocus(true)

                    chatInputActivating = false
                end
            end

            if chatLoaded and isSpawned then
                local forceHide = IsScreenFadedOut() or IsPauseMenuActive()
                local wasForceHide = false

                if chatHideState ~= CHAT_HIDE_STATES.ALWAYS_HIDE then
                    if forceHide then
                        origChatHideState = chatHideState
                        chatHideState = CHAT_HIDE_STATES.ALWAYS_HIDE
                    end
                elseif not forceHide and origChatHideState ~= -1 then
                    chatHideState = origChatHideState
                    origChatHideState = -1
                    wasForceHide = true
                end

                if chatHideState ~= lastChatHideState then
                    lastChatHideState = chatHideState

                    SendNUIMessage(
                        {
                            type = "ON_SCREEN_STATE_CHANGE",
                            hideState = chatHideState,
                            fromUserInteraction = false
                        }
                    )

                    isFirstHide = false
                end
            end
        end
    end
)

-- ME, DO, DOC
local time = 10000

local displayingCount = {}
local last = 0
local newMessage = {}
local isMe = {}

local font = RegisterFontId("AMSANSL")

function trim(s)
    return s:match "^%s*(.-)%s*$"
end

function getIndexPosition()
    last = last + 1
    if last > 5 then
        last = 1
    end

    return last
end

RegisterCommand(
    "clear",
    function(source, args)
        TriggerEvent("chat:clear")
    end
)

RegisterNetEvent("chat:triggerDisplay")
AddEventHandler(
    "chat:triggerDisplay",
    function(text, source, type, shouldBeHidden, charName)
        if not isSpawned then
            return
        end

        local mePlayer = GetPlayerFromServerId(source)

        isMe[mePlayer] = true
        if type == "me" then
            isMe[mePlayer] = false
        end

        local index = getIndexPosition()
        local offset = 1 + (index * 0.14)

        if type == "me" then
            if meChat and not shouldBeHidden then
                local chatText = text
                if chatCharName and charName then
                    chatText = charName .. ": " .. chatText
                end

                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "me",
                        args = {chatText}
                    }
                )
            end
        else
            if doChat and not shouldBeHidden then
                local chatText = text
                if chatCharName and charName then
                    chatText = charName .. ": " .. chatText
                end

                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = type,
                        args = {chatText}
                    }
                )
            end
        end

        if charName ~= nil then
            newMessage[mePlayer] = true
            Display(mePlayer, text, offset, index)
        end
    end
)

function Display(mePlayer, text, offset, index)
    Citizen.CreateThread(
        function()
            Citizen.Wait(5)
            local timeLeft = time + 0.1 * utf8.len(text)
            newMessage[mePlayer] = false

            if isMe[mePlayer] then
                text = "* " .. text .. " *"
            end

            while timeLeft > 0 do
                local coordsMe = GetWorldPositionOfEntityBone(GetPlayerPed(mePlayer), 1)

                DrawText3D(coordsMe["x"], coordsMe["y"], coordsMe["z"] + 0.95, text)
                timeLeft = timeLeft - 25

                Citizen.Wait(1)

                if newMessage[mePlayer] ~= nil and newMessage[mePlayer] then
                    timeLeft = 0
                end
            end
        end
    )
end

function DrawText3D(x, y, z, text)
    local usez = z
    local onScreen, _x, _y = World3dToScreen2d(x, y, usez)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    textscale = (textscale == nil and 0.25 or textscale)
    SetTextScale(textscale, textscale)
    SetTextProportional(0.95)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextFont(font)
    SetTextOutline(1)
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = (utf8.len(text)) / 250
    DrawRect(_x, _y + 0.0140, 0.030 + factor, 0.030, 66, 66, 66, 50)
end

RegisterNetEvent("chat:doc")
AddEventHandler(
    "chat:doc",
    function(count, target, shouldBeHidden)
        if not isSpawned then
            return
        end

        local targetPlayer = GetPlayerFromServerId(target)
        if not displayingCount[target] then
            displayingCount[target] = 0
        end

        displayingCount[target] = displayingCount[target] + 1
        local currentCount = 0

        Citizen.CreateThread(
            function()
                local myId = displayingCount[target]

                while currentCount < count do
                    if displayingCount[target] == 0 or displayingCount[target] ~= myId then
                        break
                    end

                    currentCount = currentCount + 1

                    if docChat and not shouldBeHidden then
                        TriggerEvent(
                            "chat:addMessage",
                            {
                                templateId = "doc",
                                args = {currentCount, count}
                            }
                        )
                    end
                    Citizen.Wait(2000)
                end

                displayingCount[target] = 0
            end
        )

        Citizen.CreateThread(
            function()
                local myId = displayingCount[target]

                while displayingCount[target] ~= 0 and displayingCount[target] == myId do
                    Wait(1)

                    if lastDocId ~= docId then
                        break
                    end

                    local coordsMe = GetWorldPositionOfEntityBone(GetPlayerPed(targetPlayer), 1)
                    DrawText3D(coordsMe["x"], coordsMe["y"], coordsMe["z"], currentCount .. " / " .. count)
                end
            end
        )
    end
)

RegisterCommand(
    "money",
    function(source, args)
        printMoney()
    end
)

RegisterCommand(
    "hotovost",
    function(source, args)
        printMoney()
    end
)

RegisterCommand(
    "penize",
    function(source, args)
        printMoney()
    end
)

function printMoney()
    local money = exports.inventory:getCurrentCash()

    TriggerEvent(
        "chat:addMessage",
        {
            template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(0, 191, 255, 0.75); border-left: 10px solid rgb(0, 191, 255);"><strong>Hotovost:</strong> ${0}</div>',
            args = {money}
        }
    )
end
