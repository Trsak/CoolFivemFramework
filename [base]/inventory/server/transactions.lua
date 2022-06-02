-- !! TODO: Support multiple take / reward arrays

AddEventHandler('inventory:transaction', function(serverId, data, successCb, failCb)
	InventoryTransaction(
		serverId, data,
		function(state)
			successCb(state)
		end,
		function(state)
			failCb(state)
		end
	)
end)

function InventoryTransaction(serverId, data, successCb, failCb)
	if serverId == nil then
		print('Transaction failed, cannot get player serverId.')
		return
	end

	if data == nil then
		print('Transaction failed, cannot get transaction data [' .. serverId .. ']')
	end

	local transaction = data

	local transactionTake = false
	local transactionGive = false

	if transaction.take then

		local metadata = {}

		if transaction.take.metadata ~= nil then
			metadata = transaction.take.metadata
		else
			metadata = {}
		end


		local hasItem = exports.inventory:checkPlayerItem(
			serverId, 
			transaction.take.itemName, 
			transaction.take.count, 
			{}
		)

		if hasItem == nil then
			failCb(true)
			return
		end

		if hasItem then
			exports.inventory:removePlayerItem(serverId, transaction.take.itemName, transaction.take.count, metadata)
			transactionTake = true
		else
			transactionTake = false
		end
	end

	if transaction.give then

		local metadata = {}

		if transaction.give.metadata ~= nil then
			metadata = transaction.give.metadata
		else
			metadata = {}
		end

		local done = exports.inventory:addPlayerItem(serverId, transaction.give.itemName, transaction.give.count, metadata)

		if done ~= "done" then
			transactionGive = false
		else
			transactionGive = true
		end
	end


	if (transaction.take and transaction.take ~= nil) and (transaction.give and transaction.give ~= nil) then
		if transactionTake and transactionGive then
			successCb(true)
		else
			failCb(true)
		end
	else
		if (transactionTake or transactionGive) then
			successCb(true)
		else
			failCb(true)
		end
	end
end