RegisterNetEvent('qb-phone:client:UpdateMessages')
AddEventHandler('qb-phone:client:UpdateMessages', function(ChatMessages, SenderNumber)
    local New = false
    local Sender = IsNumberInContacts(SenderNumber)
    local NumberKey = GetKeyByNumber(SenderNumber)

    if NumberKey == nil then
        NumberKey = (#PhoneData.Chats + 1)
        New = true
    end

    if New then
        PhoneData.Chats[NumberKey] = {
            name = Sender,
            number = SenderNumber,
            messages = ChatMessages.messages,
            Unread = ChatMessages.Unread
        }

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.MetaData.simActive.primary.telNumber and SenderNumber ~= PhoneData.MetaData.simActive.secondary.telNumber then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Whatsapp",
                        text = "New message from "..Sender.."!",
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Whatsapp",
                        text = "Why are you sending messages to yourself you sadfuck?",
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 4000,
                    },
                })
                PhoneData.Chats[NumberKey].Unread = 0
                ChatMessages.Unread = 0
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Wait(100)
            SendNUIMessage({
                action = "UpdateChat",
                chatData = PhoneData.Chats[GetKeyByNumber(SenderNumber)],
                chatNumber = SenderNumber,
                Chats = PhoneData.Chats,
            })
            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + ChatMessages.Unread
            TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "whatsapp")
        else
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Whatsapp",
                    text = "New message from "..Sender.."!",
                    icon = "fab fa-whatsapp",
                    color = "#25D366",
                    timeout = 3500,
                },
            })
            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + ChatMessages.Unread
            TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "whatsapp")
        end
    else
        PhoneData.Chats[NumberKey].messages = ChatMessages.messages
        PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + ChatMessages.Unread

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.MetaData.simActive.primary.telNumber and SenderNumber ~= PhoneData.MetaData.simActive.secondary.telNumber then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Whatsapp",
                        text = "New message from "..Sender.."!",
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Whatsapp",
                        text = "Why are you sending messages to yourself you sadfuck?",
                        icon = "fab fa-whatsapp",
                        color = "#25D366",
                        timeout = 4000,
                    },
                })
                PhoneData.Chats[NumberKey].Unread = 0
                ChatMessages.Unread = 0
            end

            NumberKey = GetKeyByNumber(SenderNumber) or SenderNumber
            ReorganizeChats(NumberKey)

            Wait(100)
            SendNUIMessage({
                action = "UpdateChat",
                chatData = PhoneData.Chats[GetKeyByNumber(SenderNumber)],
                chatNumber = SenderNumber,
                Chats = PhoneData.Chats,
            })
        else
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Whatsapp",
                    text = "New message from "..Sender.."!",
                    icon = "fab fa-whatsapp",
                    color = "#25D366",
                    timeout = 3500,
                },
            })

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + ChatMessages.Unread
            TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "whatsapp")
        end
    end
end)


