vehicleLabels = {
    -- POLICE
    ["sahp"] = "Vapid Stanier",
    ["sahp2"] = "Bravado Buffalo S",
    ["sahp5"] = "Sebalamo",
    ["sahp3"] = "Vapid Scout",
    ["fibp3"] = "Interceptor",
    ["policeb2"] = "Police BF400",
    ["bcat"] = "SWAT Bearcat",
    ["sahpair"] = "Maverick",
    ["sahp2astx"] = "Bravado Buffalo STX",
    ["sahpb2"] = "Police Motorcycle",
    ["pbike"] = "Police Bike",
    ["sahpb"] = "WinterGreen Motorcycle",
    ["vvpi"] = "Vapid Victor Police Interceptor",
    ["polcara"] = "Vapid Caracara",
    ["buzzard4"] = "SWAT Buzzard",
    -- CIVILIAN
    ["argento"] = "Obey Argento",
    ["ariant"] = "Karin Ariant",
    ["buffaloh"] = "Bravado Buffalo Hellhound",
    ["coquette8"] = "Coquette Classic",
    ["domc"] = "Dominator Classic",
    ["gresleyh"] = "Bravado Gresley Hellbound",
    ["kriegerc"] = "Benefactor Krieger Classic",
    ["mf1"] = "Progen MF1 Spyder",
    ["paragonxr"] = "Enus Paragon XR",
    ["patriotc"] = "Mammoth Patriot Classic",
    ["rapidgt4"] = "Dewbauchee Rapid GT Classic Cabrio",
    ["roxanne"] = "Annis Roxanne",
    ["s230"] = "Annis S230",
    ["sentinelsg4"] = "Sentinel SG4",
    ["streiter2"] = "Benefactor Streiter",
    ["sunrise1"] = "Maibatsu Sunrise",
    ["supergts"] = "Dewbauchee Super GTS",
    ["tempestas"] = "Tempesta Super",
    ["vigeronew"] = "Declasse Vigero S",
    ["vorstand"] = "Ubermacht Vorstand",
    ["taco2"] = "Taco Van",
    ["zrgpr"] = "Annis ZR350 Widebody Kit",
    ["paragono"] = "Enus Paragon Safari",
    ["kawaii"] = "Annis Kawaii",
    ["oracxsle"] = "Ubermacht Oracle XS-LE",
    ["elegyx"] = "Annis Elegy RH8-X",
    ["victor"] = "Vapid Victor",
    ["hachurac"] = "Vulcar Hachura R",
    ["mesar"] = "Canis Mesa R",
    ["tempesta2"] = "Pegassi Tempesta Custom",
    ["reagpr"] = "Pegassi Reaper Custom",
    ["niner"] = "Obey Nine R",
    ["rh82"] = "Annis Elegy RH8 FR-Works",
    ["elegyrh7"] = "Annis Elegy RH6",
    ["buffalo4h"] = "Bravado Buffalo STX Hellfire",
    ["cypherct"] = "Ubermacht Cypher Hatchback",
    ["wintergreen"] = "WMC Wintergreen",
    ["sultanrsv8"] = "Karin Sultan RS V8",
    ["bansheeas"] = "Bravado Banshee Alien Styling",
    ["enduromk2"] = "Dinka Enduro MK2",
    ["nalamo"] = "Declasse Alamo",
    ["gauntlet4c"] = "Bravado Gauntlet Hellfire Custom",
    ["nigthblade2"] = "WMC Nightblade Classic",
    ["ignusadd"] = "Pegassi Ignus",

    -- EMS/LSFD
    ["dw_emssuv"] = "Vapid Sandking",
    ["dw_ambulance"] = "Ambulance",
    ["emscout"] = "Vapid Scout",
    ["cgheli"] = "EMS Swift",
    -- GOV
    ["dw_pressuv"] = "Declasse Granger Government Special Edition",
    ["pressuved"] = "Declasse Granger Government Edition",
    -- USMS
    ["usmsrumpo"] = "Bravado Rumpo",
    ["usmsscout"] = "Vapid Scout",
    ["usmswashington"] = "Albany Washington",
    -- weazel
    ["nspeedo"] = "Speedo Van",
    ["scout"] = "Vapid Scout",
    ["weazelviktor"] = "Vapid Victor",
    ["g6stockade"] = "Brute Stockade",
    ["weazelscout"] = "Vapid Scout"

}

Citizen.CreateThread(function()
    Citizen.Wait(50)
    for key, value in pairs(vehicleLabels) do
        AddTextEntry(key, vehicleLabels[key])
    end
end)

function getVehicleNameByHash(name)
    if vehicleLabels[name] == nil then
        return nil
    end
    return vehicleLabels[name]
end
