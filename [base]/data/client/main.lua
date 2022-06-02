local user = nil

RegisterNetEvent("data:userUpdated")
AddEventHandler("data:userUpdated", function(userData)
    user = userData
end)

RegisterNetEvent("data:userDataUpdated")
AddEventHandler("data:userDataUpdated", function(var, value)
    if not user then
        return
    end
    user[var] = value
end)

RegisterNetEvent("data:charUpdated")
AddEventHandler("data:charUpdated", function(var, value)
    if not user or not user.character then
        return
    end
    user.character[var] = value
end)

function saveChar(status)
    TriggerServerEvent("data:saveChar", status)
end

function isUserLoaded()
    return (user and true or false)
end

function isCharLoaded()

    if not user or not user.character then
        return false
    end

    return true
end

function getUserVar(var)
    return (user and user[var] or nil)
end

function getCharVar(var)
    if user and user.character then
        return user.character[var]
    else
        return nil
    end
end
