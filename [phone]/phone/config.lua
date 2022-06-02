Config = Config or {}
Config.Debug = true
Config.SaveWait = 60000 * 30
Config.AutoLock = 60000 * 5
Config.RepeatTimeout = 2000
Config.Notification = 1
Config.Ringtone = 2
Config.CallRepeats = 10
Config.OpenPhone = 244

Config.BannedNames = {
    ["Twitter"] = 111,
    ["Adverts"] = 222,
    ["Email Support"] = 333,
    ["Instagram"] = 444,
    ["WhatsUp"] = 555,
    ["Admin"] = 666,
    ["server.cz"] = 777,
    ["Bank"] = 777,
}

Config.emailIDs = {
    ["Twitter"] = 111,
    ["Adverts"] = 222,
    ["Email Support"] = 333,
    ["Instagram"] = 444,
    ["Bank"] = 555,
}

Config.EmergencyServices = {
    ["medic"] = "emergency",
    ["police"] = "emergency",
    ["usms"] =  "emergency"
}

Config.PhoneApplications = {
    ["phone"] = {
        app = "phone",
        color = "#04b543",
        icon = "fa fa-phone-alt",
        tooltipText = "Phone",
        tooltipPos = "top",
        job = false,
        blockedjobs = {},
        slot = 1,
        Alerts = 0,
    },
    ["whatsapp"] = {
        app = "whatsapp",
        color = "#25d366",
        icon = "fab fa-whatsapp",
        tooltipText = "Whatsapp",
        tooltipPos = "top",
        style = "font-size: 2.8vh";
        job = false,
        blockedjobs = {},
        slot = 2,
        Alerts = 0,
    },
    ["camera"] = {
        app = "camera",
        color = "#ff7400",
        icon = "fas fa-camera",
        tooltipText = "Camera",
        tooltipPos = "top",
        job = false,
        blockedjobs = {},
        slot = 3,
        Alerts = 0,
    },
    ["settings"] = {
        app = "settings",
        color = "#636e72",
        icon = "fa fa-cog",
        tooltipText = "Settings",
        tooltipPos = "top",
        style = "padding-right: .08vh; font-size: 2.3vh";
        job = false,
        blockedjobs = {},
        slot = 4,
        Alerts = 0,
    },
    ["garage"] = {
        app = "garage",
        color = "#575fcf",
        icon = "fas fa-warehouse",
        tooltipText = "Vozidla",
        job = false,
        blockedjobs = {},
        slot = 5,
        Alerts = 0,
    },
    ["mail"] = {
        app = "mail",
        color = "#ff002f",
        icon = "fas fa-envelope",
        tooltipText = "Mail",
        job = false,
        blockedjobs = {},
        slot = 6,
        Alerts = 0,
    },
    ["twitter"] = {
        app = "twitter",
        color = "#1da1f2",
        icon = "fab fa-twitter",
        tooltipText = "Twitter",
        job = false,
        blockedjobs = {},
        slot = 7,
        Alerts = 0,
    },
    ["advert"] = {
        app = "advert",
        color = "#ff8f1a",
        icon = "fas fa-ad",
        tooltipText = "Advertisements",
        job = false,
        blockedjobs = {},
        slot = 8,
        Alerts = 0,
    },
    ["bank"] = {
        app = "bank",
        color = "#9c88ff",
        icon = "fas fa-university",
        tooltipText = "Bank",
        job = false,
        blockedjobs = {},
        slot = 9,
        Alerts = 0,
    },
    ["services"] = {
        app = "services",
        color = "#26d4ce",
        icon = "fas fa-user-tie",
        tooltipText = "Services",
        tooltipPos = "bottom",
        job = false,
        blockedjobs = {},
        slot = 10,
        Alerts = 0,
    },
    --["crypto"] = {
    --     app = "crypto",
    --     color = "#004682",
    --     icon = "fas fa-chart-pie",
    --     tooltipText = "Crypto",
    --     job = false,
    --     blockedjobs = {},
    --     slot = 11,
    --     Alerts = 0,
    --},
    --["racing"] = {
    --     app = "racing",
    --     color = "#353b48",
    --     icon = "fas fa-flag-checkered",
    --     tooltipText = "Racing",
    --     job = false,
    --     blockedjobs = {},
    --     slot = 12,
    --     Alerts = 0,
    --},
    --["houses"] = {
    --     app = "houses",
    --     color = "#27ae60",
    --     icon = "fas fa-home",
    --     tooltipText = "Houses",
    --     job = false,
    --     blockedjobs = {},
    --     slot = 13,
    --     Alerts = 0,
    --},
    --["meos"] = {
    --     app = "meos",
    --     color = "#004682",
    --     icon = "fas fa-ad",
    --     tooltipText = "MDT",
    --     job = "police",
    --     blockedjobs = {},
    --     slot = 14,
    --     Alerts = 0,
    --},
    --["store"] = {
    --     app = "store",
    --     color = "#27ae60",
    --     icon = "fas fa-cart-arrow-down",
    --     tooltipText = "App Store",
    --     tooltipPos = "right",
    --     style = "padding-right: .3vh; font-size: 2.2vh";
    --     job = false,
    --     blockedjobs = {},
    --     slot = 15,
    --     Alerts = 0,
    -- },
    --["trucker"] = {
    --      app = "trucker",
    --      color = "#cccc33",
    --      icon = "fas fa-truck-moving",
    --      tooltipText = "Dumbo",
    --      tooltipPos = "right",
    --      job = false,
    --      blockedjobs = {},
    --      slot = 16,
    --      Alerts = 0,
    --},
}

