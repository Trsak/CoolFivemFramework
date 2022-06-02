Config = {}
Config.RentDuration = 1209600 -- 2 weeks
Config.AbleToKickDoors = {
    police = true
}

Config.DefaultPermissions = {
    manage = false,
    storage = true,
    vault = true,
    cloakroom = true,
    fridge = true,
    mates = false
}

Config.Appendices = {
    Permissions = {
        manage = "Přístup do správy",
        storage = "Přístup do skladu",
        vault = "Přístup do trezoru",
        cloakroom = "Přístup do šaten",
        fridge = "Přístup do lednice",
        mates = "Přístup do správy spolubydlících"
    },
    Places = {
        Labels = {
            storage = {
                "Sklad"
            },
            fridge = {
                "Lednice"
            },
            cloakroom = {
                "Šatna"
            },
            vault = {
                "Trezor"
            },
            exit = {
                "Odejít",
                "Správa"
            },
            manage = {
                "Správa"
            },
            ring = {
                "Zvonek"
            },
            mates = {
                "Spolubydlící"
            },
            charselect = {
                "Spát"
            }
        },
        Icons = {
            storage = {
                "fas fa-archive"
            },
            fridge = {
                "fas fa-utensils"
            },
            cloakroom = {
                "fas fa-tshirt"
            },
            charselect = {
                "fas fa-users"
            },
            exit = {
                "fas fa-door-open",
                "fas fa-cogs"
            },
            manage = {
                "fas fa-cogs"
            },
            vault = {
                "Trezor"
            },
            ring = {
                "fas fa-bell"
            },
            mates = {
                "fas fa-users"
            }
        },
        Visit = {}
    }
}

