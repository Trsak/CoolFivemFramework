local myCar = {}
local myCarTry = {}
local prices = {}
local isInMenu = false
local lastParentIndex = {}
local job = nil

function prepareMenu(data)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local currentMods = exports.base_vehicles:GetVehicleProperties(vehicle)
        FreezeEntityPosition(vehicle, true)

        if
        data.value == "modSpeakers" or data.value == "modTrunk" or data.value == "modHydrolic" or
            data.value == "modEngineBlock" or
            data.value == "modAirFilter" or
            data.value == "modStruts" or
            data.value == "modTank"
        then
            SetVehicleDoorOpen(vehicle, 4, false)
            SetVehicleDoorOpen(vehicle, 5, false)
        elseif data.value == "modDoorSpeaker" then
            SetVehicleDoorOpen(vehicle, 0, false)
            SetVehicleDoorOpen(vehicle, 1, false)
            SetVehicleDoorOpen(vehicle, 2, false)
            SetVehicleDoorOpen(vehicle, 3, false)
        else
            SetVehicleDoorsShut(vehicle, false)
        end

        local vehiclePrice, vehPriceClass, isVehBike = getVehiclePrice(vehicle)

        local elements = {}
        local menuName = ""
        local menuTitle = ""
        local parent = nil

        for k, v in pairs(Config.Menus) do
            if data.value == k then
                menuName = k
                menuTitle = v.label
                parent = v.parent

                if v.modType ~= nil then
                    if v.modType == 22 then
                        local isInstalled = true
                        if currentMods[k] then
                            isInstalled = false
                        end
                        table.insert(elements, { label = "Normální", modType = k, modNum = false })
                    elseif v.modType == "neonColor" or v.modType == "tyreSmokeColor" then
                        -- disable neon
                        table.insert(elements, { label = "Základní", modType = k, modNum = { 0, 0, 0 } })
                    elseif
                    v.modType == "color1" or v.modType == "color2" or v.modType == "pearlescentColor" or
                        v.modType == "dashboardColor" or
                        v.modType == "interiorColor" or
                        v.modType == "wheelColor"
                    then
                        local num = myCarTry[v.modType]
                        table.insert(elements, { label = "Základní", modType = k, modNum = num })
                    elseif v.modType == 17 then
                        local isInstalled = true
                        if currentMods[k] then
                            isInstalled = false
                        end
                        table.insert(
                            elements,
                            { label = "Bez turba", modType = k, modNum = false, isInstalled = isInstalled }
                        )
                    elseif v.modType == 48 then
                        local isInstalled = true
                        if currentMods[k] ~= -1 then
                            isInstalled = false
                        end
                        table.insert(
                            elements,
                            { label = "Bez polepu", modType = k, modNum = -1, isInstalled = isInstalled }
                        )
                    elseif v.modType == 14 then
                        local isInstalled = true
                        if currentMods[k] ~= -1 then
                            isInstalled = false
                        end
                        table.insert(elements, { label = "Car", modType = k, modNum = -1, isInstalled = isInstalled })
                    elseif
                    v.modType ~= "lightsColor" and v.modType ~= "extras" and v.modType ~= "plateIndex" and
                        v.modType ~= "windowTint" and
                        v.modType ~= "modLiveries" and v.modType ~= "modBackWheels"
                    then
                        local isInstalled = false
                        if currentMods[k] == -1 then
                            isInstalled = true
                        end

                        if type(v.prices.cost) == "table" then
                            if v.prices.type == "percentage" then
                                if not vehiclePrice then
                                    vehiclePrice = 1000000
                                end
                                price = vehiclePrice * (v.prices.cost[1] / 100)
                            else
                                price = v.prices.cost[vehPriceClass]
                            end
                        else
                            price = v.prices.cost
                        end

                        table.insert(
                            elements,
                            { label = "Základní", modType = k, modNum = -1, isInstalled = isInstalled, price = price }
                        )
                    end

                    if v.modType == 14 then
                        -- HORNS
                        for j = 0, 51 do
                            local _label = GetHornName(j)
                            local isInstalled = false
                            if type(v.prices.cost) == "table" then
                                price = v.prices.cost[vehPriceClass]
                            else
                                price = v.prices.cost
                            end
                            if j == currentMods.modHorns then
                                isInstalled = true
                            end

                            table.insert(
                                elements,
                                { label = _label, modType = k, modNum = j, isInstalled = isInstalled, price = price }
                            )
                        end
                    elseif v.modType == "plateIndex" then
                        -- PLATES
                        for j = 0, 5 do
                            local _label = GetPlatesName(j)
                            local isInstalled = false
                            if type(v.prices.cost) == "table" then
                                price = v.prices.cost[vehPriceClass]
                            else
                                price = v.prices.cost
                            end

                            if j == currentMods.plateIndex then
                                isInstalled = true
                            end

                            table.insert(
                                elements,
                                { label = _label, modType = k, modNum = j, isInstalled = isInstalled, price = price }
                            )
                        end
                    elseif v.modType == 22 then
                        -- XENON
                        local _label = "Xenonové světla"
                        local isInstalled = false
                        if type(v.prices.cost) == "table" then
                            price = v.prices.cost[vehPriceClass]
                        else
                            price = v.prices.cost
                        end

                        if currentMods.modXenon then
                            isInstalled = true
                        end
                        table.insert(
                            elements,
                            { label = _label, modType = k, modNum = true, isInstalled = isInstalled, price = price }
                        )
                    elseif v.modType == "neonColor" or v.modType == "tyreSmokeColor" then
                        -- NEON & SMOKE COLOR
                        local neons = GetNeons()
                        if type(v.prices.cost) == "table" then
                            price = v.prices.cost[vehPriceClass]
                        else
                            price = v.prices.cost
                        end
                        for _, neon in each(neons) do
                            table.insert(
                                elements,
                                {
                                    label = '<span style="color:rgb(' ..
                                        neon.r .. "," .. neon.g .. "," .. neon.b .. ');">' .. neon.label .. "</span>",
                                    modType = k,
                                    modNum = { neon.r, neon.g, neon.b },
                                    price = price
                                }
                            )
                        end
                    elseif
                    v.modType == "color1" or v.modType == "color2" or v.modType == "pearlescentColor" or
                        v.modType == "dashboardColor" or
                        v.modType == "interiorColor" or
                        v.modType == "wheelColor"
                    then
                        -- RESPRAYS
                        local colors = GetColors(data.color)
                        for _, color in each(colors) do
                            local _label = ""
                            if not isVehBike then
                                if type(v.prices.cost) == "table" then
                                    price = v.prices.cost[vehPriceClass]
                                else
                                    price = v.prices.cost
                                end
                            else
                                price = 100
                            end
                            _label = color.label

                            table.insert(elements, { label = _label, modType = k, modNum = color.index, price = price })
                        end
                    elseif v.modType == "extras" then
                        if type(v.prices.cost) == "table" then
                            price = v.prices.cost[vehPriceClass]
                        else
                            price = v.prices.cost
                        end
                        extrasState = {}

                        for id = 0, 14 do
                            if DoesExtraExist(vehicle, id) then
                                local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
                                extrasState[id] = state

                                local isInstalled = false
                                if state then
                                    isInstalled = true
                                end

                                local idText = id
                                if id < 10 then
                                    idText = "0" .. idText
                                end

                                table.insert(
                                    elements,
                                    {
                                        label = "Vylepšení #" .. idText,
                                        modType = "extras",
                                        modNum = id,
                                        modState = state,
                                        isInstalled = isInstalled,
                                        price = price
                                    }
                                )
                            end
                        end
                    elseif v.modType == "lightsColor" then
                        if type(v.prices.cost) == "table" then
                            price = v.prices.cost[vehPriceClass]
                        else
                            price = v.prices.cost
                        end
                        local current = GetVehicleXenonLightsColor(vehicle)

                        table.insert(
                            elements,
                            {
                                label = "Bílá",
                                price = price,
                                modType = "lightsColor",
                                modNum = 0,
                                isInstalled = (current == 0 or current == -1) and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Tmavě modrá",
                                price = price,
                                modType = "lightsColor",
                                modNum = 1,
                                isInstalled = current == 1 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Světle modrá",
                                price = price,
                                modType = "lightsColor",
                                modNum = 2,
                                isInstalled = current == 2 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Tyrkysová",
                                price = price,
                                modType = "lightsColor",
                                modNum = 3,
                                isInstalled = current == 3 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Zelená",
                                price = price,
                                modType = "lightsColor",
                                modNum = 4,
                                isInstalled = current == 4 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Žlutá",
                                price = price,
                                modType = "lightsColor",
                                modNum = 5,
                                isInstalled = current == 5 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Zlatá",
                                price = price,
                                modType = "lightsColor",
                                modNum = 6,
                                isInstalled = current == 6 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Oranžová",
                                price = price,
                                modType = "lightsColor",
                                modNum = 7,
                                isInstalled = current == 7 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Červená",
                                price = price,
                                modType = "lightsColor",
                                modNum = 8,
                                isInstalled = current == 8 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Růžová",
                                price = price,
                                modType = "lightsColor",
                                modNum = 9,
                                isInstalled = current == 9 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Fialová",
                                price = price,
                                modType = "lightsColor",
                                modNum = 10,
                                isInstalled = current == 10 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Purpurová",
                                price = price,
                                modType = "lightsColor",
                                modNum = 11,
                                isInstalled = current == 11 and true or false
                            }
                        )
                        table.insert(
                            elements,
                            {
                                label = "Tmavě fialová",
                                price = price,
                                modType = "lightsColor",
                                modNum = 12,
                                isInstalled = current == 12 and true or false
                            }
                        )
                    elseif v.modType == "windowTint" then
                        -- WINDOWS TINT
                        for j = 0, 5 do
                            local _label = GetWindowName(j)
                            local isInstalled = false
                            if type(v.prices.cost) == "table" then
                                price = v.prices.cost[vehPriceClass]
                            else
                                price = v.prices.cost
                            end

                            if j == currentMods.windowTint then
                                isInstalled = true
                            end
                            table.insert(
                                elements,
                                { label = _label, modType = k, modNum = j, isInstalled = isInstalled, price = price }
                            )
                        end
                    elseif v.modType == 24 then
                        local props = {}

                        props.wheels = myCarTry.wheels
                        props.modFrontWheels = myCarTry.modFrontWheels
                        exports.base_vehicles:SetVehicleProperties(vehicle, props)

                        local modCount = GetNumVehicleMods(vehicle, v.modType)

                        if modCount == 0 then
                            exports.notify:display(
                                { type = "error", title = "Chyba", text = "Ke zvolenému přednímu typu kol neexistuje sada zadních!", icon = "fas fa-times", length = 3500 }
                            )
                        end

                        for j = 1, modCount do
                            local modName = GetModTextLabel(vehicle, v.modType, j)
                            if modName ~= nil then
                                local _label = GetLabelText(modName)
                                local isInstalled = false
                                if type(v.prices.cost) == "table" then
                                    price = v.prices.cost[vehPriceClass]
                                else
                                    price = v.prices.cost
                                end

                                if j == currentMods.modBackWheels and v.modType == 24 then
                                    isInstalled = true
                                end

                                table.insert(
                                    elements,
                                    {
                                        label = _label,
                                        modType = "modBackWheels",
                                        modNum = j,
                                        wheelType = v.wheelType,
                                        price = price,
                                        isInstalled = isInstalled
                                    }
                                )
                            end
                        end
                    elseif v.modType == 23 then
                        -- WHEELS RIM & TYPE
                        local props = {}

                        props.wheels = v.wheelType
                        exports.base_vehicles:SetVehicleProperties(vehicle, props)

                        local modCount = GetNumVehicleMods(vehicle, v.modType)
                        for j = 1, modCount do
                            local modName = GetModTextLabel(vehicle, v.modType, j)
                            if modName ~= nil then
                                local _label = GetLabelText(modName)
                                local isInstalled = false
                                if type(v.prices.cost) == "table" then
                                    price = v.prices.cost[vehPriceClass]
                                else
                                    price = v.prices.cost
                                end

                                if j == currentMods.modFrontWheels and v.modType == 23 then
                                    isInstalled = true
                                end

                                table.insert(
                                    elements,
                                    {
                                        label = _label,
                                        modType = v.modType == 23 and "modFrontWheels" or "modBackWheels",
                                        modNum = j,
                                        wheelType = v.wheelType,
                                        price = price,
                                        isInstalled = isInstalled
                                    }
                                )
                            end
                        end
                    elseif v.modType == 11 or v.modType == 12 or v.modType == 13 or v.modType == 15 or v.modType == 16 then
                        local modCount = GetNumVehicleMods(vehicle, v.modType) -- UPGRADES
                        for j = 1, modCount do
                            local _label = "Úroveň " .. (j + 1)
                            local isInstalled = false
                            if type(v.prices.cost) == "table" then
                                if not vehiclePrice then
                                    vehiclePrice = 1000000
                                end
                                price = vehiclePrice * (v.prices.cost[j + 1] / 100)
                            else
                                price = v.prices.cost
                            end

                            if j == currentMods[k] then
                                isInstalled = true
                            end

                            table.insert(
                                elements,
                                { label = _label, modType = k, modNum = j, isInstalled = isInstalled, price = price }
                            )
                            if j == modCount - 1 then
                                break
                            end
                        end
                    elseif v.modType == 17 then
                        local _label = "Turbo"
                        local isInstalled = false
                        price = vehiclePrice * (v.prices.cost / 100)

                        if currentMods[k] then
                            isInstalled = true
                        end
                        table.insert(
                            elements,
                            { label = _label, modType = k, modNum = true, isInstalled = isInstalled, price = price }
                        )
                    elseif v.modType == "modLiveries" then
                        local liveriesCount = GetVehicleLiveryCount(vehicle) -- Liveries
                        for j = 1, liveriesCount do
                            local livery = GetLiveryName(vehicle, j)
                            local _label = GetLabelText(livery) ~= "NULL" and GetLabelText(livery) or "Livery #" .. j
                            local isInstalled = false
                            if type(v.prices.cost) == "table" then
                                price = v.prices.cost[vehPriceClass]
                            else
                                price = v.prices.cost
                            end

                            if j == currentMods.modLiveries then
                                isInstalled = true
                            end

                            table.insert(
                                elements,
                                {
                                    label = _label,
                                    modType = "modLiveries",
                                    modNum = j,
                                    isInstalled = isInstalled,
                                    price = price
                                }
                            )
                        end
                    else
                        local modCount = GetNumVehicleMods(vehicle, v.modType) -- BODYPARTS
                        for j = 1, modCount do
                            local modName = GetModTextLabel(vehicle, v.modType, j)
                            if modName ~= nil then
                                local _label = GetLabelText(modName)
                                local isInstalled = false
                                if type(v.prices.cost) == "table" then
                                    price = v.prices.cost[vehPriceClass]
                                else
                                    price = v.prices.cost
                                end

                                if j == currentMods[k] then
                                    isInstalled = true
                                end

                                table.insert(
                                    elements,
                                    { label = _label, modType = k, modNum = j, isInstalled = isInstalled, price = price }
                                )
                            end
                        end
                    end
                else
                    if
                    data.value == "primaryRespray" or data.value == "secondaryRespray" or
                        data.value == "pearlescentRespray" or
                        data.value == "dashboardRespray" or
                        data.value == "interiorRespray" or
                        data.value == "modFrontWheelsColor"
                    then
                        for i, color in each(Config.Colors) do
                            if data.value == "primaryRespray" then
                                table.insert(elements, { label = color.label, value = "color1", color = color.value })
                            elseif data.value == "secondaryRespray" then
                                table.insert(elements, { label = color.label, value = "color2", color = color.value })
                            elseif data.value == "pearlescentRespray" then
                                table.insert(
                                    elements,
                                    {
                                        label = color.label,
                                        value = "pearlescentColor",
                                        color = color.value
                                    }
                                )
                            elseif data.value == "dashboardRespray" then
                                table.insert(
                                    elements,
                                    {
                                        label = color.label,
                                        value = "dashboardColor",
                                        color = color.value
                                    }
                                )
                            elseif data.value == "interiorRespray" then
                                table.insert(
                                    elements,
                                    {
                                        label = color.label,
                                        value = "interiorColor",
                                        color = color.value
                                    }
                                )
                            elseif data.value == "modFrontWheelsColor" then
                                table.insert(
                                    elements,
                                    {
                                        label = color.label,
                                        value = "wheelColor",
                                        color = color.value
                                    }
                                )
                            end
                        end
                    else
                        for l, w in pairs(v) do
                            if l ~= "label" and l ~= "parent" then
                                if
                                l ~= "upgrades" or
                                    job ~= "lspd" and job ~= "lssd" and job ~= "sahp" and job ~= "ems" and
                                        job ~= "lsfd"
                                then
                                    table.insert(elements, { label = w, value = l })
                                end
                            end
                        end
                    end
                end
                break
            end
        end

        table.sort(
            elements,
            function(a, b)
                return a.label < b.label
            end
        )

        OpenLSMenu(elements, menuName, menuTitle, parent)
    else
        isInMenu = false
        exports.notify:display(
            { type = "error", title = "Chyba", text = "Musíš být ve vozidle!", icon = "fas fa-times", length = 3500 }
        )
    end
