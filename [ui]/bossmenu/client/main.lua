local isSpawned, isDead, isOpened = false, false, false

Citizen.CreateThread(
    function()
        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead, isOpened = false, false, false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("bossmenu:recieveUpdatedData")
AddEventHandler(
    "bossmenu:recieveUpdatedData",
    function(jobData)
        if isOpened then
            jobData.Vehicles = prepareVehiclesToBuy(isOpened)
            jobData.OwnedVehs = prepareVehicles(jobData.vehicles)
            jobData.vehicles = nil
            SendNUIMessage(
                {
                    action = "update",
                    data = jobData
                }
            )
        end
    end
)

function openBossMenu(job)
    TriggerServerEvent("bossmenu:open", job)
end

function openApplicationMenu()
    TriggerServerEvent("bossmenu:applications")
end

RegisterNetEvent("bossmenu:open")
AddEventHandler(
    "bossmenu:open",
    function(job, jobData, userDetails)
        if jobData ~= nil then
            jobData.Vehicles = prepareVehiclesToBuy(job)
            jobData.OwnedVehs = prepareVehicles(jobData.vehicles)
            jobData.vehicles = nil
            isOpened = job
            SendNUIMessage(
                {
                    action = "show",
                    page = "dashboard",
                    data = jobData,
                    user = userDetails
                }
            )
            SetNuiFocus(true, true)
        end
    end
)

RegisterNetEvent("bossmenu:applications")
AddEventHandler(
    "bossmenu:applications",
    function(jobs)
        local applicationData = {}
        WarMenu.CreateMenu("applications", "????dosti", "Zvolte firmu")
        WarMenu.CreateSubMenu("applications_fill", "applications", "Vypl??te ??daje")
        WarMenu.OpenMenu("applications")
        local application = {
            name = exports.data:getCharVar("firstname") .. " " .. exports.data:getCharVar("lastname"),
            born = exports.data:getCharVar("birth")
        }
        while true do
            if WarMenu.IsMenuOpened("applications") then
                for job, label in each(jobs) do
                    if WarMenu.MenuButton(label, "applications_fill") then
                        applicationData = {job = job, label = label}
                    end
                end
                WarMenu.Display()
            elseif WarMenu.IsMenuOpened("applications_fill") then
                if WarMenu.Button("Jm??no a p????jmen??", tostring(application.name)) then
                    exports.input:openInput(
                        "text",
                        {
                            title = "Zadejte jm??no",
                            placeholder = ""
                        },
                        function(name)
                            if name then
                                application.name = name
                            end
                        end
                    )
                elseif WarMenu.Button("Datum narozen??", tostring(application.born)) then
                    exports.input:openInput(
                        "text",
                        {
                            title = "Zadejte datum narozen??",
                            placeholder = ""
                        },
                        function(born)
                            if born then
                                application.born = born
                            end
                        end
                    )
                elseif
                    WarMenu.Button(
                        "Telefonn?? ????slo",
                        tostring(not application.phone and "Pr??zdn??" or application.phone)
                    )
                 then
                    exports.input:openInput(
                        "text",
                        {
                            title = "Zadejte ????slo telefonu",
                            placeholder = ""
                        },
                        function(phone)
                            if phone then
                                application.phone = phone
                            else
                                application.phone = ""
                            end
                        end
                    )
                elseif
                    WarMenu.Button(
                        "Email(discord)",
                        tostring(not application.discord and "Pr??zdn??" or application.discord)
                    )
                 then
                    exports.input:openInput(
                        "text",
                        {
                            title = "Zadejte email, (discord)",
                            placeholder = "@DiscordName#Number"
                        },
                        function(discord)
                            if discord then
                                application.discord = discord
                            else
                                application.discord = ""
                            end
                        end
                    )
                elseif WarMenu.Button("Bydlen??", tostring(not application.house and "Pr??zdn??" or application.house)) then
                    exports.input:openInput(
                        "text",
                        {
                            title = "Bydli??t??",
                            placeholder = ""
                        },
                        function(house)
                            if house then
                                application.house = house
                            else
                                application.house = ""
                            end
                        end
                    )
                elseif WarMenu.Button("Vzd??l??n??", tostring(not application.school and "Pr??zdn??" or application.school)) then
                    exports.input:openInput(
                        "text",
                        {
                            title = "Bydli??t??",
                            placeholder = ""
                        },
                        function(school)
                            if school then
                                application.school = school
                            else
                                application.school = ""
                            end
                        end
                    )
                elseif
                    WarMenu.Button(
                        "Zku??enosti",
                        tostring(not application.experiences and "Pr??zdn??" or application.experiences)
                    )
                 then
                    exports.input:openInput(
                        "text",
                        {
                            title = "Zku??enosti",
                            placeholder = ""
                        },
                        function(experiences)
                            if experiences then
                                application.experiences = experiences
                            else
                                application.experiences = ""
                            end
                        end
                    )
                elseif WarMenu.Button("Odeslat") then
                    if application.discord ~= nil and application.experiences ~= nil and application.house ~= nil then
                        applicationData.type = "applications"
                        applicationData.status = "new"
                        applicationData.application = application
                        TriggerServerEvent("bossmenu:editJobData", applicationData)
                        WarMenu.CloseMenu()
                    else
                        exports.notify:display(
                            {
                                type = "error",
                                title = "Chyba",
                                text = "M???? pr??zdn?? ok??nka! ????",
                                icon = "fas fa-times",
                                length = 5000
                            }
                        )
                    end
                end
                WarMenu.Display()
            else
                break
            end
            Citizen.Wait(0)
        end
    end
)

RegisterNUICallback(
    "closepanel",
    function(data, cb)
        SendNUIMessage(
            {
                action = "hide"
            }
        )
        SetNuiFocus(false, false)
    end
)
RegisterNUICallback(
    "changeData",
    function(data, cb)
        TriggerServerEvent("bossmenu:editJobData", data)
    end
)
RegisterNUICallback(
    "applicationData",
    function(data, cb)
        data.type = "applications"
        TriggerServerEvent("bossmenu:editJobData", data)
    end
)
RegisterNUICallback(
    "employeeAction",
    function(data, cb)
        SendNUIMessage(
            {
                action = "hide"
            }
        )
        SetNuiFocus(false, false)
        Citizen.Wait(10)
        if data.action == "new" then
            if data.action == "new" then
                TriggerEvent(
                    "util:closestPlayer",
                    {
                        radius = 3.0
                    },
                    function(player)
                        if player then
                            WarMenu.CreateMenu("bossmenu", "N??bor", "Zvolte n??borovou pozici")
                            WarMenu.OpenMenu("bossmenu")
                            while true do
                                if WarMenu.IsMenuOpened("bossmenu") then
                                    for i, grade in each(data.grades) do
                                        if WarMenu.Button(grade.label, i) then
                                            exports.notify:display(
                                                {
                                                    type = "info",
                                                    title = "N??bor",
                                                    text = "??sp????n?? jsi nab??dnul/a pr??ci!",
                                                    icon = "fas fa-briefcase",
                                                    length = 3500
                                                }
                                            )
                                            TriggerServerEvent("bossmenu:sendRequest", player, data.job, i)
                                            WarMenu.CloseMenu()
                                        end
                                    end
                                    WarMenu.Display()
                                else
                                    break
                                end
                                Citizen.Wait(0)
                            end
                        end
                    end
                )
            end
        else
            WarMenu.CreateMenu("bossmenu_fire", "V??pov????", "Opravdu chcete vyhodit zam??stance?")
            WarMenu.OpenMenu("bossmenu_fire")
            while WarMenu.IsMenuOpened("bossmenu_fire") do
                if WarMenu.Button("Zru??it") then
                    WarMenu.CloseMenu()
                    Citizen.Wait(10)
                    SendNUIMessage(
                        {
                            action = "show",
                            page = "employes"
                        }
                    )
                    SetNuiFocus(true, true)
                elseif WarMenu.Button("Potvrdit") then
                    TriggerServerEvent("bossmenu:fireEmployee", data)
                    WarMenu.CloseMenu()
                end
                WarMenu.Display()
                Citizen.Wait(0)
            end
        end
    end
)

RegisterNetEvent("bossmenu:recieveRequest")
AddEventHandler(
    "bossmenu:recieveRequest",
    function(source, data, labels)
        exports.notify:display(
            {
                type = "info",
                title = labels.job,
                text = "Obdr??el/a jsi nab??dku na pracovn?? pozici " .. labels.grade,
                icon = "fas fa-briefcase",
                length = 3500
            }
        )
        WarMenu.CreateMenu("bossmenu_request", labels.job, "Potvr??te akci")
        WarMenu.OpenMenu("bossmenu_request")
        while WarMenu.IsMenuOpened("bossmenu_request") do
            if WarMenu.Button("P??ijmout") then
                TriggerServerEvent("bossmenu:answerRequest", source, true, data)
                exports.notify:display(
                    {
                        type = "success",
                        title = "N??bor",
                        text = "P??ijal/a jsi nab??dku!",
                        icon = "fas fa-briefcase",
                        length = 3500
                    }
                )
                WarMenu.CloseMenu()
            elseif WarMenu.Button("Odm??tnout") then
                TriggerServerEvent("bossmenu:answerRequest", source, false)
                exports.notify:display(
                    {
                        type = "warning",
                        title = "N??bor",
                        text = "Odm??tnul/a jsi nab??dku!",
                        icon = "fas fa-briefcase",
                        length = 3500
                    }
                )
                WarMenu.CloseMenu()
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    end
)

RegisterNUICallback(
    "orderVehicle",
    function(data, cb)
        SendNUIMessage(
            {
                action = "hide"
            }
        )
        SetNuiFocus(false, false)
        Citizen.Wait(10)
        WarMenu.CreateMenu("bossmenu_vehicleOrder", "Koup?? vozidla", "Vyberte mo??nost")
        WarMenu.OpenMenu("bossmenu_vehicleOrder")
        while WarMenu.IsMenuOpened("bossmenu_vehicleOrder") do
            if WarMenu.Button("Zam??stn??n??") then
                exports.input:openInput(
                    "number",
                    {
                        title = "Zadejte nejni?????? hodnost (alespo?? 1) s p????stupem k vozidlu",
                        placeholder = ""
                    },
                    function(grade)
                        if grade and tonumber(grade) > 0 then
                            TriggerServerEvent(
                                "bossmenu:orderVehicle",
                                data,
                                {
                                    job = data.job,
                                    grade = tonumber(grade)
                                }
                            )
                            WarMenu.CloseMenu()
                        end
                    end
                )
            end
            if data.job == "ems" or data.job == "lspd" or data.job == "lssd" then
                if WarMenu.Button(data.job == "ems" and "St??tn?? z??chrann?? slo??ky" or "St??tn?? bezpe??nost?? slo??ky") then
                    exports.input:openInput(
                        "number",
                        {
                            title = "Zadejte nejni?????? hodnost s p????stupem k vozidlu",
                            placeholder = ""
                        },
                        function(grade)
                            if grade then
                                TriggerServerEvent(
                                    "bossmenu:orderVehicle",
                                    data,
                                    {
                                        type = data.job == "ems" and "medic" or "police",
                                        grade = tonumber(grade)
                                    }
                                )
                                WarMenu.CloseMenu()
                            end
                        end
                    )
                end
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    end
)

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end

    local i = 0 -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

function prepareVehiclesToBuy(job)
    local vehicles = {}

    if Config.Vehicles[job] ~= nil then
        for _, veh in each(Config.Vehicles[job]) do
            local vehicleLabel = GetLabelText(GetDisplayNameFromVehicleModel(veh.Model))
            if vehicleLabel == "NULL" then
                vehicleLabel = exports.base_vehicles:getVehicleNameByHash(veh.Model)
            end
            table.insert(
                vehicles,
                {
                    Label = tostring(vehicleLabel),
                    Model = veh.Model,
                    Price = veh.Price,
                    Type = veh.Type,
                    Livery = veh.Livery
                }
            )
        end
        table.sort(
            vehicles,
            function(a, b)
                return a.Label < b.Label
            end
        )
    end

    return vehicles
end

function prepareVehicles(recieved)
    local vehicles = {}

    for _, veh in each(recieved) do
        local vehicleLabel = GetLabelText(GetDisplayNameFromVehicleModel(veh.model))
        if vehicleLabel == "NULL" then
            vehicleLabel = exports.base_vehicles:getVehicleNameByHash(veh.model)
        end
        table.insert(
            vehicles,
            {
                Label = tostring(vehicleLabel),
                Plate = veh.plate,
                Garage = veh.garage,
                Data = veh.job,
                Grade = veh.grade
            }
        )
    end
    table.sort(
        vehicles,
        function(a, b)
            return a.Label < b.Label
        end
    )

    return vehicles
end
