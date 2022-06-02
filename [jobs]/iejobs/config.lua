Config = {}
Config.MinJobs = 5
Config.MaxJobs = 10
Config.MinuteInMsec = 60000 --msec
Config.RefreshTime = 460 -- minuty
Config.setup_scriptHandlerName = 'iejobs'

Config.Menu = {
    Airseal = {
        Job = 'airseal',
        JobTypes = { 'plane', 'helicopter' },
        Coords = { x = -930.73 , y = -2957.55, z = 13.95, Size = 1 },
        Type   = {'export'},
        Text   = '~s~Zmáčkni ~b~[E]~s~ pro otevření nabídky~s~'
    },
--[[    Debug = {
        Job = 'airseal',
        JobTypes = { 'plane', 'helicopter' },
        Coords = { x = -921.71 , y = -2950.05, z = 13.95, Size = 1 },
        Type   = {'export', 'import'},
        Text   = '~s~Zmáčkni ~b~[E]~s~ pro otevření nabídky~s~'
    }]]
}

Config.OtherTexts = {
    Warehouseman = '~s~Zajdi ke ~b~[skladníkovi]~s~ pro zabalení nákladu~s~',
    Warehouseman2 = '~s~Zmáčkni ~b~[E]~s~ pro zabalení nákladu~s~',
    Warehouseman3 = '~s~Zajdi ke ~b~[klientovi]~s~ pro odevzdání nákladu~s~',
    Warehouseman4 = '~s~Zmáčkni ~b~[E]~s~ pro odevzdání balíčku~s~',
    Warehouseman5 = '~s~Zmáčkni ~b~[E]~s~ pro sebrání krabice ~r~(%s ks)~s~',
    Seller = '~s~Zmáčkni ~b~[E]~s~ pro vyložení krabice ~r~(%s ks)~s~',
    Seller2 = '~s~Zmáčkni ~b~[E]~s~ pro odevzdání krabice ~r~(%s ks)~s~',
    Seller3 = '~s~Zbyva ti vyložit ~b~[%s ks]~s~ krabic u klienta',
    Veh = '~s~Zmáčkni ~b~[E]~s~ pro naložení krabice ~r~(%s ks)~s~',
    Veh2 = '~s~Zbyva ti naložit ~b~[%s ks]~s~ krabic do %s ~s~',
    Veh3 = '~s~Zajdi k firemnímu ~b~[%s]~s~ pro naložení nákladu~s~',
    inVeh = '~s~Nasedni do ~b~[firemního]~s~ vozidla pro odvoz nákladu~s~',
    bckInVeh = '~s~Vrať se zpět do ~r~[firemního]~s~ vozidla pro odvoz nákladu~s~',
    routeBack = '~s~Vrať se zpět do ~r~[firmy]~s~ pro vyzvednutí odměny!~s~',

    nEmployee = 'Nejsi zaměstnancem %s',
    nAuthorized = 'Tohle vozidlo není autorizované!',
    nAlreadyCarry = 'Už neseš krabici!',
    nFindVeh = 'Najdi své firemní letadlo/vrtulník a nalož do něj krabice!',
    nSeller = 'Vyložil si krabici u klienta!',
    nSellerSuccess = 'Vyložil si celý náklad!',
    nUpdateW = 'Aktualizace tabulek u %s, prosím zachvíli zkuste znovu!',
    nJobTake = 'Vzal si práci pro %s, jdi něco!',
    nAlreadyInJob = 'Už jednu práci máš u %s!',
    nJobtaken = 'Tahle práce u %s je už zabraná!',
    nJobPayed = 'Peníze ti byly vyplaceny na účet! ( %s $ )',
    nCancelJob = 'Zrušil si práci!',
    nCheater = 'Ojebavat chceš jo?'


}

Config.Type = {
    [1] = 'Alkohol',
    [2] = 'Tools',
    [3] = 'Others'
}