Config.DefaultSettings = {
    motel = {
        Instance = true,
        Exit = {
            Coords = vec3(151.34, -1007.68, -98.99)
        },
        CharSelect = {
            Coords = vec3(154.37, -1004.64, -99.09)
        },
        storage = {
            Coords = vec3(151.28, -1003.08, -99.00),
            weight = 620,
            slots = 30
        },
        Cloakroom = {
            Coords = vec3(151.94, -1001.47, -99.00)
        },
        Prices = {
            buy = 10000,
            rent = 500
        },
        AdminName = "Byt č.1"
    },
    pinkcage = {
        Instance = true,
        Exit = {
            Coords = vec3(347.529480, -200.012954, 33.609760)
        },
        CharSelect = {
            Coords = vec3(346.279510, -207.161332, 33.596756)
        },
        storage = {
            Coords = vec3(347.471894, -204.409790, 33.596672),
            weight = 620,
            slots = 30
        },
        fridge = {
            Coords = vec3(348.965088, -206.554000, 33.596676),
            weight = 10,
            slots = 4
        },
        Cloakroom = {
            Coords = vec3(351.501832, -205.612092, 33.596672)
        },
        Prices = {
            buy = 10000,
            rent = 500
        },
        AdminName = "Byt č.3"
    },
    lowtier = {
        Instance = true,
        Exit = {
            Coords = vec3(265.189544, -1001.227784, -99.008590)
        },
        CharSelect = {
            Coords = vec3(262.744110, -1004.174072, -99.053704)
        },
        storage = {
            Coords = vec3(265.8916, -999.423, -99.00856),
            weight = 620,
            slots = 30
        },
        fridge = {
            Coords = vec3(265.707916, -997.635376, -99.008690),
            MaxWeight = 50,
            MaxSlots = 40
        },
        Cloakroom = {
            Coords = vec3(259.73, -1003.96, -99.00)
        },
        Prices = {
            buy = 18000,
            rent = 600
        },
        AdminName = "Byt č.2"
    },
    midtier = {
        Instance = true,
        Exit = {
            Coords = vec3(346.752106, -1002.687072, -99.196258)
        },
        CharSelect = {
            Coords = vec3(349.355468, -996.345642, -99.176910)
        },
        storage = {
            Coords = vec3(351.98, -998.81, -99.00856),
            weight = 620,
            slots = 30
        },
        fridge = {
            Coords = vec3(344.088378, -1001.237488, -99.184372),
            MaxWeight = 50,
            MaxSlots = 40
        },
        Cloakroom = {
            Coords = vec3(351.30, -993.49, -99.19)
        },
        Prices = {
            buy = 22500,
            rent = 750
        },
        AdminName = "Byt č.4"
    },
    legionport = {
        Instance = true,
        Exit = {
            Coords = vec3(292.833100, -928.190612, 46.786930)
        },
        CharSelect = {
            Coords = vec3(294.087860, -921.059266, 46.786938)
        },
        storage = {
            Coords = vec3(290.392272, -927.755676, 46.786934),
            MaxWeight = 700,
            MaxSlots = 70
        },
        fridge = {
            Coords = vec3(292.714600, -924.830444, 46.786934),
            MaxWeight = 50,
            MaxSlots = 8
        },
        Cloakroom = {
            Coords = vec3(292.450104, -919.851868, 46.786938)
        },
        Prices = {
            buy = 22500,
            rent = 750
        },
        AdminName = "Legion Square na PORT"
    },
    mirror1 = {
        Instance = true,
        Exit = {
            Coords = vec3(978.515442, -716.715576, 28.869874)
        },
        CharSelect = {
            Coords = vec3(984.372924, -722.043152, 28.620550)
        },
        storage = {
            Coords = vec3(971.813110, -722.394714, 28.709092),
            MaxWeight = 700,
            MaxSlots = 70
        },
        fridge = {
            Coords = vec3(978.241394, -724.953980, 28.668952),
            MaxWeight = 100,
            MaxSlots = 16
        },
        Cloakroom = {
            Coords = vec3(987.023376, -720.947692, 28.669334)
        },
        Prices = {
            buy = 22500,
            rent = 750
        },
        AdminName = "Jednopatrový Mirror Park dům"
    },
    oats = {
        Instance = false,
        Exit = {
            Coords = vec3(-174.22, 497.84, 137.65)
        },
        CharSelect = {
            Coords = vec3(-163.620117, 483.604736, 133.843842)
        },
        storage = {
            Coords = vec3(-173.84, 493.93, 130.04),
            weight = 1200,
            slots = 110
        },
        fridge = {
            Coords = vec3(-170.374146, 496.118591, 137.653748),
            MaxWeight = 50,
            MaxSlots = 8
        },
        Cloakroom = {
            Coords = vec3(-167.68, 487.83, 133.84)
        },
        Prices = {
            buy = 216000,
            rent = 3500
        }
    },
    conker1 = {
        Instance = false,
        Exit = {
            Coords = vec3(342.1342, 437.992, 149.3808)
        },
        CharSelect = {
            Coords = vec3(331.147430, 423.275177, 145.542389)
        },
        storage = {
            Coords = vec3(338.5164, 436.5684, 141.7708),
            weight = 1200,
            slots = 110
        },
        fridge = {
            Coords = vec3(341.632538, 433.331879, 149.380859),
            MaxWeight = 50,
            MaxSlots = 8
        },
        Cloakroom = {
            Coords = vec3(334.0582, 428.6944, 145.5708)
        },
        Prices = {
            buy = 216000,
            rent = 3500
        }
    },
    conker2 = {
        Instance = false,
        Exit = {
            Coords = vec3(373.7632, 423.8332, 145.9078)
        },
        CharSelect = {
            Coords = vec3(376.168854, 405.995789, 142.152222)
        },
        storage = {
            Coords = vec3(376.8116, 429.0906, 138.3002),
            weight = 1200,
            slots = 110
        },
        fridge = {
            Coords = vec3(375.138611, 420.357971, 145.900269),
            MaxWeight = 50,
            MaxSlots = 8
        },
        Cloakroom = {
            Coords = vec3(374.2236, 411.7872, 142.1002)
        },
        Prices = {
            buy = 216000,
            rent = 3500
        }
    },
    hillcrest1 = {
        Instance = false,
        Exit = {
            Coords = vec3(-682.2712, 592.8396, 145.3798)
        },
        CharSelect = {
            Coords = vec3(-666.193726, 585.466431, 141.593628)
        },
        storage = {
            Coords = vec3(-680.5378, 589.2164, 137.7698),
            weight = 1200,
            slots = 110
        },
        fridge = {
            Coords = vec3(-678.222534, 593.039124, 145.379807),
            MaxWeight = 50,
            MaxSlots = 8
        },
        Cloakroom = {
            Coords = vec3(-671.7878, 587.1118, 141.57)
        },
        Prices = {
            buy = 216000,
            rent = 3500
        }
    },
    hillcrest2 = {
        Instance = false,
        Exit = {
            Coords = vec3(-758.184, 619.134, 144.1406)
        },
        CharSelect = {
            Coords = vec3(-771.049500, 606.741638, 140.354767)
        },
        storage = {
            Coords = vec3(-762.123, 618.256, 136.5306),
            weight = 1200,
            slots = 110
        },
        fridge = {
            Coords = vec3(-759.429749, 614.833740, 144.140488),
            MaxWeight = 50,
            MaxSlots = 8
        },
        Cloakroom = {
            Coords = vec3(-767.0464, 610.8656, 140.3308)
        },
        Prices = {
            buy = 216000,
            rent = 3500
        }
    },
    hillcrest3 = {
        Instance = false,
        Exit = {
            Coords = vec3(-860.1132, 691.3982, 152.8608)
        },
        CharSelect = {
            Coords = vec3(-851.902344, 675.303223, 148.966782)
        },
        storage = {
            Coords = vec3(-858.7766, 697.2562, 145.253),
            weight = 1200,
            slots = 110
        },
        fridge = {
            Coords = vec3(-857.408691, 688.551270, 152.853180),
            MaxWeight = 50,
            MaxSlots = 8
        },
        Cloakroom = {
            Coords = vec3(-855.6448, 680.1558, 149.0532)
        },
        Prices = {
            buy = 216000,
            rent = 3500
        }
    },
    whispymound = {
        Instance = false,
        Exit = {
            Coords = vec3(116.9526, 560.0546, 184.3048)
        },
        CharSelect = {
            Coords = vec3(125.817207, 544.003357, 180.493088)
        },
        storage = {
            Coords = vec3(118.476, 566.1044, 176.6972),
            weight = 1200,
            slots = 110
        },
        fridge = {
            Coords = vec3(119.875420, 557.169373, 184.297272),
            MaxWeight = 50,
            MaxSlots = 8
        },
        Cloakroom = {
            Coords = vec3(121.819, 548.7626, 180.4972)
        },
        Prices = {
            buy = 216000,
            rent = 3500
        }
    },
    storage1 = {
        Instance = true,
        Exit = {
            Coords = vec3(1087.427124, -3099.497070, -38.999969)
        },
        storage = {
            Coords = vec3(1097.773071, -3098.335693, -38.999969),
            MaxWeight = 1000,
            MaxSlots = 100
        },
        Prices = {
            buy = 18000,
            rent = 600
        }
    },
    storage2 = {
        Instance = true,
        Exit = {
            Coords = vec3(1048.121216, -3097.207275, -38.999966)
        },
        storage = {
            Coords = vec3(1053.299805, -3101.216064, -38.999966),
            MaxWeight = 2000,
            MaxSlots = 200
        },
        Prices = {
            buy = 18000,
            rent = 600
        }
    },
    storage3 = {
        Instance = true,
        Exit = {
            Coords = vec3(992.361206, -3097.615723, -38.995884)
        },
        storage = {
            Coords = vec3(1003.705261, -3102.295166, -38.999851),
            MaxWeight = 4000,
            MaxSlots = 400
        },
        cloakroom = {
            Coords = vec3(995.054932, -3096.318360, -38.995864)
        },
        Prices = {
            buy = 18000,
            rent = 600
        }
    },
    lowoffice = {
        Instance = true,
        Exit = {
            Coords = vec3(1173.76, -3196.53, -39.00)
        },
        storage = {
            Coords = vec3(1161.373779, -3190.885254, -39.007988),
            MaxWeight = 200,
            MaxSlots = 30
        },
        Cloakroom = {
            Coords = vec3(1169.648926, -3193.677246, -39.007988)
        },
        Prices = {
            buy = 18000,
            rent = 600
        }
    },
    yakuza = {
        Instance = true,
        Exit = {
            Coords = vec4(-999.19604492188, 1325.0668945312, 199.28411865234, 270.91717529296)
        },
        storage = {
            Coords = vec3(-993.119934, 1336.044312, 199.246110),
            MaxWeight = 200,
            MaxSlots = 30
        },
        fridge = {
            Coords = vec3(-996.962342, 1341.984130, 199.439896),
            MaxWeight = 100,
            MaxSlots = 20
        },
        Cloakroom = {
            Coords = vec3(-992.283752, 1323.922852, 199.246200)
        },
        Prices = {
            buy = 18000,
            rent = 600
        }
    }
}
