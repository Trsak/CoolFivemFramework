Config = {}
Config.openMenuKey = 38 -- [E]
Config.maxAvailableAccounts = 5
Config.maxCards = 10
Config.maxCardPinTries = 5
Config.logActions = true

Config.defaultPerms = {
    ["balance"] = true,
    ["withdraw_take"] = true,
    ["withdraw_put"] = true,
    ["transfer"] = true,
    ["changetype"] = false,
    ["changeowner"] = false,
    ["changename"] = false,
    ["access"] = false,
    ["invoices"] = true,
    ["payinvoice"] = false,
    ["delete"] = false,
    ["cards"] = false,
    ["showtransfers"] = false
}

Config.idChars = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
                  "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}

Config.banks = {{
    ["company"] = "fleeca",
    ["zone"] = {vector3(149.11, -1041.65, 29.37), 1.8, 5.8, {
        name = "fleeca-1",
        heading = 160,
        minZ = 27.77,
        maxZ = 31.77
    }},
    ["available"] = true,
    ["hidden"] = false
}, {
    ["company"] = "fleeca",
    ["zone"] = {vector3(-352.18, -51.17, 49.04), 5.8, 2.6, {
        name = "fleeca-2",
        heading = 250
    }},
    ["available"] = true,
    ["hidden"] = false
}, {
    ["company"] = "fleeca",
    ["zone"] = {vector3(313.08, -280.13, 54.16), 2.2, 6.2, {
        name = "fleeca-3",
        heading = 340
    }},
    ["available"] = true,
    ["hidden"] = false
}, {
    ["company"] = "fleeca",
    ["zone"] = {vector3(-1212.68, -332.42, 37.79), 2.8, 5.4, {
        name = "fleeca-4",
        heading = 205
    }},
    ["available"] = true,
    ["hidden"] = false
}, {
    ["company"] = "fleeca",
    ["zone"] = {vector3(-2960.98, 482.28, 15.7), 2.8, 6.2, {
        name = "fleeca-5",
        heading = 265
    }},
    ["available"] = true,
    ["hidden"] = false
}, {
    ["company"] = "fleeca",
    ["zone"] = {vector3(1175.27, 2708.41, 38.09), 2.8, 6.8, {
        name = "fleeca-6",
        heading = 180
    }},
    ["available"] = true,
    ["hidden"] = false
}, {
    ["company"] = "blaine",
    ["zone"] = {vector3(-111.88, 6470.69, 31.63), 2.6, 6.4, {
        name = "blaine-1",
        heading = 315
    }},
    ["available"] = true,
    ["hidden"] = false
}, {
    ["company"] = "pacific",
    ["zone"] = {vector3(248.18, 225.58, 106.29), 9, 15.4, {
        name = "pacific-1",
        heading = 340,
        minZ = 105.0
    }},
    ["available"] = true,
    ["hidden"] = false
}}

Config.blips = {
    ["fleeca"] = {
        ["bType"] = 207,
        ["bScale"] = 0.8,
        ["bColor"] = 0, -- 2
        ["bDisplay"] = 3,
        ["bLabel"] = "FLEECA Banka"
    },
    ["blaine"] = {
        ["bType"] = 207,
        ["bScale"] = 0.8,
        ["bColor"] = 0, -- 2
        ["bDisplay"] = 3,
        ["bLabel"] = "Blaine County Banka"
    },
    ["maze"] = {
        ["bType"] = 207,
        ["bScale"] = 0.6,
        ["bColor"] = 0, -- 1
        ["bDisplay"] = 3,
        ["bLabel"] = "MAZE BANKA"
    },
    ["pacific"] = {
        ["bType"] = 207,
        ["bScale"] = 1.0,
        ["bColor"] = 0, -- 1
        ["bDisplay"] = 3,
        ["bLabel"] = "Pacific Standard BANKA"
    }
}

Config.ATMs = {"prop_atm_01", "prop_atm_02", "prop_atm_03", "prop_fleeca_atm"}

Config.BankAccounts = {
    ["lspd"] = "6148961963", -- 3076181661
    ["lssd"] = "6473015323",
    ["sahp"] = "2428752769"
}
