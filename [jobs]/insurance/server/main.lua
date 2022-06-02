local TE, TCE,TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent,TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
local Insurance, InsurancePerson, InsuranceVehicle = {}, {}, {}
local pref = Config



MySQL.ready(function()
    Insurance = MySQL.Sync.fetchAll('SELECT * FROM insurance')

    InsurancePerson = MySQL.Sync.fetchAll('SELECT * FROM insurance_person')

    InsuranceVehicle = MySQL.Sync.fetchAll('SELECT * FROM insurance_vehicle')

    print(Utils.DumpTable(Insurance))
end)