end

function OpenLSMenu(elems, menuName, menuTitle, parent)
    Citizen.CreateThread(
        function()
            local selected = false
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            WarMenu.CreateMenu(menuName, menuTitle, "Vyberte akci")
            WarMenu.SetMenuY(menuName, 0.35)
            WarMenu.OpenMenu(menuName)

            local currentlySelected = nil
            local lastSelected = 0

            while true do
                DisableControlAction(2, 75, true)
                if WarMenu.IsMenuOpened(menuName) then
                    isInMenu = true
                    selected = false

                    if lastParentIndex[menuName] then
                        WarMenu.SetCurrentOption(lastParentIndex[menuName])
                        lastParentIndex[menuName] = nil
                    end

                    for i, elem in each(elems) do
                        local button
                        if elem.isInstalled then
                            button = WarMenu.SpriteButton(elem.label, "commonmenu", "shop_garage_icon_b")
                        else
                            button = WarMenu.Button(
                                elem.label,
                                (elem.price and getFormattedCurrency(math.ceil(elem.price)) or "")
                            )
                        end

                        if button then
                            WarMenu.CloseMenu()
                            selected = true

                            local isRimMod, found = false, false

                            if elem.modType == "modFrontWheels" then
                                isRimMod = true
                            end

                            for k, v in pairs(Config.Menus) do
                                if k == elem.modType or isRimMod then
                                    if elem.isInstalled and elem.modType ~= "extras" then
                                        exports.notify:display(
                                            {
                                                type = "error",
                                                title = "Mechanik",
                                                text = "Toto rozšíření je již nainstalováno!",
                                                icon = "fas fa-car",
                                                length = 3500
                                            }
                                        )
                                    else
                                        local price = 0

                                        local vehiclePrice, vehPriceClass, isVehBike = getVehiclePrice(vehicle)
                                        if isRimMod then
                                            price = elem.price
                                        elseif v.modType == 11 or v.modType == 12 or v.modType == 13 or v.modType == 15 then
                                            local partCost = (elem.modNum ~= -1 and elem.modNum or 0)
                                            if type(v.prices.cost) == "table" then
                                                price = vehiclePrice * (v.prices.cost[partCost + 1] / 100)
                                            end
                                        elseif v.modType == 17 then
                                            price = vehiclePrice * (v.prices.cost / 100)
                                        else
                                            if not isVehBike then
                                                if type(v.prices.cost) == "table" then
                                                    price = v.prices.cost[vehPriceClass]
                                                else
                                                    price = v.prices.cost
                                                end
                                            else
                                                price = 100
                                            end
                                        end

                                        prices[elem.modType] = math.ceil(price)

                                        installMod()
                                    end

                                    found = true
                                end
                            end

                            if not found then
                                prepareMenu(elem)
                            else
                                prepareMenu({ value = parent })
                            end

                            lastParentIndex[menuName] = WarMenu.CurrentOption()
                        end
                    end

                    currentlySelected = WarMenu.CurrentOption()

                    if lastSelected ~= currentlySelected then
                        lastSelected = currentlySelected
                        UpdateMods(elems[currentlySelected])
                    end

                    WarMenu.Display()
                else
                    if not selected then
                        local playerPed = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        SetVehicleDoorsShut(vehicle, false)
                        cancelInstallMod()

                        if parent == nil then
                            openConfirmMenu()
                        else
                            prepareMenu({ value = parent })
                        end
                    end

                    break
                end

                Citizen.Wait(0)
            end
        end
    )
