local usingCutter, cutting = false, false
local isSpawned, isDead = false, false

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

RegisterNetEvent("cutter:take")
AddEventHandler(
	"cutter:take",
	function(itemName)
		if not usingCutter then
			exports.key_hints:displayBottomHint(
                    {name = "cutter", key = "~INPUT_VEH_HEADLIGHT~", text = "Schovat řezačku"}
                )
			local pPed = PlayerPedId()
			usingCutter = true
			local cutterName = GetHashKey("prop_tool_consaw")
			while not HasModelLoaded(cutterName) do
				RequestModel(cutterName)
				Citizen.Wait(0)
			end

			local cutterCoords = GetOffsetFromEntityInWorldCoords(pPed, 0.0, 0.0, -5.0)
			local cutter = CreateObject(cutterName, cutterCoords, 1, 1, 1)
			local cutterNet = NetworkGetNetworkIdFromEntity(cutter)
			Citizen.Wait(1000)
			AttachEntityToEntity(
				cutter,
				pPed,
				GetPedBoneIndex(pPed, 28422),
				0.095,
				0.0,
				0.0,
				270.0,
				170.0,
				0.0,
				1,
				1,
				0,
				1,
				0,
				1
			)
			startAnimation("weapons@heavy@minigun", "idle_2_aim_right_med")
			while true do
				local vehicle = getVehicleInDirection()
				if vehicle ~= 0 or vehicle ~= nil then
					local pPed = PlayerPedId()
					local pCoords = GetEntityCoords(pPed)
					local shouldBeDisplayingHint = false

					for i, door in each(Config.Doors) do
						local bone = GetEntityBoneIndexByName(vehicle, door.Bone)
						local doorPos = GetWorldPositionOfEntityBone(vehicle, bone)
						local distance = #(pCoords - doorPos)
						if distance <= 3.0 and not IsVehicleDoorDamaged(vehicle, Config.Doors[i].Index) then
							shouldBeDisplayingHint = true
							--if not showingCutterHint then
							--	showingCutterHint = true
							--	exports.key_hints:displayBottomHint(
							--		{
							--			name = "cutter_door",
							--			key = "~INPUT_PICKUP~",
							--			text = "Odřezat " .. Config.Doors[i].Name
							--		}
							--	)
							--end
							if IsControlJustReleased(0, 38) and not cutting then
								cutting = true
								TriggerServerEvent("cutter:startSparks", cutterNet)
								exports.progressbar:startProgressBar({
									Duration = 20000,
									Label = "Odřezáváš dveře..",
									CanBeDead = false,
									CanCancel = true,
									DisableControls = {
										Movement = true,
										CarMovement = true,
										Mouse = false,
										Combat = true
									}
								}, function(finished)
									cutting = false
									if finished then
										if vehicle and vehicle ~= 0 then
											local veh = NetworkGetNetworkIdFromEntity(vehicle)
											TriggerServerEvent("cutter:cut", veh, i)
											TriggerServerEvent("cutter:stopSparks", cutterNet)
											exports.notify:display(
												{
													type = "info",
													title = "Odřezání dveří",
													text = "Úspěšně jsi odřízl dveře",
													icon = "fas fa-car",
													length = 3000
												}
											)
										else
											exports.notify:display(
												{
													type = "error",
													title = "Odřezání dveří",
													text = "Vozidlo se vzdálilo",
													icon = "fas fa-car",
													length = 3000
												}
											)
										end
									end
								end)
							end
							break
						end
					end
					if not shouldBeDisplayingHint and showingCutterHint then
						showingCutterHint = false
						exports.key_hints:hideHint({name = "cutter"})
					end
					if IsControlJustReleased(0, 74) and not cutting or isDead then
						usingCutter = false
						break
					end
				else
					Citizen.Wait(1000)
				end
				Citizen.Wait(0)
			end
			ClearPedSecondaryTask(pPed)
			DetachEntity(cutter)
			DeleteEntity(cutter)
			exports.notify:display(
				{
					type = "info",
					title = "Řezačka",
					text = "Schoval jsi řezačku",
					icon = "fas fa-car",
					length = 3000
				}
			)
			
			exports.key_hints:hideBottomHint({ name = "cutter" })
			usingCutter, cutting = false, false
			showingCutterHint = false
			exports.key_hints:hideHint({name = "cutter"})
			TriggerServerEvent("cutter:hideCutter")
		end
	end
)
RegisterNetEvent("cutter:cut")
AddEventHandler(
	"cutter:cut",
	function(netID, door)
		local vehicle = NetworkGetEntityFromNetworkId(netID)
		if DoesEntityExist(vehicle) then
			SetVehicleDoorBroken(vehicle, Config.Doors[door].Index, false)
		end
	end
)
RegisterNetEvent("cutter:startSparks")
AddEventHandler(
	"cutter:startSparks",
	function(netID)
		local cutter = NetworkGetEntityFromNetworkId(netID)
		if DoesEntityExist(cutter) then
			local particleDict = "des_fib_floor"
			while not HasNamedPtfxAssetLoaded(particleDict) do
				RequestNamedPtfxAsset(particleDict)
				Wait(0)
			end

			UseParticleFxAssetNextCall(particleDict)
			StartParticleFxNonLoopedOnEntity(
				"ent_ray_fbi5a_ramp_metal_imp",
				cutter,
				-0.715,
				0.005,
				0.0,
				0.0,
				25.0,
				25.0,
				0.75,
				0.0,
				0.0,
				0.0
			)
		end
	end
)
RegisterNetEvent("cutter:stopSparks")
AddEventHandler(
	"cutter:stopSparks",
	function(netID)
		local cutter = NetworkGetEntityFromNetworkId(netID)
		if DoesEntityExist(cutter) then
			RemoveParticleFxFromEntity(cutter)
		end
	end
)

function startAnimation(lib, anim)
	while not HasAnimDictLoaded(lib) do
		RequestAnimDict(lib)
		Citizen.Wait(1)
	end
	TaskPlayAnim(pPed, lib, anim, 1.0, -1, -1, 50, 0, 0, 0, 0)
end
function getVehicleInDirection()
	local pPed = PlayerPedId()
	local coordA = GetEntityCoords(pPed)
	local coordB = GetOffsetFromEntityInWorldCoords(pPed, 0.0, 6.0, 0.0)

	local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coordA, coordB, 10, pPed, 0)
	local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
	return vehicle
end