RegisterNUICallback('SendMessage', function(data, cb)
    if PhoneData.MetaData.simActive.primary.active then
        local ChatMessage = data.ChatMessage
        local ChatDate = data.ChatDate
        local ChatNumber = data.ChatNumber
        local ChatTime = data.ChatTime
        local ChatType = data.ChatType

        local Ped = PlayerPedId()
        local Pos = GetEntityCoords(Ped)
        local NumberKey = GetKeyByNumber(ChatNumber)
        local ChatKey = GetKeyByDate(NumberKey, ChatDate)
        if PhoneData.Chats[NumberKey] ~= nil then
            if(PhoneData.Chats[NumberKey].messages == nil) then
                PhoneData.Chats[NumberKey].messages = {}
            end
            if PhoneData.Chats[NumberKey].messages[ChatKey] ~= nil then
                if ChatType == "message" then
                    table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                        message = ChatMessage,
                        time = ChatTime,
                        sender = PhoneData.MetaData.simActive.primary.telNumber,
                        type = ChatType,
                        data = {},
                    })
                elseif ChatType == "location" then
                    table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                        message = "Shared Location",
                        time = ChatTime,
                        sender = PhoneData.MetaData.simActive.primary.telNumber,
                        type = ChatType,
                        data = {
                            x = Pos.x,
                            y = Pos.y,
                        },
                    })
                end
                TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey], ChatNumber, false)
                NumberKey = GetKeyByNumber(ChatNumber)
                ReorganizeChats(NumberKey)
            else
                table.insert(PhoneData.Chats[NumberKey].messages, {
                    date = ChatDate,
                    messages = {},
                })
                ChatKey = GetKeyByDate(NumberKey, ChatDate)
                if ChatType == "message" then
                    table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                        message = ChatMessage,
                        time = ChatTime,
                        sender = PhoneData.MetaData.simActive.primary.telNumber,
                        type = ChatType,
                        data = {},
                    })
                elseif ChatType == "location" then
                    table.insert(PhoneData.Chats[NumberKey].messages[ChatDate].messages, {
                        message = "Shared Location",
                        time = ChatTime,
                        sender = PhoneData.MetaData.simActive.primary.telNumber,
                        type = ChatType,
                        data = {
                            x = Pos.x,
                            y = Pos.y,
                        },
                    })
                end
                TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey], ChatNumber, true)
                NumberKey = GetKeyByNumber(ChatNumber)
                ReorganizeChats(NumberKey)
            end
        else
            table.insert(PhoneData.Chats, {
                name = IsNumberInContacts(ChatNumber),
                number = ChatNumber,
                messages = {},
            })
            NumberKey = GetKeyByNumber(ChatNumber)
            table.insert(PhoneData.Chats[NumberKey].messages, {
                date = ChatDate,
                messages = {},
            })
            ChatKey = GetKeyByDate(NumberKey, ChatDate)
            if ChatType == "message" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.MetaData.simActive.primary.telNumber,
                    type = ChatType,
                    data = {},
                })
            elseif ChatType == "location" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = "Shared Location",
                    time = ChatTime,
                    sender = PhoneData.MetaData.simActive.primary.telNumber,
                    type = ChatType,
                    data = {
                        x = Pos.x,
                        y = Pos.y,
                    },
                })
            end
            TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey], ChatNumber, true)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        end
        SendNUIMessage({
            action = "UpdateChat",
            chatData = PhoneData.Chats[GetKeyByNumber(ChatNumber)],
            chatNumber = ChatNumber,
        })
    else
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Simcard",
                text = "No signal!",
                icon = "fab fa-cog",
                color = "#25D366",
                timeout = 1500,
            },
        })
    end
    if Config.Debug then
        --Utils.DumpTable(PhoneData.Chats)
    end
end)

RegisterNUICallback('SharedLocation', function(data)
    local x = data.coords.x
    local y = data.coords.y
    SetNewWaypoint(x, y)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Whatsapp",
            text = "Location has been set!",
            icon = "fab fa-whatsapp",
            color = "#25D366",
            timeout = 1500,
        },
    })
end)

RegisterNUICallback('GetWhatsappChats', function(data, cb)
    if PhoneData.MetaData.simActive.primary.active then
        if Config.Debug then
            --Utils.DumpTable(PhoneData.Chats)
        end
        cb(PhoneData.Chats)
    else
        cb({})
        exports.notify:display({type = "error", title = "Phone", text = "Nemáš tam simku debyle!", icon = "fas fa-times", length = 5000})
    end
end)

RegisterNUICallback('GetProfilePicture', function(data, cb)
    local number = data.number
    if PhoneData.Contacts[number] then
        cb(PhoneData.Contacts[number].profilepicture)
    else
        cb("default")
    end
end)

RegisterNUICallback('GetBankContacts', function(data, cb)
    cb(PhoneData.Contacts)
end)

RegisterNUICallback('GetWhatsappChat', function(data, cb)
    local key = GetKeyByNumber(data.phone)
    if key then
        if PhoneData.Chats[key] ~= nil and isLoggedIn then
            cb(PhoneData.Chats[key])
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

RegisterNUICallback('UpdateProfilePicture', function(data)
    local pf = data.profilepicture

    PhoneData.MetaData.settings.profilepicture = pf

    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData.id, PhoneData.MetaData.settings)
end)

RegisterNUICallback('ClearAlerts', function(data, cb)
    local chat = data.number
    local ChatKey = GetKeyByNumber(chat)

    if PhoneData.Chats[ChatKey].Unread ~= nil and PhoneData.Chats[ChatKey].Unread ~= 0 then
        local newAlerts = (Config.PhoneApplications['whatsapp'].Alerts - PhoneData.Chats[ChatKey].Unread)
        Config.PhoneApplications['whatsapp'].Alerts = newAlerts
        TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "whatsapp", newAlerts, chat)

        PhoneData.Chats[ChatKey].Unread = 0

        SendNUIMessage({
            action = "RefreshWhatsappAlerts",
            Chats = PhoneData.Chats,
        })
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    else
        local newAlerts = 0
        Config.PhoneApplications['whatsapp'].Alerts = newAlerts
        TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "whatsapp", newAlerts, chat)

        PhoneData.Chats[ChatKey].Unread = 0

        SendNUIMessage({
            action = "RefreshWhatsappAlerts",
            Chats = PhoneData.Chats,
        })
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    end
end)