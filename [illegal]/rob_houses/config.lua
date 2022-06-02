Config = {}
Config.WhitelistedJobTypes = {
    ["police"] = true,
    ["medic"] = true
}

Config.Residences = {
    ["Low Tier"] = {
        ReportChance = 5,
        ChanceToFindNothing = 55,
        Items = {
            {Item = "highgrademaleseed", Chance = 5, MinCount = 1, MaxCount = 5},
            {Item = "lowgrademaleseed", Chance = 10, MinCount = 1, MaxCount = 6},
            {Item = "highgradefemaleseed", Chance = 5, MinCount = 1, MaxCount = 4},
            {Item = "lowgradefemaleseed", Chance = 10, MinCount = 1, MaxCount = 6},
            {Item = "lotteryticket", Chance = 30, MinCount = 1, MaxCount = 3},
            {Item = "food_apple", Chance = 25, MinCount = 1, MaxCount = 5},
            {Item = "drink_ecola", Chance = 20, MinCount = 1, MaxCount = 3},
            {Item = "food_banana", Chance = 20, MinCount = 1, MaxCount = 3},
            {Item = "boombox", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "cash", Chance = 40, MinCount = 50, MaxCount = 350},
            {Item = "drink_beanmachinecoffee", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "beer_logger", Chance = 20, MinCount = 1, MaxCount = 3},
            {Item = "cuffs", Chance = 5, MinCount = 1, MaxCount = 2},
            {Item = "food_donut2", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_phatchipsbigcheese", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "can_orangotang", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "flashlight", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "grip", Chance = 4, MinCount = 1, MaxCount = 1},
            {Item = "food_burger", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_hotdog", Chance = 20, MinCount = 1, MaxCount = 4},
            {Item = "can_ecola", Chance = 20, MinCount = 1, MaxCount = 8},
            {Item = "rum_ragga", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "jewels", Chance = 25, MinCount = 3, MaxCount = 9},
            {Item = "lockpick", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "magazine_pistol_default", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "canbeer_logger", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "food_phatchipsstickyribs", Chance = 15, MinCount = 1, MaxCount = 2},
            {Item = "energyfood_egochaser", Chance = 15, MinCount = 1, MaxCount = 2},
            {Item = "food_sandwich", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_pqcandybox", Chance = 20, MinCount = 1, MaxCount = 8},
            {Item = "transmitter", Chance = 5, MinCount = 1, MaxCount = 1},
            {Item = "food_biglogstrawberryrails", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "cognac_bourgeoix", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "vodka_cherenkovblue", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "water_raine", Chance = 20, MinCount = 1, MaxCount = 3},
            {Item = "weapon_bat", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "weapon_knuckle", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "weapon_switchblade", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "weapon_pistol", Chance = 5, MinCount = 1, MaxCount = 1},
            {Item = "lighter_zippo", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "cannabis", Chance = 5, MinCount = 1, MaxCount = 4},
            {Item = "laptop", Chance = 1, MinCount = 1, MaxCount = 1},
            {Item = "thermite", Chance = 2, MinCount = 1, MaxCount = 1},
            {Item = "hack_card", Chance = 2, MinCount = 1, MaxCount = 1},
            {Item = "hack_usb", Chance = 2, MinCount = 1, MaxCount = 1},
            {Item = "drill", Chance = 2, MinCount = 1, MaxCount = 1}
        },
        NeedPoliceCount = 2,
        InsidePositions = {
            ["Exit"] = vec4(265.01303100586, -1001.1868286132, -99.008689880372, 0.83740812540054),
            ["Saffron"] = vec3(265.937714, -999.368348, -99.008666),
            ["Kitchen"] = vec3(265.805358, -996.243408, -99.008666),
            ["Shelves"] = vec3(262.050964, -995.239990, -99.008666),
            ["TV"] = vec3(256.789948, -996.051270, -99.008666),
            ["Bedroom"] = vec3(262.027314, -1002.559998, -99.008666),
            ["Mirror"] = vec3(255.623292, -1000.462220, -99.009842)
        }
    },
    ["Mid Tier"] = {
        ReportChance = 80,
        ChanceToFindNothing = 55,
        Items = {
            {Item = "highgrademaleseed", Chance = 15, MinCount = 1, MaxCount = 5},
            {Item = "lowgrademaleseed", Chance = 20, MinCount = 1, MaxCount = 6},
            {Item = "highgradefemaleseed", Chance = 15, MinCount = 1, MaxCount = 5},
            {Item = "lowgradefemaleseed", Chance = 20, MinCount = 1, MaxCount = 6},
            {Item = "lotteryticket", Chance = 20, MinCount = 1, MaxCount = 3},
            {Item = "food_apple", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "drink_ecola", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_banana", Chance = 20, MinCount = 1, MaxCount = 3},
            {Item = "boombox", Chance = 30, MinCount = 1, MaxCount = 1},
            {Item = "cash", Chance = 60, MinCount = 200, MaxCount = 500},
            {Item = "drink_beanmachinecoffee", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "beer_logger", Chance = 20, MinCount = 1, MaxCount = 5},
            {Item = "cuffs", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "food_donut2", Chance = 20, MinCount = 1, MaxCount = 3},
            {Item = "food_phatchipsbigcheese", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "can_orangotang", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "flashlight", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "grip", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "food_burger", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_hotdog", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "can_ecola", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "rum_ragga", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "jewels", Chance = 30, MinCount = 1, MaxCount = 10},
            {Item = "lockpick", Chance = 30, MinCount = 1, MaxCount = 3},
            {Item = "magazine_pistol_default", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "canbeer_logger", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_phatchipsstickyribs", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "energyfood_egochaser", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_sandwich", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_pqcandybox", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "transmitter", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "food_biglogstrawberryrails", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "cognac_bourgeoix", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "vodka_cherenkovblue", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "water_raine", Chance = 15, MinCount = 1, MaxCount = 2},
            {Item = "weapon_pistol", Chance = 8, MinCount = 1, MaxCount = 1},
            {Item = "lighter_blue", Chance = 15, MinCount = 1, MaxCount = 1},
            {Item = "weapon_bat", Chance = 15, MinCount = 1, MaxCount = 1},
            {Item = "weapon_knuckle", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "weapon_switchblade", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "cannabis", Chance = 10, MinCount = 4, MaxCount = 8},
            {Item = "laptop", Chance = 1, MinCount = 1, MaxCount = 1},
            {Item = "thermite", Chance = 3, MinCount = 1, MaxCount = 1},
            {Item = "hack_card", Chance = 3, MinCount = 1, MaxCount = 1},
            {Item = "hack_usb", Chance = 3, MinCount = 1, MaxCount = 1},
            {Item = "drill", Chance = 3, MinCount = 1, MaxCount = 1}
        },
        NeedPoliceCount = 5,
        InsidePositions = {
            ["Exit"] = vector4(346.752106, -1002.687072, -99.196258, 357.81),
            ["Saffron"] = vector3(342.23, -1003.29, -99.0),
            ["Speaker"] = vector3(338.14, -997.69, -99.2),
            ["Laptop"] = vector3(350.91, -999.26, -99.2),
            ["Bag of Cocaine"] = vector3(349.19, -994.83, -99.2),
            ["Book"] = vector3(345.3, -995.76, -99.2),
            ["Coupon"] = vector3(346.14, -1001.55, -99.2),
            ["Toothpaste"] = vector3(347.23, -994.09, -99.2),
            ["Lottery Ticket"] = vector3(339.23, -1003.35, -99.2)
        }
    },
    ["High Tier"] = {
        ReportChance = 95,
        ChanceToFindNothing = 55,
        Items = {
            {Item = "highgrademaleseed", Chance = 20, MinCount = 1, MaxCount = 6},
            {Item = "lowgrademaleseed", Chance = 25, MinCount = 1, MaxCount = 7},
            {Item = "highgradefemaleseed", Chance = 20, MinCount = 1, MaxCount = 6},
            {Item = "lowgradefemaleseed", Chance = 25, MinCount = 1, MaxCount = 7},
            {Item = "lotteryticket", Chance = 65, MinCount = 1, MaxCount = 5},
            {Item = "food_apple", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "drink_ecola", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_banana", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "boombox", Chance = 35, MinCount = 1, MaxCount = 2},
            {Item = "cash", Chance = 60, MinCount = 300, MaxCount = 750},
            {Item = "drink_beanmachinecoffee", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "beer_logger", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_donut2", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_phatchipsbigcheese", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "can_orangotang", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "flashlight", Chance = 20, MinCount = 1, MaxCount = 4},
            {Item = "grip", Chance = 20, MinCount = 1, MaxCount = 1},
            {Item = "food_burger", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "food_hotdog", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "can_ecola", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "rum_ragga", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "jewels", Chance = 40, MinCount = 8, MaxCount = 16},
            {Item = "lockpick", Chance = 40, MinCount = 2, MaxCount = 4},
            {Item = "canbeer_logger", Chance = 30, MinCount = 1, MaxCount = 2},
            {Item = "food_phatchipsstickyribs", Chance = 30, MinCount = 1, MaxCount = 2},
            {Item = "energyfood_egochaser", Chance = 30, MinCount = 1, MaxCount = 2},
            {Item = "food_sandwich", Chance = 30, MinCount = 1, MaxCount = 2},
            {Item = "food_pqcandybox", Chance = 30, MinCount = 1, MaxCount = 2},
            {Item = "transmitter", Chance = 15, MinCount = 1, MaxCount = 2},
            {Item = "food_biglogstrawberryrails", Chance = 20, MinCount = 1, MaxCount = 2},
            {Item = "cognac_bourgeoix", Chance = 25, MinCount = 1, MaxCount = 4},
            {Item = "vodka_cherenkovblue", Chance = 25, MinCount = 1, MaxCount = 2},
            {Item = "water_raine", Chance = 25, MinCount = 1, MaxCount = 4},
            {Item = "suppressor", Chance = 1, MinCount = 1, MaxCount = 1},
            {Item = "weapon_combatpistol", Chance = 5, MinCount = 1, MaxCount = 1},
            {Item = "weapon_pistol", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "lighter_gold", Chance = 15, MinCount = 1, MaxCount = 1},
            {Item = "weapon_bat", Chance = 15, MinCount = 1, MaxCount = 1},
            {Item = "weapon_knuckle", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "weapon_switchblade", Chance = 10, MinCount = 1, MaxCount = 1},
            {Item = "laptop", Chance = 1, MinCount = 1, MaxCount = 1},
            {Item = "thermite", Chance = 4, MinCount = 1, MaxCount = 1},
            {Item = "hack_card", Chance = 4, MinCount = 1, MaxCount = 1},
            {Item = "hack_usb", Chance = 4, MinCount = 1, MaxCount = 1},
            {Item = "drill", Chance = 4, MinCount = 1, MaxCount = 1}
        },
        NeedPoliceCount = 5,
        InsidePositions = {
            ["Exit"] = vector4(-787.48413085938, 315.70617675782, 187.9133758545, 270.08288574218),
            ["Saffron"] = vec3(-788.957886, 320.741302, 187.313248),
            ["Kitchen #1"] = vec3(-783.327454, 325.411712, 187.313248),
            ["Kitchen #2"] = vec3(-782.004090, 330.077392, 187.313248),
            ["TV"] = vec3(-781.370544, 338.451324, 187.113678),
            ["Books"] = vec3(-792.645020, 329.171875, 187.313400),
            ["Heist storage"] = vec3(-794.997680, 326.787872, 187.313340),
            ["Heist computer"] = vec3(-798.083740, 322.035584, 187.313340),
            ["Stair saffron"] = vec3(-793.373352, 341.711944, 187.113678),
            ["Bedroom saffron"] = vec3(-800.065612, 338.434052, 190.716018),
            ["Locker #1"] = vec3(-799.149902, 328.694580, 190.716018),
            ["Locker #2"] = vec3(-796.366760, 328.144348, 190.716004),
            ["Bathroom"] = vec3(-806.068360, 332.405182, 190.716004)
        }
    }
}

Config.RobPlaces = {
    ["Low Tier 1"] = {
        Coords = vector4(1439.9510498046, -1480.2639160156, 63.621147155762, 344.99169921875),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 2"] = {
        Coords = vector4(1391.0789794922, -1508.3510742188, 58.43571472168, 27.841844558716),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 3"] = {
        Coords = vector4(1344.6776123046, -1513.2449951172, 54.585018157958, 357.40856933594),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 4"] = {
        Coords = vector4(1334.0083007812, -1566.462524414, 54.447093963624, 26.486280441284),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 5"] = {
        Coords = vector4(1205.712524414, -1607.1795654296, 50.736503601074, 215.91757202148),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 6"] = {
        Coords = vector4(1203.4724121094, -1670.4978027344, 42.98184967041, 215.35614013672),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 7"] = {
        Coords = vector4(1314.3514404296, -1733.125366211, 54.700096130372, 292.40447998046),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 8"] = {
        Coords = vector4(1241.1490478516, -1725.7978515625, 52.024227142334, 21.665655136108),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 9"] = {
        Coords = vector4(377.73178100586, -2066.3830566406, 21.754623413086, 229.9900817871),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 10"] = {
        Coords = vector4(388.68139648438, -2025.8564453125, 23.403129577636, 66.319847106934),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 11"] = {
        Coords = vector4(377.2367553711, -2004.0202636718, 24.245515823364, 159.1927947998),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 12"] = {
        Coords = vector4(250.80558776856, -2011.9210205078, 19.258785247802, 49.714580535888),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 13"] = {
        Coords = vector4(375.8370666504, -1873.3664550782, 26.034967422486, 51.236057281494),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 14"] = {
        Coords = vector4(566.24487304688, -1778.1442871094, 29.353143692016, 334.7201538086),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 15"] = {
        Coords = vector4(554.64196777344, -1766.2067871094, 29.312232971192, 245.14688110352),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 16"] = {
        Coords = vector4(552.44995117188, -1765.39453125, 33.442581176758, 241.41784667968),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 17"] = {
        Coords = vector4(559.25463867188, -1750.914428711, 33.442588806152, 243.1700744629),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 18"] = {
        Coords = vector4(295.35369873046, -1767.4598388672, 29.102558135986, 44.40385055542),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 19"] = {
        Coords = vector4(470.6789855957, -1561.2846679688, 32.82721710205, 228.91326904296),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 20"] = {
        Coords = vector4(430.17001342774, -1559.4747314454, 32.823333740234, 319.89874267578),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 21"] = {
        Coords = vector4(460.44500732422, -1573.5128173828, 32.824443817138, 232.24485778808),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 22"] = {
        Coords = vector4(-29.20470046997, -1869.3747558594, 25.33507347107, 231.6229095459),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 23"] = {
        Coords = vector4(-30.070446014404, -1787.683227539, 27.820589065552, 317.04580688476),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 24"] = {
        Coords = vector4(115.5834350586, -1685.7084960938, 33.49084854126, 231.84379577636),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 25"] = {
        Coords = vector4(200.10475158692, -1717.4931640625, 29.474201202392, 296.79635620118),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 26"] = {
        Coords = vector4(214.9253692627, -1693.251586914, 29.692222595214, 37.374946594238),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 27"] = {
        Coords = vector4(182.88832092286, -1688.7075195312, 29.67063331604, 237.97708129882),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 28"] = {
        Coords = vector4(-19.570234298706, -1550.7830810546, 30.676733016968, 50.03609085083),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 29"] = {
        Coords = vector4(-69.262321472168, -1526.778930664, 34.235233306884, 320.82794189454),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 30"] = {
        Coords = vector4(-35.73694229126, -1555.3193359375, 30.676733016968, 318.69680786132),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 31"] = {
        Coords = vector4(-120.03304290772, -1574.4460449218, 34.176342010498, 139.81312561036),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 32"] = {
        Coords = vector4(-224.24298095704, -1674.474975586, 34.463314056396, 357.5297241211),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 33"] = {
        Coords = vector4(-121.31495666504, -1653.117553711, 32.56432723999, 142.56224060058),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 34"] = {
        Coords = vector4(-147.7469177246, -1596.251586914, 38.212619781494, 240.25482177734),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 35"] = {
        Coords = vector4(-216.5677947998, -1648.3937988282, 34.46322631836, 179.76997375488),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 36"] = {
        Coords = vector4(-138.79573059082, -1658.9692382812, 36.514152526856, 237.0506286621),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 37"] = {
        Coords = vector4(-121.61269378662, -1290.5515136718, 29.355710983276, 275.24697875976),
        Residence = Config.Residences["Low Tier"]
    },
    ["Low Tier 38"] = {
        Coords = vector4(133.22546386718, -1328.7561035156, 34.002498626708, 307.02685546875),
        Residence = Config.Residences["Low Tier"]
    },
    ["Mid Tier 1"] = {
        Coords = vector4(-957.3041381836, -1566.759399414, 5.0187458992004, 108.65511322022),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 2"] = {
        Coords = vector4(-1063.0949707032, -1641.5561523438, 4.4911875724792, 312.95495605468),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 3"] = {
        Coords = vector4(-1078.2329101562, -1613.2375488282, 8.0473823547364, 302.19357299804),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 4"] = {
        Coords = vector4(-1093.6120605468, -1608.2810058594, 8.4588069915772, 305.02108764648),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 5"] = {
        Coords = vector4(-1144.0732421875, -1528.9401855468, 4.3452463150024, 123.14791107178),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 6"] = {
        Coords = vector4(-1150.8819580078, -1519.2153320312, 4.358250617981, 123.87828826904),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 7"] = {
        Coords = vector4(-1204.5219726562, -1021.9776000976, 5.9451127052308, 299.82635498046),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 8"] = {
        Coords = vector4(-1064.7055664062, -1057.4013671875, 6.4116525650024, 304.36849975586),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 9"] = {
        Coords = vector4(-1184.7005615234, -1045.2147216796, 2.1502439975738, 302.69815063476),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 10"] = {
        Coords = vector4(-673.05676269532, -981.23596191406, 22.340850830078, 178.18501281738),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 11"] = {
        Coords = vector4(-675.92950439454, -884.76153564454, 24.442680358886, 91.441329956054),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 12"] = {
        Coords = vector4(-1712.8016357422, -477.32983398438, 41.649452209472, 277.07681274414),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 13"] = {
        Coords = vector4(-1583.6497802734, -265.84478759766, 48.274982452392, 266.99096679688),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 14"] = {
        Coords = vector4(-410.74645996094, 159.5998840332, 73.732887268066, 259.18215942382),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 15"] = {
        Coords = vector4(-341.02062988282, 34.532775878906, 52.110355377198, 174.10987854004),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 16"] = {
        Coords = vector4(79.211891174316, -58.094482421875, 68.135429382324, 70.41944885254),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 17"] = {
        Coords = vector4(141.45469665528, -90.159469604492, 72.469116210938, 252.19720458984),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 18"] = {
        Coords = vector4(322.17245483398, -146.65382385254, 64.557716369628, 161.5998840332),
        Residence = Config.Residences["Mid Tier"]
    },
    ["Mid Tier 19"] = {
        Coords = vector4(191.98303222656, 331.5291442871, 105.3996887207, 276.41870117188),
        Residence = Config.Residences["Mid Tier"]
    },
    ["High Tier 1"] = {
        Coords = vector4(216.44435119628, 620.49877929688, 187.75685119628, 74.529731750488),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 2"] = {
        Coords = vector4(128.08323669434, 565.9828491211, 183.95948791504, 13.116044998168),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 3"] = {
        Coords = vector4(-70.449180603028, 359.169921875, 112.44513702392, 154.654006958),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 4"] = {
        Coords = vector4(-297.75091552734, 379.74154663086, 112.09530639648, 17.48217201233),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 5"] = {
        Coords = vector4(-378.72024536132, 548.69793701172, 124.04608917236, 232.05072021484),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 6"] = {
        Coords = vector4(-307.38409423828, 643.35284423828, 176.13484191894, 117.0717163086),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 7"] = {
        Coords = vector4(-167.55686950684, 916.00909423828, 235.6554260254, 42.985126495362),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 8"] = {
        Coords = vector4(-565.7494506836, 761.18444824218, 185.42039489746, 42.985126495362),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 9"] = {
        Coords = vector4(-745.89361572266, 589.7060546875, 142.615234375, 62.036220550538),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 10"] = {
        Coords = vector4(-972.3031616211, 752.21697998046, 176.38061523438, 47.425468444824),
        Residence = Config.Residences["High Tier"]
    },
    ["High Tier 11"] = {
        Coords = vector4(-2009.2062988282, 367.52465820312, 94.814422607422, 272.41589355468),
        Residence = Config.Residences["High Tier"]
    }
}

Config.lotteryTicketChances = {
    {
        Min = 1,
        Max = 15,
        Chance = 15
    },
    {
        Min = 16,
        Max = 30,
        Chance = 30
    },
    {
        Min = 31,
        Max = 50,
        Chance = 40
    },
    {
        Min = 51,
        Max = 100,
        Chance = 20
    },
    {
        Min = 101,
        Max = 200,
        Chance = 15
    },
    {
        Min = 201,
        Max = 400,
        Chance = 10
    },
    {
        Min = 401,
        Max = 700,
        Chance = 5
    },
    {
        Min = 701,
        Max = 1000,
        Chance = 2
    }
}

