local isSpawned, isDead = false, false
local isCuffing, isCuffed = false, false
local isDragging, isDragged = false, false

Citizen.CreateThread(
	function()
		Citizen.Wait(500)

		local status = exports.data:getUserVar("status")
		if status == ("spawned" or "dead") then
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
		elseif status == ("spawned" or "dead") then
			isSpawned = true
			isDead = (status == "dead")
		end
	end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
	"inventory:usedItem",
	function(itemName, slot, data)
		if not isDead then
			if itemName == "cuffs" then
				if not isCuffed and not isCuffing then
					if canDoAction() then
						cuff()
					end
				end
			elseif itemName == "cuffkey" then
				uncuff()
			end
		end
	end
)
function cuff()
	TriggerEvent(
		"util:closestPlayer",
		{
			radius = 2.0
		},
		function(player)
			if player then
				WarMenu.CreateMenu("cuffs", "Pouta", "Zvolte druh spoutání")
				WarMenu.SetMenuY("cuffs", 0.35)
				WarMenu.OpenMenu("cuffs")
				while WarMenu.IsMenuOpened("cuffs") do
					if WarMenu.Button("Spoutat silně") then
						checkIsCuffed(player, "strong")
						WarMenu.CloseMenu()
					elseif WarMenu.Button("Spoutat lehce") then
						checkIsCuffed(player, "weak")
						WarMenu.CloseMenu()
					elseif WarMenu.Button("Ruce dopředu") then
						checkIsCuffed(player, "front")
					end
					WarMenu.Display()
					Citizen.Wait(0)
				end
			end
		end
	)
end

function checkIsCuffed(player, style)
	WarMenu.CloseMenu()
	if not Player(player).state.isCuffed then
		TriggerServerEvent("cuffs:cuffPlayer", player, style)
	else
		exports.notify:display(
			{type = "error", title = "Chyba", text = "Hráč je již spoután!", icon = "fas fa-times", length = 4000}
		)
	end
end

RegisterNetEvent("cuffs:startCuff")
AddEventHandler(
	"cuffs:startCuff",
	function(style)
		if style == "strong" then
			exports.emotes:cancelEmote()
			loadAnimDict("mp_arrest_paired")
			isCuffing = true

			Citizen.CreateThread(
				function()
					while isCuffing do
						DisablePlayerFiring(PlayerId(), true)
						Citizen.Wait(1)
					end
				end
			)

			TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "cop_p2_back_right", 8.0, -8.0, 5500, 33, 0, false, false, false)
			isCuffing = false
		elseif style == "weak" then
			exports.emotes:cancelEmote()
			loadAnimDict("mp_arresting")
			isCuffing = true

			Citizen.CreateThread(
				function()
					while isCuffing do
						DisablePlayerFiring(PlayerId(), true)
						Citizen.Wait(1)
					end
				end
			)

			TaskPlayAnim(PlayerPedId(), "mp_arresting", "a_uncuff", 8.0, -8, 3000, 2, 0, 0, 0, 0)
			isCuffing = false
		elseif style == "front" then
			exports.emotes:cancelEmote()
			loadAnimDict("mp_arresting")
			isCuffing = true

			Citizen.CreateThread(
				function()
					while isCuffing do
						DisablePlayerFiring(PlayerId(), true)
						Citizen.Wait(1)
					end
				end
			)

			TaskPlayAnim(PlayerPedId(), "mp_arresting", "a_uncuff", 8.0, -8, 3000, 2, 0, 0, 0, 0)
			isCuffing = false
		end
	end
)

