Config = {}

Config.SerialChars = {
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9"
}

Config.Blips = {
    ["grocery"] = {
        Sprite = 52,
        Scale = 0.6,
        Label = "Potraviny"
    },
    ["ammunation"] = {
        Sprite = 110,
        Scale = 0.6,
        Label = "Obchod se zbraněmi"
    },
    ["electronic"] = {
        Sprite = 521,
        Scale = 0.6,
        Label = "Elektronika"
    },
    ["gardener"] = {
        Sprite = 253,
        Scale = 0.6,
        Label = "Zahradnické potřeby"
    },
    ["youtool"] = {
        Sprite = 761,
        Scale = 0.8,
        Label = "You Tool"
    },
    ["alcohol"] = {
        Sprite = 93,
        Scale = 0.8,
        Label = "Obchod s alkoholem"
    },
    ["smokeonwater"] = {
        Sprite = 140,
        Scale = 0.6,
        Label = "Smoke On The Water"
    }
}

Config.Restricted = {
    ["alcohol"] = {
        "bar"
    }
}

Config.Products = {
    ["grocery"] = {
        ["beer_am"] = {
            BasePrice = 25,
            OrderAmount = 20
        },
        ["beer_cervezabarracho"] = {
            BasePrice = 30,
            OrderAmount = 20
        },
        ["beer_dusche"] = {
            BasePrice = 15,
            OrderAmount = 20
        },
        ["beer_glass"] = {
            BasePrice = 5,
            OrderAmount = 10
        },
        ["beer_jakeyslager"] = {
            BasePrice = 27,
            OrderAmount = 20
        },
        ["beer_logger"] = {
            BasePrice = 23,
            OrderAmount = 20
        },
        ["beer_patriot"] = {
            BasePrice = 22,
            OrderAmount = 20
        },
        ["beer_pisswasser"] = {
            BasePrice = 18,
            OrderAmount = 20
        },
        ["beer_pridebrew"] = {
            BasePrice = 23,
            OrderAmount = 20
        },
        ["beer_stoutblarneys"] = {
            BasePrice = 30,
            OrderAmount = 20
        },
        ["beer_stronzo"] = {
            BasePrice = 23,
            OrderAmount = 20
        },
        ["beer_benedict"] = {
            BasePrice = 28,
            OrderAmount = 20
        },
        ["beerpack_am"] = {
            BasePrice = 150,
            OrderAmount = 4
        },
        ["beerpack_benedict"] = {
            BasePrice = 123,
            OrderAmount = 4
        },
        ["beerpack_blarneysstout"] = {
            BasePrice = 180,
            OrderAmount = 4
        },
        ["beerpack_cervezabarracho"] = {
            BasePrice = 180,
            OrderAmount = 4
        },
        ["beerpack_duschegold"] = {
            BasePrice = 90,
            OrderAmount = 4
        },
        ["beerpack_jakeyslager"] = {
            BasePrice = 162,
            OrderAmount = 4
        },
        ["beerpack_logger"] = {
            BasePrice = 138,
            OrderAmount = 4
        },
        ["beerpack_patriot"] = {
            BasePrice = 132,
            OrderAmount = 4
        },
        ["beerpack_pisswasser"] = {
            BasePrice = 108,
            OrderAmount = 4
        },
        ["beerpack_pridebrew"] = {
            BasePrice = 138,
            OrderAmount = 4
        },
        ["brandy_cardiaque"] = {
            BasePrice = 800,
            OrderAmount = 5
        },
        ["brandy_glass"] = {
            BasePrice = 5,
            OrderAmount = 10
        },
        ["champ_bleuterdclassic"] = {
            BasePrice = 500,
            OrderAmount = 6
        },
        ["champ_bleuterdgold"] = {
            BasePrice = 750,
            OrderAmount = 6
        },
        ["champ_bleuterdsilver"] = {
            BasePrice = 650,
            OrderAmount = 6
        },
        ["champ_glass"] = {
            BasePrice = 5,
            OrderAmount = 10
        },
        ["cocktail_glass"] = {
            BasePrice = 5,
            OrderAmount = 10
        },
        ["cognac_bourgeoix"] = {
            BasePrice = 800,
            OrderAmount = 5
        },
        ["rum_ragga"] = {
            BasePrice = 900,
            OrderAmount = 5
        },
        ["shaker"] = {
            BasePrice = 80,
            OrderAmount = 10
        },
        ["shot"] = {
            BasePrice = 5,
            OrderAmount = 10
        },
        ["tall_glass"] = {
            BasePrice = 10,
            OrderAmount = 20
        },
        ["tequila_cazafortunas"] = {
            BasePrice = 550,
            OrderAmount = 5
        },
        ["tequila_sinsimitogold"] = {
            BasePrice = 750,
            OrderAmount = 5
        },
        ["tequila_sinsimitosilver"] = {
            BasePrice = 650,
            OrderAmount = 5
        },
        ["tequila_tequilya"] = {
            BasePrice = 450,
            OrderAmount = 5
        },
        ["vodka_cherenkovblue"] = {
            BasePrice = 500,
            OrderAmount = 6
        },
        ["vodka_cherenkovgreen"] = {
            BasePrice = 550,
            OrderAmount = 6
        },
        ["vodka_cherenkovpurple"] = {
            BasePrice = 900,
            OrderAmount = 6
        },
        ["vodka_cherenkovred"] = {
            BasePrice = 650,
            OrderAmount = 6
        },
        ["vodka_nogo"] = {
            BasePrice = 500,
            OrderAmount = 6
        },
        ["whiskey_glass"] = {
            BasePrice = 25,
            OrderAmount = 20
        },
        ["whiskey_macbeth"] = {
            BasePrice = 500,
            OrderAmount = 5
        },
        ["whiskey_richard"] = {
            BasePrice = 800,
            OrderAmount = 5
        },
        ["whiskey_themount"] = {
            BasePrice = 1100,
            OrderAmount = 5
        },
        ["wine_costadelperro"] = {
            BasePrice = 300,
            OrderAmount = 10
        },
        ["wine_glass"] = {
            BasePrice = 15,
            OrderAmount = 20
        },
        ["wine_rockfordhill"] = {
            BasePrice = 450,
            OrderAmount = 10
        },
        ["wine_vinewoodred"] = {
            BasePrice = 525,
            OrderAmount = 10
        },
        ["wine_vinewoodwhite"] = {
            BasePrice = 525,
            OrderAmount = 10
        },
        ["can_ecola"] = {
            BasePrice = 17,
            OrderAmount = 20
        },
        ["can_orangotang"] = {
            BasePrice = 17,
            OrderAmount = 20
        },
        ["can_sprunk"] = {
            BasePrice = 17,
            OrderAmount = 20
        },
        ["canbeer_blarneysstout"] = {
            BasePrice = 25,
            OrderAmount = 20
        },
        ["canbeer_hoplivion"] = {
            BasePrice = 21,
            OrderAmount = 20
        },
        ["canbeer_logger"] = {
            BasePrice = 23,
            OrderAmount = 20
        },
        ["cigars_estancia"] = {
            BasePrice = 400,
            OrderAmount = 10
        },
        ["cigs_69brand"] = {
            BasePrice = 200,
            OrderAmount = 10
        },
        ["cigs_cardiaque"] = {
            BasePrice = 160,
            OrderAmount = 10
        },
        ["cigs_debonaireblue"] = {
            BasePrice = 100,
            OrderAmount = 10
        },
        ["cigs_debonairegreen"] = {
            BasePrice = 120,
            OrderAmount = 10
        },
        ["cigs_redwood"] = {
            BasePrice = 60,
            OrderAmount = 10
        },
        ["cigs_redwoodgold"] = {
            BasePrice = 80,
            OrderAmount = 10
        },
        ["drink_cocomotion"] = {
            BasePrice = 9,
            OrderAmount = 10
        },
        ["drink_coffe"] = {
            BasePrice = 7,
            OrderAmount = 14
        },
        ["drink_ecola"] = {
            BasePrice = 17,
            OrderAmount = 20
        },
        ["drink_milk"] = {
            BasePrice = 15,
            OrderAmount = 15
        },
        ["drink_pq"] = {
            BasePrice = 17,
            OrderAmount = 15
        },
        ["energydrink_junk"] = {
            BasePrice = 20,
            OrderAmount = 15
        },
        ["energyfood_egochaser"] = {
            BasePrice = 30,
            OrderAmount = 20
        },
        ["food_apple"] = {
            BasePrice = 15,
            OrderAmount = 15
        },
        ["food_banana"] = {
            BasePrice = 17,
            OrderAmount = 15
        },
        ["food_biglogcracklesodawn"] = {
            BasePrice = 18,
            OrderAmount = 15
        },
        ["food_biglogstrawberryrails"] = {
            BasePrice = 18,
            OrderAmount = 15
        },
        ["food_burger"] = {
            BasePrice = 60,
            OrderAmount = 15
        },
        ["food_donut1"] = {
            BasePrice = 20,
            OrderAmount = 15
        },
        ["food_donut2"] = {
            BasePrice = 25,
            OrderAmount = 15
        },
        ["food_fries"] = {
            BasePrice = 40,
            OrderAmount = 15
        },
        ["food_hotdog"] = {
            BasePrice = 50,
            OrderAmount = 15
        },
        ["food_noodleschicken"] = {
            BasePrice = 70,
            OrderAmount = 15
        },
        ["food_noodleschicken2"] = {
            BasePrice = 65,
            OrderAmount = 15
        },
        ["food_orange"] = {
            BasePrice = 17,
            OrderAmount = 15
        },
        ["food_peanuts"] = {
            BasePrice = 30,
            OrderAmount = 15
        },
        ["food_phatchipsbigcheese"] = {
            BasePrice = 45,
            OrderAmount = 15
        },
        ["food_phatchipscrinkle"] = {
            BasePrice = 35,
            OrderAmount = 15
        },
        ["food_phatchipsstickyribs"] = {
            BasePrice = 35,
            OrderAmount = 15
        },
        ["food_phatchipssupersalt"] = {
            BasePrice = 35,
            OrderAmount = 15
        },
        ["food_pineapple"] = {
            BasePrice = 5,
            OrderAmount = 15
        },
        ["food_popcorn"] = {
            BasePrice = 40,
            OrderAmount = 15
        },
        ["food_pqcandybox"] = {
            BasePrice = 15,
            OrderAmount = 15
        },
        ["food_sandwich"] = {
            BasePrice = 40,
            OrderAmount = 15
        },
        ["food_bagel"] = {
            BasePrice = 45,
            OrderAmount = 15
        },
        ["food_taco"] = {
            BasePrice = 65,
            OrderAmount = 15
        },
        ["lighter_blue"] = {
            BasePrice = 25,
            OrderAmount = 15
        },
        ["lighter_gold"] = {
            BasePrice = 30,
            OrderAmount = 15
        },
        ["lighter_gray"] = {
            BasePrice = 25,
            OrderAmount = 15
        },
        ["lighter_zippo"] = {
            BasePrice = 50,
            OrderAmount = 5
        },
        ["notepad"] = {
            BasePrice = 5,
            OrderAmount = 20
        },
        ["tonic_ecolatonic"] = {
            BasePrice = 17,
            OrderAmount = 20
        },
        ["umbrella"] = {
            BasePrice = 100,
            OrderAmount = 10
        },
        ["water_flow"] = {
            BasePrice = 10,
            OrderAmount = 25
        },
        ["water_raine"] = {
            BasePrice = 15,
            OrderAmount = 25
        },
        ["dice"] = {
            BasePrice = 15,
            OrderAmount = 10
        },
        ["sponge"] = {
            BasePrice = 100,
            OrderAmount = 15
        },
        ["bakingsoda"] = {
            BasePrice = 20,
            OrderAmount = 50
        },
        ["citricacid"] = {
            BasePrice = 15,
            OrderAmount = 50
        }
    },
    ["gardener"] = {
        ["highgradefert"] = {
            BasePrice = 40,
            OrderAmount = 150
        },
        ["lowgradefert"] = {
            BasePrice = 20,
            OrderAmount = 150
        },
        ["plantpot"] = {
            BasePrice = 30,
            OrderAmount = 35
        },
        ["purifiedwater"] = {
            BasePrice = 30,
            OrderAmount = 50
        },
        ["wateringcan"] = {
            BasePrice = 15,
            OrderAmount = 55
        },
        ["lowgrademaleseed"] = {
            BasePrice = 1,
            OrderAmount = 5
        }
    },
    ["electronic"] = {
        ["boombox"] = {
            BasePrice = 250,
            OrderAmount = 8
        },
        ["cam_recording"] = {
            BasePrice = 300,
            OrderAmount = 5
        },
        ["microphone"] = {
            BasePrice = 50,
            OrderAmount = 5
        },
        ["microphonebig"] = {
            BasePrice = 75,
            OrderAmount = 5
        },
        ["transmitter"] = {
            BasePrice = 100,
            OrderAmount = 15
        },
        --["vape"] = {
        --    BasePrice = 50,
        --    OrderAmount = 10
        --}
        ["phone"] = {
            BasePrice = 1000,
            OrderAmount = 30
        },
        ["sim"] = {
            BasePrice = 200,
            OrderAmount = 30
        },
        ["piano"] = {
            BasePrice = 4500,
            OrderAmount = 5
        }
    },
    ["ammunation"] = {
        ["weapon_knife"] = {
            name = "weapon_knife",
            BasePrice = 400,
            OrderAmount = 10
        },
        ["weapon_machete"] = {
            name = "weapon_machete",
            BasePrice = 450,
            OrderAmount = 10
        },
        ["weapon_knuckle"] = {
            name = "weapon_knuckle",
            BasePrice = 300,
            OrderAmount = 10
        },
        ["weapon_flashlight"] = {
            name = "weapon_flashlight",
            BasePrice = 150,
            OrderAmount = 5
        },
        ["weapon_switchblade"] = {
            name = "weapon_switchblade",
            BasePrice = 350,
            OrderAmount = 10
        },
        ["weapon_combatpistol"] = {
            name = "weapon_combatpistol",
            BasePrice = 2700,
            OrderAmount = 20,
            License = "shortWeapon"
        },
        ["weapon_pistol"] = {
            name = "weapon_pistol",
            BasePrice = 2000,
            OrderAmount = 20,
            License = "shortWeapon"
        },
        ["weapon_pistol_mk2"] = {
            name = "weapon_pistol_mk2",
            BasePrice = 3750,
            OrderAmount = 10,
            License = "shortWeapon"
        },
        ["weapon_vintagepistol"] = {
            name = "weapon_vintagepistol",
            BasePrice = 75000,
            OrderAmount = 5,
            License = "collectorWeapon"
        },
        ["weapon_gadgetpistol"] = {
            name = "weapon_gadgetpistol",
            BasePrice = 90000,
            OrderAmount = 5,
            License = "collectorWeapon"
        },
        ["weapon_navyrevolver"] = {
            name = "weapon_navyrevolver",
            BasePrice = 60000,
            OrderAmount = 5,
            License = "collectorWeapon"
        },
        ["weapon_doubleaction"] = {
            name = "weapon_doubleaction",
            BasePrice = 150000,
            OrderAmount = 2,
            License = "collectorWeapon"
        },
        ["weapon_pumpshotgun"] = {
            name = "weapon_pumpshotgun",
            BasePrice = 25000,
            OrderAmount = 2,
            License = "longWeapon"
        },
        ["weapon_musket"] = {
            name = "weapon_musket",
            BasePrice = 50000,
            OrderAmount = 1,
            License = "longWeapon"
        },
        ["weapon_sniperrifle"] = {
            name = "weapon_sniperrifle",
            BasePrice = 100000,
            OrderAmount = 2,
            License = "longWeapon"
        },
        ["ammo_flaregun"] = {
            BasePrice = 15,
            OrderAmount = 25
        },
        ["ammo_pistol"] = {
            BasePrice = 5,
            OrderAmount = 200,
            License = "shortWeapon"
        },
        --["ammo_rifle"] = {
        --    BasePrice = 5000,
        --    OrderAmount = 45
        --},
        ["ammo_shotgun"] = {
            BasePrice = 8,
            OrderAmount = 50,
            License = "longWeapon"
        },
        --["ammo_smg"] = {
        --    BasePrice = 5000,
        --    OrderAmount = 45
        --},
        ["magazine_combatpistol_default"] = {
            BasePrice = 250,
            OrderAmount = 25
        },
        ["magazine_pistol_default"] = {
            BasePrice = 200,
            OrderAmount = 25
        },
        ["magazine_pistol_mk2_default"] = {
            BasePrice = 300,
            OrderAmount = 10
        },
        ["magazine_vintagepistol_default"] = {
            BasePrice = 3000,
            OrderAmount = 10,
            License = "collectorWeapon"
        },
        ["magazine_sniperrifle_default"] = {
            BasePrice = 2000,
            OrderAmount = 4,
            License = "longWeapon"
        }
    },
    ["youtool"] = {
        ["binoculars"] = {
            BasePrice = 150,
            OrderAmount = 20
        },
        ["confetti"] = {
            BasePrice = 80,
            OrderAmount = 200
        },
        ["sack"] = {
            BasePrice = 50,
            OrderAmount = 60
        },
        ["lockpick"] = {
            BasePrice = 50,
            OrderAmount = 200
        },
        ["screwdriver"] = {
            BasePrice = 50,
            OrderAmount = 50
        },
        ["roadcone"] = {
            BasePrice = 30,
            OrderAmount = 60
        },
        ["barrier"] = {
            BasePrice = 35,
            OrderAmount = 60
        },
        ["cosmetickit"] = {
            BasePrice = 300,
            OrderAmount = 50
        },
        ["neon_remote"] = {
            BasePrice = 2000,
            OrderAmount = 50
        },
        ["weapon_hatchet"] = {
            BasePrice = 400,
            OrderAmount = 10
        },
        ["weapon_crowbar"] = {
            BasePrice = 400,
            OrderAmount = 10
        },
        ["weapon_hammer"] = {
            BasePrice = 150,
            OrderAmount = 10
        },
        ["weapon_wrench"] = {
            BasePrice = 150,
            OrderAmount = 10
        },
        -- Drugs
        ["mortal"] = {
            BasePrice = 40,
            OrderAmount = 20
        },
        ["mixtube"] = {
            BasePrice = 35,
            OrderAmount = 20
        },
        ["tray"] = {
            BasePrice = 50,
            OrderAmount = 20
        },
        ["cokepack_empty"] = {
            BasePrice = 2,
            OrderAmount = 100
        },
        ["acetone"] = {
            BasePrice = 25,
            OrderAmount = 40
        },
        ["bismuth"] = {
            BasePrice = 22,
            OrderAmount = 40
        },
        ["hydrogenperoxide"] = {
            BasePrice = 15,
            OrderAmount = 40
        },
        ["lithiumbattery"] = {
            BasePrice = 150,
            OrderAmount = 40
        },
        ["phosphoricacid"] = {
            BasePrice = 60,
            OrderAmount = 40
        },
        ["propyloneglycol"] = {
            BasePrice = 18,
            OrderAmount = 40
        },
        ["toluene"] = {
            BasePrice = 22,
            OrderAmount = 40
        },
        ["technicalpetrol"] = {
            BasePrice = 70,
            OrderAmount = 40
        },
        ["sulfuricacid"] = {
            BasePrice = 65,
            OrderAmount = 40
        },
        ["kerosene"] = {
            BasePrice = 100,
            OrderAmount = 40
        }
    },
    ["alcohol"] = {
        ["beer_am"] = {
            BasePrice = 20,
            OrderAmount = 100
        },
        ["beer_cervezabarracho"] = {
            BasePrice = 24,
            OrderAmount = 100
        },
        ["beer_dusche"] = {
            BasePrice = 12,
            OrderAmount = 100
        },
        ["beer_glass"] = {
            BasePrice = 4,
            OrderAmount = 100
        },
        ["beer_jakeyslager"] = {
            BasePrice = 22,
            OrderAmount = 100
        },
        ["beer_logger"] = {
            BasePrice = 18,
            OrderAmount = 100
        },
        ["beer_patriot"] = {
            BasePrice = 18,
            OrderAmount = 100
        },
        ["beer_pisswasser"] = {
            BasePrice = 14,
            OrderAmount = 100
        },
        ["beer_pridebrew"] = {
            BasePrice = 18,
            OrderAmount = 100
        },
        ["beer_stoutblarneys"] = {
            BasePrice = 24,
            OrderAmount = 100
        },
        ["beer_stronzo"] = {
            BasePrice = 18,
            OrderAmount = 100
        },
        ["beerpack_am"] = {
            BasePrice = 120,
            OrderAmount = 100
        },
        ["beer_benedict"] = {
            BasePrice = 28,
            OrderAmount = 20
        },
        ["beerpack_benedict"] = {
            BasePrice = 98,
            OrderAmount = 100
        },
        ["beerpack_blarneysstout"] = {
            BasePrice = 144,
            OrderAmount = 100
        },
        ["beerpack_cervezabarracho"] = {
            BasePrice = 144,
            OrderAmount = 100
        },
        ["beerpack_duschegold"] = {
            BasePrice = 72,
            OrderAmount = 100
        },
        ["beerpack_jakeyslager"] = {
            BasePrice = 130,
            OrderAmount = 100
        },
        ["beerpack_logger"] = {
            BasePrice = 110,
            OrderAmount = 100
        },
        ["beerpack_patriot"] = {
            BasePrice = 106,
            OrderAmount = 100
        },
        ["beerpack_pisswasser"] = {
            BasePrice = 86,
            OrderAmount = 100
        },
        ["beerpack_pridebrew"] = {
            BasePrice = 110,
            OrderAmount = 100
        },
        ["brandy_cardiaque"] = {
            BasePrice = 600,
            OrderAmount = 100
        },
        ["brandy_glass"] = {
            BasePrice = 4,
            OrderAmount = 100
        },
        ["champ_bleuterdclassic"] = {
            BasePrice = 400,
            OrderAmount = 100
        },
        ["champ_bleuterdgold"] = {
            BasePrice = 600,
            OrderAmount = 100
        },
        ["champ_bleuterdluxe"] = {
            BasePrice = 1500,
            OrderAmount = 100
        },
        ["champ_bleuterdsilver"] = {
            BasePrice = 500,
            OrderAmount = 100
        },
        ["champ_glass"] = {
            BasePrice = 4,
            OrderAmount = 100
        },
        ["cocktail_glass"] = {
            BasePrice = 4,
            OrderAmount = 100
        },
        ["cognac_bourgeoix"] = {
            BasePrice = 600,
            OrderAmount = 100
        },
        ["drink_champ"] = {
            BasePrice = 600,
            OrderAmount = 100
        },
        ["drink_cocktail"] = {
            BasePrice = 4,
            OrderAmount = 100
        },
        ["rum_ragga"] = {
            BasePrice = 700,
            OrderAmount = 100
        },
        ["shaker"] = {
            BasePrice = 700,
            OrderAmount = 100
        },
        ["shot"] = {
            BasePrice = 3,
            OrderAmount = 100
        },
        ["tall_glass"] = {
            BasePrice = 6,
            OrderAmount = 100
        },
        ["tequila_cazafortunas"] = {
            BasePrice = 400,
            OrderAmount = 100
        },
        ["tequila_sinsimitogold"] = {
            BasePrice = 600,
            OrderAmount = 100
        },
        ["tequila_sinsimitosilver"] = {
            BasePrice = 500,
            OrderAmount = 100
        },
        ["tequila_tequilya"] = {
            BasePrice = 350,
            OrderAmount = 100
        },
        ["vodka_cherenkovblue"] = {
            BasePrice = 440,
            OrderAmount = 100
        },
        ["vodka_cherenkovgreen"] = {
            BasePrice = 440,
            OrderAmount = 100
        },
        ["vodka_cherenkovpurple"] = {
            BasePrice = 700,
            OrderAmount = 100
        },
        ["vodka_cherenkovred"] = {
            BasePrice = 500,
            OrderAmount = 100
        },
        ["vodka_nogo"] = {
            BasePrice = 400,
            OrderAmount = 100
        },
        ["whiskey_glass"] = {
            BasePrice = 20,
            OrderAmount = 100
        },
        ["whiskey_macbeth"] = {
            BasePrice = 400,
            OrderAmount = 100
        },
        ["whiskey_richard"] = {
            BasePrice = 600,
            OrderAmount = 100
        },
        ["whiskey_themount"] = {
            BasePrice = 850,
            OrderAmount = 100
        },
        ["wine_costadelperro"] = {
            BasePrice = 240,
            OrderAmount = 100
        },
        ["wine_glass"] = {
            BasePrice = 10,
            OrderAmount = 100
        },
        ["wine_rockfordhill"] = {
            BasePrice = 360,
            OrderAmount = 100
        },
        ["wine_vinewoodred"] = {
            BasePrice = 400,
            OrderAmount = 100
        },
        ["wine_vinewoodwhite"] = {
            BasePrice = 400,
            OrderAmount = 100
        }
    },
    ["smokeonwater"] = {
        ["scale"] = {
            BasePrice = 100,
            OrderAmount = 100
        },
        ["joint_paper"] = {
            BasePrice = 4,
            OrderAmount = 4000
        },
        ["drugbag"] = {
            BasePrice = 2,
            OrderAmount = 5000
        }
    }
}

Config.defaultRobDetails = {
    ped = {
        model = 416176080
    },
    loot = {
        min = 250,
        max = 600
    },
    baseDelay = 60000 * 60 -- 60 minutes
}
