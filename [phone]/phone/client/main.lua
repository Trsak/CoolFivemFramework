isLoggedIn = false
isDead = false
batteryDead = false
isSpawned = false
isLocked = false
phoneProp = 0
Races = {}
PlayerJob = {}
Bank = {}

PhoneData = {
    MetaData = {},
    isOpen = false,
    PlayerData = {},
    Contacts = {},
    Tweets = {},
    MentionedTweets = {},
    Hashtags = {},
    Chats = {},
    Invoices = {},
    Fines = {},
    CallData = {},
    RecentCalls = {},
    Garage = {},
    Mails = {},
    Adverts = {},
    GarageVehicles = {},
    AnimationData = {
        lib = nil,
        anim = nil,
    },
    SuggestedContacts = {},
    PlayerRaceRoutes = {},
    CryptoTransactions = {},
    loaded = false,
    phoneModel = "prop_npc_phone_02"
}

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        setMobile()
        SetTimeout(500, function()
            local mobile = getActiveMobile()
            local anyJob = false
            for _, v in each(exports.data:getCharVar("jobs")) do
                if v['duty'] then
                    anyJob = true
                    PlayerJob['name'] = v.job
                    PlayerJob['isBoss'] = (exports.base_jobs:getJobGradeVar(v.job, v.job_grade, "rank") == "boss")
                    PlayerJob["label"] = exports.base_jobs:getJobVar(v.job, "label")
                    jobType = exports.base_jobs:getJobVar(v.job, "type")
                    PlayerJob["typejob"] = Config.EmergencyServices[jobType] or jobType
                    break
                end
            end
            if not anyJob then
                PlayerJob = {}
            end
            isSpawned = true
            if mobile ~= nil then
                if not isLoggedIn then
                    TriggerServerEvent('qb-phone:server:GetPhoneData', mobile.data)
                end
            else
                unLoad()
            end
        end)
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    isDead = (status == "dead")
    if isDead and PhoneData.isOpen then
        SendNUIMessage({
            action = "close"
        })
    end
    if status == "choosing" then
        SendNUIMessage({
            action = "reload"
        })
        unLoad()
    end
    if status == "spawned" then
        local anyJob = false
        isSpawned = true
        setMobile()
        for _, v in each(exports.data:getCharVar("jobs")) do
            if v['duty'] then
                anyJob = true
                PlayerJob['name'] = v.job
                PlayerJob['isBoss'] = (exports.base_jobs:getJobGradeVar(v.job, v.job_grade, "rank") == "boss")
                PlayerJob["label"] = exports.base_jobs:getJobVar(v.job, "label")
                jobType = exports.base_jobs:getJobVar(v.job, "type")
                PlayerJob["typejob"] = Config.EmergencyServices[jobType] or jobType
                break
            end
        end
        if not anyJob then
            PlayerJob = {}
        end
        SetTimeout(500, function()
            local mobile = getActiveMobile()
            isSpawned = true
            if mobile ~= nil then
                if not isLoggedIn then
                    TriggerServerEvent('qb-phone:server:GetPhoneData', mobile.data)
                end
            else
                unLoad()
            end
        end)
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(job)
    local anyJob = false
    for _, v in each(job) do
        if v['duty'] then
            anyJob = true
            PlayerJob['name'] = v.job
            PlayerJob['isBoss'] = (exports.base_jobs:getJobGradeVar(v.job, v.job_grade, "rank") == "boss")
            PlayerJob["label"] = exports.base_jobs:getJobVar(v.job, "label")
            jobType = exports.base_jobs:getJobVar(v.job, "type")
            if jobType then
                PlayerJob["typejob"] = Config.EmergencyServices[jobType] or jobType
            end
            break
        end
    end
    if not anyJob then
        PlayerJob = {}
    end
    SendNUIMessage({
        action = "UpdateApplications",
        JobData = PlayerJob,
        applications = Config.PhoneApplications
    })
end)

RegisterNetEvent('qb-phone:client:lockPhone')
AddEventHandler('qb-phone:client:lockPhone', function(locked)
    isLocked = locked
end)

RegisterNetEvent('qb-phone:client:RefreshPhone')
AddEventHandler('qb-phone:client:RefreshPhone', function()
    local mobile = exports.inventory:getActiveMobile()
    setMobile()
    if mobile then
        TriggerServerEvent('qb-phone:server:GetPhoneData', mobile.data)
    end
end)

RegisterNetEvent('qb-phone:client:GetPhoneData')
AddEventHandler('qb-phone:client:GetPhoneData', function(pData, ttt)
    if (getNewMobile()) then
        SendNUIMessage({
            action = "reload"
        })
        unLoad()
    end
    SetTimeout(600, function()
        LoadPhone(pData)
    end)
end)