RegisterNetEvent("cuffs:cuffTarget")
AddEventHandler(
	"cuffs:cuffTarget",
	function(source, style)
		local pPed = PlayerPedId()
		local tPed = GetPlayerPed(GetPlayerFromServerId(source))

		if not isCuffed and not isDead then
			exports.emotes:cancelEmote()
			TriggerEvent("rp:updateCuffed", true)
			isCuffed = style
			if style == "strong" then
				loadAnimDict("mp_arrest_paired")
				AttachEntityToEntity(pPed, tPed, 11816, 0.07, 1.1, 0.0, 80.0, 100.0, 20.0, false, false, false, false, 20)
				TaskPlayAnim(pPed, "mp_arrest_paired", "crook_p2_back_right", 8.0, -8.0, 5500, 33, 0)

				Citizen.Wait(5500)

				DetachEntity(pPed, true, false)
				ClearPedTasks(pPed)
				loadAnimDict("mp_arresting")
				exports.emotes:DisableEmotes(true)
				while isCuffed do
					if not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) then
						TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
					end
					disableControl()
					SetEnableHandcuffs(PlayerPedId(), true)
					SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
					SetPedCanPlayGestureAnims(PlayerPedId(), false)
					DisplayRadar(false)
					Citizen.Wait(0)
				end
			elseif style == "weak" then
				loadAnimDict("mp_arresting")
				AttachEntityToEntity(pPed, tPed, 11816, 0.035, 0.7, 0.0, 80.0, 100.0, 20.0, false, false, false, false, 20)
				TaskPlayAnim(pPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
				Citizen.Wait(3760)
				DetachEntity(pPed, true, false)
				exports.emotes:DisableEmotes(true)
				while isCuffed do
					if not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) then
						TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
					end
					disableControl()
					SetEnableHandcuffs(PlayerPedId(), true)
					SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
					SetPedCanPlayGestureAnims(PlayerPedId(), false)
					DisplayRadar(false)
					Citizen.Wait(0)
				end
			elseif style == "front" then
				loadAnimDict("anim@move_m@prisoner_cuffed")
				AttachEntityToEntity(pPed, tPed, 11816, 0.035, 0.7, 0.0, 0.0, 0.0, 180.0, false, false, false, false, 20)
				TaskPlayAnim(pPed, "anim@move_m@prisoner_cuffed", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
				Citizen.Wait(3760)
				DetachEntity(pPed, true, false)
				exports.emotes:DisableEmotes(true)
				while isCuffed do
					if not IsEntityPlayingAnim(PlayerPedId(), "anim@move_m@prisoner_cuffed", "idle", 3) then
						TaskPlayAnim(PlayerPedId(), "anim@move_m@prisoner_cuffed", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
					end
					disableControl()
					SetEnableHandcuffs(PlayerPedId(), true)
					SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
					SetPedCanPlayGestureAnims(PlayerPedId(), false)
					DisplayRadar(false)
					Citizen.Wait(0)
				end
			end
		end
	end
)
-- Uncuff

function uncuff(checkItem)
	if checkItem then
		TriggerServerEvent("cuffs:checkItem", "keycuff")
		return
	end
	TriggerEvent(
		"util:closestPlayer",
		{
			radius = 2.0
		},
		function(player)
			if player then
				if Player(player).state.isCuffed then
					TriggerServerEvent("cuffs:uncuffPlayer", player)
				else
					exports.notify:display(
						{type = "error", title = "Chyba", text = "Hráč nemá pouta!", icon = "fas fa-times", length = 4000}
					)
				end
			end
		end
	)
end

RegisterNetEvent("cuffs:startUncuff")
AddEventHandler(
	"cuffs:startUncuff",
	function(style)
		local pPed = PlayerPedId()
		if style == "strong" or style == "weak" then
			exports.emotes:cancelEmote()
			Citizen.Wait(50)
			isCuffing = true
			loadAnimDict("mp_arresting")

			TaskPlayAnim(pPed, "mp_arresting", "a_uncuff", 8.0, -8.0, 5500, 33, 0, false, false, false)

			Citizen.Wait(50)
			while IsEntityPlayingAnim(pPed, "mp_arresting", "a_uncuff", 3) do
				Wait(200)
			end
			isCuffing = false
		elseif style == "Front" then
		end
	end
)

RegisterNetEvent("cuffs:uncuffTarget")
AddEventHandler(
	"cuffs:uncuffTarget",
	function(source)
		local pPed = PlayerPedId()
		local tPed = GetPlayerPed(GetPlayerFromServerId(source))

		if isCuffed and not isDead then
			if isCuffed == "strong" or isCuffed == "weak" then
				Citizen.Wait(3500)
				ClearPedSecondaryTask(pPed)
				SetEnableHandcuffs(pPed, false)
				SetPedCanPlayGestureAnims(pPed, true)
			elseif isCuffed == "front" then
				loadAnimDict("anim@move_m@prisoner_cuffed")
				AttachEntityToEntity(pPed, tPed, 11816, 0.035, 0.7, 0.0, 0.0, 0.0, 180.0, false, false, false, false, 20, false)
				TaskPlayAnim(pPed, "anim@move_m@prisoner_cuffed", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
				Citizen.Wait(3760)
				DetachEntity(pPed, true, false)
				ClearPedSecondaryTask(pPed)
				SetEnableHandcuffs(pPed, false)
				SetPedCanPlayGestureAnims(pPed, true)
			end
			TriggerServerEvent("cuffs:startUncuff", true, source, isCuffed)
			exports.emotes:cancelEmote()
			TriggerEvent("rp:updateCuffed", false)
			isCuffed = false
			exports.emotes:DisableEmotes(false)
		end
	end
)

function disableControl()
	DisableControlAction(1, 23, true)
	DisableControlAction(1, 24, true)
	DisableControlAction(1, 25, true)
	DisableControlAction(0, 37, true) -- Select Weapon
	DisableControlAction(0, 44, true) -- Cover
	DisableControlAction(0, 45, true) -- Reload
	DisableControlAction(1, 55, true)
	DisableControlAction(1, 75, true)
	DisableControlAction(1, 75, true)
	DisableControlAction(0, 257, true) -- Attack 2
	DisableControlAction(0, 263, true) -- Melee Attack 1
	DisableControlAction(0, 288, true) -- Disable phone
	DisableControlAction(0, 170, true) -- Animations
	DisableControlAction(0, 167, true) -- Job
	DisableControlAction(0, 0, true) -- Disable changing view
	DisableControlAction(0, 26, true) -- Disable looking behind
	DisableControlAction(0, 73, true) -- Disable clearing animation
	DisableControlAction(2, 199, true) -- Disable pause screen

	DisableControlAction(0, 59, true) -- Disable steering in vehicle
	DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
	DisableControlAction(0, 72, true) -- Disable reversing in vehicle

	DisableControlAction(2, 36, true) -- Disable going stealth

	DisableControlAction(0, 47, true) -- Disable weapon
	DisableControlAction(0, 264, true) -- Disable melee
	DisableControlAction(0, 257, true) -- Disable melee
	DisableControlAction(0, 140, true) -- Disable melee
	DisableControlAction(0, 141, true) -- Disable melee
	DisableControlAction(0, 142, true) -- Disable melee
	DisableControlAction(0, 143, true) -- Disable melee
	DisableControlAction(0, 75, true) -- Disable exit vehicle
	DisableControlAction(27, 75, true) -- Disable exit vehicle
end

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(25)
	end
end

function takePlayer()
	if not isDragging then
		TriggerEvent(
			"util:closestPlayer",
			{
				radius = 2.0
			},
			function(player)
				if player then
					if canDoAction() then
						if not Player(player).state.isDragged then
							if Player(player).state.isCuffed then
								isDragging = player
								exports.emotes:DisableEmotes(true)
								TriggerServerEvent("cuffs:dragPlayer", player)
								Citizen.CreateThread(
									function()
										while isDragging do
											Citizen.Wait(0)
											disableControl()
										end
										exports.emotes:DisableEmotes(false)
									end
								)
							else
								exports.notify:display(
									{type = "error", title = "Chyba", text = "Hráč nemá pouta!", icon = "fas fa-times", length = 4000}
								)
							end
						else
							exports.notify:display(
								{type = "error", title = "Chyba", text = "Hráče již vede někdo jiný!", icon = "fas fa-times", length = 4000}
							)
						end
					end
				end
			end
		)
	else
		TriggerServerEvent("cuffs:undragPlayer", isDragging)
		isDragging = false
	end
end

function vehiclePlayer()
	if not isCuffed and not isCuffing and GetVehiclePedIsIn(PlayerPedId()) == 0 then
		if isDragging then
			local draggedPed = GetPlayerPed(GetPlayerFromServerId(isDragging))
			if DoesEntityExist(draggedPed) then
				local veh = GetVehiclePedIsIn(draggedPed)

				if veh == 0 then
					TriggerServerEvent("cuffs:putInVehicle", isDragging)
					isDragging = false
				end
			end
		else
			TriggerEvent(
				"util:closestPlayer",
				{
					radius = 2.0
				},
				function(player)
					if player then
						local veh = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(player)))

						if veh ~= 0 then
							TriggerServerEvent("cuffs:outVehicle", player)
						end
					end
				end
			)
		end
	end
