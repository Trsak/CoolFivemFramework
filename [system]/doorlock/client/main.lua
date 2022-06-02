local doorsChanging = {}
local doorsState = {}
local isSpawned = false
local jobs = {}
local forcingIn = false
local closestDoors = nil
local isDoingAction = false

Citizen.CreateThread(
	function()
		Citizen.Wait(500)

		local status = exports.data:getUserVar("status")

		if status == "spawned" or status == "dead" then
			isSpawned = true
			isDead = (status == "dead")

			loadJobs()
		end
	end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
	"s:jobUpdated",
	function(newJobs)
		loadJobs(newJobs)
	end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
	"s:statusUpdated",
	function(status)
		if status == "choosing" then
			isSpawned, isDead, jobs = false, false, {}
		elseif status == "spawned" or status == "dead" then
			isDead = (status == "dead")

			if not isSpawned then
				isSpawned = true
				loadJobs()
				TriggerServerEvent("doorlock:getDoorsState")
			end
		end
	end
)

RegisterNetEvent("doorlock:doorsState")
AddEventHandler(
	"doorlock:doorsState",
	function(doors)
		doorsState = doors
		for key, door in pairs(doorsState) do
			applyDoorState(key)
		end
	end
)

function applyDoorState(key)
	local doorId = doorsState[key]

	if not doorId.applied then
		for _, door in each(doorId.objects) do
			local closeDoor =
				GetClosestObjectOfType(
				door.objCoords.x,
				door.objCoords.y,
				door.objCoords.z,
				1.0,
				GetHashKey(door.objName),
				false,
				false,
				false
			)

			if DoesEntityExist(closeDoor) then
				if not IsDoorRegisteredWithSystem(closeDoor) then
					AddDoorToSystem(closeDoor, GetHashKey(door.objName), door.objCoords, true, true, true)
				end

				if DoorSystemGetDoorState(closeDoor) ~= doorId.locked then
					DoorSystemSetDoorState(closeDoor, doorId.locked, true, true)
				end
				doorId.applied = true
			end
		end
	end
end

RegisterNetEvent("doorlock:updateState")
AddEventHandler(
	"doorlock:updateState",
	function(doorID, state)
		if doorsState[doorID] then
			doorsState[doorID].locked = state
			doorsState[doorID].applied = false
			applyDoorState(doorID)
		end
	end
)

Citizen.CreateThread(
	function()
		while true do
			if isSpawned and tableLength(doorsState) ~= 0 then
				local playerCoords = GetEntityCoords(PlayerPedId())
				closestDoors = nil

				for key, doorData in pairs(doorsState) do
					local distance = #(playerCoords - doorData.text)
					local maxDistance = 1.25
					if doorData.distance then
						maxDistance = doorData.distance
					end
					if distance < 25.0 then
						applyDoorState(key)

						if distance <= maxDistance then
							if not closestDoors or closestDoors.distance > distance then
								closestDoors = {
									distance = distance,
									doorsID = key
								}
							end
						end
					elseif doorData.applied then
						doorData.applied = false
					end
				end
			end
			Citizen.Wait(250)
		end
	end
)

RegisterCommand(
	"openDoors",
	function()
		if closestDoors then
			if not isDoingAction then
				local hasKey = exports.inventory:checkDoorKey(doorsState[closestDoors.doorsID].key_id)
				if hasKey and not isDead then
					isDoingAction = true
					local id = closestDoors.doorsID
					local doorID = doorsState[id]

					local text = "Odemykáš dveře.."
					if not doorID.locked then
						text = "Zamykáš dveře.."
					end

					if not IsPedInAnyVehicle(PlayerPedId(), false) then
						makeEntityFaceCoords(PlayerPedId(), doorID.text)
					end
					exports.progressbar:startProgressBar({
						Duration = 800,
						Label = text,
						CanBeDead = false,
						CanCancel = true,
						DisableControls = {
							Movement = false,
							CarMovement = true,
							Mouse = false,
							Combat = true
						},
						Animation = {
							animDict = "anim@heists@keycard@",
							anim = "exit"
						}
					}, function(finished)
						isDoingAction = false
						if finished then
							doorID.locked = not doorID.locked
							TriggerServerEvent("doorlock:updateState", id, doorID.locked)
							applyDoorState(id)
						end
					end)
				end
			end
		end
	end
)
createNewKeyMapping({command = "openDoors", text = "Odemykání / zamykání dveří a vrat", key = "e"})

RegisterCommand(
	"forceOpen",
	function()
		if isSpawned and not isDead and closestDoors and not isDoingAction then
			if hasWhitelistedJob() or exports.data:getUserVar("admin") > 1 then
				isDoingAction = true
				local id = closestDoors.doorsID
				local doorID = doorsState[id]

				if not IsPedInAnyVehicle(PlayerPedId(), false) then
					makeEntityFaceCoords(PlayerPedId(), doorID.text)
				end

				exports.progressbar:startProgressBar({
					Duration = 5000,
					Label = "Vykopáváš dveře..",
					CanBeDead = false,
					CanCancel = true,
					DisableControls = {
						Movement = false,
						CarMovement = true,
						Mouse = false,
						Combat = true
					},
					Animation = {
						animDict = "anim@amb@casino@brawl@attacks@slot_machine@",
						anim = "rocking_slot_machine_loop_mp_m_brawler",
					}
				}, function(finished)
					isDoingAction = false
					if finished then
						doorID.locked = not doorID.locked
						TriggerServerEvent("doorlock:updateState", id, false)
						applyDoorState(id)
					end
				end)
			end
		end
	end
)

