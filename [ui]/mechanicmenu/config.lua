Config = {}

Config.Colors = {
    { label = "Černé", value = "black" },
    { label = "Bílé", value = "white" },
    { label = "Šedé", value = "grey" },
    { label = "Červené", value = "red" },
    { label = "Růžové", value = "pink" },
    { label = "Modré", value = "blue" },
    { label = "Žluté", value = "yellow" },
    { label = "Zelené", value = "green" },
    { label = "Oranžové", value = "orange" },
    { label = "Hnědé", value = "brown" },
    { label = "Fialové", value = "purple" },
    { label = "Chromové", value = "chrome" },
    { label = "Zlaté", value = "gold" }
}

function GetColors(color)
    local colors = {}
    if color == "black" then
        colors = {
            { index = 0, label = "black" },
            { index = 1, label = "graphite" },
            { index = 2, label = "black_metallic" },
            { index = 3, label = "caststeel" },
            { index = 11, label = "black_anth" },
            { index = 12, label = "matteblack" },
            { index = 15, label = "darknight" },
            { index = 16, label = "deepblack" },
            { index = 21, label = "oil" },
            { index = 147, label = "carbon" }
        }
    elseif color == "white" then
        colors = {
            { index = 106, label = "vanilla" },
            { index = 107, label = "creme" },
            { index = 111, label = "white" },
            { index = 112, label = "polarwhite" },
            { index = 113, label = "beige" },
            { index = 121, label = "mattewhite" },
            { index = 122, label = "snow" },
            { index = 131, label = "cotton" },
            { index = 132, label = "alabaster" },
            { index = 134, label = "purewhite" }
        }
    elseif color == "grey" then
        colors = {
            { index = 4, label = "silver" },
            { index = 5, label = "metallicgrey" },
            { index = 6, label = "laminatedsteel" },
            { index = 7, label = "darkgray" },
            { index = 8, label = "rockygray" },
            { index = 9, label = "graynight" },
            { index = 10, label = "aluminum" },
            { index = 13, label = "graymat" },
            { index = 14, label = "lightgrey" },
            { index = 17, label = "asphaltgray" },
            { index = 18, label = "grayconcrete" },
            { index = 19, label = "darksilver" },
            { index = 20, label = "magnesite" },
            { index = 22, label = "nickel" },
            { index = 23, label = "zinc" },
            { index = 24, label = "dolomite" },
            { index = 25, label = "bluesilver" },
            { index = 26, label = "titanium" },
            { index = 66, label = "steelblue" },
            { index = 93, label = "champagne" },
            { index = 144, label = "grayhunter" },
            { index = 156, label = "grey" }
        }
    elseif color == "red" then
        colors = {
            { index = 27, label = "red" },
            { index = 28, label = "torino_red" },
            { index = 29, label = "poppy" },
            { index = 30, label = "copper_red" },
            { index = 31, label = "cardinal" },
            { index = 32, label = "brick" },
            { index = 33, label = "garnet" },
            { index = 34, label = "cabernet" },
            { index = 35, label = "candy" },
            { index = 39, label = "matte_red" },
            { index = 40, label = "dark_red" },
            { index = 43, label = "red_pulp" },
            { index = 44, label = "bril_red" },
            { index = 46, label = "pale_red" },
            { index = 143, label = "wine_red" },
            { index = 150, label = "volcano" }
        }
    elseif color == "pink" then
        colors = {
            { index = 135, label = "electricpink" },
            { index = 136, label = "salmon" },
            { index = 137, label = "sugarplum" }
        }
    elseif color == "blue" then
        colors = {
            { index = 54, label = "topaz" },
            { index = 60, label = "light_blue" },
            { index = 61, label = "galaxy_blue" },
            { index = 62, label = "dark_blue" },
            { index = 63, label = "azure" },
            { index = 64, label = "navy_blue" },
            { index = 65, label = "lapis" },
            { index = 67, label = "blue_diamond" },
            { index = 68, label = "surfer" },
            { index = 69, label = "pastel_blue" },
            { index = 70, label = "celeste_blue" },
            { index = 73, label = "rally_blue" },
            { index = 74, label = "blue_paradise" },
            { index = 75, label = "blue_night" },
            { index = 77, label = "cyan_blue" },
            { index = 78, label = "cobalt" },
            { index = 79, label = "electric_blue" },
            { index = 80, label = "horizon_blue" },
            { index = 82, label = "metallic_blue" },
            { index = 83, label = "aquamarine" },
            { index = 84, label = "blue_agathe" },
            { index = 85, label = "zirconium" },
            { index = 86, label = "spinel" },
            { index = 87, label = "tourmaline" },
            { index = 127, label = "paradise" },
            { index = 140, label = "bubble_gum" },
            { index = 141, label = "midnight_blue" },
            { index = 146, label = "forbidden_blue" },
            { index = 157, label = "glacier_blue" }
        }
    elseif color == "yellow" then
        colors = {
            { index = 42, label = "yellow" },
            { index = 88, label = "wheat" },
            { index = 89, label = "raceyellow" },
            { index = 91, label = "paleyellow" },
            { index = 126, label = "lightyellow" }
        }
    elseif color == "green" then
        colors = {
            { index = 49, label = "met_dark_green" },
            { index = 50, label = "rally_green" },
            { index = 51, label = "pine_green" },
            { index = 52, label = "olive_green" },
            { index = 53, label = "light_green" },
            { index = 55, label = "lime_green" },
            { index = 56, label = "forest_green" },
            { index = 57, label = "lawn_green" },
            { index = 58, label = "imperial_green" },
            { index = 59, label = "green_bottle" },
            { index = 92, label = "citrus_green" },
            { index = 125, label = "green_anis" },
            { index = 128, label = "khaki" },
            { index = 133, label = "army_green" },
            { index = 151, label = "dark_green" },
            { index = 152, label = "hunter_green" },
            { index = 155, label = "matte_foilage_green" }
        }
    elseif color == "orange" then
        colors = {
            { index = 36, label = "tangerine" },
            { index = 38, label = "orange" },
            { index = 41, label = "matteorange" },
            { index = 123, label = "lightorange" },
            { index = 124, label = "peach" },
            { index = 130, label = "pumpkin" },
            { index = 138, label = "orangelambo" }
        }
    elseif color == "brown" then
        colors = {
            { index = 45, label = "copper" },
            { index = 47, label = "lightbrown" },
            { index = 48, label = "darkbrown" },
            { index = 90, label = "bronze" },
            { index = 94, label = "brownmetallic" },
            { index = 95, label = "Expresso" },
            { index = 96, label = "chocolate" },
            { index = 97, label = "terracotta" },
            { index = 98, label = "marble" },
            { index = 99, label = "sand" },
            { index = 100, label = "sepia" },
            { index = 101, label = "bison" },
            { index = 102, label = "palm" },
            { index = 103, label = "caramel" },
            { index = 104, label = "rust" },
            { index = 105, label = "chestnut" },
            { index = 108, label = "brown" },
            { index = 109, label = "hazelnut" },
            { index = 110, label = "shell" },
            { index = 114, label = "mahogany" },
            { index = 115, label = "cauldron" },
            { index = 116, label = "blond" },
            { index = 129, label = "gravel" },
            { index = 153, label = "darkearth" },
            { index = 154, label = "desert" }
        }
    elseif color == "purple" then
        colors = {
            { index = 71, label = "indigo" },
            { index = 72, label = "deeppurple" },
            { index = 76, label = "darkviolet" },
            { index = 81, label = "amethyst" },
            { index = 142, label = "mysticalviolet" },
            { index = 145, label = "purplemetallic" },
            { index = 148, label = "matteviolet" },
            { index = 149, label = "mattedeeppurple" }
        }
    elseif color == "chrome" then
        colors = {
            { index = 117, label = "brushedchrome" },
            { index = 118, label = "blackchrome" },
            { index = 119, label = "brushedaluminum" },
            { index = 120, label = "chrome" }
        }
    elseif color == "gold" then
        colors = {
            { index = 37, label = "gold" },
            { index = 158, label = "puregold" },
            { index = 159, label = "brushedgold" },
            { index = 160, label = "lightgold" }
        }
    end
    return colors
