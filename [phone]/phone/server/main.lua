local QBPhone = {}
local Tweets = {}
local Twitter = {}
local Mails = {}
local Email = {}
local AppAlerts = {}
local MentionedTweets = {}
local Hashtags = {}
local Adverts = {}
local PhoneData = {}
local OnlinePlayers = {}
local AllSims = {}
local PhoneSettings = {}
local Chats = {}
local Services = {}
local loaded = false

MySQL.ready(function()
    Wait(500)
    print("^2[SYSTEM MESSAGE]^5 Loading resource phone!")
    local wait = 10
    local start = GetGameTimer() + (8*wait)
    local numberData = 0
    MySQL.Async.fetchAll("SELECT simid, telephoneNumber FROM simcard", {}, function(sim)
        for _, v in each(sim) do
            telNumber = tostring(v.telephoneNumber)
            simid = tostring(v.simid)
            phone = v.phone
            AllSims[telNumber] = { simId = simid, phone = phone }
            numberData = numberData + 1
        end
    end)
    Wait(wait)
    local simcards = numberData
    print(string.format("^2[PHONE]^5 Loaded %s Sim cards!", simcards))
    MySQL.Async.fetchAll("SELECT * FROM phone_settings", {}, function(phone_settings)
        for _, v in each(phone_settings) do
            v["app_alerts"] = json.decode(v["app_alerts"])
            v["recent_calls"] = json.decode(v["recent_calls"])
            v["player_contacts"] = json.decode(v["player_contacts"])
            v["settings"] = json.decode(v["settings"])
            v["InstalledApps"] = json.decode(v["InstalledApps"])
            PhoneSettings[tostring(v.phoneid)] = v
            numberData = numberData + 1
        end
    end)
    Wait(wait)
    local phones = numberData - simcards
    print(string.format("^2[PHONE]^5 Loaded %s Phones!", phones))
    while exports.base_jobs:getJobs() == nil do Citizen.Wait(20) end
    for k, v in each(exports.base_jobs:getJobs()) do
        local dataJob = {
            name = v.name,
            label = v.label,
            typejob = Config.EmergencyServices[v.type] or v.type,
            messages = {}
        }
        table.insert(Services, dataJob)
    end
    MySQL.Async.fetchAll("SELECT * FROM phone_services", {}, function(phone_settings)
        for k, v in each(Services) do
            for _, d in each(phone_settings) do
                if v.name == d.name then
                    d["messages"] = json.decode(d["messages"])
                    if d["messages"] and d["messages"].userData then
                    d["messages"].userData.created = d.created
                    table.insert(Services[k].messages, d.messages)
                    end
                    numberData = numberData + 1
                end
            end
        end
    end)
    Wait(wait)
    print(string.format("^2[PHONE]^5 Loaded %s Services!", #Services))
    local messages_count = 0
    MySQL.Async.fetchAll("SELECT messages, number, simid FROM phone_messages", {}, function(messages)
        for _, v in each(messages) do
            msg = v.messages
            simid = tostring(v.simid)
            Chats[simid] = json.decode(msg)
            numberData = numberData + 1
            messages_count = messages_count + 1
        end
    end)
    Wait(wait)
    print(string.format("^2[PHONE]^5 Loaded %s WhatsApp messages!", messages_count))
    local twts = {}
    MySQL.Async.fetchAll("SELECT * FROM twitter_posts WHERE deleted is false ORDER BY id DESC LIMIT 500", {}, function(tweets)
        for _, v in each(tweets) do
            v.data = json.decode(v.data)
            v.likes = json.decode(v.likes)
            v.hashtag = json.decode(v.hashtag)
            v.mentioned = json.decode(v.mentioned)
            table.insert(twts, v)
        end
    end)
    Wait(wait)
    for y = #twts, 1, -1 do
        local v = twts[y]
        table.insert(Tweets, v)
        if v.hashtag_handle ~= nil and v.hashtag_handle ~= "null" then
            if Hashtags[v.hashtag_handle] ~= nil and next(Hashtags[v.hashtag_handle]) ~= nil then
                table.insert(Hashtags[v.hashtag_handle].messages, v)
            else
                Hashtags[v.hashtag_handle] = {
                    hashtag = v.hashtag_handle,
                    messages = {}
                }
                table.insert(Hashtags[v.hashtag_handle].messages, v)
            end
        end

        if v.mentioned ~= nil and #v.mentioned ~= 0 then
            for i = 1, #v.mentioned do
                QBPhone.AddMentionedTweet(v.mentioned[i], v)
            end
        end
        numberData = numberData + 1
    end
    Wait(wait)
    print(string.format("^2[PHONE]^5 Loaded %s Tweets!", #Tweets))
    MySQL.Async.fetchAll("SELECT * FROM twitter_accounts WHERE blocked is false", {}, function(twitter)
        for k, v in each(twitter) do
            if v.lastloggedData ~= "" then
                v.blocked = (v.blocked == 1)
                v.lastloggedData = json.decode(v.lastloggedData)
                table.insert(Twitter, v)
            end
            numberData = numberData + 1
        end
    end)
    Wait(wait)
    print(string.format("^2[PHONE]^5 Loaded %s Twitters!", #Twitter))
    MySQL.Async.fetchAll("SELECT * FROM mail_accounts WHERE blocked is false", {}, function(mail_acc)
        for k, v in each(mail_acc) do
            if v.data ~= "" then
                v.blocked = (v.blocked == 1)
                v.data = json.decode(v.data)
                v.last_logged = json.decode(v.last_logged)
                table.insert(Email, v)
            end
            numberData = numberData + 1
        end
    end)
    Wait(wait)
    print(string.format("^2[PHONE]^5 Loaded %s Emails!", #Email))
    MySQL.Async.fetchAll("SELECT * FROM player_mails WHERE sender_deleted is false OR reciever_deleted is false", {}, function(player_mails)
        for _, v in each(player_mails) do
            if not v.sender_deleted or not v.reciever_deleted then
                v.emailID = v.emailID
                v.message = v.message
                v.data = json.decode(v.data)
                v.button = json.decode(v.button)
                table.insert(Mails, v)
            end
            numberData = numberData + 1
        end
    end)
    Wait(wait)
    print(string.format("^2[PHONE]^5 Loaded %s Mails!", #Email))
    MySQL.Async.fetchAll("SELECT * FROM phone_adverts WHERE expired is false", {}, function(phone_adverts)
        for _, v in each(phone_adverts) do
            table.insert(Adverts, v)
            numberData = numberData + 1
        end
    end)
    print(string.format("^2[PHONE]^5 Loaded %s Adverts!", #Adverts))
    local time = (GetGameTimer() - start)
    local unit = "ms"
    if time > 1000 then
        time = time / 1000
        unit = "secs"
    end
    print(string.format("^2[SYSTEM MESSAGE]^5 Phone is loaded %s columns in %.2f %s! Save starts in %s", numberData, time, unit, os.date("%X", os.time() + (Config.SaveWait / 1000))))
    loaded = true
    --Utils.DumpTable(Chats)
    SetTimeout(Config.SaveWait, saveAll)
end)

RegisterNetEvent('qb-phone:server:GetPhoneData')
AddEventHandler('qb-phone:server:GetPhoneData', function(phoneData)
    local src = source
    local phone = phoneData
    local Player = exports.data:getCharVar(src, 'id')
    local phoneid = phone.id
    local simActive = phone.simActive
    local repair = false

    if not loaded then 
        while not loaded do 
            Citizen.Wait(0) 
        end
    end

    -- Temporary
    for k, v in each(simActive) do
        if v.active then
            if AllSims[v.telNumber] then
                AllSims[v.telNumber].phone = phoneid
                TriggerEvent("qb-phone:server:updateSimPhone", phoneid, v.id)
            end
        end
    end

    if Player ~= nil then
        OnlinePlayers[Player] = {
            sim = {
                primary = simActive.primary,
                secondary = simActive.secondary
            },
            settings = phone.settings,
            source = src,
            inCall = false,
            phoneid = phoneid,
            Jobs = exports.data:getCharVar(src, 'jobs')
        }

        PhoneData[phoneid] = {
            Applications = {},
            PlayerContacts = {},
            MentionedTweets = {},
            Chats = {},
            Hashtags = {},
            Invoices = {},
            Fines = {},
            Garage = {},
            Mails = {},
            Adverts = {},
            PlayerRaceRoutes = {},
            CryptoTransactions = {},
            Tweets = {},
            InstalledApps = {},
            Bank = {}
        }
        PhoneData[phoneid].Adverts = Adverts
        PhoneData[phoneid].PlayerRaceRoutes = {} --getPlayerRoutes(Player)
        PhoneData[phoneid].Garage = {}


        if OnlinePlayers[Player].settings.email.account ~= nil then
            emailAcc = OnlinePlayers[Player].settings.email.account
            if emailAcc.blocked ~= nil and not emailAcc.blocked then
                if emailAcc.logged ~= nil and emailAcc.logged then
                    mails = {}
                    for _, mail in each(Mails) do
                        if mail.sender == emailAcc.name then
                            if not mail.sender_deleted then
                                table.insert(mails, mail)
                            end
                        elseif mail.reciever == emailAcc.name  then
                            if not mail.reciever_deleted then
                                table.insert(mails, mail)
                            end
                        end
                    end
                    PhoneData[phoneid].Mails = mails
                end
            end
        end

        if PhoneSettings[tostring(phoneid)] ~= nil and next(PhoneSettings[tostring(phoneid)]) then
            PhoneData[tostring(phoneid)].PlayerContacts = PhoneSettings[tostring(phoneid)].player_contacts
            if AppAlerts[phoneid] == nil then
                AppAlerts[phoneid] = PhoneSettings[phoneid].app_alerts
            end
        end

        if simActive.primary.id then
            local sms = {}
            if Chats[simActive.primary.id] then
                table.insert(sms, Chats[simActive.primary.id])
            elseif simActive.secondary.simid then
                if Chats[simActive.secondary.id] then
                    table.insert(sms, Chats[simActive.secondary.id])
                end
            end
            PhoneData[phoneid].Chats = sms
        end

        PhoneData[phoneid].Applications = AppAlerts[phoneid]

        if OnlinePlayers[Player].settings.twitter.account ~= nil and next(OnlinePlayers[Player].settings.twitter.account) ~= nil and OnlinePlayers[Player].settings.twitter.account.logged then
            local twtID = tostring(OnlinePlayers[Player].settings.twitter.account.twitterID)
            if twtID ~= nil and MentionedTweets[twtID] ~= nil then
                PhoneData[phoneid].MentionedTweets = MentionedTweets[twtID]
            end

            if Hashtags ~= nil and next(Hashtags) ~= nil then
                PhoneData[phoneid].Hashtags = Hashtags
            end

            if Tweets ~= nil and next(Tweets) ~= nil then
                PhoneData[phoneid].Tweets = Tweets
            end
        end

        if OnlinePlayers[Player].settings.twitter.account.logged and not checkTwitterID(OnlinePlayers[Player].settings.twitter.account.twitterID) or OnlinePlayers[Player].settings.twitter.account.blocked then
            repair = true
            OnlinePlayers[Player].settings.twitter.account = {
                logged = false
            }
        end

        if OnlinePlayers[Player].settings.email.account.logged and not checkEmailID(OnlinePlayers[Player].settings.email.account.emailID) or OnlinePlayers[Player].settings.email.account.blocked then
            repair = true
            OnlinePlayers[Player].settings.email.account = {
                    logged = false
            }
        end

        if not repair then
            SetTimeout(100, function()
                TriggerLatentClientEvent("qb-phone:client:GetPhoneData", src, 50000, PhoneData[phoneid])
                --TriggerClientEvent("qb-phone:client:UpdateOnlinePlayers", -1, OnlinePlayers)
            end)
        else
            local newData = {}
            newData['settings'] = OnlinePlayers[Player].settings
            exports.inventory:updateItemData(src, phoneid, newData)
            SetTimeout(600, function()
                TriggerClientEvent('qb-phone:client:RefreshPhone', src)
            end)
        end
    end
end)

RegisterNetEvent('qb-phone:server:AddAdvert')
AddEventHandler('qb-phone:server:AddAdvert', function(data)
    local src = source
    local advertID = generateAdvertID()
    if advertID then
        advertsData = {
            advertID = advertID,
            name = data.name,
            number = data.number,
            message = data.message,
            date = os.date(),
            expired = false
        }
        table.insert(Adverts, advertsData)
        TriggerClientEvent('qb-phone:client:UpdateAdverts', -1, advertsData)
    end
end)

RegisterNetEvent('qb-phone:server:blockEmail')
AddEventHandler('qb-phone:server:blockEmail', function(args)
    local src = source
    print(getKey(Mails, args[1]))
end)

RegisterNetEvent('qb-phone:server:blockTwitter')
AddEventHandler('qb-phone:server:blockTwitter', function(args)
    local src = source
    print(getKey(Twitter, args[1]))
end)

RegisterNetEvent('qb-phone:server:SetupGarageVehicles')
AddEventHandler('qb-phone:server:SetupGarageVehicles', function(phoneid)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    for k, v in each(exports.base_vehicles:getVehicles()) do
        if type(v.owner) ~= "table" then
            if tonumber(v.owner) == tonumber(Player) then
                PhoneData[phoneid].Garage[k] = v
                if tonumber(v.in_garage) ~= 0 then
                    PhoneData[phoneid].Garage[k]['garage_coords'] = {
                        ["x"] = exports.garages:getVehicleGarageData(v.in_garage)["SelectCoords"].x,
                        ["y"] = exports.garages:getVehicleGarageData(v.in_garage)["SelectCoords"].y
                    }
                end
            end
        end
    end
    TriggerClientEvent('qb-phone:client:SetupGarageVehicles', src, PhoneData[phoneid].Garage)
end)

RegisterNetEvent('qb-phone:server:SetCallState')
AddEventHandler('qb-phone:server:SetCallState', function(bool)
    local src = source
    local Ply = exports.data:getCharVar(src, 'id')

    if OnlinePlayers[Ply] ~= nil then
        OnlinePlayers[Ply].inCall = bool
    end

    --TriggerClientEvent('qb-phone:client:UpdateCalls', -1, OnlinePlayers)
end)

RegisterNetEvent('qb-phone:server:getCallState')
AddEventHandler('qb-phone:server:getCallState', function(data)
    local src = source
    local Player = GetPlayerByPhone(data.ContactData.number)
    local inCall = false
    local online = false

    if OnlinePlayers[Player] ~= nil then
        inCall  = OnlinePlayers[Player].inCall
        online = true
    end

    TriggerClientEvent('qb-phone:client:getCallState', src, data, inCall, online)
end)

RegisterNetEvent('qb-phone:server:setNewServices')
AddEventHandler('qb-phone:server:setNewServices', function(data)
    local client = source
    local found = false
    if data.isBoss then
        for _, v in each(Services) do
            if v.name == data.name then
                found = true
                break
            end
        end
        if not found then
            local dataJob = {
                name = data.name,
                label = data.label,
                typejob = data.typejob,
                messages = {}
            }
            table.insert(Services, dataJob)
            TriggerClientEvent("notify:display", client, { type = "success", title = "Services", text = "Úspěšně si přidal svou firmu", icon = "fas fa-times", length = 3500 })
        else
            TriggerClientEvent("notify:display", client, { type = "error", title = "Services", text = "Už byla založena!", icon = "fas fa-times", length = 3500 })
        end
    else
        TriggerClientEvent("notify:display", client, { type = "error", title = "Services", text = "Nejsi boss!", icon = "fas fa-times", length = 3500 })
    end
end)

RegisterNetEvent('qb-phone:server:getServices')
AddEventHandler('qb-phone:server:getServices', function(data)
    local client = source
    TriggerClientEvent("qb-phone:client:getServices", client, Services)
end)

RegisterNetEvent('qb-phone:server:postNewReport')
AddEventHandler('qb-phone:server:postNewReport', function(data, message)
    local client = source
    local name = false
    message['time'] = os.time()
    for k, v in each(Services) do
        if data.type == "single" then
            if v.name == data.name then
                name = v.name
                table.insert(Services[k].messages, message)
                break
            end
        elseif data.type == "all" then
            if v.typejob == data.typejob then
                name = v.typejob
                table.insert(Services[k].messages, message)
            end
        end
    end
    if name then
        TriggerClientEvent("qb-phone:client:postedReport", -1, data.type, name, data.typejob, message)
    end
    TriggerClientEvent("notify:display", client, { type = "success", title = "Services", text = "bylo to úspěšně zasláno", icon = "fas fa-times", length = 3500 })
end)

RegisterNetEvent('qb-phone:server:EditContact')
AddEventHandler('qb-phone:server:EditContact', function(phoneid, contacts)
    local src = source
    local phoneId = false
    local Player = exports.data:getCharVar(src, 'id')
    if PhoneData[phoneid] then
        phoneId = phoneid
    elseif OnlinePlayers[Player] then
        phoneId = OnlinePlayers[Player].phoneid
    end
    PhoneData[phoneId].PlayerContacts = contacts
    if PhoneSettings[phoneId] ~= nil then
        PhoneSettings[phoneId].player_contacts = contacts
    else
        PhoneSettings[phoneId] = {}
        PhoneSettings[phoneId].player_contacts = contacts
    end
    TriggerClientEvent("qb-phone:client:UpdateContacts", src, PhoneData[phoneId].PlayerContacts)
    --saveMobile(phoneId)
end)

RegisterNetEvent('qb-phone:server:UpdateMessages')
AddEventHandler('qb-phone:server:UpdateMessages', function(ChatMessages, ChatNumber, New)
    local src = source
    local SenderData = exports.data:getCharVar(src, 'id')
    local SenderSimid = "offline"
    local SenderTel = OnlinePlayers[SenderData].sim.primary.telNumber
    local Senderchat = {}

    local TargetData = OnlinePlayers[GetPlayerByPhone(ChatNumber)] or "offline"
    local TargetTel = ChatNumber
    local TargetSimid = "offline"
    local Targetchat = {}

    for k, v in each(ChatMessages) do
        Targetchat[k] = v
        Senderchat[k] = v
    end

    if AllSims[SenderTel] then
        SenderSimid = AllSims[SenderTel].simId
        if Chats[SenderSimid] then
            local keySender = GetKeyByNumber(SenderSimid, TargetTel)
            --Senderchat['sender'] = SenderTel
            --Senderchat['target'] = TargetTel
            if keySender == nil then
                table.insert(Chats[SenderSimid], Senderchat)
            else
                Chats[SenderSimid][keySender].messages = Senderchat.messages
            end
        else
            if SenderSimid ~= "offline" then
                Chats[SenderSimid] = {}
                --Senderchat['number'] = TargetTel
                --Senderchat['sender'] = SenderTel
                --Senderchat['target'] = TargetTel
                table.insert(Chats[SenderSimid], Senderchat)
            end
        end
    end

    if Targetchat.Unread == nil then
        Targetchat.Unread = 1
    end

    if AllSims[TargetTel] then
        TargetSimid = AllSims[TargetTel].simId
        if Chats[TargetSimid] then
            local keyTarget = GetKeyByNumber(TargetSimid, SenderTel)
            Targetchat['number'] = SenderTel
            --Targetchat['target'] = TargetTel
            if keyTarget == nil then
                table.insert(Chats[TargetSimid], Targetchat)
            else
                Chats[TargetSimid][keyTarget].messages = Targetchat.messages
                if Chats[TargetSimid][keyTarget].Unread then
                    Targetchat.Unread = Targetchat.Unread + 1
                end
            end
        else
            if TargetSimid ~= "offline" then
                Chats[TargetSimid] = {}
                Targetchat['number'] = SenderTel
                table.insert(Chats[TargetSimid], Targetchat)
            end
        end
    end

    if TargetData ~= "offline" then
        --Utils.DumpTable(Targetchat.messages)
        TriggerClientEvent('qb-phone:client:UpdateMessages', TargetData.source, Targetchat, SenderTel, true)
    end
    if Config.Debug then
        if TargetSimid ~= "offline" then
            --print("target", TargetSimid)
            --Utils.DumpTable(Chats[TargetSimid])
        end
        if SenderSimid ~= "offline" then
            --print("sender", SenderSimid)
            --Utils.DumpTable(Chats[SenderSimid])
        end
    end
end)

RegisterNetEvent('qb-phone:server:AddRecentCall')
AddEventHandler('qb-phone:server:AddRecentCall', function(type, data)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneID = OnlinePlayers[Player].phoneid
    local Hour = os.date("%H")
    local Minute = os.date("%M")
    local label = Hour..":"..Minute

    TriggerClientEvent('qb-phone:client:AddRecentCall', src, data, label, type)
--[[    table.insert(PhoneSettings[phoneID].recent_calls, {
        name = data.number,
        time = label,
        type = type,
        number = data.number,
        anonymous = data.anonymous
    })]]

    local Trgt = GetPlayerByPhone(data.number)
    local TrgtSource = OnlinePlayers[Trgt].source
    if Trgt ~= nil then
        TriggerClientEvent('qb-phone:client:AddRecentCall', TrgtSource, {
            name = data.name,
            number = data.number,
            anonymous = data.anonymous
        }, label, "outgoing")
    end
--[[    table.insert(PhoneSettings[Trgt].recent_calls, {
        name = data.number,
        time = label,
        type = type,
        number = data.number,
        anonymous = data.anonymous
    })]]
end)

RegisterNetEvent('qb-phone:server:TakeScreenshot')
AddEventHandler('qb-phone:server:TakeScreenshot', function()
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneID = OnlinePlayers[Player].phoneid
    local currentTime = os.time()
--[[    exports['screenshot-basic']:requestClientScreenshot(src, {
        fileName = "/home/container/static/phone/".. phoneID .. "/images/".. currentTime .. "-" .. Player .. ".jpg"
    }, function(err, data)
        if not err then
            url = "https://static.server.cz/phone/".. phoneID .. "/images/".. currentTime .. "-" .. Player .. ".jpg"
            TriggerClientEvent('qb-phone:client:TakeScreenshot', url)
        else
            print(err)
        end
    end)]]
end)


RegisterNetEvent('qb-phone:server:CancelCall')
AddEventHandler('qb-phone:server:CancelCall', function(ContactData)
    local Ply = GetPlayerByPhone(ContactData)
    if OnlinePlayers[Ply] then
        local targetSrc = OnlinePlayers[Ply].source
        if targetSrc ~= nil then
            TriggerClientEvent('qb-phone:client:CancelCall', targetSrc)
        end
    end
end)

RegisterNetEvent('qb-phone:server:AnswerCall')
AddEventHandler('qb-phone:server:AnswerCall', function(CallData)
    local Ply = GetPlayerByPhone(CallData)
    if OnlinePlayers[Ply] then
        local targetSrc = OnlinePlayers[Ply].source
        if targetSrc ~= nil then
            TriggerClientEvent('qb-phone:client:AnswerCall', targetSrc)
        end
    end
end)

RegisterNetEvent('qb-phone:server:CallContact')
AddEventHandler('qb-phone:server:CallContact', function(TargetData, CallId, AnonymousCall)
    local src = source
    local SenderData = exports.data:getCharVar(src, 'id')
    local SenderTel = OnlinePlayers[SenderData].sim.primary.telNumber

    local target = GetPlayerByPhone(TargetData.number)
    if OnlinePlayers[target] then
        local targetSrc = OnlinePlayers[target].source
        local targetNumber = TargetData.number
        if targetSrc ~= nil and targetNumber ~= nil then
            TriggerClientEvent('qb-phone:client:GetCalled', targetSrc, SenderTel, CallId, AnonymousCall)
        end
    end
end)

RegisterNetEvent('qb-phone:server:BillingEmail')
AddEventHandler('qb-phone:server:BillingEmail', function(data, paid)
--[[    for k,v in each(QBCore.Functions.GetPlayers()) do
        local target = QBCore.Functions.GetPlayer(v)
        if target.PlayerData.job.name == data.society then
            if paid then
                local name = ''..QBCore.Functions.GetPlayer(source).PlayerData.charinfo.firstname..' '..QBCore.Functions.GetPlayer(source).PlayerData.charinfo.lastname..''
                TriggerClientEvent('qb-phone:client:BillingEmail', target.PlayerData.source, data, true, name)
            else
                local name = ''..QBCore.Functions.GetPlayer(source).PlayerData.charinfo.firstname..' '..QBCore.Functions.GetPlayer(source).PlayerData.charinfo.lastname..''
                TriggerClientEvent('qb-phone:client:BillingEmail', target.PlayerData.source, data, false, name)
            end
        end
    end]]
end)

QBPhone.SetPhoneAlerts = function(phoneid, app, alerts)
    if phoneid ~= nil and app ~= nil then
        if AppAlerts[phoneid] == nil then
            AppAlerts[phoneid] = {}
            if AppAlerts[phoneid][app] == nil then
                if alerts == nil then
                    AppAlerts[phoneid][app] = 1
                else
                    AppAlerts[phoneid][app] = alerts
                end
            end
        else
            if AppAlerts[phoneid][app] == nil then
                if alerts == nil then
                    AppAlerts[phoneid][app] = 1
                else
                    AppAlerts[phoneid][app] = 0
                end
            else
                if alerts == nil then
                    AppAlerts[phoneid][app] = AppAlerts[phoneid][app] + 1
                else
                    AppAlerts[phoneid][app] = AppAlerts[phoneid][app] + 0
                end
            end
        end
    end
end

RegisterNetEvent('qb-phone:server:SetPhoneAlerts')
AddEventHandler('qb-phone:server:SetPhoneAlerts', function(app, alerts, chat)
    local src = source
    local charid = exports.data:getCharVar(src, 'id')
    if OnlinePlayers[charid] then
        local phoneid = OnlinePlayers[charid].phoneid
        if phoneid ~= nil then
            QBPhone.SetPhoneAlerts(phoneid, app, alerts)

            if app == "whatsapp" then
                if chat then
                    local Tel = OnlinePlayers[charid].sim.primary.telNumber
                    if AllSims[Tel] then
                        local Simid = AllSims[Tel].simId
                        if Chats[Simid] then
                            for k, v in each(Chats[Simid]) do
                                if v.number == chat then
                                    if Chats[Simid][k].Unread then
                                        Chats[Simid][k].Unread = 0
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
            TriggerClientEvent('qb-phone:client:SetPhoneAlerts', src)
        end
    end
end)


RegisterNetEvent('qb-phone:server:GetBank')
AddEventHandler('qb-phone:server:GetBank', function()
    local src = source
    local charid = exports.data:getCharVar(src, 'id')
    OnlinePlayers[charid].Jobs = exports.data:getCharVar(src, 'jobs') or {}
    local phoneid = OnlinePlayers[charid].phoneid
    PhoneData[phoneid]["Bank"]['Personal'] = exports.bank:getPlayerAccesibleAccounts(src, "root")

    PhoneData[phoneid]["Bank"]['Company'] = {}

    PhoneData[phoneid].Fines = exports.fines:getFineList(charid, 0)

    PhoneData[phoneid].Invoices = exports.invoices:getInvoiceList(charid, 0)

    if OnlinePlayers[charid].Jobs and next(OnlinePlayers[charid].Jobs) then
        Company = {}
        for k, v in each(OnlinePlayers[charid].Jobs) do
            Company = exports.bank:getJobAccesibleAccounts(v.job, v.job_grade, "root")
        end
        PhoneData[phoneid]["Bank"]['Company'] =  Company
    end

    TriggerClientEvent('qb-phone:client:GetBank', src, PhoneData[phoneid]["Bank"], PhoneData[phoneid].Fines, PhoneData[phoneid].Invoices)
end)



RegisterNetEvent('qb-phone:server:TransferMoney')
AddEventHandler('qb-phone:server:TransferMoney', function(data)
    local src = source
    local charid = exports.data:getCharVar(src, 'id')
    OnlinePlayers[charid].Jobs = exports.data:getCharVar(src, 'jobs') or {}
    local phoneid = OnlinePlayers[charid].phoneid
    local pay = false
    local done = false
    if data.id ~= nil and data.amountOf ~= nil and data.sendTo ~= nil and data.from ~= nil and data.description ~= nil then
        if phoneid then
            if data.fine or data.invoice then
                fine = exports.fines:getFineData(charid, data.id)
                price = exports.fines:getFineData(charid, data.id).price
                Invoice, amount =  getInvoice(phoneid, data.id)
                if fine and tonumber(price) == tonumber(data.amountOf) or Invoice and tonumber(amount) == tonumber(data.amountOf) then
                    done = true
                end
            end

            if (not data.fine and not data.invoice and not done) or ((data.fine or data.invoice) and done) then

                if not data.void then
                    pay = exports.bank:payFromAccountToAccount(data.from, data.sendTo, tonumber(data.amountOf), false, data.description, data.description, src)
                else
                    pay = exports.bank:payFromAccount(data.from, tonumber(data.amountOf), false, data.description, src)
                end

                PhoneData[phoneid]["Bank"]['Personal'] = exports.bank:getPlayerAccesibleAccounts(src, "root")

                PhoneData[phoneid]["Bank"]['Company'] = {}

                if OnlinePlayers[charid].Jobs and next(OnlinePlayers[charid].Jobs) then
                    Company = {}
                    for k, v in each(OnlinePlayers[charid].Jobs) do
                        Company = exports.bank:getJobAccesibleAccounts(v.job, v.job_grade, "root")
                    end
                    PhoneData[phoneid]["Bank"]['Company'] =  Company
                end

                TriggerClientEvent('qb-phone:client:CanTransferMoney', src, pay, PhoneData[phoneid]["Bank"])
            end
        end
    else
        TriggerClientEvent('notify:display', src, {type = "error", title = "Phone Bank", text = string.format("Něco nebylo vyplněno správně"), icon = "fas fa-times", length = 5000})
    end
    --TriggerClientEvent('qb-phone:client:RemoveBankMoney', src, data.amountOf)
end)





--[[QBCore.Functions.CreateCallback('qb-phone:server:FetchResult', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    local ApaData = {}

    local query = 'SELECT * FROM `players` WHERE `citizenid` = "'..search..'"'
    -- Split on " " and check each var individual
    local searchParameters = SplitStringToArray(search)

    -- Construct query dynamicly for individual parm check
    if #searchParameters > 1 then
        query = query .. ' OR `charinfo` LIKE "%'..searchParameters[1]..'%"'
        for i = 2, #searchParameters do
            query = query .. ' AND `charinfo` LIKE  "%' .. searchParameters[i] ..'%"'
        end
    else
        query = query .. ' OR `charinfo` LIKE "%'..search..'%"'
    end

    exports.ghmattimysql:execute(query, function(result)
        exports.ghmattimysql:execute('SELECT * FROM `apartments`', function(ApartmentData)
            for k, v in each(ApartmentData) do
                ApaData[v.citizenid] = ApartmentData[k]
            end

            if result[1] ~= nil then
                for k, v in each(result) do
                    local charinfo = json.decode(v.charinfo)
                    local metadata = json.decode(v.metadata)
                    local appiepappie = {}
                    if ApaData[v.citizenid] ~= nil and next(ApaData[v.citizenid]) ~= nil then
                        appiepappie = ApaData[v.citizenid]
                    end
                    table.insert(searchData, {
                        citizenid = v.citizenid,
                        firstname = charinfo.firstname,
                        lastname = charinfo.lastname,
                        birthdate = charinfo.birthdate,
                        phone = charinfo.phone,
                        nationality = charinfo.nationality,
                        gender = charinfo.gender,
                        warrant = false,
                        driverlicense = metadata["licences"]["driver"],
                        appartmentdata = appiepappie,
                    })
                end
                cb(searchData)
            else
                cb(nil)
            end
        end)
    end)
end)]]



--[[QBCore.Functions.CreateCallback('qb-phone:server:GetVehicleSearchResults', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    exports.ghmattimysql:execute('SELECT * FROM `player_vehicles` WHERE `plate` LIKE "%'..search..'%" OR `citizenid` = "'..search..'"', function(result)
        if result[1] ~= nil then
            for k, v in each(result) do
                QBCore.Functions.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[k].citizenid..'"', function(player)
                    if player[1] ~= nil then
                        local charinfo = json.decode(player[1].charinfo)
                        local vehicleInfo = QBCore.Shared.Vehicles[result[k].vehicle]
                        if vehicleInfo ~= nil then
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = charinfo.firstname .. " " .. charinfo.lastname,
                                citizenid = result[k].citizenid,
                                label = vehicleInfo["name"]
                            })
                        else
                            table.insert(searchData, {
                                plate = result[k].plate,
                                status = true,
                                owner = charinfo.firstname .. " " .. charinfo.lastname,
                                citizenid = result[k].citizenid,
                                label = "Name not found.."
                            })
                        end
                    end
                end)
            end
        else
            if GeneratedPlates[search] ~= nil then
                table.insert(searchData, {
                    plate = GeneratedPlates[search].plate,
                    status = GeneratedPlates[search].status,
                    owner = GeneratedPlates[search].owner,
                    citizenid = GeneratedPlates[search].citizenid,
                    label = "Brand unknown.."
                })
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[search] = {
                    plate = search,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
                table.insert(searchData, {
                    plate = search,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                    label = "Brand unknown.."
                })
            end
        end
        cb(searchData)
    end)
end)

QBCore.Functions.CreateCallback('qb-phone:server:ScanPlate', function(source, cb, plate)
    local src = source
    local vehicleData = {}
    if plate ~= nil then
        exports.ghmattimysql:execute('SELECT * FROM `player_vehicles` WHERE `plate` = "'..plate..'"', function(result)
            if result[1] ~= nil then
                QBCore.Functions.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[1].citizenid..'"', function(player)
                    local charinfo = json.decode(player[1].charinfo)
                    vehicleData = {
                        plate = plate,
                        status = true,
                        owner = charinfo.firstname .. " " .. charinfo.lastname,
                        citizenid = result[1].citizenid,
                    }
                end)
            elseif GeneratedPlates ~= nil and GeneratedPlates[plate] ~= nil then
                vehicleData = GeneratedPlates[plate]
            else
                local ownerInfo = GenerateOwnerName()
                GeneratedPlates[plate] = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
                vehicleData = {
                    plate = plate,
                    status = true,
                    owner = ownerInfo.name,
                    citizenid = ownerInfo.citizenid,
                }
            end
            cb(vehicleData)
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, "No vehicle nearby..", "error")
        cb(nil)
    end
end)]]

RegisterNetEvent('qb-phone:server:GiveContactDetails')
AddEventHandler('qb-phone:server:GiveContactDetails', function(PlayerId)
    local src = source

    local SuggestionData = {
        name = {
            [1] = "Name",
            [2] = "LastName"
        },
        number = 123456,
        bank = 0
    }

    TriggerClientEvent('qb-phone:client:AddNewSuggestion', PlayerId, SuggestionData)
end)

RegisterNetEvent('qb-phone:server:AddTransaction')
AddEventHandler('qb-phone:server:AddTransaction', function(data)
--[[    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('INSERT INTO crypto_transactions (citizenid, title, message) VALUES (@citizenid, @title, @message)', {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@title'] = escape_sqli(data.TransactionTitle),
        ['@message'] = escape_sqli(data.TransactionMessage)
    })]]
end)

--[[QBCore.Functions.CreateCallback('qb-phone:server:GetCurrentLawyers', function(source, cb)
    local Lawyers = {}
    for k, v in each(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "service" or Player.PlayerData.job.name == "realestate" or Player.PlayerData.job.name == "mechanic" or Player.PlayerData.job.name == "taxi" or Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "ambulance") and Player.PlayerData.job.onduty then
                table.insert(Lawyers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                    typejob = Player.PlayerData.job.name,
                })
            end
        end
    end
    cb(Lawyers)
end)]]

QBPhone.AddMentionedTweet = function(twitterID, TweetData)
    if MentionedTweets[twitterID] == nil then MentionedTweets[twitterID] = {} end
    table.insert(MentionedTweets[twitterID], TweetData)
end

--RegisterNetEvent('qb-phone:server:UpdateHashtags')
--AddEventHandler('qb-phone:server:UpdateHashtags', function(Handle, messageData)
    function UpdateHashtags(messageData)
        local Handle = messageData.hashtag_handle
        local HashTags = messageData.hashtag
        if Hashtags[Handle] ~= nil and next(Hashtags[Handle]) ~= nil then
            table.insert(Hashtags[Handle].messages, messageData)
        else
            Hashtags[Handle] = {
                hashtag_handle = Handle,
                hashtag = HashTags,
                messages = {}
            }
            table.insert(Hashtags[Handle].messages, messageData)
        end
        if Config.Debug then
            --Utils.DumpTable(Hashtags)
        end
        TriggerClientEvent('qb-phone:client:UpdateHashtags', -1, messageData)
    end
--end)

--RegisterNetEvent('qb-phone:server:MentionedPlayer')
--AddEventHandler('qb-phone:server:MentionedPlayer', function(username, TweetMessage)
    function MentionedPlayer(username, TweetMessage)
        local Player = accountOnline(username.name)
        if Player then
            local src = OnlinePlayers[Player].source
            local phoneid = OnlinePlayers[Player].phoneid

            if (src and phoneid) then
                QBPhone.SetPhoneAlerts(phoneid, "twitter")
                TriggerClientEvent('qb-phone:client:GetMentioned', src, TweetMessage, AppAlerts[phoneid]["twitter"])
                SetTimeout(1500, function()
                    if OnlinePlayers[Player].settings.twitter.account.email ~= nil then
                        msg = username.name.."mentioned you in tweet"
                        sentEmail('Twitter', OnlinePlayers[Player].settings.twitter.account.email, "Mention", msg, nil)
                    end
                end)
            end
        end
        QBPhone.AddMentionedTweet(username.id, TweetMessage)
    end
--end)

RegisterNetEvent('qb-phone:server:UpdateTweets')
AddEventHandler('qb-phone:server:UpdateTweets', function(data)
    local patt = "[?!@#]"
    local TooMuch = false
    local tweetID = generateTwitterID()
    if tweetID then
        local TweetMessage = {
            tweetID = tonumber(tweetID),
            twitterID = data.twitterID,
            name = data.name,
            message = data.Message,
            data = data.data,
            time = data.Time,
            picture = data.Picture,
            image = data.Image,
            likes = {},
            hashtag = {},
            hashtag_handle = "null",
            mentioned = {},
            deleted = false
        }
        local TwitterMessage = data.Message
        local MentionTag = TwitterMessage:split("@")
        local Mentions = {}
        local Hashtag = TwitterMessage:split("#")
        local HashTags = {}

        if Hashtag[2] ~= nil and Hashtag[2] ~= "" then
            for i = 2, #Hashtag do
                if Hashtag[2] ~= "" then
                    local hash = Hashtag[i]:split(" ")[1]
                    if hash ~= nil and hash ~= '' then
                        local InvalidSymbol = string.match(hash, patt)
                        if InvalidSymbol then
                            hash = hash:gsub("%"..InvalidSymbol, "")
                        end
                        table.insert(HashTags, hash)
                    end
                end
            end

            if #HashTags ~= 0 then
                if #HashTags < 5 then
                    local len = #HashTags
                    local string = HashTags[1]
                    for i = 2, len do
                        if HashTags[i] ~= '' then
                            string = string .. " " .. HashTags[i]
                        end
                    end
                    if string ~= nil or string ~= "" then
                        TweetMessage.hashtag = HashTags
                        if not checkTwitterHasTagHandle(string) then
                            TweetMessage.hashtag_handle = string
                            if TweetMessage.hashtag_handle ~= "null" then
                                UpdateHashtags(TweetMessage)
                            end
                        end
                    end
                else
                    TooMuch = true
                end
            end
        end

        if MentionTag[2] ~= nil and MentionTag[2] ~= "" then
            for i = 2, #MentionTag, 1 do
                local mention = MentionTag[i]:split(" ")[1]
                if mention ~= nil or mention ~= "" then
                    local InvalidSymbol = string.match(mention, patt)
                    if InvalidSymbol then
                        mention = mention:gsub("%"..InvalidSymbol, "")
                    end
                    local account = GetAccount(Twitter, mention)
                    if account  then
                        local accountID = tostring(Twitter[account].twitterID)
                        if mention ~= TweetMessage.name then
                            table.insert(Mentions, { name = mention, id = accountID })
                            --Mentions[mention] = false
                        end
                    end
                end
            end
            --Utils.DumpTable(Mentions)
            --Utils.DumpTable(Twitter)
            if #Mentions ~= 0 then
                if #Mentions < 10 then
                    local len = #Mentions
                    TweetMessage.mentioned = Mentions
                    for i=1, len do
                        MentionedPlayer(Mentions[i], TweetMessage)
                    end
                else
                    TooMuch = true
                end
            end
--[[            if Mentions ~= nil and next(Mentions) ~= nil then
                local len = #Mentions
                TweetMessage.mentioned = Mentions
                for k, v in each(Mentions) do
                    if not string.find(TweetMessage.mentioned_handle, TweetMessage.name) then
                        MentionedPlayer(k, TweetMessage)
                    end
                end
            end]]
        end

        if not TooMuch then
            table.insert(Tweets, TweetMessage)
            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, TweetMessage)
        end
    end
end)

RegisterNetEvent('qb-phone:server:EditTweets')
AddEventHandler('qb-phone:server:EditTweets', function(data)
    local tweetsKey = nil
    local mentionedKey = {}
    local hashtagKey = nil

    for k, v in each(Tweets) do
        if v.tweetID == data.tweetID then
            tweetsKey = k
            Tweets[k] = data
            break
        end
    end

    if data.mentioned ~= nil and next(data.mentioned) then
        for _, mData in each(data.mentioned) do
            if mData.id then
                if MentionedTweets[mData.id] and next(MentionedTweets[mData.id]) then
                    for k, v in each(MentionedTweets[mData.id]) do
                        if v.tweetID == data.tweetID then
                            MentionedTweets[mData.id][k] = data
                            table.insert(mentionedKey, k)
                        end
                    end
                end
            end
        end
    end

    if data.hashtag_handle ~= "null" then
        for k, v in each(Hashtags[data.hashtag_handle].messages) do
            if v.tweetID == data.tweetID then
                mentionedKey = k
                Hashtags[data.hashtag_handle].messages[k] = data
                break
            end
        end
    end

    TriggerClientEvent('qb-phone:client:EditTweets', -1, { Tweet = Tweets[tweetsKey], Mention = mentionedKey, hashtags = data.hashtag_handle } )
end)

RegisterNetEvent('qb-phone:server:EditTwitter')
AddEventHandler('qb-phone:server:EditTwitter', function(twitterAcc, userData)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneid = OnlinePlayers[Player].phoneid
    local oldTwitter = OnlinePlayers[Player].settings.twitter.account
    local newTwitter = twitterAcc
    local TwitterKey = getKey(Twitter, oldTwitter.name)
    local passwordChanged = false
    local changed = false
    if TwitterKey then
        OnlinePlayers[Player].settings.twitter.account.lastloggedData = userData
        Twitter[TwitterKey].lastloggedData = userData
    end

    if newTwitter.name ~= nil and oldTwitter.name ~= nil then
        if oldTwitter.name ~= newTwitter.name then
            if not checkTwitterName(newTwitter.name) then
                OnlinePlayers[Player].settings.twitter.account.name = newTwitter.name
                changed = true
            end
        end
    end

    if newTwitter.email ~= nil and oldTwitter.email ~= nil then
        if oldTwitter.email ~= newTwitter.email then
            if not compareEmail(Twitter, newTwitter.email) then
                OnlinePlayers[Player].settings.twitter.account.email = newTwitter.email
                changed = true
            end
        end
    end

    if newTwitter.password ~= nil and oldTwitter.password ~= nil then
        if oldTwitter.password ~= newTwitter.password then
            OnlinePlayers[Player].settings.twitter.account.password = newTwitter.password
            changed = true
            passwordChanged = true
        end
    end

    if newTwitter.profilepicture ~= nil and oldTwitter.profilepicture ~= nil then
        if oldTwitter.profilepicture ~= newTwitter.profilepicture then
            OnlinePlayers[Player].settings.twitter.account.profilepicture = newTwitter.profilepicture

            for k, v in each(Tweets) do
                if v.twitterID == oldTwitter.twitterID then
                    Tweets[k].picture = newTwitter.profilepicture
                end
            end
            TriggerClientEvent('qb-phone:client:updateImagesAll', -1, oldTwitter.twitterID, newTwitter.profilepicture)
            changed = true
        end
    end


    if changed then
        Twitter[TwitterKey] = OnlinePlayers[Player].settings.twitter.account
        Settings = {
            settings = OnlinePlayers[Player].settings
        }

        exports.inventory:updateItemData(src, phoneid, Settings)
        SetTimeout(100, function()
            TriggerClientEvent('qb-phone:client:RefreshPhone', src)
            TriggerClientEvent('qb-phone:client:EditTwitter', src, true)
        end)
        if passwordChanged then
            SetTimeout(1500, function()
                if Twitter[TwitterKey].email ~= nil then
                    local msg = "Change log your name is: " .. Twitter[TwitterKey].name .. " and password is: " .. Twitter[TwitterKey].password .. "Dont FORGET IT!"
                    sentEmail('Twitter', Twitter[TwitterKey].email, "Created Account", msg)
                end
            end)
        end
    else
        TriggerClientEvent('qb-phone:client:EditTwitter', src, false)
    end
end)

RegisterNetEvent('qb-phone:server:CreateTwitterAcc')
AddEventHandler('qb-phone:server:CreateTwitterAcc', function(twitterAcc, userData)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneid = OnlinePlayers[Player].phoneid
    local found = false
    local twitterID = generateTwitterID()
    if twitterAcc.email ~= nil then
        found = compareEmail(Twitter, twitterAcc.email)
    end
    if twitterID then
        if getKey(Twitter, twitterAcc.name) == nil and not found and not checkTwitterName(twitterAcc.name) then
            OnlinePlayers[Player].settings.twitter.account = {
                twitterID = tonumber(twitterID),
                logged = true,
                name = twitterAcc.name,
                email = twitterAcc.email,
                password = twitterAcc.password,
                profilepicture = twitterAcc.profilepicture,
                lastloggedData = userData,
                blocked = false
            }
            table.insert(Twitter, OnlinePlayers[Player].settings.twitter.account)
            Settings = {
                settings = OnlinePlayers[Player].settings
            }

            exports.inventory:updateItemData(src, phoneid, Settings)
            SetTimeout(100, function()
                TriggerClientEvent('qb-phone:client:RefreshPhone', src)
                TriggerClientEvent('qb-phone:client:CreateTwitterAcc', src, true)
            end)
            SetTimeout(1500, function()
                if twitterAcc.email ~= nil then
                    local msg = "Welcome on TWITTER your name is: " .. twitterAcc.name .. " and password is: " .. twitterAcc.password .. "Dont FORGET IT!"
                    sentEmail('Twitter', twitterAcc.email, "Created Account", msg)
                end
            end)
        else
            TriggerClientEvent('qb-phone:client:CreateTwitterAcc', src, false)
        end
    end
end)

RegisterNetEvent('qb-phone:server:LogInTwitter')
AddEventHandler('qb-phone:server:LogInTwitter', function(twitterAcc, userData)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneid = OnlinePlayers[Player].phoneid
    local key = getKey(Twitter, twitterAcc.name)
    local pw = comparePW(Twitter, twitterAcc.name, twitterAcc.password)
    local IP = nil
    if OnlinePlayers[Player].settings.twitter.account.lastloggedData then
        IP = OnlinePlayers[Player].settings.twitter.account.lastloggedData.ip
    end

    if pw and key then
        if not Twitter[key].logged and not Twitter[key].blocked then
            Twitter[key].logged = true
            Twitter[key].lastloggedData = userData
            OnlinePlayers[Player].settings.twitter.account = Twitter[key]
            Settings = {
                settings = OnlinePlayers[Player].settings
            }
            exports.inventory:updateItemData(src, phoneid, Settings)
            SetTimeout(100, function()
                TriggerClientEvent('qb-phone:client:RefreshPhone', src)
                TriggerClientEvent('qb-phone:client:LogInTwitter', src, true)
            end)
            SetTimeout(1500, function()
                if OnlinePlayers[Player].settings.twitter.account.email ~= nil then
                    if IP ~= nil and userData.ip ~= IP then
                        msg = "Somebody from other device is logged into your Twitter accout with IP"..userData.ip..". If its your device consider to dont change IPs, like little pussy, do you thing that government is chasing you? heh, little hero"
                        sentEmail('Twitter', OnlinePlayers[Player].settings.twitter.account.email, "Uknown device", msg)
                    end
                end
            end)
        else
            TriggerClientEvent('qb-phone:client:LogInTwitter', src, false, 'logged')
            SetTimeout(1500, function()
                if OnlinePlayers[Player].settings.twitter.account.email ~= nil then
                    if IP ~= nil and userData.ip ~= IP then
                        msg = "Somebody from other device is logged into your Twitter accout with IP"..userData.ip..". If its your device consider to dont change IPs, like little pussy, do you thing that government is chasing you? heh, little hero"
                        sentEmail('Twitter', OnlinePlayers[Player].settings.twitter.account.email, "Uknown device", msg)
                    end
                end
            end)
        end
    else
        TriggerClientEvent('qb-phone:client:LogInTwitter', src, false, 'PW')
    end
end)

RegisterNetEvent('qb-phone:server:SignOutTwitter')
AddEventHandler('qb-phone:server:SignOutTwitter', function(twitterAcc, userData)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneid = OnlinePlayers[Player].phoneid
    local key = getKey(Twitter, twitterAcc.name)

    OnlinePlayers[Player].settings.twitter.account.logged = false
    OnlinePlayers[Player].settings.twitter.account.lastloggedData = userData
    if key then
        Twitter[key].logged = false
        Twitter[key].lastloggedData = userData
    end
    Settings = {
        settings = OnlinePlayers[Player].settings
    }
    exports.inventory:updateItemData(src, phoneid, Settings)

    SetTimeout(200, function()
        TriggerClientEvent('qb-phone:client:RefreshPhone', src)
        TriggerClientEvent('qb-phone:client:SignOutTwitter', src, true)
    end)
end)

RegisterNetEvent('qb-phone:server:CreateMail')
AddEventHandler('qb-phone:server:CreateMail', function(MailData, userdata)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneid = OnlinePlayers[Player].phoneid
    local emailID = generateEmailID()
    local data = {
        ip = userdata.ip,
        location = userdata.location,
        player = Player,
        phone = phoneid
    }
    if emailID then
        if getKey(Email, MailData.name) == nil and not checkEmailName(MailData.name) then
            OnlinePlayers[Player].settings.email.account = {
                emailID = tonumber(emailID),
                logged = true,
                name = MailData.name,
                password = MailData.pw,
                telephone = MailData.tel,
                last_logged = data,
                data = data,
                blocked = false
            }
            table.insert(Email, OnlinePlayers[Player].settings.email.account)
            Settings = {
                settings = OnlinePlayers[Player].settings
            }
            exports.inventory:updateItemData(src, phoneid, Settings)
            SetTimeout(100, function()
                TriggerClientEvent('qb-phone:client:RefreshPhone', src)
                TriggerClientEvent('qb-phone:client:CreateMail', src, true)
            end)
        else
            TriggerClientEvent('qb-phone:client:CreateMail', src, false)
        end
    end
end)

RegisterNetEvent('qb-phone:server:SignOutMail')
AddEventHandler('qb-phone:server:SignOutMail', function(MailData, userdata)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneid = OnlinePlayers[Player].phoneid
    local key = getKey(Email, MailData.name)
    local data = {
        ip = userdata.ip,
        location = userdata.location,
        player = Player,
        phone = phoneid
    }

    OnlinePlayers[Player].settings.email.account.logged = false
    OnlinePlayers[Player].settings.email.account.last_logged = data
    if key then
        Email[key].logged = false
        Email[key].last_logged = data
    end
    Settings = {
        settings = OnlinePlayers[Player].settings
    }
    exports.inventory:updateItemData(src, phoneid, Settings)
end)

RegisterNetEvent('qb-phone:server:LogInMail')
AddEventHandler('qb-phone:server:LogInMail', function(MailData, userdata)
    local src = source
    local Player = exports.data:getCharVar(src, 'id')
    local phoneid = OnlinePlayers[Player].phoneid
    local key = getKey(Email, MailData.name)
    local pw = comparePW(Email, MailData.name, MailData.pw)
    local data = {
        ip = userdata.ip,
        location = userdata.location,
        player = Player,
        phone = phoneid
    }

    if pw and key then
        if not Email[key].logged and not Email[key].blocked then
            Email[key].logged = true
            Email[key].last_logged = data
            OnlinePlayers[Player].settings.email.account = Email[key]
            Settings = {
                settings = OnlinePlayers[Player].settings
            }
            exports.inventory:updateItemData(src, phoneid, Settings)
            SetTimeout(100, function()
                TriggerClientEvent('qb-phone:client:RefreshPhone', src)
                TriggerClientEvent('qb-phone:client:LogInMail', src, true, 'done')
            end)
        else
            TriggerClientEvent('qb-phone:client:LogInMail', src, false, 'logged')
        end
    else
        TriggerClientEvent('qb-phone:client:LogInMail', src, false, 'PW')
    end
end)

RegisterNetEvent('qb-phone:server:RemoveMail')
AddEventHandler('qb-phone:server:RemoveMail', function(MailId, sender)
    local key = getMail(MailId)
    if key then
        if sender then
            Mails[key].sender_deleted = true
        else
            Mails[key].reciever_deleted = true
        end
    end
end)

RegisterNetEvent('qb-phone:server:ReadMail')
AddEventHandler('qb-phone:server:ReadMail', function(MailId)
    local src = source
    local key = getMail(MailId)
    if key then
        Mails[key].read = true
        local Player = accountOnline(Mails[key].sender)
        if Player then
            playerSrc = OnlinePlayers[Player].source
            if playerSrc then
                TriggerClientEvent('qb-phone:client:RefreshMail', playerSrc, MailId)
            end
        end
    end
end)

RegisterNetEvent('qb-phone:server:sendNewMail')
AddEventHandler('qb-phone:server:sendNewMail', function(mailData, data)
    local src = source
    local Player = accountOnline(mailData.reciever)
    local mailID = generateMailID()
    if mailID then
        local Mail = {
            mailID = tonumber(mailID),
            emailID = tonumber(mailData.emailID),
            sender = mailData.sender,
            reciever = mailData.reciever,
            subject = mailData.subject,
            message = mailData.message,
            data = data,
            read = false,
            sender_deleted = false,
            reciever_deleted = false,
            date = os.date(),
            button = mailData.button
        }

        table.insert(Mails, Mail)
        if mailData.button == nil then
            TriggerClientEvent('qb-phone:client:UpdateMails', src, Mail)
        end
        if Player then
            playerSrc = OnlinePlayers[Player].source
            TriggerClientEvent('qb-phone:client:NewMailNotify', playerSrc, Mail)
        end
    end
end)

--RegisterNetEvent('qb-phone:server:sendNewMailToOffline')
--AddEventHandler('qb-phone:server:sendNewMailToOffline', function(citizenid, mailData)
    function sendNewMailToOffline()

    end
--end)

RegisterNetEvent('qb-phone:server:sendNewEventMail')
AddEventHandler('qb-phone:server:sendNewEventMail', function(citizenid, mailData)

end)

RegisterNetEvent('qb-phone:server:ClearButtonData')
AddEventHandler('qb-phone:server:ClearButtonData', function(mailId)
    local key = getMail(mailId)
    if key then
        Mails[key].button = nil
    end
end)

RegisterNetEvent('qb-phone:server:InstallApplication')
AddEventHandler('qb-phone:server:InstallApplication', function(ApplicationData)
    local src = source
    local phoneData = ApplicationData.MData
    local phoneId = phoneData.id

    if phoneData["InstalledApps"] == nil then
        phoneData["InstalledApps"] = {}
    end
    table.insert(phoneData["InstalledApps"], ApplicationData.app)

    local data = {
        ["InstalledApps"] = phoneData["InstalledApps"]
    }

    PhoneData[phoneId]["InstalledApps"] = phoneData["InstalledApps"]
    exports.inventory:updateItemData(src, phoneData.id, data)

    SetTimeout(100, function()
        TriggerClientEvent('qb-phone:client:RefreshPhone', src)
    end)
end)

RegisterNetEvent('qb-phone:server:RemoveInstallation')
AddEventHandler('qb-phone:server:RemoveInstallation', function(MData, App)
    local src = source
    local phoneData = MData
    local phoneId = phoneData.id

    if phoneData["InstalledApps"] ~= nil then
        for k, v in each(phoneData["InstalledApps"]) do
            if v.app == App then
                table.remove(phoneData["InstalledApps"], k)
                break
            end
        end

        local data = {
            ["InstalledApps"] = phoneData["InstalledApps"]
        }
        PhoneData[phoneId]["InstalledApps"] = phoneData["InstalledApps"]
        exports.inventory:updateItemData(src, phoneData.id, data)

        SetTimeout(100, function()
            TriggerClientEvent('qb-phone:client:RefreshPhone', src)
        end)
    end
end)

RegisterNetEvent('qb-phone:server:SaveMetaData')
AddEventHandler('qb-phone:server:SaveMetaData', function(id, Settings)
    local src = source
    local data = {}
    data["settings"] = Settings
    exports.inventory:updateItemData(src, id, data)
    SetTimeout(100, function()
        TriggerClientEvent('qb-phone:client:updateMetaData', src)
    end)
end)

RegisterNetEvent('qb-phone:server:SaveMetaDataSIM')
AddEventHandler('qb-phone:server:SaveMetaDataSIM', function(id, simActive)
    local src = source
    local data = {}
    data["simActive"] = simActive
    exports.inventory:updateItemData(src, id, data)
    SetTimeout(100, function()
        TriggerClientEvent('qb-phone:client:RefreshPhone', src)
    end)
end)

RegisterNetEvent('qb-phone:server:SaveMetaDataALL')
AddEventHandler('qb-phone:server:SaveMetaDataALL', function(id, data)
    local src = source
    exports.inventory:updateItemData(src, id, data)
    TriggerClientEvent('qb-phone:client:updateMetaData', src)
end)

function getInvoice(phoneid, id)
    local found, amount = false, nil
    for _, v in each(PhoneData[phoneid].Invoices) do
        if v.Id == id then
            found = true
            amount = v.Price
            break
        end
    end
    return found, amount
end

function sentEmail(sender, reciever, subject, message, action)
    local Player = accountOnline(reciever)
    if Player then
        local src = OnlinePlayers[Player].source
        local EmailID = generateEmailID()
        if EmailID then
            local Mail = {
                mailID = Config.emailIDs[sender],
                emailID = tonumber(EmailID),
                sender = sender,
                reciever = reciever,
                subject = subject,
                message = message,
                data = {},
                read = false,
                reciever_deleted = false,
                sender_deleted = false,
                date = os.date(),
                button = action
            }
            table.insert(Mails, Mail)
            if src then
                TriggerClientEvent('qb-phone:client:NewMailNotify', src, Mail)
            end
        end
    end
end

function getKey(where, identifier)
    local key = nil
    if where ~= nil then
        for k, v in each(where) do
            if tostring(identifier) == tostring(v.name) then
                key = k
                break
            end
        end
    end
    return key
end

function checkTwitterName(name)
    local found = false
    for _, data in each(Twitter) do
        if data.name == name then
            found = true
            break
        end
    end
    for k, v in each(Config.BannedNames) do
        if string.lower(k) == string.lower(name) then
            found = true
            break
        end
    end
    return found
end

function checkEmailName(name)
    local found = false
    for _, data in each(Email) do
        if data.name == name then
            found = true
            break
        end
    end
    for k, v in each(Config.BannedNames) do
        if string.lower(k) == string.lower(name) then
            found = true
        end
    end
    return found
end

function comparePW(where, name, password)
    local key = false
    if where ~= nil then
        for k, v in each(where) do
            if not v.blocked then
                if v.name == name then
                    if password == v.password then
                        key = true
                        break
                    end
                end
            end
        end
    end
    return key
end

function compareEmail(where, email)
    local key = false
    if where ~= nil then
        for k, v in each(where) do
            if not v.blocked then
                if email == v.email then
                    key = true
                    break
                end
            end
        end
    end
    return key
end

function GetPlayerByPhone(number)
    local targetSrc = nil
    for k, v in each(OnlinePlayers) do
        if v.sim.primary.telNumber== number then
            targetSrc = k
            break
        end
        if v.sim.secondary.telNumber == number then
            targetSrc = k
            break
        end
    end
    return targetSrc
end

function GetSimByPhone(number)
    local targetSimid = nil
    for telNumber, v in each(AllSims) do
        if telNumber == number then
            targetSimid = v.simid
            break
        end
    end
    return targetSimid
end

function getMail(identifier)
    local key = nil
    if Mails ~= nil then
        for k, v in each(Mails) do
            if identifier == v.mailID then
                key = k
                break
            end
        end
    end
    return key
end

function GetAccount(where, name)
    local key = false
    for k, v in each(where) do
        if name == v.name then
            key = k
            break
        end
    end
    return key
end

function accountOnline(name)
    local key = false
    for k, v in each(OnlinePlayers) do
        for _, accounts in each(v.settings) do
            if type(accounts) == "table" and accounts.account then
                if accounts.account.blocked ~= nil and not accounts.account.blocked then
                    if accounts.account.logged then
                        if name == accounts.account.name then
                            key = k
                            break
                        end
                    end
                end
            end
        end
    end
    return key
end

function generateTwitterID()
    local TwitterID
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        TwitterID = Utils.GetRandomNumber(9)
        if not checkTwitterID(TwitterID) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return TwitterID
end

function checkTwitterID(uid)
    local found = false
    for _, v in each(Twitter) do
        if uid == v.twitterID then
            found = true
            break
        end
    end
    return found
end

function generateTweetID()
    local TweetID
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        TweetID = Utils.GetRandomNumber(9)
        if not checkTweetID(TweetID) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return TweetID
end

function checkTweetID(uid)
    local found = false
    for _, v in each(Tweets) do
        if uid == v.tweetID then
            found = true
            break
        end
    end
    return found
end

function generateTwitterHasTagHandle()
    local HasTagHandle
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        HasTagHandle = Utils.GetRandomNumber(9)
        if not checkTwitterHasTagHandle(HasTagHandle) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return HasTagHandle
end

function checkTwitterHasTagHandle(uid)
    local found = false
    for _, v in each(Twitter) do
        if v.hashtag ~= nil and next(v.hashtag)then
            if uid == v.hashtag.handle then
                found = true
                break
            end
        end
    end
    return found
end

function generateMailID()
    local MailID
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        MailID = Utils.GetRandomNumber(9)
        if not checkMailID(MailID) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return MailID
end

function checkMailID(uid)
    local found = false
    for _, v in each(Mails) do
        if uid == v.mailID then
            found = true
            break
        end
    end

    return found
end

function generateEmailID()
    local EmailID
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        EmailID = Utils.GetRandomNumber(9)
        if not checkEmailID(EmailID) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return EmailID
end

function checkEmailID(uid)
    local found = false
    for _, v in each(Email) do
        if uid == v.emailID then
            found = true
            break
        end
    end
    return found
end

function generateAdvertID()
    local AdvertID
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        AdvertID = Utils.GetRandomNumber(9)
        if not checkAdvertID(AdvertID) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return AdvertID
end

function checkAdvertID(uid)
    local found = false
    for _, v in each(Adverts) do
        if uid == v.advertID then
            found = true
            break
        end
    end
    return found
end

function getNumberBySim(simid)
    for k, v in each(AllSims) do
        if v.simId == simid then
            return k
        end
    end
    return simid
end

function GetOnlineStatus(number)
    local retval = false
    for _, v in each(OnlinePlayers) do
        if v.primary.telNumber == number then
            retval = true
            break
        end
        if v.secondary.telNumber == number then
            retval = true
            break
        end
    end
    return retval
end

function GetKeyByNumber(where, Number)
    local retval = nil
    if Chats[where][1] ~= nil then
        for i=1, #Chats[where] do
            for k, v in each(Chats[where][i]) do
                if k == "number" then
                    if tonumber(v) == tonumber(Number) then
                        retval = i
                        break
                    end
                end
            end
        end
    end
    return retval
end

function SplitStringToArray(string)
    local retval = {}
    for i in string.gmatch(string, "%S+") do
        table.insert(retval, i)
    end
    return retval
end

function insertNewSim(telNumber, simid)
    if not AllSims[tostring(telNumber)] then
        AllSims[tostring(telNumber)] = { simId = tostring(simid), phone = 0 }
    end
end

function insertNewPhone(phoneid, settings, charid)
    if not PhoneSettings[tostring(phoneid)] and not next(PhoneSettings[tostring(phoneid)]) then
        PhoneSettings[tostring(phoneid)] = {
            charid = tostring(charid),
            phoneid = phoneid,
            settings = settings,
            player_contacts = {},
            app_alerts = {},
            recent_calls = {},
            InstalledApps = {}
        }
    end
end

function GetKeyByDate(where, Number, Date)
    local retval = nil
    if where ~= nil then
        if where.messages ~= nil then
            for key, chat in each(where.messages) do
                if chat.date == Date then
                    retval = key
                    break
                end
            end
        end
    end
    return retval
end

function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
        table.insert( result, string.sub( self, from , delim_from-1 ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 180 then
        CreateThread(function()
            saveAll()
        end)
    end
end)

function getAllPhones()
    return PhoneSettings
end

function saveAll()
    print("^2[SYSTEM MESSAGE]^5 Saving phones!")
    local wait = 10
    local start = GetGameTimer() + (7*wait)
    local numberData = 0
    for k, v in each(PhoneData) do
        if v.PlayerContacts ~= nil then
            MySQL.Async.execute(
                    "UPDATE `phone_settings` SET `player_contacts`=@player_contacts WHERE `phoneid`=@phoneid",
                    {
                        ["@player_contacts"] = json.encode(v.PlayerContacts),
                        ["@phoneid"] = tonumber(k)
                    })
        end
        if v.settings ~= nil then
            MySQL.ASync.execute(
                    "UPDATE phone_settings SET settings=@settings WHERE phoneid = @phoneid",
                    {
                        ["@settings"] = json.encode(v.settings),
                        ["@phoneid"] = tonumber(k)
                    })
        end
        if v.InstalledApps ~= nil then
            MySQL.Async.execute(
                    "UPDATE phone_settings SET InstalledApps=@InstalledApps WHERE phoneid = @phoneid",
                    {
                        ["@InstalledApps"] = json.encode(v.InstalledApps),
                        ["@phoneid"] = tonumber(k)
                    })
        end
        numberData = numberData + 1
    end
    Wait(wait)
    if Chats ~= nil then
        for simid, chat in each(Chats) do
            number = getNumberBySim(simid)
            if number ~= nil then
                if #chat.messages ~= 0 then
                    for i = 1, #chat.messages do
                        MySQL.Async.execute(
                                "INSERT INTO phone_messages (simid, number, target, messages) VALUES (@simid, @number, @messages) ON DUPLICATE KEY UPDATE messages = @messages",
                                {
                                    ["@simid"] = tonumber(simid),
                                    ["@number"] = tonumber(getNumberBySim(number)),
                                    ["@target"] = tonumber(chat.number),
                                    ["@messages"] = json.encode(chat.messages[i])
                                })
                    end
                end
                --PhoneData['offline'].Chats = {}
            end
            numberData = numberData + 1
        end
    end
    Wait(wait)
    if Email ~= nil then
        for _, data in each(Email) do
            if data ~= nil then
                MySQL.Async.execute(
                        "INSERT INTO mail_accounts (emailID, name, telephone, password, data, blocked, last_logged) VALUES (@emailID, @name, @telephone, @password, @data, @blocked, last_logged) ON DUPLICATE KEY UPDATE last_logged = @last_logged, blocked = @blocked, password = @password, telephone = @telephone",
                        {
                            ["@emailID"] = data.emailID,
                            ["@name"] = data.name,
                            ["@password"] = data.password,
                            ["@telephone"] = data.telephone,
                            ["@data"] = json.encode(data.data),
                            ['@last_logged'] = json.encode(data.last_logged),
                            ["@blocked"] = data.blocked
                        })
            end
            numberData = numberData + 1
        end
    end
    Wait(wait)
    if Mails ~= nil then
        for _, data in each(Mails) do
            if data ~= nil then
                MySQL.Async.execute(
                        "INSERT INTO player_mails (mailID, emailID, sender, reciever, subject, message, data, `read`, sender_deleted, reciever_deleted, `date`, button) VALUES (@mailID, @emailID, @sender, @reciever, @subject, @message, @data, @read, @sender_deleted, @reciever_deleted, @date, @button) ON DUPLICATE KEY UPDATE `read` = @read, sender_deleted = @sender_deleted, reciever_deleted = @reciever_deleted",
                        {
                            ["@mailID"] = tonumber(data.mailID),
                            ["@emailID"] = tonumber(data.emailID),
                            ["@sender"] = data.sender,
                            ["@reciever"] = data.reciever,
                            ["@subject"] = data.subject,
                            ["@message"] = data.message,
                            ["@data"] = json.encode(data.data),
                            ["@read"] = data.read,
                            ["@sender_deleted"] = data.sender_deleted,
                            ["@reciever_deleted"] = data.reciever_deleted,
                            ["@date"] = data.date,
                            ["@button"] = json.encode(data.button or {})
                        })
            end
            numberData = numberData + 1
        end
    end
    Wait(wait)
    if Twitter ~= nil then
        for _, data in each(Twitter) do
            if data ~= nil then
                MySQL.Async.execute(
                        "INSERT INTO twitter_accounts (twitterID, name, email, password, profilepicture, lastloggedData, blocked) VALUES (@twitterID, @name, @email, @password, @profilepicture, @lastloggedData, @blocked) ON DUPLICATE KEY UPDATE email = @email, profilepicture = @profilepicture, password = @password, lastloggedData = @lastloggedData, blocked = @blocked",
                        {
                            ["@twitterID"] = data.twitterID,
                            ["@name"] = data.name,
                            ["@email"] = data.email,
                            ["@password"] = data.password,
                            ["@profilepicture"] = data.profilepicture,
                            ["@lastloggedData"] = json.encode(data.lastloggedData),
                            ["@blocked"] = data.blocked
                        })
            end
            numberData = numberData + 1
        end
    end
    Wait(wait)
    if Tweets ~= nil then
        for _, data in each(Tweets) do
            if data ~= nil then
                MySQL.Async.execute(
                        "INSERT INTO twitter_posts (tweetID, twitterID, name, message, data, picture, image, likes, time, hashtag, hashtag_handle, mentioned, deleted) VALUES (@tweetID, @twitterID,  @name, @message, @data, @picture, @image, @likes, @time, @hashtag, @hashtag_handle, @mentioned, @deleted) ON DUPLICATE KEY UPDATE deleted = @deleted, likes = @likes, picture = @picture",
                        {
                            ["@tweetID"] = data.tweetID,
                            ["@twitterID"] = data.twitterID,
                            ["@name"] = data.name,
                            ["@message"] = data.message,
                            ["@data"] = json.encode(data.data),
                            ["@picture"] = data.picture,
                            ["@image"] = data.image,
                            ["@likes"] = json.encode(data.likes or {}),
                            ["@time"] = data.time,
                            ["@hashtag"] = json.encode(data.hashtag or {}),
                            ["@hashtag_handle"] = data.hashtag_handle or nil,
                            ["@mentioned"] = json.encode(data.mentioned or {}),
                            ["@deleted"] = data.deleted,
                        })
            end
            numberData = numberData + 1
        end
    end
    Wait(wait)
    if Services ~= nil then
        for _, data in each(Services) do
            if data ~= nil then
                if #data.messages ~= 0 then
                    for i = 1, #data.messages do
                        MySQL.Async.execute(
                                "INSERT INTO phone_services (name, label, typejob, messages) VALUES (@name, @label, @typejob, @messages)",
                                {
                                    ["@name"] = data.name,
                                    ['@label'] = data.label,
                                    ["@typejob"] = data.typejob,
                                    ["@messages"] = json.encode(data.messages[i])
                                })
                    end
                end
            end
            numberData = numberData + 1
        end
    end
    Wait(wait)
    if Adverts ~= nil then
        for _, data in each(Adverts) do
            if data ~= nil then
                if tonumber(data.date) ~= nil then
                    daysfrom = os.difftime(os.time(), tonumber(data.date)) / (24 * 60 * 60) -- seconds in a day
                    wholedays = math.floor(daysfrom)
                    if wholedays > 7 then
                        data.expired = true
                    end
                    MySQL.Async.execute(
                            "INSERT INTO phone_adverts (advertID, name, number, message, date, expired) VALUES (@advertID, @name, @number, @message, @date, @expired) ON DUPLICATE KEY UPDATE expired = @expired",
                            {
                                ["@advertID"] = data.advertID,
                                ["@name"] = data.name,
                                ["@number"] = data.number,
                                ["@message"] = json.encode(data.message),
                                ["@date"] = data.date,
                                ["@expired"] = data.expired
                            })
                    numberData = numberData + 1
                end
            end
        end
    end
    local time = (GetGameTimer() - start)
    local unit = "ms"
    if time > 1000 then
        time = time / 1000
        unit = "secs"
    end
    print(string.format("^2[SYSTEM MESSAGE]^5 Phone is saved %s columns in %.2f %s! next save %s", numberData, time, unit, os.date("%X", os.time() + (Config.SaveWait / 1000))))
    SetTimeout(Config.SaveWait, saveAll)
end

RegisterCommand('saveMobile', function(source, args)
    if exports.data:getUserVar(source, "admin") == 3 then
        saveAll()
    end
end)