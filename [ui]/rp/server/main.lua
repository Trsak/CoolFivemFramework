RegisterNetEvent("rp:cuff")
AddEventHandler(
	"rp:cuff",
	function(target)
		local _source = source
		local hascuffs = exports.inventory:checkPlayerItem(_source, "cuffs", 1, {})
		local haskeys = exports.inventory:checkPlayerItem(_source, "cuffkey", 1, {})
		TriggerClientEvent("rp:cuff", target, _source, hascuffs, haskeys)
	end
)

RegisterNetEvent("rp:cuffing")
AddEventHandler(
	"rp:cuffing",
	function(target)
		TriggerClientEvent("rp:cuffing", target)
	end
)

RegisterNetEvent("rp:uncuffing")
AddEventHandler(
	"rp:uncuffing",
	function(target)
		local _source = source
		TriggerClientEvent("rp:uncuffing", target, _source)
	end
)

RegisterNetEvent("rp:uncuff")
AddEventHandler(
	"rp:uncuff",
	function(target)
		local _source = source
		TriggerClientEvent("rp:uncuff", target)
	end
)

RegisterNetEvent("rp:refreshanim")
AddEventHandler(
	"rp:refreshanim",
	function()
		TriggerClientEvent("rp:refreshanim", source)
	end
)

RegisterNetEvent("rp:dragging")
AddEventHandler(
	"rp:dragging",
	function(target)
		local _source = source

		TriggerClientEvent("rp:dragging", target, _source)
	end
)

RegisterNetEvent("rp:removeItem")
AddEventHandler(
	"rp:removeItem",
	function(itemname, count)
		local _source = source
		exports.inventory:removePlayerItem(_source, itemname, count, {})
	end
)

RegisterNetEvent("rp:notify")
AddEventHandler(
	"rp:notify",
	function(target, type, title, text)
		TriggerClientEvent("rp:notify", target, type, title, text)
	end
)

RegisterNetEvent("rp:updateCuff")
AddEventHandler(
	"rp:updateCuff",
	function(flag)
		local _source = source
		if flag ~= nil then
			exports.data:updateCharVar(_source, "cuffed", flag)
		end
	end
)