end

function GetWindowName(index)
    if index == 0 then
        return "Čisté"
    elseif index == 1 then
        return "Čistě tmavé"
    elseif index == 2 then
        return "Tmavé"
    elseif index == 3 then
        return "Lehce tmavé"
    elseif index == 4 then
        return "Úplně čisté"
    elseif index == 5 then
        return "Zelené"
    else
        return "Unknown"
    end
end

function GetHornName(index)
    if index == 0 then
        return "Truck"
    elseif index == 1 then
        return "Emergency"
    elseif index == 2 then
        return "Claun"
    elseif index == 3 then
        return "Musical 1"
    elseif index == 4 then
        return "Musical 2"
    elseif index == 5 then
        return "Musical 3"
    elseif index == 6 then
        return "Musical 4"
    elseif index == 7 then
        return "Musical 5"
    elseif index == 8 then
        return "Sad trombone"
    elseif index == 9 then
        return "Classic 1"
    elseif index == 10 then
        return "Classic 2"
    elseif index == 11 then
        return "Classic 3"
    elseif index == 12 then
        return "Classic 4"
    elseif index == 13 then
        return "Classic 5"
    elseif index == 14 then
        return "Classic 6"
    elseif index == 15 then
        return "Classic 7"
    elseif index == 16 then
        return "Scale - Do"
    elseif index == 17 then
        return "Scale - Re"
    elseif index == 18 then
        return "Scale - Mi"
    elseif index == 19 then
        return "Scale - Fa"
    elseif index == 20 then
        return "Scale - Sol"
    elseif index == 21 then
        return "Scale - La"
    elseif index == 22 then
        return "Scale - Ti"
    elseif index == 23 then
        return "Scale - Do"
    elseif index == 24 then
        return "Jazz 1"
    elseif index == 25 then
        return "Jazz 2"
    elseif index == 26 then
        return "Jazz 3"
    elseif index == 27 then
        return "Jazz Loop"
    elseif index == 28 then
        return "Star-studded banner 1"
    elseif index == 29 then
        return "Star-studded banner 2"
    elseif index == 30 then
        return "Star-studded banner 3"
    elseif index == 31 then
        return "Star-studded banner 4"
    elseif index == 32 then
        return "Classic 8 loop"
    elseif index == 33 then
        return "Classic 9 loop"
    elseif index == 34 then
        return "Classic 10 loop"
    elseif index == 35 then
        return "Classic 8"
    elseif index == 36 then
        return "Classic 9"
    elseif index == 37 then
        return "Classic 10"
    elseif index == 38 then
        return "Funeral loop"
    elseif index == 39 then
        return "Funeral"
    elseif index == 40 then
        return "Scary loop"
    elseif index == 41 then
        return "Scary"
    elseif index == 42 then
        return "San Andreas loop"
    elseif index == 43 then
        return "San Andreas"
    elseif index == 44 then
        return "Liberty City loop"
    elseif index == 45 then
        return "Liberty City"
    elseif index == 46 then
        return "Celebrate 1 loop"
    elseif index == 47 then
        return "Celebrate 1"
    elseif index == 48 then
        return "Celebrate 2 loop"
    elseif index == 49 then
        return "Celebrate 2"
    elseif index == 50 then
        return "Celebrate 3 loop"
    elseif index == 51 then
        return "Celebrate 3"
    else
        return "Unknown"
    end
