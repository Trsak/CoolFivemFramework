local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ""
local LastEntity = nil

Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(500)
			local coords = GetEntityCoords(GetPlayerPed(-1))
			local closestDistance = -1
			local closestEntity = nil

			for k, objName in ipairs(Config.TrackedEntities) do
				local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.8, GetHashKey(objName), false, false, false)

				if DoesEntityExist(object) then
					local objCoords = GetEntityCoords(object)
					local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, objCoords.x, objCoords.y, objCoords.z, true)

					if closestDistance == -1 or closestDistance > distance then
						closestDistance = distance
						closestEntity = object
						CurrentActionPos = objCoords
					end
				end
			end

			if closestDistance ~= -1 and closestDistance <= 3.0 then
				if LastEntity ~= closestEntity then
					TriggerEvent("bins:hasEnteredEntityZone")
					LastEntity = closestEntity
				end
			else
				if LastEntity ~= nil then
					TriggerEvent("bins:hasExitedEntityZone", LastEntity)
					LastEntity = nil
				end
			end
		end
	end
)

AddEventHandler(
	"bins:hasEnteredEntityZone",
	function()
		local playerPed = GetPlayerPed(-1)

		CurrentAction = "bin_menu"
		CurrentActionMsg = "[E] Prohledat koš"
	end
)

AddEventHandler(
	"bins:hasExitedEntityZone",
	function(entity)
		if CurrentAction == "bin_menu" then
			CurrentAction = nil
		end
	end
)

Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(2)
			if CurrentAction ~= nil then
				DrawText3D(CurrentActionPos.x, CurrentActionPos.y, CurrentActionPos.z + 0.5, CurrentActionMsg)

				if IsControlJustReleased(0, 38) then
					if CurrentAction == "bin_menu" then
					end

					CurrentAction = nil
				end
			end
		end
	end
)
