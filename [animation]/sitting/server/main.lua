local SeatsTaken = {}
local SeatsCapacity = {}

Citizen.CreateThread(
	function()
		for i, sitable in each(Config.Sitable) do
			local hashkey = GetHashKey(sitable.prop)
			SeatsCapacity[hashkey] = 1

			if sitable.seats then
				SeatsCapacity[hashkey] = #sitable.seats
			end
		end
	end
)

-- SEATS
RegisterNetEvent("sitting:server:TakeChair")
AddEventHandler(
	"sitting:server:TakeChair",
	function(object, seat)
		if not SeatsTaken[object] then
			SeatsTaken[object] = {}
		end

		SeatsTaken[object][tostring(seat)] = true
	end
)

RegisterNetEvent("sitting:server:LeaveChair")
AddEventHandler(
	"sitting:server:LeaveChair",
	function(object, seat)
		if not SeatsTaken[object] then
			SeatsTaken[object] = {}
		end

		SeatsTaken[object][tostring(seat)] = false
	end
)

RegisterNetEvent("sitting:server:GetChair")
AddEventHandler(
	"sitting:server:GetChair",
	function(object, modelHash)
		local _source = source
		local found = true
		local seat = 1

		if SeatsTaken[object] == nil then
			SeatsTaken[object] = {}
		end

		for i = 1, SeatsCapacity[modelHash] do
			if not SeatsTaken[object][tostring(i)] then
				seat = i
				found = false
				break
			end
		end
		TriggerClientEvent("sitting:client:GetChair", _source, found, seat)
	end
)