Config.List = {
    [1] = {
        [1] = { --{ 'itemname', 'itemlabel', count, price }
            [1] = { 'absint', 'BM Absint 1l', math.random(50, 100), 40 } ,
            [2] = { 'amundsen', 'BM Amundsen 1l', math.random(50, 1000), 30 },
            [3] = { 'cervenevino', 'BC Červené víno', math.random(50, 1000), 220 },
            [4] = { 'bilevino', '	BC Bílé Víno', math.random(50, 1000), 220 },
            [5] = { 'burbon', 'BM Burbon 1l', math.random(50, 1000), 30 },
            [6] = { 'gin', 'BM Gin 1l', math.random(50, 1000), 30 },
            [7] = { 'jackdaniels', 'BM JackDaniels 1l', math.random(50, 1000), 35 },
            [8] = { 'jagermeister', 'BM Jägermeister 1l', math.random(50, 1000), 20 },
            [9] = { 'tequila', 'BM Tequila 1l', math.random(50, 1000), 35 },
            [10] = { 'zacapa', 'BM Zacapa 1l', math.random(50, 1000), 25 },
            [11] = { 'beer', 'Pivo', math.random(50, 1000), 60 }
        },

        [2] = {
            [1] = { 'barel', 'Dřevenej sud', math.random(50, 100), 910 },
            [2] = { 'bilahev', 'Prázdná láhev', math.random(50, 200), 22 },
            [3] = { 'folie', 'Folie', math.random(50, 100), 30 },
            [4] = { 'nuz', 'Zahradnický nůž', math.random(50, 100), 40 },
            [5] = { 'shovel', 'Zahradnická lopata', math.random(50, 100), 94 },
            [6] = { 'kelimek', 'Prázdný kelímek', math.random(50, 100), 25 },
            [7] = { 'wash', 'Mycí houba', math.random(50, 100), 45 },
            [8] = { 'glass', 'Sklo', math.random(50, 100), 15 },
            [9] = { 'hrnec', 'Hrnec', math.random(50, 100), 45 },
            [10] = { 'susicka', 'Sušička', math.random(50, 100), 45 },
            [11] = { 'kos', 'Dřevěný košíček', math.random(50, 100), 52 },
            [12] = { 'plast', 'Plast', math.random(50, 300), 9 }
        },

        [3] = {
            [1] = { 'espresso', 'Bean Machine Espresso', math.random(50, 100), 35 },
            [2] = { 'cernakava', 'Bean Machine Černá Káva', math.random(50, 100), 35},
            [3] = { 'box_cigaret', 'Marlboro', math.random(50, 100), 92 },
            [4] = { 'leather', 'Zvířecí látka', math.random(50, 100), 10 }
        }
    },
    [2] = {
        [1] = {
            [1] = { 'absint', 'BM Absint 1l', math.random(50, 1000), 40 } ,
            [2] = { 'amundsen', 'BM Amundsen 1l', math.random(50, 1000), 30 },
            [3] = { 'cervenevino', 'BC Červené víno', math.random(50, 1000), 220 },
            [4] = { 'bilevino', '	BC Bílé Víno', math.random(50, 1000), 220 },
            [5] = { 'burbon', 'BM Burbon 1l', math.random(50, 1000), 30 },
            [6] = { 'burbon', 'BM Burbon 1l', math.random(50, 1000), 30 },
            [7] = { 'gin', 'BM Gin 1l', math.random(50, 1000), 30 },
            [8] = { 'jackdaniels', 'BM JackDaniels 1l', math.random(50, 1000), 35 },
            [9] = { 'jagermeister', 'BM Jägermeister 1l', math.random(50, 1000), 20 },
            [10] = { 'tequila', 'BM Tequila 1l', math.random(50, 1000), 35 },
            [11] = { 'zacapa', 'BM Zacapa 1l', math.random(50, 1000), 25 },
            [12] = { 'beer', 'Pivo', math.random(50, 1000), 60 }
        },

        [2] = {
            [1] = { 'barel', 'Dřevenej sud', math.random(50, 100), 910 },
            [2] = { 'bilahev', 'Prázdná láhev', math.random(50, 200), 22 },
            [3] = { 'folie', 'Folie', math.random(50, 100), 30 },
            [4] = { 'nuz', 'Zahradnický nůž', math.random(50, 100), 40 },
            [5] = { 'shovel', 'Zahradnická lopata', math.random(50, 100), 94 },
            [6] = { 'kelimek', 'Prázdný kelímek', math.random(50, 100), 25 },
            [7] = { 'wash', 'Mycí houba', math.random(50, 100), 45 },
            [8] = { 'glass', 'Sklo', math.random(50, 100), 15 },
            [9] = { 'hrnec', 'Hrnec', math.random(50, 100), 45 },
            [10] = { 'susicka', 'Sušička', math.random(50, 100), 45 },
            [11] = { 'kos', 'Dřevěný košíček', math.random(50, 100), 52 },
            [12] = { 'plast', 'Plast', math.random(50, 300), 9 }
        },

        [3] = {
            [1] = { 'espresso', 'Bean Machine Espresso', math.random(50, 100), 35 },
            [2] = { 'cernakava', 'Bean Machine Černá Káva', math.random(50, 100), 35},
            [3] = { 'box_cigaret', 'Marlboro', math.random(50, 100), 92 },
            [4] = { 'leather', 'Zvířecí látka', math.random(50, 100), 10 }
        }
    }
}

