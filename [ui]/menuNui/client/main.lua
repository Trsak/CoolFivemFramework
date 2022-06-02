menuNui					  = {}
menuNui.RegisteredTypes   = {}
menuNui.Opened            = {}

menuNui.RegisterType = function(type, open, close)
	menuNui.RegisteredTypes[type] = {
		open   = open,
		close  = close
	}
end

menuNui.Open = function(type, namespace, name, data, submit, cancel, change, close)
	local menu = {}

	menu.type      = type
	menu.namespace = namespace
	menu.name      = name
	menu.data      = data
	menu.submit    = submit
	menu.cancel    = cancel
	menu.change    = change

	menu.close = function()

		menuNui.RegisteredTypes[type].close(namespace, name)

		for i=1, #menuNui.Opened, 1 do
			if menuNui.Opened[i] then
				if menuNui.Opened[i].type == type and menuNui.Opened[i].namespace == namespace and menuNui.Opened[i].name == name then
					menuNui.Opened[i] = nil
				end
			end
		end

		if close then
			close()
		end

	end

	menu.update = function(query, newData)

		for i=1, #menu.data.elements, 1 do
			local match = true
			for k,v in pairs(query) do
				if menu.data.elements[i][k] ~= v then
					match = false
				end
			end
			if match then
				for k,v in pairs(newData) do
					menu.data.elements[i][k] = v
				end
			end
		end

	end

	menu.refresh = function()
		menuNui.RegisteredTypes[type].open(namespace, name, menu.data)
	end

	menu.setElement = function(i, key, val)
		menu.data.elements[i][key] = val
	end

	menu.setTitle = function(val)
		menu.data.title = val
	end

	menu.removeElement = function(query)
		for i=1, #menu.data.elements, 1 do
			for k,v in pairs(query) do
				if menu.data.elements[i] then
					if menu.data.elements[i][k] == v then
						table.remove(menu.data.elements, i)
						break
					end
				end

			end
		end
	end

	table.insert(menuNui.Opened, menu)
	menuNui.RegisteredTypes[type].open(namespace, name, data)

	return menu
end

menuNui.Close = function(type, namespace, name)
	for i=1, #menuNui.Opened, 1 do
		if menuNui.Opened[i] then
			if menuNui.Opened[i].type == type and menuNui.Opened[i].namespace == namespace and menuNui.Opened[i].name == name then
				menuNui.Opened[i].close()
				menuNui.Opened[i] = nil
			end
		end
	end
end

menuNui.CloseAll = function()
	for i=1, #menuNui.Opened, 1 do
		if menuNui.Opened[i] then
			menuNui.Opened[i].close()
			menuNui.Opened[i] = nil
		end
	end
end

menuNui.GetOpened = function(type, namespace, name)
	for i=1, #menuNui.Opened, 1 do
		if menuNui.Opened[i] then
			if menuNui.Opened[i].type == type and menuNui.Opened[i].namespace == namespace and menuNui.Opened[i].name == name then
				return menuNui.Opened[i]
			end
		end
	end
end

menuNui.GetOpenedMenus = function()
	return menuNui.Opened
end

menuNui.IsOpen = function(type, namespace, name)
	return menuNui.GetOpened(type, namespace, name) ~= nil
end

