local isSpawned, isDead, pCoords = false, false, nil
local jobs = nil

local requestedDocuments = {}
local myVehicles = {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
        end

        exports.target:AddCircleZone(
            "documentMaster",
            Config.Reception,
            1.5,
            {
                actions = {
                    documents = {
                        cb = function()
                            openOfficeMenu("Documents")
                        end,
                        icon = "fas fa-file-alt",
                        label = "Ztráta dokumentů"
                    },
                    car = {
                        cb = function()
                            openOfficeMenu("Vehicles")
                        end,
                        icon = "fas fa-car",
                        label = "Registr vozidel"
                    },
                    employment = {
                        cb = function()
                            exports.bossmenu:openApplicationMenu()
                        end,
                        icon = "fas fa-briefcase",
                        label = "Pracovní nabídky"
                    }
                },
                distance = 1.0
            }
        )

        checkMisc()
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                loadJobs()
            end
        end
    end
)

function checkMisc()
    if not DoesEntityExist(reception) then
        createReception()
    end
end
function createReception()
    while not HasModelLoaded(GetHashKey("a_f_y_business_02")) do
        RequestModel(GetHashKey("a_f_y_business_02"))
        Wait(5)
    end
    reception =
        CreatePed(4, GetHashKey("a_f_y_business_02"), Config.Reception.xy, Config.Reception.z - 1.0, false, false)
    SetEntityHeading(reception, 179.0)
    SetEntityAsMissionEntity(reception, true, true)
    SetPedHearingRange(reception, 0.0)
    SetPedSeeingRange(reception, 0.0)
    SetPedAlertness(reception, 0.0)
    SetPedFleeAttributes(reception, 0, 0)
    SetBlockingOfNonTemporaryEvents(reception, true)
    SetPedCombatAttributes(reception, 46, true)
    SetPedFleeAttributes(reception, 0, 0)
    SetEntityInvincible(reception, true)
    FreezeEntityPosition(reception, true)
    TaskStartScenarioInPlace(reception, "WORLD_HUMAN_CLIPBOARD", 0, false)
end

RegisterNetEvent("documents:requestNewDocument")
AddEventHandler(
    "documents:requestNewDocument",
    function(document, cash, removed, data)
        if not cash then
            exports.notify:display(
                {
                    type = "error",
                    title = "Žádost o dokument",
                    text = "Nemáte u sebe dost peněz!",
                    icon = "far fa-id-card",
                    length = 5000
                }
            )
        else
            if removed == "done" then
                exports.notify:display(
                    {
                        type = "success",
                        title = "Žádost o dokument",
                        text = "Žádost se zpracovává. Za 2 minuty buďte na recepci!",
                        icon = "far fa-id-card",
                        length = 5000
                    }
                )
                requestedDocuments[document] = {
                    Active = true,
                    Data = data
                }
                Citizen.SetTimeout(
                    10000,
                    function()
                        exports.target:AddCircleZone(
                            "documentMaster",
                            Config.Reception,
                            1.5,
                            {
                                actions = {
                                    documents = {
                                        cb = function()
                                            openOfficeMenu("Documents")
                                        end,
                                        icon = "fas fa-file-alt",
                                        label = "Ztráta dokumentů"
                                    },
                                    car = {
                                        cb = function()
                                            openOfficeMenu("Vehicles")
                                        end,
                                        icon = "fas fa-car",
                                        label = "Registr vozidel"
                                    },
                                    collect = {
                                        cb = function()
                                            pickupDocument()
                                        end,
                                        icon = "fas fa-thumbs-up",
                                        label = "Vyzvednout dokumenty"
                                    },
                                    employment = {
                                        cb = function()
                                            exports.bossmenu:openApplicationMenu()
                                        end,
                                        icon = "fas fa-briefcase",
                                        label = "Pracovní nabídky"
                                    }
                                },
                                distance = 1.0
                            }
                        )
                        requestedDocuments[document].Active = false
                    end
                )
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Žádost o dokument",
                        text = "Žádost bohužel neprošla naším systémem. Požádejte si později.",
                        icon = "far fa-id-card",
                        length = 5000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("documents:takeNewDocument")
AddEventHandler(
    "documents:takeNewDocument",
    function(documents)
        local info = {}
        for key, value in pairs(documents) do
            if documents[key] == "done" then
                table.insert(info, "Zde máte " .. Config.documentName[key] .. "<br>")
            else
                table.insert(info, "Někde se stala chyba ve vaší žádosti o " .. Config.documentName[key] .. "<br>")
            end

            requestedDocuments[key] = nil
        end
        exports.notify:display(
            {
                type = "info",
                title = "Žádost o dokument",
                text = table.concat(info),
                icon = "far fa-id-card",
                length = 4000
            }
        )
    end
)

RegisterNetEvent("documents:ownedVehicles")
AddEventHandler(
    "documents:ownedVehicles",
    function(vehicles)
        myVehicles = vehicles
        if vehicles then
            SendNUIMessage(
                {
                    Action = "show"
                }
            )

            local content, leftmenu = formatContent("vehicles", "carkeys", myVehicles)
            SendNUIMessage(
                {
                    Action = "opencontent",
                    Content = table.concat(content),
                    Leftmenu = table.concat(leftmenu),
                    Openedmenu = "vehicles"
                }
            )
            SetNuiFocus(true, true)
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Registr vozidel",
                    text = "Nemáte v záznamech žádná vlastněná vozidla",
                    icon = "fas fa-car",
                    length = 4000
                }
            )
        end
    end
)