end

function GetNeons()
    local neons = {
        { label = "white", r = 255, g = 255, b = 255 },
        { label = "Slate gray", r = 112, g = 128, b = 144 },
        { label = "Blue", r = 0, g = 0, b = 255 },
        { label = "Light blue ", r = 0, g = 150, b = 255 },
        { label = "Navy blue", r = 0, g = 0, b = 128 },
        { label = "Sky blue", r = 135, g = 206, b = 235 },
        { label = "Turquoise", r = 0, g = 245, b = 255 },
        { label = "Ment green", r = 50, g = 255, b = 155 },
        { label = "Lime green", r = 0, g = 255, b = 0 },
        { label = "Olive", r = 128, g = 128, b = 0 },
        { label = "Yellow", r = 255, g = 255, b = 0 },
        { label = "Gold", r = 255, g = 215, b = 0 },
        { label = "Orange", r = 255, g = 165, b = 0 },
        { label = "Wheat", r = 245, g = 222, b = 179 },
        { label = "Red", r = 255, g = 0, b = 0 },
        { label = "Pink", r = 255, g = 161, b = 211 },
        { label = "Brightpink", r = 255, g = 1, b = 255 },
        { label = "Purple", r = 153, g = 0, b = 153 },
        { label = "Ivory", r = 41, g = 36, b = 33 }
    }

    return neons