RegisterNetEvent('qb-phone:client:updateMetaData')
AddEventHandler('qb-phone:client:updateMetaData', function()
    local mobile = exports.inventory:getActiveMobile()
    PhoneData.MetaData = {}
    for k, v in each(mobile.data) do
        PhoneData.MetaData[k] = v
    end

    PhoneData.MetaData.internet = true
    PhoneData.MetaData.ip = nil
    if not PhoneData.MetaData.wifi then
        for _, v in each(PhoneData.MetaData.simActive) do
            if v.ip and v.active then
                PhoneData.MetaData.internet = true
                PhoneData.MetaData.ip = v.fakeIP and Config.FakeIP or v.ip
            end
        end
    end

    if PhoneData.MetaData.simActive.primary.active == nil or not PhoneData.MetaData.simActive.primary.active then
        PhoneData.MetaData.simActive.primary.active = false
        PhoneData.MetaData.simActive.primary.telNumber = "Sim Not Found"
    end

    if PhoneData.MetaData.simActive.primary.active == nil or not PhoneData.MetaData.simActive.secondary.active  then
        PhoneData.MetaData.simActive.secondary.active = false
        PhoneData.MetaData.simActive.secondary.telNumber = "Sim Not Found"
    end
    for k, v in each(PhoneData.MetaData.settings) do
        if v.account ~= nil then
            if v.account.blocked ~= nil and v.account.blocked then
                PhoneData.MetaData.settings[k].account.logged = false
            end
        end
    end

    print('refreshDataE')
    SendNUIMessage({
        action = "RefreshData",
        MetaData = PhoneData.MetaData
    })
end)

