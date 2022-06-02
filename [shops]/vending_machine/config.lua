Config = {}

Config.DispenseDict = { "mini@sprunk", "plyr_buy_drink_pt1" }
Config.PocketAnims = { "mp_common_miss", "put_away_coke" }

Config.TrackedEntities = {
    ["drink"] = {
        label = "Koupit si pití ($17)",
        models = { "prop_vend_soda_01", "prop_vend_soda_02" },
        items = { "can_ecola", "can_sprunk" },
        price = 17,
        icon = "fas fa-wine-bottle",
        machineSound = true,
        canBreak = true
    },
    ["eat"] = {
        label = "Koupit si jídlo ($40)",
        models = { "prop_vend_snak_01", "prop_vend_snak_01_tu" },
        items = { "food_phatchipsbigcheese", "food_phatchipscrinkle", "food_phatchipsstickyribs", "food_phatchipssupersalt"},
        price = 40,
        icon = "fas fa-cookie",
        machineSound = true,
        canBreak = true
    },
    ["coffee"] = {
        label = "Koupit si kávu ($30)",
        models = { "prop_vend_coffe_01" },
        items = { "drink_beanmachinecoffee" },
        price = 30,
        icon = "fas fa-coffee",
        machineSound = true,
        canBreak = true
    },
    ["water"] = {
        label = "Koupit si vodu ($15)",
        models = { "prop_vend_water_01" },
        items = { "water_raine" },
        price = 15,
        icon = "fas fa-tint",
        machineSound = true,
        canBreak = true
    },
    ["waterFree"] = {
        label = "Vzít si kelímek s vodou",
        models = { "prop_watercooler", "prop_watercooler_dark" },
        items = { "water_cup" },
        price = 0,
        icon = "fas fa-tint",
        machineSound = false,
        canBreak = false
    }
}