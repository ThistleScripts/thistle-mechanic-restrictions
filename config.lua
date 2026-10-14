Config = {}

Config.CheckInterval = 250
Config.VehicleSearchDistance = 8.0

-----------------------------------------------------------
-- VEHICLE TYPE OVERRIDES
-- Use the vehicle's spawn name. Ignores its GTA class.
--
-- "bike"  = bike + both mechanics only (blocked at car mechanics)
-- "both"  = car, bike and both mechanics
-- "car"   = car + both mechanics only (blocked at bike mechanics)
-- "other" = blocked everywhere
-----------------------------------------------------------

Config.VehicleTypeOverrides = {
    blazer = "bike",
    blazer2 = "bike",
    blazer3 = "bike",
    blazer4 = "bike",
    blazer5 = "bike",
    dune = "bike",
    dune3 = "bike",
    outlaw = "bike",
    vagrant = "bike",
    verus = "bike",
}

-----------------------------------------------------------
-- RESTRICTION MESSAGES
-- A mechanic can also set its own message = "..."
-----------------------------------------------------------

Config.Messages = {
    car = "This mechanic only services cars.",
    bike = "This mechanic only services motorcycles.",
    default = "This mechanic cannot service this vehicle.",
}

-----------------------------------------------------------
-- MECHANICS
-- type: "car", "bike" or "both"
-- size: zone diameter in metres (radius is size / 2)
-----------------------------------------------------------

Config.Mechanics = {

    -- Blacklist Customs - CARS ONLY
    BlacklistCustoms = {
        type = "car",

        locations = {
            {
                coords = vector3(-313.543, -134.699, 39.146),
                size = 8.0,
            },
            {
                coords = vector3(-317.595, -145.224, 39.146),
                size = 8.0,
            },
            {
                coords = vector3(-321.584, -156.169, 38.572),
                size = 8.0,
            },
            {
                coords = vector3(-333.115, -132.698, 39.077),
                size = 8.0,
            },
            {
                coords = vector3(-339.494, -159.640, 38.640),
                size = 8.0,
            },
            {
                coords = vector3(-347.920, -158.201, 38.572),
                size = 8.0,
            },
            {
                coords = vector3(-721.860, -1472.700, 5.000),
                size = 8.0,
            },
        }
    },

    -- Benny's Customs - CARS ONLY
    BennysCustoms = {
        type = "car",

        locations = {
            {
                coords = vector3(-221.02, -1314.68, 31.05),
                size = 5.0,
            },
            {
                coords = vector3(-213.97, -1314.85, 31.05),
                size = 5.0,
            },
            {
                coords = vector3(-205.68, -1315.07, 31.05),
                size = 5.0,
            },
            {
                coords = vector3(-218.31, -1337.92, 31.44),
                size = 5.0,
            },
            {
                coords = vector3(-210.12, -1338.04, 31.44),
                size = 5.0,
            },
        }
    },

    -- PistonMeOff - MOTORCYCLES ONLY
    PistonMeOff = {
        type = "bike",

        locations = {
            {
                coords = vector3(866.41, -2416.85, 26.84),
                size = 4.0,
            },
            {
                coords = vector3(866.78, -2408.47, 26.68),
                size = 4.0,
            },
            {
                coords = vector3(867.13, -2399.28, 26.67),
                size = 4.0,
            },
        }
    },

    -- Local Mechanic - CARS + MOTORCYCLES
    LocalMechanic = {
        type = "both",

        locations = {
            {
                coords = vector3(1175.067, 2640.411, 37.754),
                size = 5.0,
            },
        }
    },

    -- Police - CARS + MOTORCYCLES
    Police = {
        type = "both",

        locations = {
            {
                coords = vector3(410.87, -954.60, 21.04),
                size = 5.0,
            },
        }
    }
}