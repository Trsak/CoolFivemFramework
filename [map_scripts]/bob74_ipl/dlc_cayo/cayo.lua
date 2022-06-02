local requestedIpl = {
    "h4_islandairstrip",
    "h4_islandairstrip_props",
    "h4_islandx_mansion",
    "h4_islandx_mansion_props",
    "h4_islandx_props",
    "h4_islandxdock",
    "h4_islandxdock_props",
    "h4_islandxdock_props_2",
    "h4_islandxtower",
    "h4_islandx_maindock",
    "h4_islandx_maindock_props",
    "h4_islandx_maindock_props_2",
    "h4_IslandX_Mansion_Vault",
    "h4_islandairstrip_propsb",
    "h4_beach",
    "h4_beach_props",
    "h4_beach_bar_props",
    "h4_islandx_barrack_props",
    "h4_islandx_checkpoint",
    "h4_islandx_checkpoint_props",
    "h4_islandx_Mansion_Office",
    "h4_islandx_Mansion_LockUp_01",
    "h4_islandx_Mansion_LockUp_02",
    "h4_islandx_Mansion_LockUp_03",
    "h4_islandairstrip_hangar_props",
    "h4_IslandX_Mansion_B",
    "h4_islandairstrip_doorsopen",
    "h4_Underwater_Gate_Closed",
    "h4_mansion_gate_closed",
    "h4_aa_guns",
    "h4_IslandX_Mansion_GuardFence",
    "h4_IslandX_Mansion_Entrance_Fence",
    "h4_IslandX_Mansion_B_Side_Fence",
    "h4_IslandX_Mansion_Lights",
    "h4_islandxcanal_props",
    "h4_beach_props_party",
    "h4_islandX_Terrain_props_06_a",
    "h4_islandX_Terrain_props_06_b",
    "h4_islandX_Terrain_props_06_c",
    "h4_islandX_Terrain_props_05_a",
    "h4_islandX_Terrain_props_05_b",
    "h4_islandX_Terrain_props_05_c",
    "h4_islandX_Terrain_props_05_d",
    "h4_islandX_Terrain_props_05_e",
    "h4_islandX_Terrain_props_05_f",
    "H4_islandx_terrain_01",
    "H4_islandx_terrain_02",
    "H4_islandx_terrain_03",
    "H4_islandx_terrain_04",
    "H4_islandx_terrain_05",
    "H4_islandx_terrain_06",
    "h4_ne_ipl_00",
    "h4_ne_ipl_01",
    "h4_ne_ipl_02",
    "h4_ne_ipl_03",
    "h4_ne_ipl_04",
    "h4_ne_ipl_05",
    "h4_ne_ipl_06",
    "h4_ne_ipl_07",
    "h4_ne_ipl_08",
    "h4_ne_ipl_09",
    "h4_nw_ipl_00",
    "h4_nw_ipl_01",
    "h4_nw_ipl_02",
    "h4_nw_ipl_03",
    "h4_nw_ipl_04",
    "h4_nw_ipl_05",
    "h4_nw_ipl_06",
    "h4_nw_ipl_07",
    "h4_nw_ipl_08",
    "h4_nw_ipl_09",
    "h4_se_ipl_00",
    "h4_se_ipl_01",
    "h4_se_ipl_02",
    "h4_se_ipl_03",
    "h4_se_ipl_04",
    "h4_se_ipl_05",
    "h4_se_ipl_06",
    "h4_se_ipl_07",
    "h4_se_ipl_08",
    "h4_se_ipl_09",
    "h4_sw_ipl_00",
    "h4_sw_ipl_01",
    "h4_sw_ipl_02",
    "h4_sw_ipl_03",
    "h4_sw_ipl_04",
    "h4_sw_ipl_05",
    "h4_sw_ipl_06",
    "h4_sw_ipl_07",
    "h4_sw_ipl_08",
    "h4_sw_ipl_09",
    "h4_islandx_mansion",
    "h4_islandxtower_veg",
    "h4_islandx_sea_mines",
    "h4_islandx",
    "h4_islandx_barrack_hatch",
    "h4_islandxdock_water_hatch",
    "h4_beach_party",
    -- Vypnuto na test
    --"h4_mph4_airstrip_interior_0_airstrip_hanger",
    -- Uncle
    "int_cayo_bung",
    "int_cayo_bung_01_milo_",
    "int_cayo_bung_02_milo_",
    "int_cayo_bung_03_milo_",
    "int_cayo_bung_04_milo_",
    "int_cayo_bung_05_milo_",
    "int_cayo_bung_06_milo_",
    "int_cayo_bung_07_milo_",
    "uj_cayo_jungle_01",
    "uj_cayo_jungle_02",
    "uj_cayo_water_01",
    "uj_cayo_light_01",
    "uj_cayo_shops",
    "int_cayo_base2_milo_",
    "int_cayo_base3_milo_",
    "int_cayo_base_milo_",
    "int_cayo_barracks_01_milo_",
    "int_cayo_barracks_02_milo_",
    "int_cayo_stock_01_milo_",
    "int_cayo_stock_02_milo_",
    "int_cayo_stock_03_milo_",
    "int_cayo_stock_04_milo_",
    "int_cayo_stock_05_milo_",
    "uj_cayo_barracs",
    "uj_cayo_med2_milo_",
    "uj_cayo_med_milo_",
    "uj_cayo_med3_milo_",
    "uj_cayo_med_build",
    "uj_ipl_cayom_pool_door"
}