end

function openConfirmMenu()
    Citizen.CreateThread(
        function()
            WarMenu.CreateMenu("mechanic_confirm", "Mechanik", "Vyberte akci")
            WarMenu.SetMenuY("mechanic_confirm", 0.35)
            WarMenu.OpenMenu("mechanic_confirm")
            local selected = false
            local isReturning = false
            local price = getTotalPrice()
            local vehicle = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(PlayerPedId(), false))

            while true do
                DisableControlAction(2, 75, true)
                if WarMenu.IsMenuOpened("mechanic_confirm") then
                    isInMenu = true

                    if WarMenu.Button("Zakoupit (" .. getFormattedCurrency(price) .. ")") then
                        TriggerServerEvent("mechanicmenu:buy", job, price, vehicle, myCarTry)
                        selected = true
                    elseif WarMenu.Button("Zrušit a vrátit do původního stavu") then
                        selected = true
                        resetVehicle()
                        WarMenu.CloseMenu()
                    elseif WarMenu.Button("Pokračovat v tunění") then
                        selected = true
                        WarMenu.CloseMenu()

                        isReturning = true
                        isInMenu = false
                        openMechanicMenu({ value = "main" }, true)
                    end

                    WarMenu.Display()
                else
                    if not selected then
                        openConfirmMenu()
                    elseif not isReturning then
                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                        FreezeEntityPosition(vehicle, false)
                        myCar = {}
                        myCarTry = {}
                        isInMenu = false
                    end

                    break
                end

                Citizen.Wait(0)
            end
        end
    )
