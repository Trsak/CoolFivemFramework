RegisterNetEvent('qb-phone:client:BillingEmail')
AddEventHandler('qb-phone:client:BillingEmail', function(data, paid, name)
    if paid then
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = 'Billing Department',
            subject = 'Invoice Paid',
            message = 'Invoice Has Been Paid From '..name..' In The Amount Of $'..data.amount,
        })
    else
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = 'Billing Department',
            subject = 'Invoice Declined',
            message = 'Invoice Has Been Declined From '..name..' In The Amount Of $'..data.amount,
        })
    end
end)

RegisterNetEvent('qb-phone:client:UpdateAdverts')
AddEventHandler('qb-phone:client:UpdateAdverts', function(Advert)
    if Advert then
        table.insert(PhoneData.Adverts, Advert)
        if PhoneData.MetaData.internet and PhoneData.MetaData.settings.twitter.account.logged then
            --if PhoneData.isOpen then
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Advertisement",
                    text = "A new ad has been posted by "..Advert.name,
                    icon = "fas fa-ad",
                    color = "#ff8f1a",
                    timeout = 2500,
                },
            })
            --[[else
                SendNUIMessage({
                    action = "Notification",
                    NotifyData = {
                        title = "Advertisement",
                        content = "A new ad has been posted by "..LastAd,
                        icon = "fas fa-ad",
                        timeout = 2500,
                        color = "#ff8f1a",
                    },
                })
            end]]
        end

        SendNUIMessage({
            action = "RefreshAdverts",
            Adverts = PhoneData.Adverts
        })
    end
end)

RegisterNetEvent('qb-phone:client:NewMailNotify')
AddEventHandler('qb-phone:client:NewMailNotify', function(MailData)
    if PhoneData.MetaData.internet and PhoneData.MetaData.settings.twitter.account.logged then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Mail",
                text = "You received a new mail from "..MailData.sender,
                icon = "fas fa-envelope",
                color = "#ff002f",
                timeout = 1500,
            },
        })
    end
    Config.PhoneApplications['mail'].Alerts = Config.PhoneApplications['mail'].Alerts + 1
    TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "mail")
    table.insert(PhoneData.Mails, MailData)
    SendNUIMessage({
        action = "UpdateMails",
        Mails = PhoneData.Mails
    })
end)

RegisterNetEvent('qb-phone:client:UpdateMails')
AddEventHandler('qb-phone:client:UpdateMails', function(NewMail)
    table.insert(PhoneData.Mails, NewMail)
    SendNUIMessage({
        action = "UpdateMails",
        Mails = PhoneData.Mails
    })
end)

RegisterNetEvent('qb-phone:client:RefreshMail')
AddEventHandler('qb-phone:client:RefreshMail', function(NewMailID)
    local key = GetMail(NewMailID)
    if key then
        PhoneData.Mails[key].read = true
        SendNUIMessage({
            action = "UpdateMails",
            Mails = PhoneData.Mails
        })
    end
end)

RegisterNUICallback('SendNewMail', function(data, cb)
    local userData = {
        ip = PhoneData.MetaData.ip,
        location = getLocation(),
        player = exports.data:getCharVar('id'),
        phone = PhoneData.MetaData.id
    }
    TriggerServerEvent('qb-phone:server:sendNewMail', data, userData)
    cb(true)
end)

RegisterNUICallback('GetMails', function(data, cb)
    cb(PhoneData.Mails)
end)

RegisterNUICallback('AcceptMailButton', function(data)
    if data.buttonEvent ~= nil or data.buttonData ~= nil then
        TriggerEvent(data.buttonEvent, data.buttonData) --NEED TO SANITIZE THIS ON THE JS PART, WE ARE RECEIVING AN ACTUALL EVENT WITH PARAMETERS HERE!!!!
    end
    TriggerServerEvent('qb-phone:server:ClearButtonData', data.mailId)
end)

RegisterNUICallback('RemoveMail', function(data, cb)
    local Id = tonumber(data.Id)
    local key = GetMail(Id)
    local reformed = {}
    if key then
        if data.sender then
            PhoneData.Mails[key].sender_deleted = true
        else
            PhoneData.Mails[key].reciever_deleted = true
        end

        for k, v in each(PhoneData.Mails) do
            local static = PhoneData.MetaData.settings.email.account.name == v.sender
            if static and not v.sender_deleted then
                table.insert(reformed, v)
            elseif not static and not v.reciever_deleted then
                table.insert(reformed, v)
            end
        end

        PhoneData.Mails = reformed

        TriggerServerEvent('qb-phone:server:RemoveMail', Id, data.sender)
        SendNUIMessage({
            action = "UpdateMails",
            Mails = PhoneData.Mails
        })
        cb('ok')
    end
end)

RegisterNUICallback('ReadMail', function(data, cb)
    local Id = tonumber(data.Id)
    local key = GetMail(Id)
    if key then
        PhoneData.Mails[key].read = true
        TriggerServerEvent('qb-phone:server:ReadMail', Id)
        SendNUIMessage({
            action = "UpdateMails",
            Mails = PhoneData.Mails
        })
        if Config.PhoneApplications['mail'].Alerts ~= 0 then
            Config.PhoneApplications['mail'].Alerts = Config.PhoneApplications['mail'].Alerts - 1
            TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "mail", Config.PhoneApplications['mail'].Alerts)
        end
        cb('ok')
    end
end)

RegisterNUICallback('SignOutMail', function()
    local userData = {
        ip = PhoneData.MetaData.ip,
        location = getLocation(),
        player = exports.data:getCharVar('id'),
        phone = PhoneData.MetaData.id
    }
    SendNUIMessage({
        action = "UpdateMails",
        Mails = PhoneData.Mails
    })
    TriggerServerEvent('qb-phone:server:SignOutMail', PhoneData.MetaData.settings.email.account, userData)
    Config.PhoneApplications['mail'].Alerts = 0
    TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "mail", Config.PhoneApplications['mail'].Alerts)
end)

RegisterNUICallback('LogInMail', function(data, cb)
    local userData = {
        ip = PhoneData.MetaData.ip,
        location = getLocation(),
        player = exports.data:getCharVar('id'),
        phone = PhoneData.MetaData.id
    }
    TriggerServerEvent('qb-phone:server:LogInMail', data, userData)
    RegisterNetEvent("qb-phone:client:LogInMail")
    AddEventHandler("qb-phone:client:LogInMail", function(status, error)
        cb({ status, error })
        SendNUIMessage({
            action = "UpdateMails",
            Mails = PhoneData.Mails
        })
    end)
end)

RegisterNUICallback('CreateMail', function(data, cb)
    local userData = {
        ip = PhoneData.MetaData.ip,
        location = getLocation()
    }
    TriggerServerEvent('qb-phone:server:CreateMail', data, userData)
    RegisterNetEvent("qb-phone:client:CreateMail")
    AddEventHandler("qb-phone:client:CreateMail", function(status)
        if status then
            SendNUIMessage({
                action = "UpdateMails",
                Mails = PhoneData.Mails
            })
        end
        cb(status)
    end)
end)

RegisterNUICallback('LoadAdverts', function()
    SendNUIMessage({
        action = "RefreshAdverts",
        Adverts = PhoneData.Adverts
    })
end)

RegisterNUICallback('PostAdvert', function(data)
    TriggerServerEvent('qb-phone:server:AddAdvert', data)
end)

function GetMail(id)
    local key = false
    for k, v in each(PhoneData.Mails) do
        if v.mailID == id then
            key = k
        end
    end
    return key
end