Config.AuthorizedVehicles = {
    ['plane'] = {
        [1] = 'cuban800',
    },
    ['helicopter'] = {
        [1] = 'frogger',
    }
}


Config.CheckPoints = {
    ['helicopter'] = {
        [1] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -2621.00 , y = -749.00, z = 112.00 },
                [2] = { x = -3266.00 , y = 2118.00, z = 250.00 },
                [3] = { x = -2116.00 , y = 2410.00, z = 250.00 },
                [4] = { x = -1487.00 , y = 2885.00, z = 250.00 },
                [5] = { x = -1889.00 , y = 3493.00, z = 200.00 },
                [6] = { x = -2124.00 , y = 4567.00, z = 150.00 },
                [7] = { x = -1455.00 , y = 6149.00, z = 80.00 },
                [8] = { x = -1320.00 , y = 6592.00, z = 40.00 },
                [9] = { x = -1388.41 , y = 6742.49, z = 11.70 },
            },
            ['SellPoint'] = { x = -1403.37 , y = 6751.28, z = 11.91 } --yacht paletobay
        },
        [2] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -1749.85 , y = -1800.27, z = 120.00 },
                [2] = { x = -1559.49 , y = -1191.07, z = 168.00 },
                [3] = { x = -1581.86 , y = -569.37, z = 116.33 }, --heliport
            },
            ['SellPoint'] = { x = -1561.06 , y = -568.79, z = 114.45 } --bahamatower_Boulevard Del Perro
        },
        [3] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -1749.85 , y = -1800.27, z = 120.00 },
                [2] = { x = -1100.44 , y = -1253.15, z = 225.00 },
                [3] = { x = -531.68 , y = -773.98, z = 350.00 },
                [4] = { x = 67.64 , y = -770.42, z = 350.00 }, --finaleMBT
                [5] = { x = -74.95 , y = -819.61, z = 326.18 }, --heliport
            },
            ['SellPoint'] = { x = -66.95 , y = -822.03, z = 321.29 } --MazeBankTowerDoors
        },
        [4] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -1749.85 , y = -1800.27, z = 120.00 },
                [2] = { x = -1100.44 , y = -1253.15, z = 225.00 },
                [3] = { x = -531.68 , y = -773.98, z = 250.00},
                [4] = { x = -168.81 , y = -552.92, z = 221.28 }, --finaleAT
                [5] = { x = -144.82 , y = -593.64, z = 211.78 }, -- heliport
            },
            ['SellPoint'] = { x = -136.52 , y = -596.46, z = 206.92 } --ArcadiumTowerDoor
        },
        [5] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -1749.85 , y = -1800.27, z = 120.00 },
                [2] = { x = -1214.36 , y = -579.07, z = 190.93 },
                [3] = { x = -1084.79 , y = -223.53, z = 160.00 },
                [4] = { x = -955.18, y = -301.84, z = 158.93 }, --finaleRM
                [5] = { x = -913.68 , y = -378.11, z = 137.91 }, --heliport
            },
            ['SellPoint'] = { x = -902.74 , y = -369.62, z = 136.28 } --RichardMajesticTowerDoor
        },
        [6] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -2114.66 , y = -2361.95, z = 140.00 },
                [2] = { x = -1596.85 , y = -1841.61, z = 230.00 },
                [3] = { x = -567.94, y = -1821.33, z = 230.00 }, --krizenidrahy21_LSIA
                [4] = { x = 764.12, y = -1565.61, z = 230.00 },
                [5] = { x = 2397.96, y = -942.59, z = 230.00 },
                [6] = { x = 2594.21, y = -443.24, z = 159.45 }, --finaleGoose
                [7] = { x = 2510.55 , y = -342, z = 118.09 }, -- heliport
            },
            ['SellPoint'] = { x = 2507.39 , y = -336.72, z = 115.81 } --GooseDoors
        },
        [7] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -2114.66 , y = -2361.95, z = 140.00 },
                [2] = { x = -1596.85 , y = -1841.61, z = 230.00 },
                [3] = { x = -567.94, y = -1821.33, z = 230.00 }, --krizenidrahy21_LSIA
                [4] = { x = 764.12, y = -1565.61, z = 180.00 },
                [5] = { x = 1030.72, y = -1563.84, z = 102.00 },
                [6] = { x = 1000.60, y = -1652.84, z = 72.00 }, --finalefrosty
                [7] = { x = 910.21 , y = -1681.22, z = 51.13 }, -- heliport
            },
            ['SellPoint'] = { x = 915.73 , y = -1699.28, z = 51.13 } --FrostyDoors
        },
        [8] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -1749.85 , y = -1800.27, z = 120.00 },
                [2] = { x = -1559.49 , y = -1191.07, z = 168.00 },
                [3] = { x = -1991.83 , y = -459.51, z = 230.00 },
                [4] = { x = -2261.77 , y = 163.96, z = 220.00 },
                [5] = { x = -2303.22 , y = 261.25, z = 194.61 }, --heliport
            },
            ['SellPoint'] = { x = -2307.51 , y = 269.77, z = 184.61 } --MoseleyBuildingDoor
        },
        [9] = { --heli
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -2055.67 , y = -1932.68, z = 120.00 },
                [2] = { x = -2006.03 , y = -1408.06, z = 80.00 },
                [3] = { x = -1916.92 , y = -1143.14, z = 40.00 },
                [4] = { x = -2014.51 , y = -1042.87, z = 21.67 }, --finaleyachtavespucci
                [5] = { x = -2043.91 , y = -1031.44, z = 11.88 }, --heliport
            },
            ['SellPoint'] = { x = -2058.11 , y = -1023.27, z = 11.91 } --bar_u_heliportuYachta
        },
    },
    ['plane'] = {
        [1] = { --plane cuban 800
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -2057.00 , y = -2015.00, z = 126.00 },
                [2] = { x = -1615.00 , y = -1412.00, z = 200.00 },
                [3] = { x = -1423.00 , y = -1158.00, z = 250.00 },
                [4] = { x = -639.00 , y = -272.00, z = 250.00 },
                [5] = { x = -508.00 , y = -18.00, z = 300.00 },
                [6] = { x = 593.00 , y = 734.00, z = 400.00 },
                [7] = { x = 1922.00 , y = 2370.00, z = 240.00 },
                [8] = { x = 2648.00 , y = 3392.00, z = 180.00 },
                [9] = { x = 2022.00 , y = 3322.00, z = 98.00 },
                [10] = { x = 1560.00 , y = 3211.00, z = 41.00 },
                [11] = { x = 1074.00 , y = 3080.00, z = 41.00 },
                [12] = { x = 1508.00 , y = 3130.00, z = 41.00 },
            },
            ['SellPoint'] = { x = 1739.00 , y = 3281.00, z = 41.00 } --SSA hangar
        },
        [2] = { --plane cuban 800
            ['GetPoint'] = { x = -919.02 , y = -2946.25, z = 13.95 }, -- nesahat
            ['CheckPoints'] = {
                [1] = { x = -2621.00 , y = -749.00, z = 112.00 },
                [2] = { x = -3116.00 , y = 1571.00, z = 250.00 },
                [3] = { x = -2116.00 , y = 2410.00, z = 250.00 },
                [4] = { x = -1038.07 , y = 2637.17, z = 250.00 },
                [5] = { x = -62.12 , y = 3299.70, z = 250.00 },
                [6] = { x = 374.26 , y = 3938.96, z = 250.00 }, --finale GSX
                [7] = { x = 1101.00 , y = 4312.84, z = 158.00 },
                [8] = { x = 1673.15 , y = 4589.12, z = 75.00 },
                [9] = { x = 2030.24 , y = 4759.16, z = 41.00 },
            },
            ['SellPoint'] = { x = 2145.86 , y = 4781.98, z = 40.99 } --GSX dverehangar
        },
    }
}