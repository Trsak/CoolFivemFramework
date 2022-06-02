Config = {}

Config.Places = {
    ["pdm"] = {
        type = "car",
        coords = vector3(-34.1, -1106.22, 26.48),
        npc = {
            model = "ig_siemonyetarian",
            heading = 71.0
        },
        vehicleDelivery = {
            spawnSettings = {
                width = 2.3,
                length = 4.0,
                height = 2.0
            },
            spawnPos = {
                vec4(-43.48, -1082.39, 25.75, 339.5),
                vec4(-46.58, -1081.3, 25.79, 338.0),
                vec4(-50.14, -1080.54, 25.91, 338.0)
            }
        }
    }
}

Config.Types = {
    ["car"] = {
        type = 225,
        scale = 0.7,
        color = 0,
        display = 2,
        label = "Prodejce vozidel"
    },
    ["boat"] = {
        type = 225,
        scale = 0.7,
        color = 0,
        display = 2,
        label = "Prodejce lodí"
    },
    ["plane"] = {
        type = 225,
        scale = 0.7,
        color = 0,
        display = 2,
        label = "Prodejce letadel"
    }
}

Config.VehClasses = {
    "Kompaktní",
    "Sedan",
    "SUV",
    "Kupé",
    "Muscle",
    "Klasické sportovní",
    "Sportovní",
    "Super",
    "Motorky",
    "Off-road",
    "Dodávky",
    "Kola",
    "Průmyslové",
    "Lodě",
    "Letadla",
    "Helikoptéry"
}

Config.VehTypes = {
    ["AWD"] = "na všechna kola",
    ["FWD"] = "na přední kola",
    ["RWD"] = "na zadní kola",
    ["4WD"] = "pohon 4x4"
}
