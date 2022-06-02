RegisterNetEvent("cuffs:cuffPlayer")
AddEventHandler(
    "cuffs:cuffPlayer",
    function(target, style)
        local _source = source
        local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
        local targetCoords = GetEntityCoords(GetPlayerPed(target))
        if #(sourceCoords - targetCoords) <= 50.0 then
            local hasItem = exports.inventory:removePlayerItem(_source, "cuffs", 1, {})
            if hasItem == "done" then
                TriggerClientEvent("cuffs:cuffTarget", target, _source, style)
                TriggerClientEvent("cuffs:startCuff", _source, style)
                Player(target).state.isCuffed = style
            else
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "warning",
                        title = "Pouta",
                        text = "Chybí ti pouta!",
                        icon = "fas fa-times",
                        length = 3000
                    }
                )
            end
        else
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "cuffs:cuffPlayer",
                "Hráč se pokusil spoutat někoho, kdo není blízko!"
            )
        end
    end
)

RegisterNetEvent("cuffs:uncuffPlayer")
AddEventHandler(
    "cuffs:uncuffPlayer",
    function(target)
        local _source = source
        local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
        local targetCoords = GetEntityCoords(GetPlayerPed(target))
        if #(sourceCoords - targetCoords) <= 50.0 then
            local done = exports.inventory:forceAddPlayerItem(_source, "cuffs", 1, {})
            TriggerClientEvent("cuffs:uncuffTarget", target, _source)
            TriggerClientEvent("cuffs:startUncuff", _source, Player(target).state.isCuffed)
            Player(target).state.isCuffed = false
        else
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "cuffs:cuffPlayer",
                "Hráč se pokusil odpoutat někoho, kdo není blízko!"
            )
        end
    end
)


RegisterNetEvent("cuffs:dragPlayer")
AddEventHandler(
    "cuffs:dragPlayer",
    function(target)
        local _source = source
        local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
        local targetCoords = GetEntityCoords(GetPlayerPed(target))
        if #(sourceCoords - targetCoords) <= 50.0 then
            TriggerClientEvent("cuffs:dragTarget", target, _source, style)
            Player(target).state.isDragged = _source
        else
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "cuffs:cuffPlayer",
                "Hráč se pokusil vzít někoho, kdo není blízko!"
            )
        end
    end
)

RegisterNetEvent("cuffs:undragPlayer")
AddEventHandler(
    "cuffs:undragPlayer",
    function(target)
        local _source = source
        local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
        local targetCoords = GetEntityCoords(GetPlayerPed(target))
        if #(sourceCoords - targetCoords) <= 50.0 then
            Player(target).state.isDragged = false
            TriggerClientEvent("cuffs:undragPlayer", target)
        else
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "cuffs:cuffPlayer",
                "Hráč se pokusil pustit někoho, kdo není blízko!"
            )
        end
    end
)


RegisterNetEvent("cuffs:putInVehicle")
AddEventHandler(
	"cuffs:putInVehicle",
	function(target)
        Player(target).state.isDragged = false
		TriggerClientEvent("cuffs:putInVehicle", target)
	end
)

RegisterNetEvent("cuffs:outVehicle")
AddEventHandler(
	"cuffs:outVehicle",
	function(target)
		TriggerClientEvent("cuffs:outVehicle", target)
	end
)