RegisterNetEvent("outlawalert:checkInsurance")
AddEventHandler(
	"outlawalert:checkInsurance",
	function(char)
		local _source = source
		local sourceId = exports.data:getCharVar(_source, "id")
		if char == sourceId then
			local hasInsurance = false

			MySQL.Async.fetchAll(
				"SELECT insurance_id FROM emsdb_person WHERE charid = @char LIMIT 1",
				{
					["@char"] = sourceId
				},
				function(result)
					if #result > 0 then
						if result[1].insurance_id ~= 0 then
							hasInsurance = true
						end
					end

					if not hasInsurace then
						local emsBank = exports.base_jobs:getJobVar("ems", "bank")
						if emsBank and emsBank ~= "" then
							local invoice = {
								Sender = sourceId,
								SenderName = "Nemocnice Pillbox Hill",
								Price = 200,
								Bank = emsBank,
								Items = {
									{
										label = "Transport",
										price = 50
									},
									{
										label = "Ošetření",
										price = 150
									}
								}
							}

							TriggerEvent("invoices:give", _source, invoice)

							TriggerClientEvent(
								"notify:display",
								_source,
								{
									type = "warning",
									title = "Lékař",
									text = "Nechali jsme Vám ve věcech fakturu k zaplacení",
									icon = "fas fa-clinic-medical",
									length = 4000
								}
							)
						else
							TriggerClientEvent(
								"notify:display",
								_source,
								{
									type = "warning",
									title = "Lékař",
									text = "Ošetření Vás nic nestálo. Ať je vám lépe!",
									icon = "fas fa-clinic-medical",
									length = 4000
								}
							)
						end
					else
						TriggerClientEvent(
							"notify:display",
							_source,
							{
								type = "warning",
								title = "Lékař",
								text = "Ošetření Vás nic nestálo, pojištění vše uhradí. Ať je vám lépe!",
								icon = "fas fa-clinic-medical",
								length = 4000
							}
						)
					end
					exports.data:updateUserVar(_source, "status", "spawned")
					exports.instance:playerQuitInstance(_source)
				end
			)
		else
			exports.admin:banClientForCheating(
				_source,
				"0",
				"Cheating",
				"outlawalert:checkInsurance",
				"Hráč se pokusil dát fakturu někomu jinému než sobě za NPC odvoz!"
			)
		end
	end
)

RegisterNetEvent("outlawalert:sendAlert")
AddEventHandler(
	"outlawalert:sendAlert",
	function(data)
		local client = source
		if not data.Time then
			local currentTime = os.time()
			data.Time = currentTime
			data.TimeLabel = os.date("%H:%M", currentTime)
		end
		if client and data.Type and Config.Alerts[data.Type] and Config.Alerts[data.Type].FlashBlip then
			exports.active_blips:activateFlash(client)
		end

		TriggerClientEvent("outlawalert:recieveAlert", -1, data)
	end
)

RegisterCommand(
	"panicbutton",
	function(source)
		local _source = source
		if exports.base_jobs:hasUserJobType(_source, "police", false) then
			local userChar = exports.data:getUserVar(_source, "character")
			exports.chat:displayMeDoDoc("me", "Stisknul tlačítko na vysílačce", _source, 20.0, true, userChar.firstname .. " " .. userChar.lastname)
			TriggerClientEvent(
				"outlawalert:recieveAlert",
				-1,
				{
					Type = "panic",
					Coords = GetEntityCoords(GetPlayerPed(_source)),
					Time = os.time(),
					TimeLabel = os.date("%H:%M", os.time())
				}
			)

			exports.active_blips:activateFlash(_source)
		end
	end
)