Config.StoreApps = {
    --[[    ["territory"] = {
            app = "territory",
            color = "#353b48",
            icon = "fas fa-globe-europe",
            tooltipText = "Territorium",
            tooltipPos = "right",
            style = "";
            job = false,
            blockedjobs = {},
            slot = 15,
            Alerts = 0,
            password = true,
            creator = "Qbus",
            title = "Territory",
        },]]
}


Config.Phones = {
    ["IFruit"] = {
        label = "Ifruit",
        item = "phone",
        maxApps = 10,
        maxCapacity = 7000,
        capacity = 7000,
        dualSim = false,
        wifi = false,
        internet = false,
        ip = nil,
        job = false,
        phoneModel = "prop_phone_ing",
        settings = {
            twitter = {
                account = {
                    logged = false,
                },
                notifications = {
                    ["all-notification"] = true,
                    ["mention-notification"] = true,
                    ["email-notification"] = false
                }
            },
            instagram = {
                account = {
                    logged = false,
                },
                notification = {
                    ["popup-notification"] = true,
                    ["notificated"] = false
                }
            },
            advert = {
                notifications = {
                    ["notification"] = true,
                    ["email-notification"] = false
                }
            },
            email = {
                account = {
                    logged = false,
                },
                notification = {
                    ["popup-notification"] = true,
                    ["notificated"] = false
                }
            },
            sound = {
                ['ringtone'] = "",
                ['notification'] = ""
            },
            background = "default-qbus",
            profilepicture = "default",
            lockscreen = "default",
            password = {
                type = 'none'
            }
        },
        disabledApps = {

        },
        simActive = {
            primary = {},
            secondary = {}
        }
    },
    ["BitterSweet"] = {
        label = "BitterSweet",
        item = "phone",
        maxApps = 10,
        maxCapacity = 7000,
        capacity = 7000,
        dualSim = false,
        wifi = false,
        internet = false,
        ip = nil,
        job = false,
        phoneModel = "ch_prop_ch_phone_ing_02a",
        settings = {
            twitter = {
                account = {
                    logged = false,
                },
                notifications = {
                    ["all-notification"] = true,
                    ["mention-notification"] = true,
                    ["email-notification"] = false
                }
            },
            instagram = {
                account = {
                    logged = false,
                },
                notification = {
                    ["popup-notification"] = true,
                    ["notificated"] = false
                }
            },
            advert = {
                notifications = {
                    ["notification"] = true,
                    ["email-notification"] = false
                }
            },
            email = {
                account = {
                    logged = false,
                },
                notification = {
                    ["popup-notification"] = true,
                    ["notificated"] = false
                }
            },
            sound = {
                ['ringtone'] = "",
                ['notification'] = ""
            },
            background = "default-qbus",
            profilepicture = "default",
            lockscreen = "background-1",
            password = {
                type = 'none'
            }
        },
        disabledApps = {

        },
        simActive = {
            primary = {},
            secondary = {}
        }
    },
    ["Badger"] = {
        label = "Badger",
        item = "phone",
        maxApps = 10,
        maxCapacity = 7000,
        capacity = 7000,
        dualSim = false,
        wifi = false,
        internet = false,
        ip = nil,
        job = false,
        phoneModel = "prop_police_phone",
        settings = {
            twitter = {
                account = {
                    logged = false,
                },
                notifications = {
                    ["all-notification"] = true,
                    ["mention-notification"] = true,
                    ["email-notification"] = false
                }
            },
            instagram = {
                account = {
                    logged = false,
                },
                notification = {
                    ["popup-notification"] = true,
                    ["notificated"] = false
                }
            },
            advert = {
                notifications = {
                    ["notification"] = true,
                    ["email-notification"] = false
                }
            },
            email = {
                account = {
                    logged = false,
                },
                notification = {
                    ["popup-notification"] = true,
                    ["notificated"] = false
                }
            },
            sound = {
                ['ringtone'] = "",
                ['notification'] = ""
            },
            background = "default-qbus",
            profilepicture = "default",
            lockscreen = "default",
            password = {
                type = 'none'
            }
        },
        disabledApps = {

        },
        simActive = {
            primary = {},
            secondary = {}
        }
    }

}

