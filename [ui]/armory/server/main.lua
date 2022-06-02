RegisterNetEvent("armory:giveItems")
AddEventHandler(
	"armory:giveItems",
	function(data)
		local _source = source
		local job = data.job
		local items = data.selectedItems
		for _, itemId in each(items) do
			local itemData = Config.Items[data.job][itemId]
			local item = exports.inventory:getItem(itemData.Item)
			local charName = exports.data:getCharNameById(exports.data:getCharVar(_source, "id"))
			local done = "error"
			if itemData.Price then
				payment =
					exports.bank:payFromAccount(
					tostring(exports.base_jobs:getJobVar(job, "bank")),
					itemData.Price * (item.Count and item.Count or 1),
					false,
					"Koupě vybavení - provedl " .. charName
				)
			end
			if not itemData.Price or payment == "done" then
				local data = {}
				if item.type == "weapon" then
					number = exports.base_shops:generateSerialNumber()
					data = {
						id = number,
						number = number,
						time = os.time(),
						label = "Seriové číslo: " .. number .. "<br>Datum vydání: " .. os.date("%x", os.time()),
						color = itemData.Color or 0
					}
				end
				exports.inventory:forceAddPlayerItem(_source, itemData.Item, (itemData.Count ~= nil and itemData.Count or 1), data)
				if itemData.Item == "cuffs" then
					exports.inventory:forceAddPlayerItem(_source, "cuffkey", 1, {})
				end
				local text =
					"Vydán předmět: " ..
					item.label ..
						"\nPočet: " ..
							(itemData.Count ~= nil and itemData.Count or 1) ..
								"\nOsoba: " .. charName .. "\nZaměstnání: " .. exports.base_jobs:getJobVar(job, "label")
				if item.type == "weapon" then
					text = text .. "\nSériové číslo: " .. number
				end
				exports.logs:sendToDiscord(
					{
						channel = "armory",
						title = "Zbrojnice",
						description = text,
						color = "34749"
					},
					_source
				)
				if ServerConfig.Urls[job] then
					PerformHttpRequest(
						ServerConfig.Urls[job],
						function(err, text, headers)
						end,
						"POST",
						json.encode(
							{
								embeds = {
									{
										["color"] = "42320",
										["title"] = "Výdej věcí",
										["timestamp"] = os.date("!%Y-%m-%dT%TZ"),
										["description"] = text
									}
								}
							}
						),
						{["Content-Type"] = "application/json"}
					)
				end
			else
				TriggerClientEvent(
					"notify:display",
					_source,
					{
						type = "error",
						title = "Vybavení " .. tostring(exports.base_jobs:getJobVar(data.job, "label")),
						text = "Firma nemá dostatek financí!",
						icon = "fas fa-briefcase",
						length = 5000
					}
				)
				return
			end
		end
		TriggerClientEvent(
			"notify:display",
			_source,
			{
				type = "success",
				title = "Vybavení " .. tostring(exports.base_jobs:getJobVar(data.job, "label")),
				text = "A nezapomeň se o to vybavení starat!",
				icon = "fas fa-briefcase",
				length = 5000
			}
		)
	end
)