function LoadPhone(pData)
    local newPhone = getNewMobile()
    mobileMetaData = getActiveMobile()
    Bank = pData.Bank
    PhoneData.PlayerData = PlayerData()
    for k, v in each(mobileMetaData.data) do
        PhoneData.MetaData[k] = v
    end
    PhoneData.MetaData.internet = true
    PhoneData.MetaData.ip = nil
    if not PhoneData.MetaData.wifi then
        for _, v in each(PhoneData.MetaData.simActive) do
            if v.ip and v.active then
                PhoneData.MetaData.internet = true
                PhoneData.MetaData.ip = v.fakeIP and Config.FakeIP or v.ip
            end
        end
    end

    if PhoneData.MetaData.simActive.primary.active == nil or not PhoneData.MetaData.simActive.primary.active then
        PhoneData.MetaData.simActive.primary.active = false
        PhoneData.MetaData.simActive.primary.telNumber = "Sim Not Found"
    end

    if PhoneData.MetaData.simActive.primary.active == nil or not PhoneData.MetaData.simActive.secondary.active  then
        PhoneData.MetaData.simActive.secondary.active = false
        PhoneData.MetaData.simActive.secondary.telNumber = "Sim Not Found"
    end
    for k, v in each(PhoneData.MetaData.settings) do
        if v.account ~= nil then
            if v.account.blocked ~= nil and v.account.blocked then
                PhoneData.MetaData.settings[k].account.logged = false
            end
        end
    end

    if PhoneData.MetaData.InstalledApps ~= nil and next(PhoneData.MetaData.InstalledApps) ~= nil then
        for k, v in each(PhoneData.MetaData.InstalledApps) do
            local AppData = Config.StoreApps[v.app]
            Config.PhoneApplications[v.app] = {
                app = v.app,
                color = AppData.color,
                icon = AppData.icon,
                tooltipText = AppData.title,
                tooltipPos = "right",
                job = AppData.job,
                blockedjobs = AppData.blockedjobs,
                slot = AppData.slot,
                Alerts = 0,
            }
        end
    end

    if pData.Applications ~= nil and next(pData.Applications) ~= nil then
        for k, v in each(pData.Applications) do
            if k ~= nil and v ~= nil and Config.PhoneApplications[k] ~= nil then
                Config.PhoneApplications[k].Alerts = v
            end
        end
    end

    if pData.PlayerRaceRoutes ~= nil and next(pData.PlayerRaceRoutes) ~= nil then
        PhoneData.PlayerRaceRoutes = pData.PlayerRaceRoutes
    end

    if pData.MentionedTweets ~= nil and next(pData.MentionedTweets) ~= nil then
        PhoneData.MentionedTweets = pData.MentionedTweets
    end

    if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then
        PhoneData.Contacts = pData.PlayerContacts
    end

    if pData.Chats ~= nil and next(pData.Chats) ~= nil then
        local Chats = {}
        Config.PhoneApplications['whatsapp'].Alerts = 0
        for i = 1, #pData.Chats do
            for k, v in each(pData.Chats[i]) do
                MSG = {
                    name = IsNumberInContacts(tostring(v.number)),
                    number = tostring(v.number),
                    messages = v.messages,
                    Unread = v.Unread or 0
                }
                table.insert(Chats, MSG)
                if v.Unread then
                    if v.Unread > 0 then
                        Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
                    end
                end
            end
        end
        for k, Chat in each(Chats) do
            for _, Contact in each(PhoneData.Contacts) do
                if k == Contact.Number then
                    Chats[k].profilepicture = Contact.profilepicture
                end
            end
        end
        PhoneData.Chats = Chats
    end

    if pData.Invoices ~= nil and next(pData.Invoices) ~= nil then
        for _, invoice in each(pData.Invoices) do
            invoice.name = IsNumberInContacts(invoice.number)
        end
        PhoneData.Invoices = pData.Invoices
    end

    if pData.Fines ~= nil and next(pData.Fines) ~= nil then
        PhoneData.Fines = pData.Fines
    end

    if pData.Hashtags ~= nil and next(pData.Hashtags) ~= nil then
        PhoneData.Hashtags = pData.Hashtags
    end

    if pData.Tweets ~= nil and next(pData.Tweets) ~= nil then
        PhoneData.Tweets = pData.Tweets
    end

    if pData.Mails ~= nil and next(pData.Mails) ~= nil then
        PhoneData.Mails = pData.Mails
        if PhoneData.MetaData.settings.email.account ~= nil and next(PhoneData.MetaData.settings.email.account) then
            if not PhoneData.MetaData.settings.email.account.blocked and PhoneData.MetaData.settings.email.account.logged then
                Config.PhoneApplications['mail'].Alerts = 0
                for _, v in each(PhoneData.Mails) do
                    if v.reciever == PhoneData.MetaData.settings.email.account.name and not v.read then
                        Config.PhoneApplications['mail'].Alerts = Config.PhoneApplications['mail'].Alerts + 1
                    end
                end
            end
        end
        TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "mail", Config.PhoneApplications['mail'].Alerts)
    end

    if pData.Adverts ~= nil and next(pData.Adverts) ~= nil then
        PhoneData.Adverts = pData.Adverts
    end

    if pData.CryptoTransactions ~= nil and next(pData.CryptoTransactions) ~= nil then
        PhoneData.CryptoTransactions = pData.CryptoTransactions
    end
    PhoneData.GarageVehicles = pData.Garage
    if not newPhone and isLoggedIn then
        SendNUIMessage({
            action = "RefreshData",
            MetaData = PhoneData.MetaData
        })
        SendNUIMessage({
            action = "UpdateTwitter"
        })
        if Config.Debug then
            print('refreshData')
            --Utils.DumpTable(PhoneData.Chats)
        end
    else
        isLoggedIn = true
        SendNUIMessage({
            action = "LoadPhoneData",
            PhoneData = PhoneData,
            PlayerData = PhoneData.PlayerData,
            PlayerJob = PlayerJob,
            applications = Config.PhoneApplications
        })
        if Config.Debug then
            --Utils.DumpTable(pData.Chats)
            --Utils.DumpTable(PhoneData)
            --Utils.DumpTable(PhoneData.Contacts)
        end
    end
    TriggerServerEvent('qb-phone:server:SaveMetaDataALL', PhoneData.MetaData.id, PhoneData.MetaData)
end

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            SendNUIMessage({
                action = "UpdateTime",
                InGameTime = CalculateTimeToDisplay(),
            })
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if PhoneData.isOpen and isLoggedIn then
            --[[SendNUIMessage({
                    action = "UpdateTime",
                    InGameTime = CalculateTimeToDisplay(),
                })]]
        end
        Citizen.Wait(10000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if not PhoneData.isOpen and isLoggedIn then
            --TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData.id, PhoneData.MetaData.settings)
        end
        Citizen.Wait(Config.SaveWait)
    end
end)

function autoLock()
    Citizen.Wait(Config.AutoLock)
    if not PhoneData.isOpen and not PhoneData.MetaData.settings.password.lock then
        PhoneData.MetaData.settings.password.lock = true
        TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData.id, PhoneData.MetaData.settings)
    else
        if not PhoneData.isOpen then
            autoLock()
        end
    end
end

RegisterNUICallback('Close', function()
    if PhoneData.isOpen and isLoggedIn then
        if not PhoneData.CallData.InCall then
            DoPhoneAnimation('cellphone_text_out')
            SetTimeout(400, function()
                StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
                deletePhone()
                PhoneData.AnimationData.lib = nil
                PhoneData.AnimationData.anim = nil
            end)
        else
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
            DoPhoneAnimation('cellphone_text_to_call')
        end
        SetNuiFocus(false, false)
        SetTimeout(500, function()
            PhoneData.isOpen = false
        end)
        autoLock()
    end
end)

