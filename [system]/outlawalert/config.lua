Config = {}

Config.Respawn = {
    Hospital = vec4(317.78, -594.13, 43.29, 80.80),
    Jail = vec4(317.78, -594.13, 43.29, 80.80)
}

Config.Alerts = {
    carJack = {
        Timer = 10.0,
        ReportChance = 50,
        NpcDistance = 25.0,
        Code = "10-16",
        VehicleModelReportChance = 30,
        VehiclePlateReportChance = 10,
        VehicleColorReportChance = 95,
        Jobs = { "police" },
        WhitelistJobs = {},
        Blip = {
            Text = "Krádež vozidla",
            Time = 60000,
            Color = 44,
            Size = 1.0,
            Sprite = 380
        },
        Notify = {
            Type = "error",
            Text = "Hlášena krádež vozidla",
            Icon = "fas fa-car",
            Time = 10000
        }
    },
    shooting = {
        Timer = 90.0,
        ReportChance = 100,
        ReportChanceWithSuppresor = 5,
        NpcDistance = 100.0,
        Code = "10-13",
        WeaponModelReportChance = 1,
        Jobs = { "police" },
        WhitelistJobs = { "police" },
        IgnoreWeapons = {
            "weapon_fireextinguisher",
            "weapon_flare",
            "weapon_snowball",
            "weapon_ball",
            "weapon_molotov",
            "weapon_petrolcan",
            "weapon_fertilizercan",
            "weapon_hazardcan",
            "weapon_paintballgun",
            "weapon_firework",
            "weapon_flashbang",
            "weapon_smokegrenade",
        },
        Blip = {
            Text = "Střelba",
            Time = 60000,
            Color = 17,
            Size = 1.2,
            Sprite = 156
        },
        Notify = {
            Type = "error",
            Text = "Hlášena střelba",
            Icon = "fas fa-exclamation-triangle",
            Time = 10000
        }
    },
    combat = {
        Timer = 90.0,
        ReportChance = 10,
        NpcDistance = 20.0,
        Code = "10-10",
        Jobs = { "police" },
        WhitelistJobs = { "police" },
        Blip = {
            Text = "Potyčka",
            Time = 40000,
            Color = 17,
            Size = 1.0,
            Sprite = 311
        },
        Notify = {
            Type = "error",
            Text = "Hlášena potyčka",
            Icon = "fas fa-hand-rock",
            Time = 7000
        }
    },
    officerdown = {
        ReportChance = 100,
        Code = "10-100",
        Jobs = { "police", "medic" },
        ReportedJobs = { "police" },
        Blip = {
            Text = "OFFICER DOWN",
            Time = 60000,
            Color = 76,
            Size = 1.5,
            Sprite = 310
        },
        Notify = {
            Type = "extreme",
            Text = "Officer down",
            Icon = "fas fa-skull",
            Time = 15000
        },
        FlashBlip = true
    },
    mandown = {
        Timer = 90.0,
        ReportChance = 100,
        Code = "10-52",
        Jobs = { "police", "medic" },
        Blip = {
            Text = "Osoba v bezvědomí",
            Time = 60000,
            Color = 7,
            Size = 1.0
        },
        Notify = {
            Type = "error",
            Text = "Osoba v bezvědomí",
            Icon = "fas fa-ambulance",
            Time = 15000
        }
    },
    jewelry = {
        Code = "10-68",
        Jobs = { "police" },
        Blip = {
            Text = "Ozbrojená loupež klenotnictví",
            Time = 60000,
            Color = 63,
            Size = 1.0,
            Sprite = 617
        },
        Notify = {
            Type = "error",
            Text = "Ozbrojená loupež klenotnictví",
            Icon = "far fa-gem",
            Time = 15000
        }
    },
    pacific = {
        Code = "10-68",
        Jobs = { "police" },
        Blip = {
            Text = "Ozbrojená loupež hlavní banky",
            Time = 60000,
            Color = 63,
            Size = 1.5,
            Sprite = 207
        },
        Notify = {
            Type = "error",
            Text = "Ozbrojená loupež hlavní banky",
            Icon = "fas fa-university",
            Time = 15000
        }
    },
    bank = {
        Code = "10-68",
        Jobs = { "police" },
        Blip = {
            Text = "Ozbrojená loupež banky",
            Time = 60000,
            Color = 63,
            Size = 1.5,
            Sprite = 207
        },
        Notify = {
            Type = "error",
            Text = "Ozbrojená loupež banky",
            Icon = "fas fa-university",
            Time = 15000
        }
    },
    powerplant = {
        Code = "10-68",
        Jobs = { "police" },
        Blip = {
            Text = "Přepadení elektrárny",
            Time = 60000,
            Color = 63,
            Size = 1.0,
            Sprite = 620
        },
        Notify = {
            Type = "error",
            Text = "Přepadení elektrárny",
            Icon = "fas fa-bolt",
            Time = 15000
        }
    },
    shop = {
        Code = "10-68",
        Jobs = { "police" },
        Blip = {
            Text = "Ozbrojená loupež",
            Time = 60000,
            Color = 23,
            Size = 1.0,
            Sprite = 628
        },
        Notify = {
            Type = "error",
            Text = "Ozbrojená loupež",
            Icon = "fas fa-shopping-basket",
            Time = 15000
        }
    },
    house = {
        Code = "10-68",
        Jobs = { "police" },
        Blip = {
            Text = "Vloupání do domu",
            Time = 35000,
            Color = 23,
            Size = 1.0,
            Sprite = 374
        },
        Notify = {
            Type = "error",
            Text = "Vloupání do domu",
            Icon = "fas fa-home",
            Time = 10000
        }
    },
    illegalsell = {
        Code = "10-14",
        Jobs = { "police" },
        Blip = {
            Text = "Ilegální prodej",
            Time = 35000,
            Color = 23,
            Size = 1.0,
            Sprite = 140
        },
        Notify = {
            Type = "error",
            Text = "Ilegální prodej",
            Icon = "fas fa-book-dead",
            Time = 10000
        }
    },
    weed = {
        Code = "10-14",
        Jobs = { "police" },
        Blip = {
            Text = "Potencionální pěstování marihuany",
            Time = 35000,
            Color = 23,
            Size = 1.0,
            Sprite = 140
        },
        Notify = {
            Type = "error",
            Text = "Potencionální pěstování marihuany",
            Icon = "fas fa-cannabis",
            Time = 10000
        }
    },
    panic = {
        Code = "10-99",
        Jobs = { "police" },
        Blip = {
            Text = "Panic Button",
            Time = 35000,
            Color = 76,
            Size = 1.0,
            Sprite = 792
        },
        Notify = {
            Type = "extreme",
            Text = "Panic Button",
            Icon = "fas fa-flag",
            Time = 12000
        },
        FlashBlip = true
    }
}