function openOfficeMenu(office)
    if Config.Offices[office].Main == "vehicles" then
        TriggerServerEvent("documents:ownedVehicles")
        return
    end
    SendNUIMessage(
        {
            Action = "show"
        }
    )

    local content, leftmenu = formatContent(Config.Offices[office].Main, Config.Offices[office].Left)
    SendNUIMessage(
        {
            Action = "opencontent",
            Content = table.concat(content),
            Leftmenu = table.concat(leftmenu),
            Openedmenu = Config.Offices[office].Main
        }
    )
    SetNuiFocus(true, true)
end
--

RegisterNUICallback(
    "closepanel",
    function(data, cb)
        SendNUIMessage(
            {
                Action = "hide"
            }
        )
        SetNuiFocus(false, false)
    end
)

RegisterNUICallback(
    "openmenu",
    function(data, cb)
        local content, leftmenu =
            formatContent(data.openedmenu, data.newmenu, (#myVehicles > 0 and myVehicles or {}), data.plate)
        SendNUIMessage(
            {
                Action = "opencontent",
                Content = table.concat(content),
                Leftmenu = table.concat(leftmenu)
            }
        )
    end
)

RegisterNUICallback(
    "selectaction",
    function(data, cb)
        if data.action == "newid" or data.action == "newlicense" or data.action == "getcarkeys" then
            if not requestedDocuments[data.action] or not requestedDocuments[data.action].data then
                TriggerServerEvent("documents:requestNewDocument", data.action, data.data)
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Žádost o přepis vozu",
                        text = "Aktuálně pro vás zpracováváme jiný požadavek",
                        icon = "far fa-id-card",
                        length = 3500
                    }
                )
            end
        elseif data.action == "vehowner_player" then -- done
            if requestedDocuments.carKeys then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Žádost o přepis vozu",
                        text = "Aktuálně pro vás zpracováváme jiný požadavek",
                        icon = "fas fa-car",
                        length = 3500
                    }
                )
                return
            end
            TriggerEvent(
                "util:closestPlayer",
                {
                    radius = 2.0
                },
                function(player)
                    if player then
                        TriggerServerEvent("documents:changeOwner", "person", player, data.data)
                    end
                end
            )
        elseif data.action == "vehowner_job" then
            if requestedDocuments.carKeys then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Žádost o přepis vozu",
                        text = "Aktuálně pro vás zpracováváme jiný požadavek",
                        icon = "fas fa-car",
                        length = 3500
                    }
                )
            else
                local content, leftmenu =
                    formatContent(data.openedmenu, data.newmenu, (#myVehicles > 0 and myVehicles or {}))
                SendNUIMessage(
                    {
                        Action = "opencontent",
                        Content = table.concat(content),
                        Leftmenu = table.concat(leftmenu)
                    }
                )
            end
        end

        SendNUIMessage(
            {
                Action = "hide"
            }
        )
        SetNuiFocus(false, false)
    end
)

RegisterNUICallback(
    "selectjob",
    function(data, cb)
        if data.job ~= "medic" and data.job ~= "police" then
            local gradeRank = exports.base_jobs:getJobGradeVar(data.job, jobs[data.job].Grade, "rank")
            print(gradeRank)
            if gradeRank == "boss" or gradeRank == "secondboss" then
                exports.input:openInput(
                    "number",
                    {title = "Zadejte minimální hodnost (alespoň 1)", placeholder = ""},
                    function(grade)
                        if grade and tonumber(grade) > 0 then
                            data.grade = grade
                            TriggerServerEvent("documents:changeOwner", "job", data, data.plate)
                            SendNUIMessage(
                                {
                                    Action = "hide"
                                }
                            )
                            SetNuiFocus(false, false)
                        end
                    end
                )
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Žádost o přepis vozu",
                        text = "Nejste majitelem nebo spolumajitelem společnosti!",
                        icon = "fas fa-car",
                        length = 3500
                    }
                )
            end
        else
            for _, jobData in pairs(jobs) do
                if jobData.Type == data.job then
                    local gradeRank = exports.base_jobs:getJobGradeVar(jobData.Name, jobData.Grade, "rank")
                    if gradeRank == "boss" or gradeRank == "secondboss" then
                        exports.input:openInput(
                            "number",
                            {title = "Zadejte minimální hodnost (alespoň 1)", placeholder = ""},
                            function(grade)
                                if grade and tonumber(grade) > 0 then
                                    data.grade = grade
                                    TriggerServerEvent("documents:changeOwner", "type", data, data.plate)
                                    SendNUIMessage(
                                        {
                                            Action = "hide"
                                        }
                                    )
                                    SetNuiFocus(false, false)
                                end
                            end
                        )
                    else
                        exports.notify:display(
                            {
                                type = "error",
                                title = "Žádost o přepis vozu",
                                text = "Nejste majitelem nebo spolumajitelem společnosti!",
                                icon = "fas fa-car",
                                length = 3500
                            }
                        )
                    end
                    break
                end
            end
        end
    end
)
function pickupDocument()
    documentsReady = false
    local canTake = {}
    for key, value in pairs(requestedDocuments) do
        if requestedDocuments[key].Data then
            canTake[key] = requestedDocuments[key].Data
        end
    end
    exports.target:AddCircleZone(
        "documentMaster",
        Config.Reception,
        1.5,
        {
            actions = {
                documents = {
                    cb = function()
                        openOfficeMenu("Documents")
                    end,
                    icon = "fas fa-file-alt",
                    label = "Ztráta dokumentů"
                },
                car = {
                    cb = function()
                        openOfficeMenu("Vehicles")
                    end,
                    icon = "fas fa-car",
                    label = "Registr vozidel"
                },
                employment = {
                    cb = function()
                        exports.bossmenu:openApplicationMenu()
                    end,
                    icon = "fas fa-briefcase",
                    label = "Pracovní nabídky"
                }
            },
            distance = 1.0
        }
    )

    TriggerServerEvent("documents:takeNewDocument", canTake)