Citizen.CreateThread(function()
	local Keys = {
		["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
		["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
		["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
		["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
		["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
		["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
		["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
		["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
		["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
	}

	local GUI      = {}
	GUI.Time       = 0
	local MenuType = 'default'

	local openMenu = function(namespace, name, data)
		SendNUIMessage({
			action    = 'openMenu',
			namespace = namespace,
			name      = name,
			data      = data
		})

	end

	local closeMenu = function(namespace, name)
		SendNUIMessage({
			action    = 'closeMenu',
			namespace = namespace,
			name      = name,
			data      = data
		})
	end

	menuNui.RegisterType(MenuType, openMenu, closeMenu)

	RegisterNUICallback('menu_submit', function(data, cb)
		local menu = menuNui.GetOpened(MenuType, data._namespace, data._name)

		if menu.submit ~= nil then
			menu.submit(data, menu)
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_cancel', function(data, cb)
		local menu = menuNui.GetOpened(MenuType, data._namespace, data._name)

		if menu.cancel ~= nil then
			menu.cancel(data, menu)
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_change', function(data, cb)
		local menu = menuNui.GetOpened(MenuType, data._namespace, data._name)

		for i=1, #data.elements, 1 do
			menu.setElement(i, 'value', data.elements[i].value)

			if data.elements[i].selected then
				menu.setElement(i, 'selected', true)
			else
				menu.setElement(i, 'selected', false)
			end

		end

		if menu.change ~= nil then
			menu.change(data, menu)
		end

		cb('OK')
	end)

	Citizen.CreateThread(function()
		while true do

			Citizen.Wait(10)

			if IsControlPressed(0, Keys['ENTER']) and IsInputDisabled(0) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'ENTER'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, Keys['BACKSPACE']) and IsInputDisabled(0) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'BACKSPACE'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, Keys['TOP']) and IsInputDisabled(0) and (GetGameTimer() - GUI.Time) > 200 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'TOP'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, Keys['DOWN']) and IsInputDisabled(0) and (GetGameTimer() - GUI.Time) > 200 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'DOWN'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, Keys['LEFT']) and IsInputDisabled(0) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'LEFT'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, Keys['RIGHT']) and IsInputDisabled(0) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressed',
					control = 'RIGHT'
				})

				GUI.Time = GetGameTimer()
			end

		end
	end)
end)

AddEventHandler("menuNui:Open", function(menuData, callback)
	local menu = menuNui.Open(menuData.type,  menuData.namespace or string.format("%s-%s", menuData.namespace, menuData.name), menuData.name, {
		title = menuData.title or 'Opened Menu',
		description = menuData.description or nil,
		align = menuData.align or 'top-right',
		elements = menuData.elements or {},
	}, function(data, menu)
		callback(menu, data)
		menu.refresh()
	end, function(cancelData, cancelMenu)
		cancelMenu.close()
	end, function(changeData, changeMenu)
		--callback(changeData)
		changeMenu.refresh()
	end, function(closeData, closeMenu)
		--closeMenu.close()
	end)
	callback(menu, {})
end)
AddEventHandler("menuNui:Close", function(menuData, callback)
	menuNui.Close(menuData.type, menuData.namespace, menuData.name)
	callback('ok')
end)

AddEventHandler("menuNui:GetOpened", function(menuData, callback)
	menuNui.GetOpened(menuData.type, menuData.namespace, menuData.name)
	callback('ok')
end)

AddEventHandler("menuNui:GetOpenedMenus", function(menuData, callback)
	callback(menuNui.GetOpenedMenus)
end)
AddEventHandler("menuNui:IsOpen", function(menuData, callback)
	callback(menuNui.IsOpen(menuData.type, menuData.namespace, menuData.name))
end)

RegisterCommand('test', function(source, args)
	local options = { "1", "2", "3", "4", "5", "6"}
	local elements = {
		{ label = '🅿 Firemní garáž', value = 'company-garage' },
		{ type = "slider", label = '⛐ Odtáhnutá vozidla', value = 0, max = #options-1, options = options },
		{ type = "checkbox", label = 'Test', value = false },
	}
	local elements2 = {
		{ label = '🅿 Firemní garáž23', value = 'company-garage' },
		{ type = "slider23", label = '⛐ Odtáhnutá vozidla', value = 0, max = #options-1, options = options },
		{ type = "checkbox", label = 'Test', value = false },
	}
	TriggerEvent("menuNui:Open", { type = "default", namespace = "23", elements = elements, name = "asděšěš", description = "kaboom", title = "Pfchěšěš" }, function(menu, data)
		Utils.DumpTable(menu)
		if data.current ~= nil and data.current.type == "checkbox" then
			local new = data.current
			new.value  = not data.current.value
			menu.update({label = data.current.label}, new)
			menu.refresh()
		end
	end)
end, false)