end

function canDoAction()
	if not isCuffed and not isCuffing and not isDragged and not isDragging and GetVehiclePedIsIn(PlayerPedId()) == 0 then
		return true
	end
	exports.notify:display(
		{type = "error", title = "Akce", text = "Nelze momentálně provést akci!", icon = "fas fa-times", length = 3000}
	)
	return false
end

RegisterNetEvent("cuffs:dragTarget")
AddEventHandler(
	"cuffs:dragTarget",
	function(source)
		isDragged = source
		while isDragged and isCuffed do
			if isDragged then
				playerPed = PlayerPedId()
				sourcePed = GetPlayerPed(GetPlayerFromServerId(isDragged))
				if not IsPedSittingInAnyVehicle(sourcePed) then
					AttachEntityToEntity(
						playerPed,
						sourcePed,
						11816,
						0.54,
						0.54,
						0.0,
						0.0,
						0.0,
						0.0,
						false,
						false,
						false,
						false,
						2,
						true
					)
				else
					DetachEntity(playerPed, true, false)
				end

				if IsPedDeadOrDying(sourcePed, true) then
					isDragged = false
					DetachEntity(playerPed, true, false)
				end
			end
			Citizen.Wait(100)
		end
		isDragged = false
		DetachEntity(playerPed, true, false)
	end
)

