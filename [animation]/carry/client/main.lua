local isCarried, isCarrying = false, false
local isLifted, isLifting = false, false
local isSpawned, isDead = false, false
local isInPhone, isCuffed = false, false
Citizen.CreateThread(
	function()
		Citizen.Wait(500)

		local status = exports.data:getUserVar("status")
		if status == "spawned" or status == "dead" then
			isSpawned = true
			isDead = (status == "dead")
		end
	end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
	"s:statusUpdated",
	function(status)
		if status == "choosing" then
			isSpawned = false
		elseif status == "spawned" or status == "dead" then
			isSpawned = true
			isDead = (status == "dead")
		end
	end
)

RegisterNetEvent("gcPhone:toggle")
AddEventHandler(
	"gcPhone:toggle",
	function(status)
		isInPhone = status
	end
)

RegisterNetEvent("rp:updateCuffed")
AddEventHandler(
	"rp:updateCuffed",
	function(status)
		isCuffed = status
	end
)

RegisterCommand(
	"carry",
	function()
		carry()
	end
)
RegisterCommand(
	"nest",
	function()
		carry()
	end
)
RegisterCommand(
	"liftup",
	function()
		liftup()
	end
)
RegisterCommand(
	"donaruci",
	function()
		liftup()
	end
)
RegisterCommand(
	"backride",
	function()
		backride()
	end
)
RegisterCommand(
	"nazadech",
	function()
		backride()
	end
)

function carry()
	if not isCuffed then
		if not isCarried and not isCarrying and not isDead then
			if not isLifted and not isLifting then
				TriggerEvent(
					"util:closestPlayer",
					{
						radius = 2.0
					},
					function(player)
						if player then
							local target = Player(player).state
							if not target.isCarried and not target.isCarrying and not target.isLifted and not target.isLifting then
								TriggerServerEvent("carry:startCarry", player)
								startCarry(player)
							end
						end
					end
				)
			end
		else
			stopCarry(true)
		end
	else
		exports.notify:display(
			{type = "error", title = "Chyba", text = "Jsi spoutaný!", icon = "fas fa-times", length = 4000}
		)
	end
end

function startCarry(target)
	Citizen.CreateThread(
		function()
			TriggerEvent("carry:update", true)
			isCarrying = target
			local anim = Config.Anims.Source.Carry
			loadAnimDict(anim.AnimDict)
			while isCarrying do
				if not IsEntityPlayingAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 3) then
					TaskPlayAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 8.0, 8.0, -1, 49, 0, 0, 0, 0)
				end
				if isDead or isCuffed then
					stopCarry(true)
				end

				Citizen.Wait(500)
			end
		end
	)
end

RegisterNetEvent("carry:carryTarget")
AddEventHandler(
	"carry:carryTarget",
	function(target)
		TriggerEvent("carry:update", true)
		local tPed = GetPlayerPed(GetPlayerFromServerId(target))
		isCarried = target
		local anim = Config.Anims.Target.Carry
		loadAnimDict(anim.AnimDict)

		AttachEntityToEntity(PlayerPedId(), tPed, 0, 0.3, -0.1, 0.63, 0.5, 0.5, 180.0, false, false, false, false, 2, false)
		while isCarried do
			if not IsEntityPlayingAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 3) then
				TaskPlayAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 8.0, 8.0, -1, 1, 0, false, false, false)
				if isCuffed then
					stopCarry()
				end
			end
			Citizen.Wait(500)
		end
	end
)

RegisterNetEvent("carry:stopCarry")
AddEventHandler(
	"carry:stopCarry",
	function()
		stopCarry()
	end
)

function stopCarry(first)
	local pPed = PlayerPedId()
	local tPed = GetPlayerPed(GetPlayerFromServerId(isCarrying and isCarrying or isCarried))
	if first then
		TriggerServerEvent("carry:stopCarry", isCarrying and isCarrying or isCarried)
	end
	if isCarrying then
		ClearPedTasksImmediately(pPed)
		ClearPedTasksImmediately(tPed)
		isCarrying = nil
	elseif isCarried then
		ClearPedTasksImmediately(tPed)
		ClearPedTasksImmediately(pPed)
		isCarried = nil
	end
	TriggerEvent("carry:update", false)
	DetachEntity(pPed, true, false)
end

function liftup()
	if not isCuffed then
		if not isLifted and not isLifting and not isDead then
			if not isCarried and not isCarrying then
				TriggerEvent(
					"util:closestPlayer",
					{
						radius = 2.0
					},
					function(player)
						if player then
							local target = Player(player).state
							if not target.isCarried and not target.isCarrying and not target.isLifted and not target.isLifting then
								TriggerServerEvent("carry:startLift", player)
								startLift(player)
							end
						end
					end
				)
			end
		else
			stopLift(true)
		end
	else
		exports.notify:display(
			{type = "error", title = "Chyba", text = "Jsi spoutaný!", icon = "fas fa-times", length = 4000}
		)
	end
end

function startLift(target)
	Citizen.CreateThread(
		function()
			TriggerEvent("carry:update", true)
			isLifting = target
			local anim = Config.Anims.Source.Liftup
			loadAnimDict(anim.AnimDict)
			while isLifting do
				if not IsEntityPlayingAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 3) then
					TaskPlayAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 8.0, 8.0, -1, 50, 0, false, false, false)
				end
				if isDead or isCuffed then
					stopLift(true)
				end

				Citizen.Wait(500)
			end
		end
	)