function closeMobile()
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_out')
        SetTimeout(400, function()
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end)
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
        DoPhoneAnimation('cellphone_text_to_call')
    end
end

function OpenMobile()
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_in')
    else
        DoPhoneAnimation('cellphone_call_to_text')
    end
    newPhoneProp()
end

RegisterNUICallback('dataDone', function()
    isLoggedIn = true
end)

RegisterCommand('phone', function()
    if HasPhone() then
        if not IsPauseMenuActive() then
            if not takePhoto then
                if not PhoneData.isOpen and not batteryDead and not isDead and isLoggedIn then
                    local IsHandcuffed = exports.data:getCharVar("cuffed")
                    if not IsHandcuffed and not IsPedArmed(PlayerPedId(), 4) then
                        WarMenu.CloseMenu()
                        OpenPhone()
                    else
                        exports.notify:display({type = "error", title = "Chyba", text = "Momentálně nemůžeš mobilovat. 👿", icon = "fas fa-times", length = 5000})
                    end
                else
                    if isLoggedIn then
                        SendNUIMessage({
                            action = "close"
                        })
                    end
                end
            end
        end
    end
end)

RegisterCommand('refresh_phone', function()
    if not isDead then
        unLoad()
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "close"
        })
        SendNUIMessage({
            action = "reload"
        })
        isLoggedIn = false
        local mobile = exports.inventory:getActiveMobile()
        if mobile then
            TriggerServerEvent('qb-phone:server:GetPhoneData', mobile.data)
        end

    end
end)

local MenuCreated = false
RegisterCommand('QuickMenu', function()
    if IsUsingKeyboard(2) and IsControlPressed(0, 21) then
        if PhoneData.MetaData.bCharID == PhoneData.PlayerData.charid then
            if HasPhone() and not MenuCreated then
                if not IsPauseMenuActive() then
                    if not takePhoto then
                        if not PhoneData.isOpen and not batteryDead and not isDead and isLoggedIn then
                            local mainMenu = true
                            local selectedContact = false
                            local selectedContactData = false
                            local anyContacts = false
                            MenuCreated = true
                            OpenMobile()
                            WarMenu.CreateMenu("QuickMenu", "QuickMenu", "Contacts")
                            WarMenu.OpenMenu("QuickMenu")
                            WarMenu.SetMenuY("QuickMenu", 0.35)

                            while true do
                                if WarMenu.IsMenuOpened("QuickMenu") then
                                    if not PhoneData.CallData.InCall then
                                        if mainMenu  then
                                            for k, v in each(PhoneData.Contacts) do
                                                anyContacts = true
                                                name = "Contact: " .. v.name
                                                if WarMenu.Button(name) then
                                                    selectedContact = v.name
                                                    selectedContactData = v
                                                    mainMenu = false
                                                end
                                            end
                                            if not anyContacts and WarMenu.Button("No contacts!") then
                                                MenuCreated = false
                                                WarMenu.CloseMenu()
                                            end
                                        else
                                            name2 = "Quick Call to " .. selectedContact
                                            name3 = "Quick GPS to " .. selectedContact
                                            if WarMenu.Button(name2) then
                                                SendNUIMessage({
                                                    action = "QuickCall",
                                                    call = true,
                                                    cData = selectedContactData
                                                })
                                                MenuCreated = false
                                                closeMobile()
                                                WarMenu.CloseMenu()
                                            elseif WarMenu.Button(name3) then
                                                SendNUIMessage({
                                                    action = "QuickCall",
                                                    gps = true,
                                                    cData = selectedContactData
                                                })
                                                MenuCreated = false
                                                WarMenu.CloseMenu()
                                            end
                                        end
                                    else
                                        if PhoneData.CallData.CallType == "incoming" and WarMenu.Button("Answer Call") then
                                            AnswerCall()
                                            MenuCreated = false
                                            WarMenu.CloseMenu()
                                        elseif PhoneData.CallData.CallType == "ongoing" and WarMenu.Button("Hangup Call") then
                                            CancelCall()
                                            SendNUIMessage({
                                                action = "DeleteCallNotification",
                                            })
                                            MenuCreated = false
                                            WarMenu.CloseMenu()
                                        end
                                    end
                                    WarMenu.Display()
                                else
                                    closeMobile()
                                    MenuCreated = false
                                    WarMenu.CloseMenu()
                                    break
                                end
                                Citizen.Wait(0)
                            end
                        end
                    end
                end
            end
        end
    end
end)

createNewKeyMapping({command ='phone', text ='Open Phone', key = 'F1'})
createNewKeyMapping({command ='QuickMenu', text ='Quick Phone Menu', key = 'Q'})