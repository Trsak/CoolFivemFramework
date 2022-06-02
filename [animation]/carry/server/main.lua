RegisterNetEvent("carry:startCarry")
AddEventHandler(
	"carry:startCarry",
	function(target)
		local _source = source
		local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
		local targetCoords = GetEntityCoords(GetPlayerPed(target))
		local isDead = (exports.data:getUserVar(target, "status") == "dead")
		local distance = #(sourceCoords - targetCoords)
		if distance <= (isDead and 200.0  or 50.0) then
			Player(_source).state.isCarrying = target
			Player(target).state.isCarried = _source
			TriggerClientEvent("carry:carryTarget", target, _source)
		else
			exports.admin:banClientForCheating(_source, "0", "Cheating", "carry:startCarry", "Hráč se pokusil vzít někoho, kdo je ve vzdálenosti " .. distance.. " !")
		end
	end
)

RegisterNetEvent("carry:startLift")
AddEventHandler(
	"carry:startLift",
	function(target)
		local _source = source
		local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
		local targetCoords = GetEntityCoords(GetPlayerPed(target))
		local isDead = (exports.data:getUserVar(target, "status") == "dead")
		local distance = #(sourceCoords - targetCoords)
		if distance <= (isDead and 200.0  or 50.0) then
			Player(_source).state.isLifting = target
			Player(target).state.isLifted = _source
			TriggerClientEvent("carry:liftTarget", target, _source)
		else
			exports.admin:banClientForCheating(_source, "0", "Cheating", "carry:startLift", "Hráč se pokusil vzít někoho, kdo je ve vzdálenosti " .. distance.. " !")
		end
	end
)

RegisterNetEvent("carry:startBackride")
AddEventHandler(
	"carry:startBackride",
	function(target)
		local _source = source
		local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
		local targetCoords = GetEntityCoords(GetPlayerPed(target))
		local isDead = (exports.data:getUserVar(target, "status") == "dead")
		local distance = #(sourceCoords - targetCoords)
		if distance <= (isDead and 500.0  or 50.0) then
			Player(_source).state.isLifting = target
			Player(target).state.isLifted = _source
			TriggerClientEvent("carry:backrideTarget", target, _source)
		else
			exports.admin:banClientForCheating(_source, "0", "Cheating", "carry:startBackride", "Hráč se pokusil vzít někoho, kdo je ve vzdálenosti " .. distance.. " !")
		end
	end
)

RegisterNetEvent("carry:stopCarry")
AddEventHandler(
	"carry:stopCarry",
	function(target)
		Player(source).state.isCarrying = nil
		Player(target).state.isCarrying = nil
		Player(source).state.isCarried = nil
		Player(target).state.isCarried = nil
		TriggerClientEvent("carry:stopCarry", target)
	end
)

RegisterNetEvent("carry:stopLift")
AddEventHandler(
	"carry:stopLift",
	function(target)
		Player(source).state.isLifting = nil
		Player(target).state.isLifting = nil
		Player(source).state.isLifted = nil
		Player(target).state.isLifted = nil
		TriggerClientEvent("carry:stopLift", target)
	end
)

RegisterNetEvent("carry:stopBackride")
AddEventHandler(
	"carry:stopBackride",
	function(target)
		Player(source).state.isLifting = nil
		Player(target).state.isLifting = nil
		Player(source).state.isLifted = nil
		Player(target).state.isLifted = nil
		TriggerClientEvent("carry:stopBackride", target)
	end
)