end

RegisterNetEvent("mechanicmenu:buy")
AddEventHandler(
    "mechanicmenu:buy",
    function(status)
        if status == "done" then
            exports.notify:display(
                {
                    type = "success",
                    title = "Mechanik",
                    text = "Úprava vozidla byla dokončena",
                    icon = "fas fa-car",
                    length = 3500
                }
            )
        else
            print("MECHANIC FAILED: " .. status)
            exports.notify:display(
                {
                    type = "error",
                    title = "Mechanik",
                    text = "Při transakci nastala chyba!",
                    icon = "fas fa-car",
                    length = 3500
                }
            )
            resetVehicle()
        end
        job = nil
        WarMenu.CloseMenu()
    end
)

function UpdateMods(data)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if data then
        if data.modType ~= nil then
            local props = {}

            if data.wheelType ~= nil then
                props["wheels"] = data.wheelType
                exports.base_vehicles:SetVehicleProperties(vehicle, props)
                props = {}
            elseif data.modType == "neonColor" then
                if data.modNum[1] == 0 and data.modNum[2] == 0 and data.modNum[3] == 0 then
                    props["neonEnabled"] = { false, false, false, false }
                else
                    props["neonEnabled"] = { true, true, true, true }
                end
                exports.base_vehicles:SetVehicleProperties(vehicle, props)
                props = {}
            elseif data.modType == "tyreSmokeColor" then
                props["modSmokeEnabled"] = true
                exports.base_vehicles:SetVehicleProperties(vehicle, props)
                props = {}
            end

            if data.modType == "extras" then
                if props[data.modType] == nil then
                    props[data.modType] = {}
                end

                for i = 1, #extrasState do
                    props[data.modType][i] = extrasState[i]
                end

                props[data.modType][data.modNum] = not (data.modState)
                exports.base_vehicles:SetVehicleProperties(vehicle, props)
                lastExtrasID = data.modNum
            else
                props[data.modType] = data.modNum
                exports.base_vehicles:SetVehicleProperties(vehicle, props)
            end
        end
    end
