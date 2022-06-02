local usingConfetti = false
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
		elseif status == ("spawned" or "dead") then
			isSpawned = true
			isDead = (status == "dead")
		end
	end
)

RegisterNetEvent("confetti:use")
AddEventHandler(
	"confetti:use",
	function()
		if usingConfetti then
			return
		end
		usingConfetti = true
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)

		local confettiHash = GetHashKey("xs_prop_arena_confetti_cannon")
		local animDict = "special_ped@griff@monologue_1@monologue_1b"

		loadPropDict(confettiHash)
		loadAnim(animDict)

		exports.target:DisableTarget(true)
		exports.emotes:DisableEmotes(true)

		local entity = CreateObject(confettiHash, playerCoords, true, true, false)
		local boneIndex = GetPedBoneIndex(playerPed, 57005)
		AttachEntityToEntity(
			entity,
			playerPed,
			boneIndex,
			0.08,
			0.0,
			-0.02,
			-76.0,
			-10.0,
			-35.0,
			true,
			true,
			false,
			true,
			1,
			true
		)
		SetEntityCollision(entity, false, true)
		SetModelAsNoLongerNeeded(confettiHash)
		TaskPlayAnim(playerPed, animDict, "iamnotaracist_1", 2.0, 2.0, -1, 51, 0, false, false, false)

		showHints()

		local pressedUse = false
		while usingConfetti do
			Citizen.Wait(0)
			if not pressedUse then
				if IsControlJustReleased(0, 54) then
					pressedUse = true
					makeEffect(entity)
					ClearPedTasks(PlayerPedId())
					DeleteEntity(entity)
					hideHints()
					usingConfetti, pressedUse = false, false
					break
				elseif IsControlJustReleased(0, 74) then
					hideHints()
					ClearPedTasks(PlayerPedId())
					DeleteEntity(entity)
					usingConfetti = false
					TriggerServerEvent("confetti:getItemBack")
				end
			end
		end
	end
)

function loadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function loadPropDict(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Wait(10)
	end
end

function showHints()
	exports.key_hints:displayBottomHint(
		{
			name = "confetti_use",
			key = "~INPUT_PICKUP~",
			text = "Odpálit konfety"
		}
	)

	exports.key_hints:displayBottomHint(
		{
			name = "confetti_hide",
			key = "~INPUT_VEH_HEADLIGHT~",
			text = "Schovat konfety"
		}
	)
end

function hideHints()
	exports.key_hints:hideBottomHint(
		{
			name = "confetti_use"
		}
	)
	exports.key_hints:hideBottomHint(
		{
			name = "confetti_hide"
		}
	)
	exports.target:DisableTarget(false)
	exports.emotes:DisableEmotes(false)
end

function makeEffect(entity)
	local count = 4
	while not HasNamedPtfxAssetLoaded("scr_xs_celebration") do
		RequestNamedPtfxAsset("scr_xs_celebration")
		Citizen.Wait(1)
	end
	while true do
		SetPtfxAssetNextCall("scr_xs_celebration")
		local effect =
			StartNetworkedParticleFxNonLoopedOnEntity(
			"scr_xs_confetti_burst",
			entity,
			0.0,
			0.0,
			0.3,
			GetEntityRotation(entity, 5),
			1.0
		)
		Citizen.Wait(900)
		StopParticleFxLooped(effect, 0)
		Citizen.Wait(100)
		count = count - 1
		if count <= 0 then
			break
		end
	end
end