end

function GetPlatesName(index)
    if index == 0 then
        return "Modrá na bílé #1"
    elseif index == 1 then
        return "Žlutá na černé"
    elseif index == 2 then
        return "Žlutá na modré"
    elseif index == 3 then
        return "Modrá na bílé #2"
    elseif index == 4 then
        return "Modrá na bílé #3"
    elseif index == 5 then
        return "Yankton"
    end
end

Config.Menus = {
    main = {
        label = "Mechanik",
        upgrades = "Vylepšení",
        cosmetics = "Kosmetické úpravy"
    },
    upgrades = {
        label = "Vylepšení",
        parent = "main",
        modEngine = "Vylepšení motoru",
        modBrakes = "Vylepšení brzd",
        modTransmission = "Vylepšení převodovky",
        modSuspension = "Snížení vozidla",
        modTurbo = "Turbo"
    },
    modEngine = {
        label = "Motor",
        parent = "upgrades",
        modType = 11,
        prices = {
            type = "percentage",
            cost = {
                15,
                20,
                25,
                30,
                35,
                40
            }
        }
    },
    modBrakes = {
        label = "Brzdy",
        parent = "upgrades",
        modType = 12,
        prices = {
            type = "percentage",
            cost = {
                15,
                20,
                25,
                30,
                35,
                40
            }
        }
    },
    modTransmission = {
        label = "Převodovka",
        parent = "upgrades",
        modType = 13,
        prices = {
            type = "percentage",
            cost = {
                15,
                20,
                25,
                30,
                35,
                40
            }
        }
    },
    modSuspension = {
        label = "Snížení",
        parent = "upgrades",
        modType = 15,
        prices = {
            type = "percentage",
            cost = {
                15,
                20,
                25,
                30,
                35,
                40
            }
        }
    },
    modTurbo = {
        label = "Turbo",
        parent = "upgrades",
        modType = 17,
        prices = {
            type = "percentage",
            cost = 30
        }
    },
    cosmetics = {
        label = "Kosmetické úpravy",
        parent = "main",
        bodyparts = "Karosérie",
        accesories = "Příslušenství",
        windowTint = "Fólie na okna",
        modHorns = "Klakson",
        neonColor = "Neony",
        resprays = "Přebarvení",
        modXenon = "Xenony",
        plateIndex = "SPZ",
        wheels = "Kola",
        modBackWheels = "Kola (zadní) a hydraulika",
        lightsColor = "Barva světel",
        extras = "Doplňky",
        modLivery = "Polepy #1",
        modLiveries = "Polepy #2"
    },
    lightsColor = {
        label = "Barva světel",
        parent = "cosmetics",
        modType = "lightsColor",
        prices = {
            type = "cost",
            cost = 100
        }
    },
    extras = {
        label = "Doplňky",
        parent = "cosmetics",
        modType = "extras",
        prices = {
            type = "cost",
            cost = { 250, 300, 300, 300, 300 }
        }
    },
    modLivery = {
        label = "Polepy #1",
        parent = "cosmetics",
        modType = 48,
        prices = {
            type = "cost",
            cost = {
                2000,
                6000,
                10000,
                14000,
                20000
            }
        }
    },
    modLiveries = {
        label = "Polepy #2",
        parent = "cosmetics",
        modType = "modLiveries",
        prices = {
            type = "cost",
            cost = {
                200,
                6000,
                10000,
                14000,
                20000
            }
        }
    },
    modBackWheels = {
        label = "Zadní kola",
        parent = "cosmetics",
        modType = 24,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsTypes = {
        label = "Typ kol",
        parent = "wheelsRear",
        modRearWheelsType0 = "Sport",
        modRearWheelsType1 = "Muscle",
        modRearWheelsType2 = "Low Rider",
        modRearWheelsType3 = "SUV",
        modRearWheelsType4 = "Off-Road",
        modRearWheelsType5 = "Tuner",
        modRearWheelsType6 = "Motorcycles",
        modRearWheelsType7 = "High End",
        modRearWheelsType8 = "Benny's Wheels",
        modRearWheelsType9 = "Bespoke Wheels",
        modRearWheelsType11 = "Street",
        modRearWheelsType12 = "Track"
    },
    modRearWheelsType0 = {
        label = "Sport",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 0,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType1 = {
        label = "Muscle",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 1,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType2 = {
        label = "Low Rider",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 2,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType3 = {
        label = "SUV",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 3,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType4 = {
        label = "Off-Road",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 4,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType5 = {
        label = "Tuner",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 5,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType6 = {
        label = "Motorcycles",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 6,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType7 = {
        label = "High End",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 7,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType8 = {
        label = "Benny's Wheels",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 8,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType9 = {
        label = "Bespoke Wheels",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 9,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType11 = {
        label = "Street",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 11,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsType12 = {
        label = "Track",
        parent = "modRearWheelsTypes",
        modType = 24,
        wheelType = 12,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modRearWheelsColor = {
        label = "Barva kol",
        parent = "wheelsRear"
    },
    wheels = {
        label = "Kola",
        parent = "cosmetics",
        modFrontWheelsTypes = "Typ kol",
        modFrontWheelsColor = "Barva kol",
        tyreSmokeColor = "Kouř kol"
    },
    modFrontWheelsTypes = {
        label = "Typ kol",
        parent = "wheels",
        modFrontWheelsType0 = "Sport",
        modFrontWheelsType1 = "Muscle",
        modFrontWheelsType2 = "Low Rider",
        modFrontWheelsType3 = "SUV",
        modFrontWheelsType4 = "Off-Road",
        modFrontWheelsType5 = "Tuner",
        modFrontWheelsType6 = "Motorcycles",
        modFrontWheelsType7 = "High End",
        modFrontWheelsType8 = "Benny's Wheels",
        modFrontWheelsType9 = "Bespoke Wheels",
        modFrontWheelsType10 = "Drag",
        modFrontWheelsType11 = "Street",
        modFrontWheelsType12 = "Track"
    },
    modFrontWheelsType0 = {
        label = "Sport",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 0,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType1 = {
        label = "Muscle",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 1,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType2 = {
        label = "Low Rider",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 2,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType3 = {
        label = "SUV",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 3,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType4 = {
        label = "Off-Road",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 4,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType5 = {
        label = "Tuner",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 5,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType6 = {
        label = "Motorcycles",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 6,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType7 = {
        label = "High End",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 7,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType8 = {
        label = "Benny's Wheels",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 8,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType9 = {
        label = "Bespoke Wheels",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 9,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType10 = {
        label = "Drag",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 10,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType11 = {
        label = "Street",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 11,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsType12 = {
        label = "Track",
        parent = "modFrontWheelsTypes",
        modType = 23,
        wheelType = 12,
        prices = {
            type = "cost",
            cost = {
                750,
                2200,
                4000,
                6000,
                8000
            }
        }
    },
    modFrontWheelsColor = {
        label = "Barva kol",
        parent = "wheels"
    },
    wheelColor = {
        label = "Wheel Color",
        parent = "modFrontWheelsColor",
        modType = "wheelColor",
        prices = {
            type = "cost",
            cost = { 300, 1000, 1000, 1000, 1000 }
        }
    },
    plateIndex = {
        label = "Barvy SPZ",
        parent = "cosmetics",
        modType = "plateIndex",
        prices = {
            type = "cost",
            cost = 500
        }
    },
    resprays = {
        label = "Přebarvení",
        parent = "cosmetics",
        primaryRespray = "Primární",
        secondaryRespray = "Sekundární",
        pearlescentRespray = "Perleť",
        dashboardRespray = "Palubní deska",
        interiorRespray = "Interiér"
    },
    primaryRespray = {
        label = "primary",
        parent = "resprays"
    },
    secondaryRespray = {
        label = "secondary",
        parent = "resprays"
    },
    pearlescentRespray = {
        label = "pearlescent",
        parent = "resprays"
    },
    color1 = {
        label = "primary",
        parent = "primaryRespray",
        modType = "color1",
        prices = {
            type = "cost",
            cost = {
                500,
                1500,
                1500,
                2500,
                4000
            }
        }
    },
    color2 = {
        label = "secondary",
        parent = "secondaryRespray",
        modType = "color2",
        prices = {
            type = "cost",
            cost = {
                500,
                1000,
                1000,
                2000,
                2000
            }
        }
    },
    pearlescentColor = {
        label = "pearlescent",
        parent = "pearlescentRespray",
        modType = "pearlescentColor",
        prices = {
            type = "cost",
            cost = {
                600,
                2000,
                2000,
                3000,
                4000
            }
        }
    },
    dashboardRespray = {
        label = "dashboard",
        parent = "resprays"
    },
    interiorRespray = {
        label = "Interiér",
        parent = "resprays"
    },
    dashboardColor = {
        label = "Palubní deska",
        parent = "dashboardRespray",
        modType = "dashboardColor",
        prices = {
            type = "cost",
            cost = { 300, 1000, 1000, 1000, 1000 }
        }
    },
    interiorColor = {
        label = "Interiér",
        parent = "interiorRespray",
        modType = "interiorColor",
        prices = {
            type = "cost",
            cost = { 300, 1000, 1000, 1000, 1000 }
        }
    },
    modXenon = {
        label = "Světla",
        parent = "cosmetics",
        modType = 22,
        prices = {
            type = "cost",
            cost = { 300, 1000, 1000, 1000, 1000 }
        }
    },
    bodyparts = {
        label = "Karosérie",
        parent = "cosmetics",
        modFender = "Levé blatínky",
        modRightFender = "Pravé blatníky",
        modSpoilers = "Spoilery",
        modSideSkirt = "Boční lišty",
        modFrame = "Klece",
        modHood = "Kapoty",
        modGrille = "Mřížky chladiče",
        modRearBumper = "Zadní nárazníky",
        modFrontBumper = "Přední nárazníky",
        modExhaust = "Výfuky",
        modRoof = "Střechy"
    },
    modSpoilers = {
        label = "Spoilery",
        parent = "bodyparts",
        modType = 0,
        prices = {
            type = "cost",
            cost = {
                650,
                2000,
                3500,
                5000,
                8000
            }
        }
    },
    modFrontBumper = {
        label = "Přední nárazník",
        parent = "bodyparts",
        modType = 1,
        prices = {
            type = "cost",
            cost = {
                500,
                1500,
                2500,
                4000,
                7000
            }
        }
    },
    modRearBumper = {
        label = "Zadní nárazník",
        parent = "bodyparts",
        modType = 2,
        prices = {
            type = "cost",
            cost = {
                500,
                1500,
                2500,
                4000,
                7000
            }
        }
    },
    modSideSkirt = {
        label = "Boční lisšty",
        parent = "bodyparts",
        modType = 3,
        prices = {
            type = "cost",
            cost = {
                300,
                1000,
                2000,
                3000,
                4000
            }
        }
    },
    modExhaust = {
        label = "Výfuky",
        parent = "bodyparts",
        modType = 4,
        prices = {
            type = "cost",
            cost = {
                400,
                1200,
                2400,
                3400,
                4400
            }
        }
    },
    modFrame = {
        label = "Klece",
        parent = "bodyparts",
        modType = 5,
        prices = {
            type = "cost",
            cost = { 600, 1800, 1800, 1800, 1800 }
        }
    },
    modGrille = {
        label = "Mřížky chladiče",
        parent = "bodyparts",
        modType = 6,
        prices = {
            type = "cost",
            cost = {
                200,
                600,
                1200,
                1800,
                2600
            }
        }
    },
    modHood = {
        label = "Kapoty",
        parent = "bodyparts",
        modType = 7,
        prices = {
            type = "cost",
            cost = {
                500,
                1600,
                3000,
                5000,
                8000
            }
        }
    },
    modFender = {
        label = "Levé blatníky",
        parent = "bodyparts",
        modType = 8,
        prices = {
            type = "cost",
            cost = {
                300,
                1000,
                2000,
                3000,
                4000
            }
        }
    },
    modRightFender = {
        label = "Pravé blatníky",
        parent = "bodyparts",
        modType = 9,
        prices = {
            type = "cost",
            cost = {
                300,
                1000,
                2000,
                3000,
                4000
            }
        }
    },
    modRoof = {
        label = "Střechy",
        parent = "bodyparts",
        modType = 10,
        prices = {
            type = "cost",
            cost = {
                300,
                1000,
                2000,
                2000,
                2000
            }
        }
    },
    accesories = {
        label = "Příslušenství",
        parent = "cosmetics",
        modAerials = "Antény",
        modEngineBlock = "Blok motoru",
        modPlateHolder = "Držák SPZ",
        modHydrolic = "Hydraulika",
        modTrimA = "Interiér",
        modTrunk = "Kufr",
        modTrimB = "Křídlo",
        modWindows = "Okna",
        modTank = "Palivová nádrž",
        modDashboard = "Palubní deska",
        modArchCover = "Podběh kola",
        modOrnaments = "Potah",
        modSpeakers = "Reproduktory",
        modDoorSpeaker = "Reproduktory dveří",
        modSeats = "Sedadla",
        modVanityPlate = "Speciální SPZ",
        modDial = "Tachometr",
        modSteeringWheel = "Volant",
        modAirFilter = "Vzduchový filtr",
        modStruts = "Vzpěry",
        modAPlate = "Zadní paluba",
        modShifterLeavers = "Řadicí páka"
    },
    modAerials = {
        label = "Antény",
        parent = "accesories",
        modType = 43,
        prices = {
            type = "cost",
            cost = 100
        }
    },
    modEngineBlock = {
        label = "Motor",
        parent = "accesories",
        modType = 39,
        prices = {
            type = "cost",
            cost = 500
        }
    },
    modPlateHolder = {
        label = "Držák SPZ",
        parent = "accesories",
        modType = 25,
        prices = {
            type = "cost",
            cost = 200
        }
    },
    modHydrolic = {
        label = "Hydraulika",
        parent = "accesories",
        modType = 38,
        prices = {
            type = "cost",
            cost = 500
        }
    },
    modTrimA = {
        label = "Interiér",
        parent = "accesories",
        modType = 27,
        prices = {
            type = "cost",
            cost = { 250, 500, 500, 500, 500 }
        }
    },
    modTrunk = {
        label = "Kufr",
        parent = "accesories",
        modType = 37,
        prices = {
            type = "cost",
            cost = 1400
        }
    },
    modTrimB = {
        label = "Křídlo",
        parent = "accesories",
        modType = 44,
        prices = {
            type = "cost",
            cost = 500
        }
    },
    windowTint = {
        label = "Fólie na okna",
        parent = "accesories",
        modType = "windowTint",
        prices = {
            type = "cost",
            cost = {
                500,
                1500,
                1500,
                1500,
                1500
            }
        }
    },
    modWindows = {
        label = "Okna",
        parent = "accesories",
        modType = 46,
        prices = {
            type = "cost",
            cost = 500
        }
    },
    modTank = {
        label = "Palivová nádrž",
        parent = "accesories",
        modType = 45,
        prices = {
            type = "cost",
            cost = 500
        }
    },
    modDashboard = {
        label = "Palubní deska",
        parent = "accesories",
        modType = 29,
        prices = {
            type = "cost",
            cost = { 500, 1000, 1000, 1000, 1000 }
        }
    },
    modArchCover = {
        label = "Podběh kola",
        parent = "accesories",
        modType = 42,
        prices = {
            type = "cost",
            cost = { 250, 500, 500, 500, 500 }
        }
    },
    modOrnaments = {
        label = "Potahy",
        parent = "accesories",
        modType = 28,
        prices = {
            type = "cost",
            cost = 800
        }
    },
    modSpeakers = {
        label = "Reproduktory",
        parent = "accesories",
        modType = 36,
        prices = {
            type = "cost",
            cost = { 1500, 2600, 2600, 2600, 2600 }
        }
    },
    modDoorSpeaker = {
        label = "Reproduktory dveří",
        parent = "accesories",
        modType = 31,
        prices = {
            type = "cost",
            cost = { 400, 1200, 1200, 1200, 1200 }
        }
    },
    modSeats = {
        label = "Sedadla",
        parent = "accesories",
        modType = 32,
        prices = {
            type = "cost",
            cost = 600
        }
    },
    modVanityPlate = {
        label = "Speciální SPZ",
        parent = "accesories",
        modType = 26,
        prices = {
            type = "cost",
            cost = { 250, 300, 300, 300, 300 }
        }
    },
    modDial = {
        label = "Tachometr",
        parent = "accesories",
        modType = 30,
        prices = {
            type = "cost",
            cost = 200
        }
    },
    modSteeringWheel = {
        label = "Volant",
        parent = "accesories",
        modType = 33,
        prices = {
            type = "cost",
            cost = 500
        }
    },
    modAirFilter = {
        label = "Vzduchový filtr",
        parent = "accesories",
        modType = 40,
        prices = {
            type = "cost",
            cost = {
                300,
                1000,
                1500,
                2500,
                4000
            }
        }
    },
    modStruts = {
        label = "Vzpěry",
        parent = "accesories",
        modType = 41,
        prices = {
            type = "cost",
            cost = 300
        }
    },
    modAPlate = {
        label = "Zadní paluba",
        parent = "accesories",
        modType = 35,
        prices = {
            type = "cost",
            cost = 200
        }
    },
    modShifterLeavers = {
        label = "Řadicí páka",
        parent = "accesories",
        modType = 34,
        prices = {
            type = "cost",
            cost = 300
        }
    },
    modHorns = {
        label = "Klaksony",
        parent = "cosmetics",
        modType = 14,
        prices = {
            type = "cost",
            cost = { 100, 300, 300, 300, 300 }
        }
    },
    neonColor = {
        label = "Neony",
        parent = "cosmetics",
        modType = "neonColor",
        prices = {
            type = "cost",
            cost = { 300, 1000, 1000, 1000, 1000 }
        }
    },
    tyreSmokeColor = {
        label = "Barva kouře",
        parent = "wheels",
        modType = "tyreSmokeColor",
        prices = {
            type = "cost",
            cost = 500
        }
    }
}