end

function openMechanicMenu(data, isReturning)
    if isInMenu then
        return
    end

    job = (data.job ~= nil and data.job or job)
    isInMenu = true
    Citizen.CreateThread(
        function()
            if not isReturning then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                myCar = exports.base_vehicles:GetVehicleProperties(vehicle)
                myCarTry = exports.base_vehicles:GetVehicleProperties(vehicle)
                prices = {}
            end

            prepareMenu(data)
        end
    )
end

function resetVehicle()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    exports.base_vehicles:SetVehicleProperties(vehicle, myCar)
end

function installMod()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    myCarTry = exports.base_vehicles:GetVehicleProperties(vehicle)
end

function cancelInstallMod()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    exports.base_vehicles:SetVehicleProperties(vehicle, myCarTry)
end

function getVehiclePrice(vehicle)
    local model = GetEntityModel(vehicle)
    local foundVeh = nil

    for _, data in pairs(VEHICLE) do
        if model == GetHashKey(data.model) then
            local price = data.baseprice
            if price <= 30000 then
                return price, 1, GetVehicleClass(vehicle) == 13
            elseif 30000 < price and price <= 100000 then
                return price, 2
            elseif 100000 < price and price <= 300000 then
                return price, 3
            elseif 300000 < price and price <= 600000 then
                return price, 4
            elseif 600000 < price then
                return price, 5
            end
        end
    end

    print("Vehicle is not defined:", vehicleModel)
    return 1000000000, 4
end

function getTotalPrice()
    local total = 0
    for k, v in pairs(prices) do
        total = total + v
    end

    return total
end
