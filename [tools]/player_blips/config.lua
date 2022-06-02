Config = {}

Config.ClientWait = 5000

Config.Emergency = {
    lspd = true,
    sahp = true,
    lssd = true,
    usms = true,
    ems = true,
    lsfd = true,
    government = true,
    ffa = false,
    plane = false,
    crime = true,
    airseal = true
}

Config.BlipColors = {
    lspd = 26,
    sahp = 47,
    lssd = 25,
    usms = 27,
    ems = 37,
    lsfd = 75,
    government = 70,
    plane = 20,
    ffa = 20,
    noJob = 4,
    instance = 61,
    crime = 76
}

Config.specificVehicleClass = {
    ["policeb2"] = 8,
    ["policeb"] = 8,
    ["lspdb"] = 8
}

Config.Markers = {
    ["car"] = 225,
    ["motorcycle"] = 226,
    ["cycle"] = 226,
    ["boat"] = 404,
    ["heli"] = 422,
    ["plane"] = 307,
    ["emergency"] = {
        lspd = 56,
        sahp = 56,
        lssd = 56,
        usms = 56,
        ems = 659,
        lsfd = 635,
        government = 56,
        noJob = 225,
        instance = 225
    },
    ["foot"] = {
        lspd = 60,
        sahp = 60,
        lssd = 60,
        usms = 60,
        ems = 61,
        lsfd = 648,
        government = 56,
        noJob = 1,
        instance = 1
    }
}

Config.Zones = {
    plane = {
        Blips = {"plane", "airseal"}
    },
    lspd = {
        Blips = {"lspd", "sahp", "lssd", "ems", "lsfd", "crime"}
    },
    sahp = {
        Blips = {"lspd", "sahp", "lssd", "ems", "lsfd", "crime"}
    },
    lssd = {
        Blips = {"lspd", "sahp", "lssd", "ems", "lsfd", "crime"}
    },
    ems = {
        Blips = {"lspd", "sahp", "lssd", "ems", "lsfd"}
    },
    usms = {
        Blips = {"usms"}
    },
    lsfd = {
        Blips = {"ems", "lsfd", "lspd", "sahp", "lssd"}
    },
    government = {
        Blips = {"government"}
    },
    airseal = {
        Blips = {"plane", "airseal"}
    }
}