CreateThread(
    function()
        for i, ipl in each(requestedIpl) do
            RequestIpl(ipl)
        end
        SetZoneEnabled(GetZoneFromNameId("PrLog"), false)
        
        local hangar = GetInteriorAtCoords(4440.551758, -4461.650391, 4.216489)
        ActivateInteriorEntitySet(hangar, "island_hanger_padlock_props")

        local int_barracks = GetInteriorAtCoordsWithType(4969.689, -5286.237, 6.293, "uj_cayo_barracks")
        ActivateInteriorEntitySet(int_barracks, "box")
        RefreshInterior(int_barracks)

        local int_stock1 = GetInteriorAtCoordsWithType(5130.676, -4611.803, -4.666, "int_stock")
        ActivateInteriorEntitySet(int_stock1, "light_stock")
        ActivateInteriorEntitySet(int_stock1, "meth_app")
        ActivateInteriorEntitySet(int_stock1, "meth_staff_01")
        ActivateInteriorEntitySet(int_stock1, "meth_staff_02")
        ActivateInteriorEntitySet(int_stock1, "meth_update_lab_01")
        ActivateInteriorEntitySet(int_stock1, "meth_update_lab_02")
        ActivateInteriorEntitySet(int_stock1, "meth_update_lab_01_2")
        ActivateInteriorEntitySet(int_stock1, "meth_update_lab_02_2")
        ActivateInteriorEntitySet(int_stock1, "meth_stock")
        RefreshInterior(int_stock1)

        local int_stock2 = GetInteriorAtCoordsWithType(5134.326, -5190.307, -4.675, "int_stock")
        ActivateInteriorEntitySet(int_stock2, "weed_app")
        ActivateInteriorEntitySet(int_stock2, "weed_staff_01")
        ActivateInteriorEntitySet(int_stock2, "weed_staff_02")
        ActivateInteriorEntitySet(int_stock2, "weed_update_lamp")
        ActivateInteriorEntitySet(int_stock2, "weed_fan_update")
        ActivateInteriorEntitySet(int_stock2, "weed_stock")
        ActivateInteriorEntitySet(int_stock2, "weed_plant_v7")
        RefreshInterior(int_stock2)

        local int_stock3 = GetInteriorAtCoordsWithType(4983.767, -5133.899, -4.474, "int_stock")
        ActivateInteriorEntitySet(int_stock3, "light_stock")
        ActivateInteriorEntitySet(int_stock3, "coke_app")
        ActivateInteriorEntitySet(int_stock3, "coke_staff_01")
        ActivateInteriorEntitySet(int_stock3, "coke_staff_02")
        ActivateInteriorEntitySet(int_stock3, "coke_stock")
        RefreshInterior(int_stock3)

        local int_stock4 = GetInteriorAtCoordsWithType(4906.630, -5279.436, -1.376, "int_stock")
        ActivateInteriorEntitySet(int_stock4, "light_stock")
        ActivateInteriorEntitySet(int_stock4, "money_app")
        ActivateInteriorEntitySet(int_stock4, "money_staff_02")
        ActivateInteriorEntitySet(int_stock4, "money_stock")
        RefreshInterior(int_stock4)

        local int_stock5 = GetInteriorAtCoordsWithType(4986.189, -5295.240, -0.818, "int_stock")
        ActivateInteriorEntitySet(int_stock5, "light_stock")
        ActivateInteriorEntitySet(int_stock5, "weapon_app")
        ActivateInteriorEntitySet(int_stock5, "weapon_staff_01")
        ActivateInteriorEntitySet(int_stock5, "weapon_stock")
        RefreshInterior(int_stock5)

        local onIsland = false
        local islandCoords = vec3(4890.302734, -4924.314454, 29.292212)
        Citizen.CreateThread(
            function()
                while true do
                    Citizen.Wait(1500)
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    if not onIsland and #(playerCoords - islandCoords) < 2000.0 then
                        onIsland = true
                        LoadGlobalWaterType(1)
                        Citizen.InvokeNative(0xF74B1FFA4A15FBEA, true)
                        Citizen.InvokeNative(0x53797676AD34A9AA, false)
                        SetScenarioGroupEnabled("Heist_Island_Peds", true)

                        SetAudioFlag("PlayerOnDLCHeist4Island", true)
                        SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", true, true)
                        SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, true)
                    elseif onIsland and #(playerCoords - islandCoords) > 2000.0 then
                        onIsland = false
                        LoadGlobalWaterType(0)
                        Citizen.InvokeNative(0xF74B1FFA4A15FBEA, false)
                        Citizen.InvokeNative(0x53797676AD34A9AA, true)
                        SetScenarioGroupEnabled("Heist_Island_Peds", false)

                        SetAudioFlag("PlayerOnDLCHeist4Island", false)
                        SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", false, false)
                        SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", true, false)
                    end
                end
            end
        )
        while true do
            SetRadarAsExteriorThisFrame()
            SetRadarAsInteriorThisFrame("h4_fake_islandx", vec(4700.0, -5145.0), 0, 0)
            Wait(0)
        end
    end
)
