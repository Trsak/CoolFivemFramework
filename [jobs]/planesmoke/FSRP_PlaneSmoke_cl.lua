local SmokeEnabled, SmokeR, SmokeG, SmokeB, SmokeSize = false, 255.0, 0.0, 0.0, 1.0

local PlayerSmokeSettings = {}

local ActiveFx = {}

local found = false

RegisterNetEvent('JM36-FSRP:PlaneSmokeSettingsUpdate')
AddEventHandler('JM36-FSRP:PlaneSmokeSettingsUpdate', function(Data)
	PlayerSmokeSettings = Data
	found = false
	for _, v in each(PlayerSmokeSettings) do
		if v[1] then
			found = true
		end
	end
end)

function UpdatePlaneSmokeSettings(sEnabled, sR, sG, sB, sSize)
	SmokeEnabled, SmokeR, SmokeG, SmokeB, SmokeSize = sEnabled, sR, sG, sB, sSize
	TriggerServerEvent("JM36-FSRP:PlaneSmokeSettingsUpdate", {SmokeEnabled, SmokeR, SmokeG, SmokeB, SmokeSize})
end

Citizen.CreateThread(function()
	local particleDictionary = "scr_ar_planes"
	local particleName = "scr_ar_trail_smoke"
	RequestNamedPtfxAsset(particleDictionary)
	while not HasNamedPtfxAssetLoaded(particleDictionary) do
		Citizen.Wait(0)
	end

	while true do
		if found then
			wait = 0
			for _, v in each(PlayerSmokeSettings) do
				local SmokeEnabled, SmokeR, SmokeG, SmokeB, SmokeSize, ped, veh = table.unpack(v)
				if NetworkDoesNetworkIdExist(ped) and NetworkDoesNetworkIdExist(veh) then
					ped = NetworkGetEntityFromNetworkId(ped)
					veh = NetworkGetEntityFromNetworkId(veh)
					if (IsPedInAnyPlane(ped) and not IsEntityDead(veh)) and SmokeEnabled then
						if not ActiveFx[veh] then
							UseParticleFxAssetNextCall(particleDictionary)
							local ox, oy, oz = 0.0, 0.0, 0.0
							ActiveFx[veh] = StartNetworkedParticleFxLoopedOnEntityBone(particleName, veh, ox, oy, oz, 0.0, 0.0, 0.0, -1, SmokeSize + 0.0, ox, oy, oz)
						elseif ActiveFx[veh] and not IsEntityDead(veh) then
							SetParticleFxLoopedScale(ActiveFx[veh], SmokeSize+0.0)
							SetParticleFxLoopedRange(ActiveFx[veh], 100000.0)
							SetParticleFxLoopedAlpha(ActiveFx[veh], 1.0)
							SetParticleFxLoopedFarClipDist(ActiveFx[veh], 100000.0)
							SetParticleFxLoopedColour(ActiveFx[veh], SmokeR + 0.0, SmokeG + 0.0, SmokeB + 0.0)
						end
					else
						if ActiveFx[veh] or IsEntityDead(veh) or not veh then
							StopParticleFxLooped(ActiveFx[veh], 0)
							ActiveFx[veh] = nil
						end
					end
				end
			end
		else
			wait = 300
			for k, v in each(ActiveFx) do
				if ActiveFx[k] or IsEntityDead(k) or not k then
					StopParticleFxLooped(ActiveFx[k], 0)
					ActiveFx[k] = nil
				end
			end
		end
		Citizen.Wait(wait)
	end
end)

RegisterCommand("smokecolor", function(source, args, raw)
	UpdatePlaneSmokeSettings(SmokeEnabled, tonumber(args[1]) + 0.0, tonumber(args[2]) + 0.0, tonumber(args[3]) + 0.0, SmokeSize, GetPlayerServerId(PlayerId()))
end)

RegisterCommand("smokesize", function(source, args, raw)
	local SmokeSize = tonumber(args[1]) + 0.0
	if SmokeSize > 5.0 then SmokeSize = 5.0 elseif SmokeSize <= 0.0 then SmokeSize = 0.1 end
	UpdatePlaneSmokeSettings(SmokeEnabled, SmokeR, SmokeG, SmokeB, SmokeSize)
end)

RegisterCommand('togglePlaneSmoke', function()
	if IsPedInAnyPlane(PlayerPedId()) then
		UpdatePlaneSmokeSettings(not SmokeEnabled, SmokeR, SmokeG, SmokeB, SmokeSize)
	end
end)

createNewKeyMapping({ command = "togglePlaneSmoke", text = "Zapnutí/Vypnutí Plane Smoke", key = "Y" })