local knockedOut = false
local wait = 15
local count = 60

Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(1)

			local myPed = PlayerPedId()

			if IsPedInMeleeCombat(myPed) then
				if GetEntityHealth(myPed) < 115 then
					TriggerServerEvent("admin:playerGodModeWhitelist", true)
					SetPlayerInvincible(PlayerId(), true)
					SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
					exports.notify:display({type = "error", title = "Bezvědomí", text = "Upadl jsi do bězvědomí!", icon = "fas fa-hand-rock", length = 5000})
					wait = 20
					knockedOut = true
					SetEntityHealth(myPed, 116)
				end
			end

			if knockedOut then
				SetPlayerInvincible(PlayerId(), true)
				DisablePlayerFiring(PlayerId(), true)
				SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
				ResetPedRagdollTimer(myPed)

				if wait >= 0 then
					count = count - 1
					if count == 0 then
						count = 60
						wait = wait - 1
						SetEntityHealth(myPed, GetEntityHealth(myPed) + 1)
					end
				else
					SetPlayerInvincible(PlayerId(), false)
					TriggerServerEvent("admin:playerGodModeWhitelist", false)
					knockedOut = false
				end
			end
		end
	end
)