function makeEntityFaceCoords(entity1, p2)
	local p1 = GetEntityCoords(entity1, true)

	local dx = p2.x - p1.x
	local dy = p2.y - p1.y

	local heading = GetHeadingFromVector_2d(dx, dy)
	SetEntityHeading(entity1, heading)
end

function hasWhitelistedJob()
	for job, data in each(jobs) do
		if Config.AllowedKick[data.Type] and data.Duty then
			return true
		end
	end

	return false
end

function loadJobs(Jobs)
	jobs = {}
	for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
		jobs[data.job] = {
			Name = data.job,
			Type = exports.base_jobs:getJobVar(data.job, "type"),
			Grade = data.job_grade,
			Duty = data.duty
		}
	end
end

function round(number)
	return string.format("%.1f", number)
end

local creatingDoors = false
local newDoors = {}
local debug = false

RegisterCommand(
	"doorlock_dev",
	function(source, args)
		if exports.data:getUserVar("admin") > 2 then
			Citizen.CreateThread(
				function()
					WarMenu.CreateMenu("doorlock-dev", "Dveře DEV", "Zvolte akci")
					WarMenu.OpenMenu("doorlock-dev")
					WarMenu.CreateSubMenu("doorlock-create", "doorlock-dev", "Vytvořte dveře!")
					WarMenu.CreateSubMenu("doorlock-keys", "doorlock-create", "Zadejte možné klíče")
					WarMenu.CreateSubMenu("doorlock-objects", "doorlock-create", "Přidejte objekty")

					while true do
						if WarMenu.IsMenuOpened("doorlock-dev") then
							if WarMenu.MenuButton("Vytvořit dveře", "doorlock-create") then
							elseif WarMenu.Button("Zapnout / Vypnout debug mode") then
								if not debug then
									debug = true
								else
									debug = false
								end
							end
							if debug then
							--
							end
							WarMenu.Display()
						elseif WarMenu.IsMenuOpened("doorlock-create") then
							if not creatingDoors then
								if WarMenu.Button("Začít vytvářet") then
									creatingDoors = true
									newDoors = {
										Keys = {},
										Text = {},
										Objects = {},
										Locked = true,
										Distance = 1,
										Note = "nenastaveno"
									}
								end
							end
							if creatingDoors then
								if WarMenu.MenuButton("Přidat klíče", "doorlock-keys") then
								elseif WarMenu.MenuButton("Přidat objekty", "doorlock-objects") then
								elseif WarMenu.Button("Souřadnice") then
									local currentCoords = GetEntityCoords(PlayerPedId())
									newDoors.Text = {x = currentCoords.x, y = currentCoords.y, z = currentCoords.z}
								elseif WarMenu.Button("Nastavit vzdálenost", newDoors.Distance) then
									exports.input:openInput(
										"number",
										{title = "Zadejte vzdálenost!", placeholder = ""},
										function(distance)
											if distance then
												newDoors.Distance = distance
											end
										end
									)
								elseif WarMenu.Button("Nastavit základní hodnotu", newDoors.Locked and "Zamknuto" or "Odemknuto") then
									exports.input:openInput(
										"text",
										{title = "Zadejte hodnotu - locked / unlocked!", placeholder = ""},
										function(type)
											if type then
												if type == "locked" or type == "unlocked" then
													newDoors.Locked = (type == "locked" and true or false)
												else
													TriggerEvent(
														"chat:addMessage",
														{
															templateId = "error",
															args = {"Nesprávně zadaná hodnota!"}
														}
													)
												end
											end
										end
									)
								elseif WarMenu.Button("Uložit dveře") then
									TriggerServerEvent("doorlock:createDoors", newDoors)
									creatingDoors, newDoors = false, {}
								end
							end
							WarMenu.Display()
						elseif WarMenu.IsMenuOpened("doorlock-keys") then
							if WarMenu.Button("Přidat klíče") then
								exports.input:openInput(
									"text",
									{title = "Zadejte jméno klíčů!", placeholder = ""},
									function(keys)
										if keys then
											table.insert(newDoors.Keys, keys)
											TriggerEvent(
												"chat:addMessage",
												{
													templateId = "success",
													args = {"Přidal jsi klíče!"}
												}
											)
										else
										end
									end
								)
							end
							for i, keys in each(newDoors.Keys) do
								if WarMenu.Button("Klíče #" .. i, keys) then
									table.remove(newDoors.Keys, i)
								end
							end
							WarMenu.Display()
						elseif WarMenu.IsMenuOpened("doorlock-objects") then
							if WarMenu.Button("Přidat objekt") then
								exports.input:openInput(
									"text",
									{title = "Zadejte model", placeholder = ""},
									function(model)
										if model then
											local currentCoords = GetEntityCoords(PlayerPedId())
											table.insert(
												newDoors.Objects,
												{
													objName = model,
													objCoords = {x = currentCoords.x, y = currentCoords.y, z = currentCoords.z}
												}
											)
											TriggerEvent(
												"chat:addMessage",
												{
													templateId = "success",
													args = {"Přidal jsi objekt!"}
												}
											)
										end
									end
								)
							end
							for i, object in each(newDoors.Objects) do
								local coords = vec3(object.objCoords.x, object.objCoords.y, object.objCoords.z)
								if
									WarMenu.Button(
										"Objekt " .. object.objName,
										round(coords.x) .. "," .. round(coords.y) .. "," .. round(coords.z)
									)
								 then
									table.remove(newDoors.Objects, i)
								end
							end
							WarMenu.Display()
						else
							break
						end

						Citizen.Wait(0)
					end
				end
			)
		else
			TriggerEvent(
				"chat:addMessage",
				{
					templateId = "error",
					args = {"Na toto nemáš právo!"}
				}
			)
		end
	end
)

function tableLength(table)
	local count = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end
