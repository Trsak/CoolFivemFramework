function HasPhone()
    if not isDead then
        local mobile = getActiveMobile()
        if mobile and not batteryDead then
            return true
        end
    end
    return false
end

function unLoad()
    PhoneData = {
        MetaData = {},
        isOpen = false,
        PlayerData = nil,
        Contacts = {},
        Tweets = {},
        MentionedTweets = {},
        Hashtags = {},
        Chats = {},
        Invoices = {},
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
        CryptoTransactions = {},
        loaded = false,
        phoneModel = "prop_npc_phone_02"
    }
    Races = {}
    PlayerJob = {}
    Bank = {}
    isLoggedIn = false
    isDead = false
    batteryDead = false
    isSpawned = false
    isLocked = false
end

function PlayerData()
    return {
        source = GetPlayerServerId(PlayerId()),
        firstname = exports.data:getCharVar("firstname"),
        lastname = exports.data:getCharVar("lastname"),
        charid = exports.data:getCharVar("id"),
        bank = Bank
    }
end

function OpenPhone()
    if HasPhone() then
        if not isLocked then
            PhoneData.PlayerData = PlayerData()
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "open",
                Tweets = PhoneData.Tweets,
                AppData = Config.PhoneApplications,
                CallData = PhoneData.CallData,
                PlayerData = PhoneData.PlayerData,
            })

            PhoneData.isOpen = true

            if not PhoneData.CallData.InCall then
                DoPhoneAnimation('cellphone_text_in')
            else
                DoPhoneAnimation('cellphone_call_to_text')
            end

            newPhoneProp()
        end
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Nemáš mobil! 👿", icon = "fas fa-times", length = 5000})
    end
end

function GetKeyByDate(Number, Date)
    local retval = nil
    if PhoneData.Chats[Number] ~= nil then
        if PhoneData.Chats[Number].messages ~= nil then
            for key, chat in each(PhoneData.Chats[Number].messages) do
                if chat.date == Date then
                    retval = key
                    break
                end
            end
        end
    end
    return retval
end

function GetKeyByNumber(Number)
    local retval
    if PhoneData.Chats then
        for k, v in each(PhoneData.Chats) do
            if tostring(v.number) == tostring(Number) then
                retval = k
            end
        end
    end
    return retval
end

function ReorganizeChats(key)
    local ReorganizedChats = {}
    ReorganizedChats[1] = PhoneData.Chats[key]
    for k, chat in each(PhoneData.Chats) do
        if tostring(k) ~= tostring(key) then
            table.insert(ReorganizedChats, chat)
        end
    end
    PhoneData.Chats = ReorganizedChats
end

function GetFirstAvailableSlot()
    local retval = 0
    for k, v in each(Config.PhoneApplications) do
        retval = retval + 1
    end
    return (retval + 1)
end

function InPhone()
    return PhoneData.isOpen
end

--[[function DisableDisplayControlActions()
    DisableControlAction(0, 1, true) -- disable mouse look
    DisableControlAction(0, 2, true) -- disable mouse look
    DisableControlAction(0, 3, true) -- disable mouse look
    DisableControlAction(0, 4, true) -- disable mouse look
    DisableControlAction(0, 5, true) -- disable mouse look
    DisableControlAction(0, 6, true) -- disable mouse look

    DisableControlAction(0, 263, true) -- disable melee
    DisableControlAction(0, 264, true) -- disable melee
    DisableControlAction(0, 257, true) -- disable melee
    DisableControlAction(0, 140, true) -- disable melee
    DisableControlAction(0, 141, true) -- disable melee
    DisableControlAction(0, 142, true) -- disable melee
    DisableControlAction(0, 143, true) -- disable melee

    DisableControlAction(0, 177, true) -- disable escape
    DisableControlAction(0, 200, true) -- disable escape
    DisableControlAction(0, 202, true) -- disable escape
    DisableControlAction(0, 322, true) -- disable escape

    DisableControlAction(0, 245, true) -- disable chat
end]]

function IsNumberInContacts(num)
    local retval = num
    for _, v in each(PhoneData.Contacts) do
        if num == v.number then
            retval = v.name
        end
    end
    return retval
end

function GetNumberInContacts(num)
    local retval = num
    for _, v in each(PhoneData.Contacts) do
        if num == v.number then
            retval = v.name
        end
    end
    return retval
end

function CalculateTimeToDisplay()
    hour = GetClockHours()
    minute = GetClockMinutes()
    local obj = {}

    if minute <= 9 then
        minute = "0" .. minute
    end

    obj.hour = hour
    obj.minute = minute

    return obj
end

function getLocation()
    local location = GetEntityCoords(PlayerPedId())
    if PhoneData.MetaData.wifi then
        plusMinus = math.random(0,4)
        if plusMinus <= 2 then
            location.x = location.x + math.random(0,100)
        else
            location.x = location.x - math.random(0,100)
        end
        plusMinus = math.random(0,4)
        if plusMinus <= 2 then
            location.y = location.y + math.random(0,100)
        else
            location.y = location.y - math.random(0,100)
        end
    elseif PhoneData.MetaData.simActive.primary.ghostChip then
        location = nil
    end
    return location
end

RegisterNUICallback('HasPhone', function(data, cb)
    cb(HasPhone())
end)
