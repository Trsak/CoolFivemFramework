RegisterNetEvent("admin:openMenu")
AddEventHandler(
    "admin:openMenu",
    function(targetPlayer)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            local playerList = exports.data:getUsersBaseData(
                function(userData)
                    return userData.status == "spawned" or userData.status == "dead" or userData.status == "choosing"
                end
            )
            local playersData = {}

            for identifier, userData in each(playerList) do
                table.insert(playersData, {
                    ["identifier"] = identifier,
                    ["source"] = userData.source,
                    ["name"] = userData.nickname
                })
            end

            TriggerClientEvent("admin:openMenu", _source, playersData, targetPlayer)
        else
            banClientForCheating(
                _source,
                "0",
                "Cheating",
                "Admin server handler",
                "Hráč se pokusil vyvolat admin:openMenu"
            )
        end
    end
)

RegisterNetEvent("admin:getUserData")
AddEventHandler(
    "admin:getUserData",
    function(target)
        local _source = source

        if exports.data:getUserVar(_source, "admin") > 1 then
            TriggerClientEvent(
                "admin:getUserData",
                _source,
                exports.data:getUser(target),
                exports.data:getUserVar(target, "admin"),
                exports.data:getUserVar(target, "status"),
                exports.data:getUserVar(target, "character")
            )
        else
            banClientForCheating(
                _source,
                "0",
                "Cheating",
                "Admin server handler",
                "Hráč se pokusil vyvolat admin:getUserData"
            )
        end
    end
)

RegisterNetEvent("admin:freezePlayer")
AddEventHandler(
    "admin:freezePlayer",
    function(target)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            TriggerClientEvent("admin:freezePlayer", target)
        else
            banClientForCheating(
                _source,
                "0",
                "Cheating",
                "Admin server handler",
                "Hráč se pokusil vyvolat admin:freezePlayer"
            )
        end
    end
)

RegisterNetEvent("admin:teleportPlayers")
AddEventHandler(
    "admin:teleportPlayers",
    function(fromPlayer, toPlayer)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            local targetPlayer = fromPlayer == _source and toPlayer or fromPlayer
            if exports.data:getUserVar(targetPlayer, "status") ~= "choosing" then
                local toCoords = GetEntityCoords(GetPlayerPed(toPlayer))
                SetEntityCoords(GetPlayerPed(fromPlayer), toCoords.x, toCoords.y, toCoords.z)
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = { "Daný hráč je ve výběru postavy!" }
                    }
                )
            end
        else
            banClientForCheating(
                _source,
                "0",
                "Cheating",
                "Admin server handler",
                "Hráč se pokusil vyvolat admin:teleportPlayers"
            )
        end
    end
)
