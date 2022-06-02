RegisterNetEvent("notepad:close")
AddEventHandler(
	"notepad:close",
	function(text, index)
		local id = index
		local _source = source
		if not id then
			id = _source .. os.time()
		end
		local weight =
			exports.inventory:addPlayerItem(
			_source,
			"notepad",
			1,
			{
				id = id,
				text = text,
				label = string.sub(text, 1, 30) .. "..."
			}
		)
		if weight ~= "done" then
			TriggerClientEvent(
				"notify:display",
				_source,
				{
					type = "warning",
					title = "Ehh",
					text = "Upadly vám poznámky na zem",
					icon = "fas fa-book-open",
					length = 5000
				}
			)
		end
	end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
	"inventory:usedItem",
	function(itemName, slot, data)
		local _source = source
		if itemName == "notepad" then
			exports.inventory:removePlayerItem(
				_source,
				"notepad",
				1,
				{
					id = data.id
				}
			)
			TriggerClientEvent("notepad:open", _source, data)
		end
	end
)