Config.Colors = {
    { Index = 0, Label = "Black" },
    { Index = 1, Label = "Graphite" },
    { Index = 2, Label = "Black Metallic" },
    { Index = 3, Label = "Cast steel" },
    { Index = 11, Label = "Black Anth" },
    { Index = 12, Label = "Matte Black" },
    { Index = 15, Label = "Dark Night" },
    { Index = 16, Label = "Deep Black" },
    { Index = 21, Label = "Oil" },
    { Index = 147, Label = "Carbon" },
    { Index = 106, Label = "Vanilla" },
    { Index = 107, Label = "Creme" },
    { Index = 111, Label = "White" },
    { Index = 112, Label = "Polar White" },
    { Index = 113, Label = "Beige" },
    { Index = 121, Label = "Matte White" },
    { Index = 122, Label = "Snow" },
    { Index = 131, Label = "Cotton" },
    { Index = 132, Label = "Alabaster" },
    { Index = 134, Label = "Pure White" },
    { Index = 4, Label = "Silver" },
    { Index = 5, Label = "Metallic Grey" },
    { Index = 6, Label = "Laminated Steel" },
    { Index = 7, Label = "Dark Gray" },
    { Index = 8, Label = "Rocky Gray" },
    { Index = 9, Label = "Gray Night" },
    { Index = 10, Label = "Aluminum" },
    { Index = 13, Label = "Graym Mat" },
    { Index = 14, Label = "Light Grey" },
    { Index = 17, Label = "Asphalt Grey" },
    { Index = 18, Label = "Gray Concrete" },
    { Index = 19, Label = "Dark Silver" },
    { Index = 20, Label = "Magnesite" },
    { Index = 22, Label = "Nickel" },
    { Index = 23, Label = "Zinc" },
    { Index = 24, Label = "Dolomite" },
    { Index = 25, Label = "Blue Silver" },
    { Index = 26, Label = "Titanium" },
    { Index = 66, Label = "Steel Blue" },
    { Index = 93, Label = "Champagne" },
    { Index = 144, Label = "Gray Hunter" },
    { Index = 156, Label = "Grey" },
    { Index = 27, Label = "Red" },
    { Index = 28, Label = "Torino Red" },
    { Index = 29, Label = "Poppy" },
    { Index = 30, Label = "Copper Red" },
    { Index = 31, Label = "Cardial" },
    { Index = 32, Label = "Brick" },
    { Index = 33, Label = "Garnet" },
    { Index = 34, Label = "Cabernet" },
    { Index = 35, Label = "Candy" },
    { Index = 39, Label = "Matte Red" },
    { Index = 40, Label = "Dark Red" },
    { Index = 43, Label = "Red Pulp" },
    { Index = 44, Label = "Bril Red" },
    { Index = 46, Label = "Pale Red" },
    { Index = 143, Label = "Wine Red" },
    { Index = 150, Label = "Volcano" },
    { Index = 135, Label = "Electric Pink" },
    { Index = 136, Label = "Salmon" },
    { Index = 137, Label = "Sugar Plum" },
    { Index = 54, Label = "Topaz" },
    { Index = 60, Label = "Light Blue" },
    { Index = 61, Label = "Galaxy Blue" },
    { Index = 62, Label = "Dark Blue" },
    { Index = 63, Label = "Azure" },
    { Index = 64, Label = "Navy Blue" },
    { Index = 65, Label = "Lapis" },
    { Index = 67, Label = "Blue Diamond" },
    { Index = 68, Label = "Surfer" },
    { Index = 69, Label = "Pastel Blue" },
    { Index = 70, Label = "Celeste Blue" },
    { Index = 73, Label = "Rally Blue" },
    { Index = 74, Label = "Blue Paradise" },
    { Index = 75, Label = "Blue Night" },
    { Index = 77, Label = "Cyan Blue" },
    { Index = 78, Label = "Cobalt" },
    { Index = 79, Label = "Electric Blue" },
    { Index = 80, Label = "Horizon Blue" },
    { Index = 82, Label = "Metallic Blue" },
    { Index = 83, Label = "Aquamarine" },
    { Index = 84, Label = "Blue Agathe" },
    { Index = 85, Label = "Zirconium" },
    { Index = 86, Label = "Spinel" },
    { Index = 87, Label = "Tourmaline" },
    { Index = 127, Label = "Paradise" },
    { Index = 140, Label = "Bubble Gum" },
    { Index = 141, Label = "Midnight Blue" },
    { Index = 146, Label = "Forbidden Blue" },
    { Index = 157, Label = "Glacier Blue" },
    { Index = 42, Label = "Yellow" },
    { Index = 88, Label = "Wheat" },
    { Index = 89, Label = "Race yellow" },
    { Index = 91, Label = "Pale yellow" },
    { Index = 126, Label = "Light yellow" },
    { Index = 49, Label = "Met Dark Green" },
    { Index = 50, Label = "Rally Green" },
    { Index = 51, Label = "Oine Green" },
    { Index = 52, Label = "Olive Green" },
    { Index = 53, Label = "Light Green" },
    { Index = 55, Label = "Lime Green" },
    { Index = 56, Label = "Forest Green" },
    { Index = 57, Label = "Lawn Green" },
    { Index = 58, Label = "Imperial Green" },
    { Index = 59, Label = "Green Bottle" },
    { Index = 92, Label = "Citrus Green" },
    { Index = 125, Label = "Green Anis" },
    { Index = 128, Label = "Khaki" },
    { Index = 133, Label = "Army Green" },
    { Index = 151, Label = "Dark Green" },
    { Index = 152, Label = "Hunter Green" },
    { Index = 155, Label = "Matte Foilage Green" },
    { Index = 36, Label = "Tangerine" },
    { Index = 38, Label = "Orange" },
    { Index = 41, Label = "Matte Orange" },
    { Index = 123, Label = "Light Orange" },
    { Index = 124, Label = "Peach" },
    { Index = 130, Label = "Pumpkin" },
    { Index = 138, Label = "Orange Lambo" },
    { Index = 45, Label = "Copper" },
    { Index = 47, Label = "Light Brown" },
    { Index = 48, Label = "Barkb Brown" },
    { Index = 90, Label = "Bronze" },
    { Index = 94, Label = "Brown Metallic" },
    { Index = 95, Label = "Expresso" },
    { Index = 96, Label = "Chocolate" },
    { Index = 97, Label = "Terracotta" },
    { Index = 98, Label = "Marble" },
    { Index = 99, Label = "Sand" },
    { Index = 100, Label = "Sepia" },
    { Index = 101, Label = "Bison" },
    { Index = 102, Label = "Palm" },
    { Index = 103, Label = "Caramel" },
    { Index = 104, Label = "Rust" },
    { Index = 105, Label = "Chestnut" },
    { Index = 108, Label = "Brown" },
    { Index = 109, Label = "Hazelnut" },
    { Index = 110, Label = "Shell" },
    { Index = 114, Label = "Mahogany" },
    { Index = 115, Label = "Cauldron" },
    { Index = 116, Label = "Blond" },
    { Index = 129, Label = "Gravel" },
    { Index = 153, Label = "Darkearth" },
    { Index = 154, Label = "Desert" },
    { Index = 71, Label = "Indigo" },
    { Index = 72, Label = "Deeppurple" },
    { Index = 76, Label = "Darkviolet" },
    { Index = 81, Label = "Amethyst" },
    { Index = 142, Label = "Mystical Violet" },
    { Index = 145, Label = "Purple Metallic" },
    { Index = 148, Label = "Matte Violet" },
    { Index = 149, Label = "Matte Deep Purple" },
    { Index = 117, Label = "Brushed Chrome" },
    { Index = 118, Label = "Black Chrome" },
    { Index = 119, Label = "Brushed Aluminum" },
    { Index = 120, Label = "Chrome" },
    { Index = 37, Label = "Gold" },
    { Index = 158, Label = "Pure Gold" },
    { Index = 159, Label = "Brushed Gold" },
    { Index = 160, Label = "Light Gold" }
}