end

function formatContent(action, menu, data, rememberPlate)
    local main, leftmenu = {}, {}
    if action == "documents" then
        table.insert(leftmenu, "<ul>")
        table.insert(
            leftmenu,
            '<li onclick="openMenu(\'new\')" class=\'menu-title ' ..
                (menu == "new" and "active" or "") .. "'><i class='fas fa-file-alt'></i> Zařídit dokument</li>"
        )
        table.insert(leftmenu, "</ul>")

        table.insert(main, "<ul>")
        if menu == "new" then
            table.insert(
                main,
                '<li onclick="selectAction(\'newid\', \'none\')" class=\'menu-button\'>' ..
                    (not requestedDocuments.newid and
                        ("Zažádat o ID <span class='cash'>$" .. Config.Cost.newid .. "</span>") or
                        "Žádost o doklad se zpracovává...") ..
                        "</li>"
            )
            table.insert(
                main,
                '<li onclick="selectAction(\'newlicense\', \'none\')" class=\'menu-button\'>' ..
                    (not requestedDocuments.newlicense and
                        ("Zažádat o licenci (ŘP, ZP...) <span class='cash'>$" .. Config.Cost.newlicense .. "</span>") or
                        "Žádost o doklad se zpracovává...") ..
                        "</li>"
            )
        end
        table.insert(main, "</ul>")
    elseif action == "vehicles" then
        table.insert(leftmenu, "<ul>")
        table.insert(
            leftmenu,
            '<li onclick="openMenu(\'carkeys\')" class=\'menu-title ' ..
                (menu == "carkeys" and "active" or "") ..
                    "'><i class='fas fa-car-side'></i> Ztráta klíčů od vozidla</li>"
        )
        table.insert(
            leftmenu,
            '<li onclick="openMenu(\'vehowner\')" class=\'menu-title ' ..
                ((menu == "vehowner" or menu == "vehowner_player" or menu == "vehowner_job") and "active" or "") ..
                    "'><i class='fas fa-people-arrows'></i> Změnit majitele vozidla</li>"
        )
        table.insert(leftmenu, "</ul>")

        table.insert(main, "<ul>")
        if menu == "carkeys" then
            for i, veh in each(data) do
                local vehModel = GetLabelText(GetDisplayNameFromVehicleModel(veh.data.model))
                table.insert(
                    main,
                    ('<li onclick="selectAction(\'getcarkeys\', \'%s\')" class=\'menu-button\'>' ..
                        (not requestedDocuments.getcarkeys and
                            ("Nové klíče pro " ..
                                vehModel ..
                                    " s SPZ: " ..
                                        veh.spz .. " <span class='cash'>$" .. Config.Cost.getcarkeys .. "</span>") or
                            "Žádost o vydání klíčů se zpracovává...") ..
                            "</li>"):format(veh.spz, veh.spz, veh.spz)
                )
            end
        elseif menu == "vehowner" then
            table.insert(
                main,
                '<li onclick="openMenu(\'vehowner_player\')" class=\'menu-button\'>Přepsaní na fyzickou osobu (člověk)</li>'
            )

            if tableLength(jobs) > 0 then
                table.insert(
                    main,
                    '<li onclick="openMenu(\'vehowner_job\')" class=\'menu-button\'>Přepsání na právnickou osobu (zaměstnání)</li>'
                )
            end
        elseif menu == "vehowner_player" then
            for i, veh in each(data) do
                local vehModel = GetLabelText(GetDisplayNameFromVehicleModel(veh.data.model))
                table.insert(
                    main,
                    (('<li onclick="selectAction(\'vehowner_player\', \'%s\')" class=\'menu-button\'>Přepsat vozidlo '):format(
                        veh.spz
                    ) ..
                        vehModel ..
                            " s SPZ: " ..
                                veh.spz .. " <span class='cash'>$" .. Config.Cost.VehicleOwner .. "</span></li>")
                )
            end
        elseif menu == "vehowner_job" then
            for i, veh in each(data) do
                local vehModel = GetLabelText(GetDisplayNameFromVehicleModel(veh.data.model))
                table.insert(
                    main,
                    ('<li onclick="openMenu(\'select_job\', \'%s\')" class=\'menu-button\'>Přepsat vozidlo ' ..
                        vehModel ..
                            " s SPZ: " ..
                                veh.spz .. " <span class='cash'>$" .. Config.Cost.VehicleOwner .. "</span></li>"):format(
                        veh.spz
                    )
                )
            end
        elseif menu == "select_job" then
            local police, medic = false, false
            for name, data in pairs(jobs) do
                if data.Type == "police" then
                    police = true
                elseif data.Type == "medic" then
                    medic = true
                end

                local label = exports.base_jobs:getJobVar(name, "label")
                table.insert(
                    main,
                    ('<li onclick="selectJob(\'%s\',\'%s\')" class=\'menu-button\'>' .. label .. "</li>"):format(
                        name,
                        rememberPlate
                    )
                )
            end
            if police then
                table.insert(
                    main,
                    ('<li onclick="selectJob(\'%s\',\'%s\')" class=\'menu-button\'>' ..
                        "Státní bezpečností složky (LSPD, LSSD a SAHP)" .. "</li>"):format("police", rememberPlate)
                )
            end
            if medic then
                table.insert(
                    main,
                    ('<li onclick="selectJob(\'%s\',\'%s\')" class=\'menu-button\'>' ..
                        "Státní záchranné složky (EMS, LSFD)" .. "</li>"):format("medic", rememberPlate)
                )
            end
        end
        table.insert(main, "</ul>")
    end
    return main, leftmenu
end

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
    end
)

function loadJobs(Jobs)
    jobs = {}
    for _, jobData in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[jobData.job] = {
            Name = jobData.job,
            Type = exports.base_jobs:getJobVar(jobData.job, "type"),
            Grade = jobData.job_grade,
            Duty = jobData.duty
        }
    end
end
function resetHints()
    exports.key_hints:hideHint({name = "documents"})
    showingDocumentsHint = false
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end