Config.Sim = {
    ["Pro"] = {
        label = "Pro Sim",
        item = "sim",
        simModel = "pro",
        ghostChip = true,
        fakeIP = false,
        fakeNumber = false,
        anonymousCall = false,
        job = false
    },
    ["Job"] = {
        label = "Job Sim",
        item = "sim",
        simModel = "job",
        ghostChip = false,
        fakeIP = false,
        fakeNumber = false,
        anonymousCall = false,
        job = false
    },
    ["Basic"] = {
        label = "Basic Sim",
        item = "sim",
        simModel = "basic",
        ghostChip = false,
        fakeIP = false,
        fakeNumber = false,
        anonymousCall = false,
        job = false
    }
}

Config.WifiAdapter = {
    ["Pro"] = {
        label = "",
        item = "",
        SSID = "",
        password = "",
        location = false,
        range = 20
    }
}

Config.Wifi = {
    [1] = {
        SSID = "Free Wifi",
        password = "",
        ip = "127.0.0.1",
        location = vector3(107.26, 6425.8, 33.47),
        range = 50
    }
}

Config.FakeIP = "XXX.XXX.XX.XX"


--- Racing
-- CLIENT CONFIGURATION
config_cl = {
    saveKeyBind = 38,
    closeKeyBind = 311,
    joinProximity = 25,                 -- Proximity to draw 3D text and join race
    joinKeybind = 51,                   -- Keybind to join race ("E" by default)
    joinDuration = 30000,               -- Duration in ms to allow players to join the race
    freezeDuration = 10000, --10000 = 10s              -- Duration in ms to freeze players and countdown start (set to 0 to disable)
    checkpointProximity = 25.0,         -- Proximity to trigger checkpoint in meters
    checkpointRadius = 15.0,            -- Radius of 3D checkpoints in meters (set to 0 to disable cylinder checkpoints)
    checkpointHeight = 2.0,            -- Height of 3D checkpoints in meters
    checkpointBlipColor = 5,            -- Color of checkpoint map blips and navigation (see SetBlipColour native reference)
    hudEnabled = true,                  -- Enable racing HUD with time and checkpoints
    hudPosition = vec(0.015, 0.725)     -- Screen position to draw racing HUD
}

-- SERVER CONFIGURATION
config_sv = {
    finishTimeout = 180000,             -- Timeout in ms for removing a race after winner finishes
    notifyOfWinner = true               -- Notify all players of the winner (false will only notify the winner)
}