end

function stopLift(first)
	local pPed = PlayerPedId()
	local tPed = GetPlayerPed(GetPlayerFromServerId(isLifting and isLifting or isLifted))
	if first then
		TriggerServerEvent("carry:stopLift", isLifting and isLifting or isLifted)
	end
	if isLifting then
		ClearPedTasksImmediately(pPed)
		ClearPedTasksImmediately(tPed)
		isLifting = nil
	elseif isLifted then
		ClearPedTasksImmediately(tPed)
		ClearPedTasksImmediately(pPed)
		isLifted = nil
	end
	TriggerEvent("carry:update", false)
	DetachEntity(pPed, true, false)
end

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(25)
	end
end

RegisterNetEvent("carry:liftTarget")
AddEventHandler(
	"carry:liftTarget",
	function(target)
		TriggerEvent("carry:update", true)
		local tPed = GetPlayerPed(GetPlayerFromServerId(target))
		isLifted = target
		local anim = Config.Anims.Target.Liftup
		loadAnimDict(anim.AnimDict)

		AttachEntityToEntity(
			PlayerPedId(),
			tPed,
			9816,
			0.015,
			0.38,
			0.11,
			0.9,
			0.30,
			90.0,
			false,
			false,
			false,
			false,
			2,
			false
		)
		while isLifted do
			if not IsEntityPlayingAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 3) then
				TaskPlayAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 8.0, -8, -1, 33, 0, 0, 40, 0)
				if isCuffed then
					stopLift(true)
				end
			end
			Citizen.Wait(500)
		end
	end
)

RegisterNetEvent("carry:stopLift")
AddEventHandler(
	"carry:stopLift",
	function()
		stopLift()
	end
)

function backride()
	if not isCuffed then
		if not isLifted and not isLifting and not isDead then
			if not isCarried and not isCarrying then
				TriggerEvent(
					"util:closestPlayer",
					{
						radius = 2.0
					},
					function(player)
						if player then
							local target = Player(player).state
							if not target.isCarried and not target.isCarrying and not target.isLifted and not target.isLifting then
								TriggerServerEvent("carry:startBackride", player)
								startBackride(player)
							end
						end
					end
				)
			end
		else
			stopLift(true)
		end
	else
		exports.notify:display(
			{type = "error", title = "Chyba", text = "Jsi spoutaný!", icon = "fas fa-times", length = 4000}
		)
	end
end

function startBackride(target)
	Citizen.CreateThread(
		function()
			TriggerEvent("carry:update", true)
			isLifting = target
			local anim = Config.Anims.Source.Backride
			loadAnimDict(anim.AnimDict)
			while isLifting do
				if not IsEntityPlayingAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 3) then
					TaskPlayAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 8.0, 8.0, -1, 50, 0, false, false, false)
					Citizen.Wait(500)
					SetEntityAnimSpeed(PlayerPedId(), anim.AnimDict, anim.Anim, 0.0)
					SetEntityAnimSpeed(GetPlayerPed(target), Config.Anims.Target.Backride.AnimDict, Config.Anims.Target.Backride.Anim, 0.0)
				end
				if isCuffed then
					stopLift(true)
				end

				Citizen.Wait(500)
			end
		end
	)
end

function stopBackride(first)
	local pPed = PlayerPedId()
	local tPed = GetPlayerPed(GetPlayerFromServerId(isLifting and isLifting or isLifted))
	if first then
		TriggerServerEvent("carry:stopBackride", isLifting and isLifting or isLifted)
	end
	if isLifting then
		ClearPedTasksImmediately(pPed)
		ClearPedTasksImmediately(tPed)
		isLifting = nil
	elseif isLifted then
		ClearPedTasksImmediately(tPed)
		ClearPedTasksImmediately(pPed)
		isLifted = nil
	end
	TriggerEvent("carry:update", false)
	DetachEntity(pPed, true, false)
end

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(25)
	end
end

RegisterNetEvent("carry:backrideTarget")
AddEventHandler(
	"carry:backrideTarget",
	function(target)
		TriggerEvent("carry:update", true)
		local tPed = GetPlayerPed(GetPlayerFromServerId(target))
		isLifted = target
		local anim = Config.Anims.Target.Backride
		loadAnimDict(anim.AnimDict)

		AttachEntityToEntity(
			PlayerPedId(),
			tPed,
			0,
			0.0,
			-0.07,
			0.45,
			0.5,
			0.5,
			0.0,
			false,
			false,
			false,
			false,
			2,
			false
		)
		while isLifted do
			if not IsEntityPlayingAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 3) then
				TaskPlayAnim(PlayerPedId(), anim.AnimDict, anim.Anim, 8.0, -8, -1, 33, 0, 0, 40, 0)
				Citizen.Wait(500)
				SetEntityAnimSpeed(PlayerPedId(), anim.AnimDict, anim.Anim, 0.0)
				SetEntityAnimSpeed(GetPlayerPed(target), Config.Anims.Target.Backride.AnimDict, Config.Anims.Target.Backride.Anim, 0.0)
				if isDead or isCuffed then
					stopLift(true)
				end
			end
			Citizen.Wait(500)
		end
	end
)

RegisterNetEvent("carry:stopBackride")
AddEventHandler(
	"carry:stopBackride",
	function()
		stopBackride()
	end
)