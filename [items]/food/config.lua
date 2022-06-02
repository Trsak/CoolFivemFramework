Config = {}

Config.Drinks = {
    ["can_ecola"] = {
        Capacity = 500,
        Description = "Lahodně infekční!",
        Model = "prop_ecola_can",
        Place = {
            Offset = vec3(0.013, 00.013, -0.02),
            Rotate = vec3(0.5, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "can",
        Type = "can",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["can_orangotang"] = {
        Capacity = 500,
        Description = "Pomerančová orangutální příchuť.",
        Model = "prop_orang_can_01",
        Place = {
            Offset = vec3(0.013, 00.013, -0.02),
            Rotate = vec3(0.5, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "can",
        Type = "can",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["can_sprunk"] = {
        Capacity = 500,
        Description = "Esence života.",
        Model = "prop_ld_can_01",
        Place = {
            Offset = vec3(0.013, 00.013, -0.02),
            Rotate = vec3(0.5, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "can",
        Type = "can",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["canbeer_blarneysstout"] = {
        Capacity = 500,
        Description = "Tvoří tvé ústa šťastné.",
        Model = "v_res_tt_can01",
        Place = {
            Offset = vec3(0.009, 00.013, -0.02),
            Rotate = vec3(0.5, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "can",
        Type = "can",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 2.0
        }
    },
    ["canbeer_hoplivion"] = {
        Capacity = 500,
        Description = "Nejlepší pivo, které si vychutnáš ve svém bunkru, když přečkáváš Apokalypsu.",
        Model = "h4_prop_h4_can_beer_01a",
        Place = {
            Offset = vec3(0.01, 00.01, -0.08),
            Rotate = vec3(0.5, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "can",
        Type = "can",
        Remove = 100.0,
        Add = {
            thirst = 7.0,
            drunk = 1.5
        }
    },
    ["canbeer_logger"] = {
        Capacity = 500,
        Description = "Pivo, které svrhlo lesy.",
        Model = "v_res_tt_can02",
        Place = {
            Offset = vec3(0.009, 00.013, -0.02),
            Rotate = vec3(0.5, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "can",
        Type = "can",
        Remove = 100.0,
        Add = {
            thirst = 6.0,
            drunk = 1.5
        }
    },
    ["beer_am"] = {
        Capacity = 500,
        Description = "Co si budeme, taková ta sprcha po ránu a do toho chčiješ.",
        Model = "prop_beer_amopen",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.0,
            drunk = 1.5
        }
    },
    ["beer_vanilla"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beervanilla",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.0,
            drunk = 1.5
        }
    },
    ["beer_santamadre"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beersantamadre",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.5,
            drunk = 2.5
        }
    },
    ["beer_cervezabarracho"] = {
        Capacity = 500,
        Description = "Doba hraní!",
        Model = "prop_beer_bar",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 2.0
        }
    },
    ["beer_jfc"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beerjfc",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 3.5
        }
    },
    ["beer_lamesa"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beerlamesa",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 2.0
        }
    },
    ["beer_dusche"] = {
        Capacity = 500,
        Description = "Ať prší...",
        Model = "prop_beerdusche",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 4.0,
            drunk = 1.5
        }
    },
    ["beer_jakeyslager"] = {
        Capacity = 500,
        Description = "Pijte venku s Jakey's.",
        Model = "prop_beer_jakey",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 9.0,
            drunk = 2.0
        }
    },
    ["beer_logger"] = {
        Capacity = 500,
        Description = "Pivo, které svrhlo lesy.",
        Model = "prop_beer_logopen",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 6.0,
            drunk = 1.5
        }
    },
    ["beer_patriot"] = {
        Capacity = 500,
        Description = "Nikdy neodmítneš patriota.",
        Model = "prop_beer_patriot",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 6.0,
            drunk = 1.0
        }
    },
    ["beer_pisswasser"] = {
        Capacity = 500,
        Description = "Seš tu, aby si se dobře bavil.",
        Model = "prop_beer_pissh",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.0,
            drunk = 1.2
        }
    },
    ["beer_pridebrew"] = {
        Capacity = 500,
        Description = "Spolkni mě.",
        Model = "prop_beer_pride",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 6.0,
            drunk = 1.5
        }
    },
    ["beer_stoutblarneys"] = {
        Capacity = 500,
        Description = "Tvoří tvé ústa šťastné. ",
        Model = "prop_beer_blr",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 2.0
        }
    },
    ["beer_thelost"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beerthelost",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 2.5
        }
    },
    ["beer_sakura"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beersakura",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 3.1
        }
    },
    ["beer_barney"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beerbarney",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 2.0
        }
    },
    ["beer_benedict"] = {
        Capacity = 500,
        Description = "Zazvonil zvonec a je čas na chlast.",
        Model = "beerbenedict",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 1.8
        }
    },
    ["beer_stronzo"] = {
        Capacity = 500,
        Description = "Silné italské pivo.",
        Model = "prop_beer_stzopen",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.0,
            drunk = 1.5
        }
    },
    ["beer_corona"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company. Jo píšeme se Corrona.",
        Model = "beercorona",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.0,
            drunk = 1.5
        }
    },
    ["beer_beereater0"] = {
        Capacity = 500,
        Description = "Nealkohollické Pivo od Beereater Company",
        Model = "beereater_0",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.0
        }
    },
    ["beer_beereater12"] = {
        Capacity = 500,
        Description = "Pivo od Beereater Company",
        Model = "beereater_12",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.0,
            drunk = 1.5
        }
    },
    ["beer_beereater17"] = {
        Capacity = 500,
        Description = "Pivo od Beereater Company",
        Model = "beereater_17",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 7.0,
            drunk = 3.5
        }
    },
    ["beer_yellowjack"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beeryellowjack",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 3.1
        }
    },
    ["beer_royalcompany"] = {
        Capacity = 500,
        Description = "Pivo na zakázku od Beereater Company.",
        Model = "beerroyalcompany",
        Place = {
            Offset = vec3(0.03, 0.01, -0.11),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 8.0,
            drunk = 2.9
        }
    },
    ["drink_beanmachinecoffee"] = {
        Capacity = 500,
        Description = "Chutná jako palivo. Kopne jako mezek.",
        Model = "p_amb_coffeecup_01",
        Place = {
            Offset = vec3(0.0, 0.0, 0.0),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "can",
        Type = "cup",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    -- Big prop
    ["drink_burgershotcoffee"] = {
        Capacity = 500,
        Description = "Kelímek s tmavým nápojem uvnitř.",
        Model = "prop_food_bs_coffee",
        Place = {
            Offset = vec3(0.1, -0.11, -0.12),
            Rotate = vec3(-74.0, -1.0, -20.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "cup",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    -- Big prop
    ["drink_cluckingbellcoffee"] = {
        Capacity = 500,
        Description = "Kelímek s tmavým nápojem uvnitř.",
        Model = "prop_food_cb_coffee",
        Place = {
            Offset = vec3(0.1, -0.11, -0.12),
            Rotate = vec3(-74.0, -1.0, -20.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "cup",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    -- Big prop
    ["drink_coffe"] = {
        Capacity = 500,
        Description = "Obyčejný kelímek s tmavou tekutinou uvnitř.",
        Model = "prop_food_coffee",
        Place = {
            Offset = vec3(0.17, 0.0, -0.1),
            Rotate = vec3(-71.0, 0.0, -2.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "cup",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["brandy_cardiaque"] = {
        Capacity = 700,
        Description = "Dobrá Napoleonská pálenka.",
        Model = "prop_bottle_brandy",
        Place = {
            Offset = vec3(0.09, -0.18, -0.1),
            Rotate = vec3(-71.0, 0.0, -2.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 70.0,
        Add = {
            thirst = 8.0,
            drunk = 10.0
        }
    },
    ["brandy_sealovice"] = {
        Capacity = 750,
        Description = "Není nic lepšího, než se zahřát před letem a pak trefit mrakodrap. Slivovice na zakázku od Beereater Company.",
        Model = "brandysealovice",
        Place = {
            Offset = vec3(0.07, -0.26, -0.08),
            Rotate = vec3(-86.0, -27.0, -12.0),
            Bone = 57005
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 11.0,
            drunk = 13.5
        }
    },
    ["champ_bleuterdclassic"] = {
        Capacity = 750,
        Description = "Blêuter'd klasické.",
        Model = "ba_prop_battle_champ_01",
        Place = {
            Offset = vec3(0.06, -0.3, -0.12),
            Rotate = vec3(-77.0, -2.0, -7.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 10.0,
            drunk = 5.0
        }
    },
    ["champ_bleuterdsilver"] = {
        Capacity = 750,
        Description = "Blêuter'd stříbrné.",
        Model = "ba_prop_battle_champ_closed",
        Place = {
            Offset = vec3(0.09, -0.1, -0.04),
            Rotate = vec3(-87.0, -2.0, -7.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 10.0,
            drunk = 6.0
        }
    },
    ["champ_bleuterdgold"] = {
        Capacity = 750,
        Description = "Blêuter'd zlaté.",
        Model = "ba_prop_battle_champ_closed_02",
        Place = {
            Offset = vec3(0.09, -0.1, -0.04),
            Rotate = vec3(-87.0, -2.0, -7.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 10.0,
            drunk = 7.0
        }
    },
    ["champ_bleuterdluxe"] = {
        Capacity = 750,
        Description = "Blêuter'd luxusní.",
        Model = "ba_prop_battle_champ_closed_03",
        Place = {
            Offset = vec3(0.09, -0.1, -0.04),
            Rotate = vec3(-87.0, -2.0, -7.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 10.0,
            drunk = 9.0
        }
    },
    ["cognac_bourgeoix"] = {
        Capacity = 700,
        Description = "Francouzský koňak.",
        Model = "prop_bottle_cognac",
        Place = {
            Offset = vec3(0.12, -0.16, -0.06),
            Rotate = vec3(-87.0, -2.0, -7.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 9.0
        }
    },
    ["drink_pq"] = {
        Capacity = 500,
        Description = "P's & Q's milk-shake.",
        Model = "v_ret_fh_bscup",
        Place = {
            Offset = vec3(0.0, 0.0, -0.03),
            Rotate = vec3(0.0, 0.0, 90.0),
            Bone = 28422
        },
        Anim = "can",
        Type = "cup",
        Remove = 100.0,
        Add = {
            thirst = 15.0
        }
    },
    ["energydrink_junk"] = {
        Capacity = 500,
        Description = "Rychlá oprava a přidá stamínu!",
        Model = "prop_energy_drink",
        Place = {
            Offset = vec3(0.12, 0.04, -0.03),
            Rotate = vec3(-87.0, -2.0, -7.0),
            Bone = 57005
        },
        Anim = "beer2",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 20.0,
            stamina = 25.0
        }
    },
    ["tequila_cazafortunas"] = {
        Capacity = 750,
        Description = "Tequila z agávy modré.",
        Model = "h4_prop_h4_t_bottle_01a",
        Place = {
            Offset = vec3(0.12, -0.12, -0.03),
            Rotate = vec3(-87.0, 3.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 9.0,
            drunk = 9.0
        }
    },
    ["tequila_isabel"] = {
        Capacity = 750,
        Description = "Způsobuje 100% sexuální myšlenky, pokud teda tomu věříš.",
        Model = "tequilaisabel",
        Place = {
            Offset = vec3(0.12, -0.12, -0.03),
            Rotate = vec3(-87.0, 3.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 9.0,
            drunk = 9.0
        }
    },
    ["tequila_matt"] = {
        Capacity = 750,
        Description = "Tequila na zakázku od Beereater Company.",
        Model = "tequilamatt",
        Place = {
            Offset = vec3(0.11, -0.16, -0.08),
            Rotate = vec3(-76.0, 3.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 8.0,
            drunk = 9.0
        }
    },
    ["tequila_sinsimitosilver"] = {
        Capacity = 750,
        Description = "Nic pro padavky.",
        Model = "h4_prop_h4_t_bottle_02b",
        Place = {
            Offset = vec3(0.11, -0.16, -0.08),
            Rotate = vec3(-76.0, 3.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 8.0,
            drunk = 9.0
        }
    },
    ["tequila_sinsimitogold"] = {
        Capacity = 750,
        Description = "Pokud po tomhle neskončíš v nemocnici tak ti gratuluji přežil si svojí smrt.",
        Model = "h4_prop_h4_t_bottle_02a",
        Place = {
            Offset = vec3(0.11, -0.16, -0.08),
            Rotate = vec3(-76.0, 3.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 10.0,
            drunk = 9.0
        }
    },
    ["tequila_demacho"] = {
        Capacity = 750,
        Description = "Tequila na zakázku od Beereater Company. RIP...",
        Model = "tequilademacho",
        Place = {
            Offset = vec3(0.11, -0.16, -0.08),
            Rotate = vec3(-76.0, 3.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 75.0,
        Add = {
            thirst = 10.0,
            drunk = 10.0
        }
    },
    ["tequila_tequilya"] = {
        Capacity = 1000,
        Description = "Tento červ se proměnil v tequilu. Uvítej proteinovou senzaci!",
        Model = "prop_tequila_bottle",
        Place = {
            Offset = vec3(0.11, -0.17, -0.11),
            Rotate = vec3(-76.0, 3.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 10.0
        }
    },
    ["gin_premium"] = {
        Capacity = 750,
        Description = "Gin na zakázku od Beereater Company.",
        Model = "ginpremium",
        Place = {
            Offset = vec3(0.11, -0.17, -0.11),
            Rotate = vec3(-76.0, 3.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 10.0
        }
    },
    ["tonic_ecolatonic"] = {
        Capacity = 1000,
        Description = "Tonic od vaší oblíbené eCola.",
        Model = "ba_prop_club_tonic_bottle",
        Place = {
            Offset = vec3(0.15, -0.16, -0.09),
            Rotate = vec3(-77.0, -12.0, 2.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["drink_ecola"] = {
        Capacity = 2000,
        Description = "Lahodně infekční!",
        Model = "v_ret_247_popbot4",
        Place = {
            Offset = vec3(0.18, -0.08, -0.13),
            Rotate = vec3(-77.0, -15.0, -2.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["vodka_cherenkovblue"] = {
        Capacity = 1000,
        Description = "Zahřeje vás do morku kostí.",
        Model = "prop_cherenkov_02",
        Place = {
            Offset = vec3(0.13, -0.24, -0.1),
            Rotate = vec3(-77.0, -33.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 14.0
        }
    },
    ["vodka_cherenkovgreen"] = {
        Capacity = 1000,
        Description = "Zahřeje vás do morku kostí.",
        Model = "prop_cherenkov_03",
        Place = {
            Offset = vec3(0.13, -0.24, -0.1),
            Rotate = vec3(-77.0, -33.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 13.0
        }
    },
    ["vodka_cherenkovpurple"] = {
        Capacity = 1000,
        Description = "Zahřeje vás do morku kostí.",
        Model = "prop_cherenkov_04",
        Place = {
            Offset = vec3(0.13, -0.24, -0.1),
            Rotate = vec3(-77.0, -33.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 18.0
        }
    },
    ["vodka_cherenkovred"] = {
        Capacity = 1000,
        Description = "Zahřeje vás do morku kostí.",
        Model = "prop_cherenkov_01",
        Place = {
            Offset = vec3(0.13, -0.24, -0.1),
            Rotate = vec3(-77.0, -33.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 14.0
        }
    },
    ["vodka_pablo"] = {
        Capacity = 1000,
        Description = "Vodka na zakázku od Beereater Company.",
        Model = "vodkapablo",
        Place = {
            Offset = vec3(0.13, -0.24, -0.1),
            Rotate = vec3(-77.0, -33.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 14.0
        }
    },
    ["vodka_nogo"] = {
        Capacity = 1000,
        Description = "Prémiová vodka ze srdce, ne z vlasti.",
        Model = "prop_vodka_bottle",
        Place = {
            Offset = vec3(0.13, -0.22, -0.1),
            Rotate = vec3(-77.0, -33.0, -6.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 11.0
        }
    },
    ["water_cup"] = {
        Capacity = 250,
        Description = "Klasický modrý kelímek s čistou vodou.",
        Model = "prop_cs_paper_cup",
        Place = {
            Offset = vec3(0.0, 0.0, -0.01),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 28422
        },
        Anim = "can",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["water_flow"] = {
        Capacity = 500,
        Description = "Žádné kalorie! 100% chuti a už vůbec ne Editova Flow!",
        Model = "prop_ld_flow_bottle",
        Place = {
            Offset = vec3(0.13, -0.02, -0.05),
            Rotate = vec3(-87.0, -33.0, -6.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["water_raine"] = {
        Capacity = 500,
        Description = "Ochutnej, přímo od boha! Eh, možná trošku slaná.",
        Model = "ba_prop_club_water_bottle",
        Place = {
            Offset = vec3(0.11, -0.1, -0.03),
            Rotate = vec3(-95.0, -32.0, -6.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["whiskey_macbeth"] = {
        Capacity = 750,
        Description = "12 letá Skotská whiskey.",
        Model = "prop_bottle_macbeth",
        Place = {
            Offset = vec3(0.07, -0.26, -0.08),
            Rotate = vec3(-86.0, -27.0, -12.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 13.0
        }
    },
    ["whiskey_richard"] = {
        Capacity = 750,
        Description = "Vždy dobrá sázka, Kentucky whiskey.",
        Model = "ba_prop_battle_whiskey_opaque_s",
        Place = {
            Offset = vec3(0.09, 0.0, -0.06),
            Rotate = vec3(-116.0, -113.0, -19.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 14.0
        }
    },
    ["rum_thelost"] = {
        Capacity = 750,
        Description = "Rum na zakázku od Beereater Company",
        Model = "rumthelost",
        Place = {
            Offset = vec3(0.04, 0.08, -0.21),
            Rotate = vec3(0.0, -7.0, 0.0),
            Bone = 64097
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 18.0
        }
    },
    ["whiskey_themount"] = {
        Capacity = 750,
        Description = "Dokonalý mixér, bourbon whiskey.",
        Model = "prop_cs_whiskey_bottle",
        Place = {
            Offset = vec3(0.1, 0.0, -0.06),
            Rotate = vec3(-116.0, -113.0, -19.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 18.0
        }
    },
    ["whiskey_ramon"] = {
        Capacity = 750,
        Description = "Whiskey na zakázku od Beereater Company.",
        Model = "whiskeyramon",
        Place = {
            Offset = vec3(0.08, -0.1, -0.05),
            Rotate = vec3(-70.0, 80.0, -5.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 18.0
        }
    },
    ["wine_costadelperro"] = {
        Capacity = 700,
        Description = "Cabernet Sauvignon červené víno.",
        Model = "prop_wine_bot_01",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 6.0
        }
    },
    ["wine_marlowe"] = {
        Capacity = 700,
        Description = "Víno z Marlowské vinice.",
        Model = "prop_wine_bot_02",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 7.0
        }
    },
    ["wine_rockfordhill"] = {
        Capacity = 700,
        Description = "Rockfordhillské bíle.",
        Model = "prop_wine_bot_02",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 8.0
        }
    },
    ["wine_vinewoodred"] = {
        Capacity = 700,
        Description = "Vinewoodské červené.",
        Model = "prop_wine_rose",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 6.0
        }
    },
    ["wine_vinewoodwhite"] = {
        Capacity = 700,
        Description = "Vinewoodské bílé.",
        Model = "prop_wine_white",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 9.0
        }
    },
    ["wine_barolo"] = {
        Capacity = 700,
        Description = "Víno z Marlowské vinice.",
        Model = "winebarolo",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 11.0,
            drunk = 8.5
        }
    },
    ["wine_chardonnay"] = {
        Capacity = 700,
        Description = "Víno z Marlowské vinice.",
        Model = "winechardonnay",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 11.0,
            drunk = 7.5
        }
    },
    ["wine_chianti"] = {
        Capacity = 700,
        Description = "Víno z Marlowské vinice.",
        Model = "winechianti",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 11.0,
            drunk = 7.8
        }
    },
    ["wine_pinotgrigio"] = {
        Capacity = 700,
        Description = "Víno z Marlowské vinice.",
        Model = "winepinotgrigio",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 11.0,
            drunk = 6.5
        }
    },
    ["wine_prosecco"] = {
        Capacity = 700,
        Description = "Víno z Marlowské vinice.",
        Model = "wineprosecco",
        Place = {
            Offset = vec3(0.12, -0.2, -0.1),
            Rotate = vec3(-76.0, 0.0, 0.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 11.0,
            drunk = 9.2
        }
    },
    ["wine_vermentino"] = {
        Capacity = 700,
        Description = "Víno z Marlowské vinice.",
        Model = "winevermentino",
        Place = {
            Offset = vec3(0.1, -0.21, -0.13),
            Rotate = vec3(-100.0, -110.0, -15.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 11.0,
            drunk = 8.6
        }
    },
    ["drink_cocomotion"] = {
        Capacity = 500,
        Description = "Nápoj s příchutí kokosu.",
        Model = "h4_prop_battle_coconutdrink_01a",
        Place = {
            Offset = vec3(0.13, -0.01, -0.05),
            Rotate = vec3(-108.0, -110.0, -12.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["drink_cocomaxik"] = {
        Capacity = 500,
        Description = "Nápoj s příchutí kokosu na zakázku od Beereater Company.",
        Model = "drinkmaxik",
        Place = {
            Offset = vec3(0.13, -0.01, -0.05),
            Rotate = vec3(-108.0, -110.0, -12.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["rum_ragga"] = {
        Capacity = 750,
        Description = "Zažíj chuť Dlouhé Jamajky.",
        Model = "prop_rum_bottle",
        Place = {
            Offset = vec3(0.06, -0.16, -0.11),
            Rotate = vec3(-108.0, -110.0, -12.0),
            Bone = 57005
        },
        Anim = "beer",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 10.0,
            drunk = 11.0
        }
    },
    ["drink_milk"] = {
        Capacity = 1000,
        Description = "Čerstvé mélko.",
        Model = "v_res_tt_milk",
        Place = {
            Offset = vec3(0.13, -0.04, -0.09),
            Rotate = vec3(-109.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 100.0,
        Add = {
            thirst = 11.0
        }
    },
    ["drink_burgershotjuice"] = {
        Capacity = 500,
        Description = "Kelímek obsahuje džus z Burger Shot.",
        Model = "prop_food_bs_juice01",
        Place = {
            Offset = vec3(0.13, -0.11, -0.11),
            Rotate = vec3(-106.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["drink_cluckingbelljuice"] = {
        Capacity = 500,
        Description = "Kelímek obsahuje džus z Clucking Bell.",
        Model = "prop_food_bs_juice03",
        Place = {
            Offset = vec3(0.13, -0.11, -0.11),
            Rotate = vec3(-106.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Remove = 100.0,
        Add = {
            thirst = 10.0
        }
    },
    ["milkshake_uwuvanilla"] = {
        Capacity = 320,
        Description = "UWU! Vanilka",
        Model = "milkshake_vanilla",
        Place = {
            Offset = vec3(0.15, 0.03, -0.03),
            Rotate = vec3(-70.0, 60.0, 1.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "cup",
        Remove = 50.0,
        Add = {
            thirst = 12.0
        }
    },
    ["milkshake_uwustrawberry"] = {
        Capacity = 320,
        Description = "UWU! Jahoda",
        Model = "milkshake_strawberry",
        Place = {
            Offset = vec3(0.15, 0.03, -0.03),
            Rotate = vec3(-70.0, 60.0, 1.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "cup",
        Remove = 50.0,
        Add = {
            thirst = 12.0
        }
    },
    ["milkshake_uwuchocolate"] = {
        Capacity = 320,
        Description = "UWU! Čokoláda",
        Model = "milkshake_chocolate",
        Place = {
            Offset = vec3(0.15, 0.03, -0.03),
            Rotate = vec3(-70.0, 60.0, 1.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "cup",
        Remove = 50.0,
        Add = {
            thirst = 12.0
        }
    },
    ["milkshake_uwuchocolate2"] = {
        Capacity = 500,
        Description = "UWU! Čokoláda",
        Model = "milkshake_l_choc",
        Place = {
            Offset = vec3(0.15, 0.03, -0.03),
            Rotate = vec3(-70.0, 60.0, 1.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "cup",
        Remove = 50.0,
        Add = {
            thirst = 13.0
        }
    }
}

Config.Food = {
    ["energyfood_egochaser"] = {
        Capacity = 60,
        Description = "Je to všechno o tobě. ",
        Model = "prop_choc_ego",
        Place = {
            Offset = vec3(0.0, 0.0, 0.0),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 60309
        },
        Anim = "food",
        Type = "plastic",
        Remove = 9.0,
        Add = {
            hunger = 10.0,
            stamina = 25.0
        }
    },
    ["food_apple"] = {
        Capacity = 225,
        Description = "Kvůli tomuhle se dal Adam s Evou dohromady.",
        Model = "ng_proc_food_aple2a",
        Place = {
            Offset = vec3(0.14, 0.02, 0.04),
            Rotate = vec3(-29.0, 271.0, 33.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 45.0,
        Add = {
            hunger = 8.0
        }
    },
    ["food_banana"] = {
        Capacity = 220,
        Description = "Pozor pokud mě hodláš sníst měl/a by sis dávat pozor mohlo by to být bráno sexuálně.",
        Model = "ng_proc_food_nana1a",
        Place = {
            Offset = vec3(0.14, 0.04, 0.06),
            Rotate = vec3(-23.0, 275.0, 75.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 50.0,
        Add = {
            hunger = 10.0
        }
    },
    ["food_icecreamvan"] = {
        Capacity = 120,
        Description = "Zmrzlina mňam vanilka!",
        Model = "icecream_van",
        Place = {
            Offset = vec3(0.13, 0.04, 0.01),
            Rotate = vec3(-108.0, -40.0, -5.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 50.0,
        Add = {
            hunger = 2.0,
            thirst = 1.5
        }
    },
    ["food_icecreampis"] = {
        Capacity = 120,
        Description = "Zmrzlina mňam pistácie!",
        Model = "icecream_pis",
        Place = {
            Offset = vec3(0.13, 0.04, 0.01),
            Rotate = vec3(-108.0, -40.0, -5.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 50.0,
        Add = {
            hunger = 2.0,
            thirst = 1.5
        }
    },
    ["food_icecreamchoc"] = {
        Capacity = 120,
        Description = "Zmrzlina mňam čokoláda!",
        Model = "icecream_choc",
        Place = {
            Offset = vec3(0.13, 0.04, 0.01),
            Rotate = vec3(-108.0, -40.0, -5.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 50.0,
        Add = {
            hunger = 2.0,
            thirst = 1.5
        }
    },
    ["food_alienegg"] = {
        Capacity = 900,
        Description = "Nemám nejmenší tušení, odkud to pochází... asi to půjde i sníst.",
        Model = "prop_alien_egg_01",
        Place = {
            Offset = vec3(0.26, -0.1, 0.22),
            Rotate = vec3(236.0, 8.0, 16.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 50.0,
        Add = {
            hunger = 99.0,
            thirst = 99.0,
            drunk = 85.0
        }
    },
    ["food_bagel"] = {
        Capacity = 145,
        Description = "Hmmm proč to má díru?",
        Model = "p_ing_bagel_01",
        Place = {
            Offset = vec3(0.13, 0.05, 0.02),
            Rotate = vec3(-50.0, 16.0, 60.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 26.0,
        Add = {
            hunger = 16.0
        }
    },
    ["food_noodleschicken2"] = {
        Capacity = 150,
        Description = "Kuřecí nebo kočičí s nudlemi nikdo neví.",
        Model = "prop_ff_noodle_01",
        Place = {
            Offset = vec3(0.22, 0.02, 0.09),
            Rotate = vec3(236.0, 8.0, 16.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "paper",
        Remove = 25.0,
        Add = {
            hunger = 23.0
        }
    },
    ["food_peanuts"] = {
        Capacity = 145,
        Description = "Peanus teda co? Prostě arašídy.",
        Model = "foodplanters",
        Place = {
            Offset = vec3(0.14, 0.04, 0.04),
            Rotate = vec3(326.0, -42.0, 16.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "plastic",
        Remove = 40.0,
        Add = {
            hunger = 7.0
        }
    },
    ["food_biglogcracklesodawn"] = {
        Capacity = 360,
        Description = "Cereálie s mnoho ingrediencema uvnitř.",
        Model = "v_res_fa_cereal02",
        Place = {
            Offset = vec3(0.2, -0.05, 0.1),
            Rotate = vec3(-70.0, 170.0, 5.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "plastic",
        Remove = 60.0,
        Add = {
            hunger = 10.0
        }
    },
    ["food_biglogstrawberryrails"] = {
        Capacity = 360,
        Description = "Cereálie s příchutí jahody.",
        Model = "v_ret_247_cereal1",
        Place = {
            Offset = vec3(0.2, -0.05, 0.1),
            Rotate = vec3(-70.0, 170.0, 5.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "plastic",
        Remove = 100.0,
        Add = {
            hunger = 10.0
        }
    },
    ["food_burger"] = {
        Capacity = 220,
        Description = "Buď ti způsobím orgasmus na jazyku nebo později smrt.",
        Model = "prop_cs_burger_01",
        Place = {
            Offset = vec3(0.13, 0.05, 0.02),
            Rotate = vec3(-50.0, 16.0, 60.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 60.0,
        Add = {
            hunger = 15.0
        }
    },
    ["food_pizza"] = {
        Capacity = 210,
        Description = "Hmmm dáme na to ananas?",
        Model = "prop_pizza",
        Place = {
            Offset = vec3(0.12, 0.04, 0.01),
            Rotate = vec3(21.0, -220.0, -15.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 60.0,
        Add = {
            hunger = 14.0
        }
    },
    ["food_donut1"] = {
        Capacity = 100,
        Description = "Byl jsem kobliha než mě někdo postřelil.",
        Model = "prop_donut_01",
        Place = {
            Offset = vec3(0.13, 0.05, 0.02),
            Rotate = vec3(-50.0, 16.0, 60.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 50.0,
        Add = {
            hunger = 20.0
        }
    },
    ["food_donut2"] = {
        Capacity = 105,
        Description = "Narozdil od mého bratra Donuta já se umím nalíčit.",
        Model = "prop_donut_02",
        Place = {
            Offset = vec3(0.13, 0.05, 0.02),
            Rotate = vec3(-50.0, 16.0, 60.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 51.3,
        Add = {
            hunger = 22.0
        }
    },
    ["food_fries"] = {
        Capacity = 150,
        Description = "Nic lepšího z brambory nevymysleli.",
        Model = "prop_food_bs_chips",
        Place = {
            Offset = vec3(0.12, -0.03, 0.04),
            Rotate = vec3(-72.0, 138.0, 7.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 30.0,
        Add = {
            hunger = 12.0
        }
    },
    ["food_ravendriedmeat"] = {
        Capacity = 190,
        Description = "Sušené maso, které ještě ve své normální formě zažilo velké dobrodružství v Raven Slaughterhouse.",
        Model = "foodravendriedmeat",
        Place = {
            Offset = vec3(0.12, -0.03, 0.04),
            Rotate = vec3(-72.0, 138.0, 7.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 30.0,
        Add = {
            hunger = 26.0
        }
    },
    ["food_hotdog"] = {
        Capacity = 160,
        Description = "Šance že je uvnitř maso ze psa je 50/50.",
        Model = "prop_cs_hotdog_01",
        Place = {
            Offset = vec3(0.13, 0.07, 0.02),
            Rotate = vec3(160.0, 0.0, -50.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 15.0
        }
    },
    ["food_hotdog2"] = {
        Capacity = 165,
        Description = "Řeknu ti to takhle, jsem prostě lepší.",
        Model = "foodhotdog",
        Place = {
            Offset = vec3(0.13, 0.07, 0.02),
            Rotate = vec3(160.0, 0.0, -50.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 19.0
        }
    },
    ["food_goulash"] = {
        Capacity = 510,
        Description = "Jo jo gulášek v misce, co na to říct?",
        Model = "prop_cs_bowl_01b",
        Place = {
            Offset = vec3(0.0, 0.0, 0.02),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 60309
        },
        Anim = "food2",
        Type = "plastic",
        Remove = 25.0,
        Add = {
            hunger = 25.0,
            thirst = 2.5
        }
    },
    ["food_goulash2"] = {
        Capacity = 515,
        Description = "Speciální gulášek od Yellow Jack.",
        Model = "foodgoulash",
        Place = {
            Offset = vec3(0.0, 0.0, 0.02),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 60309
        },
        Anim = "food2",
        Type = "plastic",
        Remove = 25.0,
        Add = {
            hunger = 28.0,
            thirst = 3.2
        }
    },
    ["food_spaghetti"] = {
        Capacity = 520,
        Description = "Špagety se vším všudy jak to má být.",
        Model = "prop_spagh",
        Place = {
            Offset = vec3(0.03, 0.0, 0.0),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 60309
        },
        Anim = "food2",
        Type = "plastic",
        Remove = 25.0,
        Add = {
            hunger = 23.5,
            thirst = 2.8
        }
    },
    ["food_kimbap"] = {
        Capacity = 515,
        Description = "Kimbap nebo gimbap je populární korejské rychlé občerstvení, takže se pořádně nažer.",
        Model = "prop_sushiplate1",
        Place = {
            Offset = vec3(0.04, 0.04, -0.04),
            Rotate = vec3(0.0, 9.0, 0.0),
            Bone = 60309
        },
        Anim = "food2",
        Type = "plastic",
        Remove = 25.0,
        Add = {
            hunger = 20.5,
            thirst = 2.1
        }
    },
    ["food_sushi"] = {
        Capacity = 525,
        Description = "Suši je jedno z nejznámějších jídel japonské kuchyně, papkej kamaráde papkej. ",
        Model = "prop_sushiplate2",
        Place = {
            Offset = vec3(0.09, 0.04, -0.04),
            Rotate = vec3(0.0, 9.0, 0.0),
            Bone = 60309
        },
        Anim = "food2",
        Type = "plastic",
        Remove = 25.0,
        Add = {
            hunger = 23.5,
            thirst = 2.1
        }
    },
    ["food_pizzafull"] = {
        Capacity = 510,
        Description = "No je to pizza celá, co sem mám psát?",
        Model = "prop_pizzares",
        Place = {
            Offset = vec3(0.2, 0.15, 0.02),
            Rotate = vec3(8.0, -3.0, 0.0),
            Bone = 60309
        },
        Anim = "food2",
        Type = "plastic",
        Remove = 25.0,
        Add = {
            hunger = 24.0,
            thirst = 1.0
        }
    },
    ["food_friesbeans"] = {
        Capacity = 520,
        Description = "Hranolky a Fazole na talíři.",
        Model = "prop_cs_plate_01",
        Place = {
            Offset = vec3(0.01, 0.0, -0.04),
            Rotate = vec3(0.0, 0.0, 0.0),
            Bone = 60309
        },
        Anim = "food2",
        Type = "plastic",
        Remove = 25.0,
        Add = {
            hunger = 30.0,
            thirst = 1.2
        }
    },
    ["food_noodleschicken"] = {
        Capacity = 190,
        Description = "Kuřecí nebo kočičí s nudlemi nikdo neví.",
        Model = "v_ret_247_noodle1",
        Place = {
            Offset = vec3(0.1, 0.0, 0.07),
            Rotate = vec3(-67.0, -230.0, 4.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "plastic",
        Remove = 25.0,
        Add = {
            hunger = 25.0
        }
    },
    ["food_orange"] = {
        Capacity = 150,
        Description = "Oranžové a umí se kutálet.",
        Model = "ng_proc_food_ornge1a",
        Place = {
            Offset = vec3(0.13, 0.0, 0.01),
            Rotate = vec3(-21.0, -28.0, -2.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 30.0,
        Add = {
            hunger = 8.0
        }
    },
    ["food_phatchipsbigcheese"] = {
        Capacity = 130,
        Description = "S příchutí sýra.",
        Model = "v_ret_ml_chips4",
        Place = {
            Offset = vec3(0.17, -0.07, 0.07),
            Rotate = vec3(-116.0, 355.0, -35.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "plastic",
        Remove = 26.0,
        Add = {
            hunger = 8.0
        }
    },
    ["food_phatchipscrinkle"] = {
        Capacity = 130,
        Description = "S příchutí habaňěra. NA VLASTNÍ NEBEZPEČÍ!",
        Model = "v_ret_ml_chips2",
        Place = {
            Offset = vec3(0.17, -0.07, 0.07),
            Rotate = vec3(-116.0, 355.0, -35.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "plastic",
        Remove = 26.0,
        Add = {
            hunger = 8.0
        }
    },
    ["food_phatchipsstickyribs"] = {
        Capacity = 130,
        Description = "Lepkavá žebra.",
        Model = "v_ret_ml_chips1",
        Place = {
            Offset = vec3(0.17, -0.07, 0.07),
            Rotate = vec3(-116.0, 355.0, -35.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "plastic",
        Remove = 26.0,
        Add = {
            hunger = 8.0
        }
    },
    ["food_phatchipssupersalt"] = {
        Capacity = 130,
        Description = "Super slané.",
        Model = "v_ret_ml_chips3",
        Place = {
            Offset = vec3(0.17, -0.07, 0.07),
            Rotate = vec3(-116.0, 355.0, -35.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "plastic",
        Remove = 26.0,
        Add = {
            hunger = 8.0
        }
    },
    ["food_pineapple"] = {
        Capacity = 500,
        Description = "Já chci na pizzu!",
        Model = "prop_pineapple",
        Place = {
            Offset = vec3(0.13, 0.05, 0.02),
            Rotate = vec3(50.0, 16.0, 60.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 100.0,
        Add = {
            hunger = 10.0
        }
    },
    ["food_popcorn"] = {
        Capacity = 125,
        Description = "Byl jsem kukuřice než mě někdo spražil.",
        Model = "xs_prop_trinket_cup_01a",
        Place = {
            Offset = vec3(0.1, -0.05, 0.11),
            Rotate = vec3(-116.0, 355.0, -35.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "paper",
        Remove = 25.0,
        Add = {
            hunger = 5.0
        }
    },
    ["food_pqcandybox"] = {
        Capacity = 105,
        Description = "Krabička sladkostí, kterou milují děti a vyhulenci.",
        Model = "prop_candy_pqs",
        Place = {
            Offset = vec3(0.13, 0.01, 0.03),
            Rotate = vec3(-29.0, -29.0, 2.0),
            Bone = 18905
        },
        Anim = "food",
        Type = "paper",
        Remove = 25.0,
        Add = {
            hunger = 9.0
        }
    },
    ["food_sandwich"] = {
        Capacity = 125,
        Description = "Sice není jako od maminky ale určitě tě zasytí.",
        Model = "prop_sandwich_01",
        Place = {
            Offset = vec3(0.13, 0.05, 0.02),
            Rotate = vec3(-50.0, 16.0, 60.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 25.0,
        Add = {
            hunger = 15.0
        }
    },
    ["food_taco"] = {
        Capacity = 250,
        Description = "Obyčejné taco.",
        Model = "prop_taco_01",
        Place = {
            Offset = vec3(0.13, 0.07, 0.02),
            Rotate = vec3(160.0, 0.0, -50.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 20.0
        }
    },
    ["food_tacochicken"] = {
        Capacity = 280,
        Description = "Unikátní kuřecí taco.",
        Model = "foodtacochicken",
        Place = {
            Offset = vec3(0.13, 0.07, 0.02),
            Rotate = vec3(160.0, 0.0, -50.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 24.0
        }
    },
    ["food_tacodepescado"] = {
        Capacity = 280,
        Description = "Unikátní de Pescado taco.",
        Model = "foodtacodepescado",
        Place = {
            Offset = vec3(0.13, 0.07, 0.02),
            Rotate = vec3(160.0, 0.0, -50.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 24.0
        }
    },
    ["food_tacobarbacoa"] = {
        Capacity = 280,
        Description = "Unikátní Barbacoa taco.",
        Model = "foodtacobarbacoa",
        Place = {
            Offset = vec3(0.13, 0.07, 0.02),
            Rotate = vec3(160.0, 0.0, -50.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 24.0
        }
    },
    ["food_tacocarnitas"] = {
        Capacity = 280,
        Description = "Unikátní Carnitas taco.",
        Model = "foodtacocarnitas",
        Place = {
            Offset = vec3(0.13, 0.07, 0.02),
            Rotate = vec3(160.0, 0.0, -50.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 24.0
        }
    },
    ["food_turkey"] = {
        Capacity = 220,
        Description = "Víte, že existují dementi, co to pojmenovali krocaní stehno?",
        Model = "prop_turkey_leg_01",
        Place = {
            Offset = vec3(0.14, 0.06, 0.02),
            Rotate = vec3(-14.0, 8.0, -12.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 24.0
        }
    },
    ["food_steak"] = {
        Capacity = 260,
        Description = "Buď ti způsobím orgasmus na jazyku, nebo později smrt.",
        Model = "prop_cs_steak",
        Place = {
            Offset = vec3(0.13, 0.07, 0.02),
            Rotate = vec3(160.0, 0.0, -50.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 38.0,
        Add = {
            hunger = 32.0
        }
    },
    ["food_ravennuggets"] = {
        Capacity = 520,
        Description = "Kuřata, které zažili horor v Raven Slaughterhouse.",
        Model = "foodravennuggets",
        Place = {
            Offset = vec3(0.12, 0.04, 0.01),
            Rotate = vec3(-73.0, 158.0, -2.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 39.0,
        Add = {
            hunger = 27.0
        }
    },
    ["food_cupcakeblueberry"] = {
        Capacity = 100,
        Description = "Hmmmm mňamka.",
        Model = "cupcake_blueberry",
        Place = {
            Offset = vec3(0.13, 0.03, 0.02),
            Rotate = vec3(133.0, -4.0, 25.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 20.0
        }
    },
    ["food_cupcakechoc"] = {
        Capacity = 100,
        Description = "Hmmmm mňamka.",
        Model = "cupcake_chocolate",
        Place = {
            Offset = vec3(0.13, 0.03, 0.02),
            Rotate = vec3(133.0, -4.0, 25.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 20.0
        }
    },
    ["food_cupcakestraw"] = {
        Capacity = 100,
        Description = "Hmmmm mňamka.",
        Model = "cupcake_straw",
        Place = {
            Offset = vec3(0.13, 0.03, 0.02),
            Rotate = vec3(133.0, -4.0, 25.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 20.0
        }
    },
    ["food_cupcakevanilla"] = {
        Capacity = 100,
        Description = "Hmmmm mňamka.",
        Model = "cupcake_vanilla",
        Place = {
            Offset = vec3(0.13, 0.03, 0.02),
            Rotate = vec3(133.0, -4.0, 25.0),
            Bone = 18905
        },
        Anim = "food",
        Remove = 40.0,
        Add = {
            hunger = 20.0
        }
    }
}

Config.Packs = {
    ["pizza_box"] = {
        Count = 6,
        Item = "food_pizza",
        Type = "piece"
    },
    ["pizza_box2"] = {
        Count = 6,
        Item = "food_pizza",
        Type = "piece"
    },
    ["pizza_box3"] = {
        Count = 6,
        Item = "food_pizza",
        Type = "piece"
    },
    ["beerpack_am"] = {
        Count = 6,
        Item = "beer_am",
        Type = "bottle"
    },
    ["beerpack_benedict"] = {
        Count = 12,
        Item = "beer_benedict",
        Type = "bottle"
    },
    ["beerpack_blarneysstout"] = {
        Count = 6,
        Item = "beer_stoutblarneys",
        Type = "bottle"
    },
    ["beerpack_cervezabarracho"] = {
        Count = 6,
        Item = "beer_cervezabarracho",
        Type = "bottle"
    },
    ["beerpack_duschegold"] = {
        Count = 6,
        Item = "beer_dusche",
        Type = "bottle"
    },
    ["beerpack_jakeyslager"] = {
        Count = 12,
        Item = "beer_jakeyslager",
        Type = "bottle"
    },
    ["beerpack_logger"] = {
        Count = 12,
        Item = "beer_logger",
        Type = "bottle"
    },
    ["beerpack_patriot"] = {
        Count = 12,
        Item = "beer_patriot",
        Type = "bottle"
    },
    ["beerpack_pisswasser"] = {
        Count = 12,
        Item = "beer_pisswasser",
        Type = "bottle"
    },
    ["beerpack_pridebrew"] = {
        Count = 6,
        Item = "beer_pridebrew",
        Type = "bottle"
    }
}

Config.Glass = {
    ["shot"] = {
        Label = "Panák",
        Model = "prop_cs_shot_glass",
        Max = 40,
        Place = {
            Offset = vec3(0.1, -0.12, -0.11),
            Rotate = vec3(-106.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "glass",
        Remove = 5.0
    },
    ["tall_glass"] = {
        Label = "Velká sklenička",
        Model = "prop_sh_tall_glass",
        Max = 400,
        Place = {
            Offset = vec3(0.1, -0.12, -0.11),
            Rotate = vec3(-106.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "glass",
        Remove = 100.0
    },
    ["wine_glass"] = {
        Label = "Sklenice na víno",
        Model = "prop_sh_wine_glass",
        Max = 200,
        Place = {
            Offset = vec3(0.1, -0.08, -0.08),
            Rotate = vec3(-106.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "glass",
        Remove = 50.0
    },
    ["brandy_glass"] = {
        Label = "Sklenička na brandy",
        Model = "prop_brandy_glass",
        Max = 300,
        Place = {
            Offset = vec3(0.14, -0.1, -0.13),
            Rotate = vec3(-106.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 60.0
    },
    ["cocktail_glass"] = {
        Label = "Sklenice na míchané drinky",
        Model = "prop_cocktail_glass",
        Max = 250,
        Place = {
            Offset = vec3(0.13, -0.11, -0.11),
            Rotate = vec3(-106.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 50.0
    },
    ["beer_glass"] = {
        Label = "Sklenice na pivo",
        Model = "prop_pint_glass_tall",
        Max = 500,
        Place = {
            Offset = vec3(0.12, -0.1, -0.11),
            Rotate = vec3(-106.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 100.0
    },
    ["whiskey_glass"] = {
        Label = "Sklenice na whiskey",
        Model = "prop_whiskey_01",
        Max = 300,
        Place = {
            Offset = vec3(0.14, -0.04, -0.09),
            Rotate = vec3(-108.0, -87.0, -23.0),
            Bone = 57005
        },
        Anim = "can",
        Type = "bottle",
        Remove = 60.0
    }
}

Config.Anims = {
    ["can"] = {
        Timeout = 3500,
        Base = {"amb@world_human_drinking@coffee@male@base", "base"},
        Drink = {"amb@world_human_drinking@coffee@male@idle_a", "idle_b"}
    },
    ["beer"] = {
        Timeout = 6200,
        Base = {"amb@world_human_drinking@coffee@male@base", "base"},
        Drink = {"amb@world_human_drinking@beer@male@idle_a", "idle_a"}
    },
    ["beer2"] = {
        Timeout = 3000,
        Base = {"amb@world_human_drinking_fat@beer@male@base", "base"},
        Drink = {"amb@world_human_drinking_fat@beer@male@idle_a", "idle_b"}
    },
    ["food"] = {"mp_player_inteat@burger", "mp_player_int_eat_burger", false},  
    ["food2"] = {"anim@scripted@island@special_peds@pavel@hs4_pavel_ig5_caviar_p1", "base_idle", true}
}