RegisterNetEvent("cuffs:undragPlayer")
AddEventHandler(
	"cuffs:undragPlayer",
	function()
		isDragged = false
	end
)

SetEnableHandcuffs(PlayerPedId(), false)
SetPedCanPlayGestureAnims(PlayerPedId(), true)

RegisterNetEvent("cuffs:putInVehicle")
AddEventHandler(
	"cuffs:putInVehicle",
	function()
		if not isDragged then
			return
		end

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		local vehicle = getVehicleInDirection(2.5)

		if not DoesEntityExist(vehicle) then
			vehicle = GetClosestVehicle(coords, 5.0, 0, 71)
		end

		if DoesEntityExist(vehicle) then
			local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
			local freeSeat = 0

			for i = 1, maxSeats do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat ~= 0 then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				isDragged = false
			end
		end
	end
)

RegisterNetEvent("cuffs:outVehicle")
AddEventHandler(
	"cuffs:outVehicle",
	function()
		local playerPed = PlayerPedId()

		if not IsPedSittingInAnyVehicle(playerPed) then
			return
		end

		local vehicle = GetVehiclePedIsIn(playerPed)
		TaskLeaveVehicle(playerPed, vehicle, 16)
	end
)

function getVehicleInDirection(range)
    local coordA = GetEntityCoords(PlayerPedId(), 1)
    local coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, range, 0.0)

    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 10, PlayerPedId(), 0)
    local a, b, c, d, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end