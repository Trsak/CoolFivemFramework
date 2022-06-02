Config = {}

Config.Target = {
    Models = {"prop_wheelchair_01", "prop_wheelchair_01_s"},
    Icon = "fa fa-wheelchair"
}

Config.Anim = {
    Source = {
        Bed = {
            AnimDict = "anim@heists@box_carry@",
            Anim = "idle"
        },
        Wheelchair = {
            AnimDict = "anim@heists@box_carry@",
            Anim = "idle"
        }
    },
    Target = {
        Bed = {
            AnimDict = "amb@code_human_in_car_idles@generic@ps@base",
            Anim = "base"
        },
        Wheelchair = {
            AnimDict = "missfinale_c2leadinoutfin_c_int",
            Anim = "_leadin_loop2_lester"
        }
    }
}
