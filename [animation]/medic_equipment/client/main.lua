local carryingBackInProgress, carrying = false, nil
local isSpawned, isDead = false, false
local isCuffed = false
local showingHints = false

local isSitting = false

Citizen.CreateThread(
	function()
		Citizen.Wait(500)

		local status = exports.data:getUserVar("status")
		if status == "spawned" or status == "dead" then
			isSpawned = true
			isDead = (status == "dead")
		end

		local models = {}
		for _, model in each(Config.Target.Models) do
			table.insert(models, GetHashKey(model))
		end

		exports.target:AddTargetObject(
			models,
			{
				actions = {
					wheelChairSit = {
						cb = function(wheelchairData)
							if not isSitting then
								wheelchair("sit", wheelchairData)
							end
						end,
						icon = Config.Target.Icon,
						label = "Posadit se"
					},
					wheelChairTake = {
						cb = function(wheelchairData)
							if not isSitting then
								wheelchair("take", wheelchairData)
							end
						end,
						icon = Config.Target.Icon,
						label = "Vést vozík"
					}
				},
				distance = 1.2,
				networked = true
			}
		)
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

RegisterNetEvent("rp:updateCuffed")
AddEventHandler(
	"rp:updateCuffed",
	function(status)
		isCuffed = status
	end
)

function wheelchair(action, closestWheelchair)
	local pPed = PlayerPedId()
	resetHint()
	if action == "sit" then
		local config = Config.Anim.Target.Wheelchair
		isSitting = true
		exports.key_hints:displayBottomHint({name = "wheelchair", key = "~INPUT_VEH_HEADLIGHT~", text = "Vstát z vozíku"})
		loadAnim(config.AnimDict)
		AttachEntityToEntity(
			pPed,
			closestWheelchair.entity,
			0,
			0.0,
			0.0,
			0.4,
			0.0,
			0.0,
			180.0,
			false,
			true,
			true,
			false,
			2,
			true
		)
		while true do
			Citizen.Wait(5)

			if not IsEntityPlayingAnim(pPed, config.AnimDict, config.Anim, 3) then
				TaskPlayAnim(pPed, config.AnimDict, config.Anim, 8.0, 8.0, -1, 69, 1, false, false, false)
			end

			if IsControlJustReleased(0, 74) or isDead then
				DetachEntity(pPed, true, true)
				SetEntityCollision(closestWheelchair.entity, true, true)
				SetEntityCoords(
					pPed,
					GetEntityCoords(closestWheelchair.entity) + GetEntityForwardVector(closestWheelchair.entity) * -0.7
				)
				break
			end
		end
		RemoveAnimDict(config.AnimDict)
	elseif action == "take" then
		local config = Config.Anim.Source.Wheelchair
		isSitting = true
		exports.key_hints:displayBottomHint({name = "wheelchair", key = "~INPUT_VEH_HEADLIGHT~", text = "Pustit vozík"})
		loadAnim(config.AnimDict)
		NetworkRequestControlOfEntity(closestWheelchair.entity)

		AttachEntityToEntity(
			closestWheelchair.entity,
			pPed,
			GetPedBoneIndex(pPed, 28422),
			-0.0,
			-0.3,
			-0.73,
			195.0,
			180.0,
			180.0,
			0.0,
			false,
			false,
			true,
			false,
			2,
			true
		)

		while true do
			Citizen.Wait(5)

			if not IsEntityPlayingAnim(pPed, config.AnimDict, config.Anim, 3) then
				TaskPlayAnim(pPed, config.AnimDict, config.Anim, 8.0, 8.0, -1, 50, 0, false, false, false)
			end

			if IsControlJustReleased(0, 74) or isDead or isCuffed then
				DetachEntity(closestWheelchair.entity, true, true)
				break
			end
		end
		RemoveAnimDict(config.AnimDict)
	elseif action == "put" then
	end
	resetHint()
	isSitting = false
	ClearPedTasks(pPed)
	closestWheelchair = nil
end

function resetHint()
	exports.key_hints:hideBottomHint({name = "wheelchair"})
end

function loadAnim(dictionary)
	while not HasAnimDictLoaded(dictionary) do
		RequestAnimDict(dictionary)
		Citizen.Wait(0)
	end
end
