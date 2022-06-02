local usingBinoculars = false
local isSpawned, isDead = false, false
local fov = (Config.Fov.Max + Config.Fov.Min) * 0.5

Citizen.CreateThread(
	function()
		Citizen.Wait(500)

		local status = exports.data:getUserVar("status")
		if status == ("spawned" or "dead") then
			isSpawned = true
			isDead = (status == "dead")
		end
		while true do
			pPed = PlayerPedId()
			Citizen.Wait(5000)
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
		if itemName == "binoculars" and not usingBinoculars then
			usingBinoculars = true
			exports.emotes:playEmoteByName("binoculars")

			Wait(2000)

			local scaleform = RequestScaleformMovie("BINOCULARS")

			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end

			local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

			AttachCamToEntity(cam, pPed, 0.05, 0.25, 0.68, true)
			SetCamRot(cam, 0.0, 0.0, GetEntityHeading(pPed))
			SetCamFov(cam, fov)
			RenderScriptCams(true, false, 0, 1, 0)

			while usingBinoculars and not isDead do
				local zoomvalue = (1.0 / (Config.Fov.Max - Config.Fov.Min)) * (fov - Config.Fov.Min)
				CheckInputRotation(cam, zoomvalue)

				HandleZoom(cam)
				HideHUDThisFrame()
				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)

				if IsControlJustReleased(0, 177) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					exports.emotes:cancelEmote()
					usingBinoculars = false
				end
				Citizen.Wait(0)
			end

			usingBinoculars = false
			ClearTimecycleModifier()
			fov = (Config.Fov.Max + Config.Fov.Min) * 0.5
			RenderScriptCams(false, false, 0, 1, 0)
			SetScaleformMovieAsNoLongerNeeded(scaleform)
			DestroyCam(cam, false)
		end
	end
)

function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(2)
	HideHudComponentThisFrame(19)
end

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX * -1.0 * (Config.Speed.X) * (zoomvalue + 0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * (Config.Speed.Y) * (zoomvalue + 0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	if not IsPedSittingInAnyVehicle(pPed) then
		if IsControlJustPressed(0, 241) or IsControlJustPressed(0, 32) then -- Scrollup
			fov = math.max(fov - Config.Speed.Zoom, Config.Fov.Min)
		end
		if IsControlJustPressed(0, 242) or IsControlJustPressed(0, 8) then
			fov = math.min(fov + Config.Speed.Zoom, Config.Fov.Max) -- ScrollDown
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov - current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
	else
		if IsControlJustPressed(0, 17) then -- Scrollup
			fov = math.max(fov - Config.Speed.Zoom, Config.Fov.Min)
		end
		if IsControlJustPressed(0, 16) then
			fov = math.min(fov + Config.Speed.Zoom, Config.Fov.Max) -- ScrollDown
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov - current_fov) < 0.1 then -- the difference is too small, just set the value directly to avoid unneeded updates to FOV of order 10^-5
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov) * 0.05) -- Smoothing of camera zoom
	end
end
