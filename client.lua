local restriction = nil
local typeOverrides = {}

-----------------------------------------------------------
-- BUILD VEHICLE TYPE OVERRIDES
-- Model names are hashed once at startup
-----------------------------------------------------------

for model, vehicleType in pairs(Config.VehicleTypeOverrides or {}) do
    typeOverrides[joaat(model)] = vehicleType
end

-----------------------------------------------------------
-- NOTIFICATION
-----------------------------------------------------------

local function notify(message)

    -- Use ox_lib if available
    if GetResourceState("ox_lib") == "started" then

        local ok = pcall(function()
            exports.ox_lib:notify({
                title = "Mechanic",
                description = message,
                type = "error"
            })
        end)

        if ok then
            return
        end
    end

    -- Fallback to GTA notification
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

-----------------------------------------------------------
-- FIND CURRENT MECHANIC
-- size is the zone's diameter, so the radius is size / 2
-----------------------------------------------------------

local function getCurrentMechanic(coords)

    for mechanicId, mechanic in pairs(Config.Mechanics) do

        for _, location in ipairs(mechanic.locations or {}) do

            if #(coords - location.coords) <= (location.size / 2) then
                return mechanicId, mechanic
            end

        end

    end

    return nil, nil
end

-----------------------------------------------------------
-- GET VEHICLE
-- The vehicle the player is in, otherwise the closest one
-----------------------------------------------------------

local function getVehicle(ped, coords)

    local current = GetVehiclePedIsIn(ped, false)

    if current ~= 0 then
        return current
    end

    local closestVehicle = nil
    local closestDistance = Config.VehicleSearchDistance

    for _, vehicle in ipairs(GetGamePool("CVehicle")) do

        local distance = #(coords - GetEntityCoords(vehicle))

        if distance <= closestDistance then
            closestDistance = distance
            closestVehicle = vehicle
        end

    end

    return closestVehicle
end

-----------------------------------------------------------
-- GET VEHICLE TYPE
-----------------------------------------------------------

-- GTA vehicle classes treated as cars
-- 8 = Motorcycles, 13 = Cycles, 14 = Boats, 15 = Helicopters,
-- 16 = Planes, 21 = Trains are not cars
local carClasses = {
    [0] = true, [1] = true, [2] = true, [3] = true,
    [4] = true, [5] = true, [6] = true, [7] = true,
    [9] = true, [10] = true, [11] = true, [12] = true,
    [17] = true, [18] = true, [19] = true, [20] = true,
}

local function getVehicleType(vehicle)

    -------------------------------------------------------
    -- CONFIG OVERRIDE
    -------------------------------------------------------

    local override = typeOverrides[GetEntityModel(vehicle)]

    if override then
        return override
    end

    -------------------------------------------------------
    -- VEHICLE CLASS
    -------------------------------------------------------

    local vehicleClass = GetVehicleClass(vehicle)

    if vehicleClass == 8 then
        return "bike"
    end

    if carClasses[vehicleClass] then
        return "car"
    end

    return "other"
end

-----------------------------------------------------------
-- CHECK IF VEHICLE IS ALLOWED
-----------------------------------------------------------

local function isVehicleAllowed(mechanic, vehicleType)

    if mechanic.type == "both" then
        return vehicleType == "car" or vehicleType == "bike"
    end

    if mechanic.type == "car" or mechanic.type == "bike" then
        return vehicleType == mechanic.type
    end

    -- Unknown mechanic type
    return true
end

-----------------------------------------------------------
-- GET RESTRICTION MESSAGE
-----------------------------------------------------------

local function getRestrictionMessage(mechanic)

    return mechanic.message
        or Config.Messages[mechanic.type]
        or Config.Messages.default
end

-----------------------------------------------------------
-- MAIN RESTRICTION LOOP
-- Runs every Config.CheckInterval ms
-----------------------------------------------------------

CreateThread(function()

    while true do

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local newRestriction = nil
        local mechanicId, mechanic = getCurrentMechanic(coords)

        if mechanic then

            local vehicle = getVehicle(ped, coords)

            if vehicle and not isVehicleAllowed(mechanic, getVehicleType(vehicle)) then

                newRestriction = {
                    mechanic = mechanicId,
                    vehicle = vehicle,
                }

                ------------------------------------------------
                -- NOTIFY ONCE PER MECHANIC + VEHICLE
                ------------------------------------------------

                if not restriction
                    or restriction.mechanic ~= mechanicId
                    or restriction.vehicle ~= vehicle then

                    notify(getRestrictionMessage(mechanic))
                end

            end

        end

        restriction = newRestriction

        Wait(Config.CheckInterval)

    end

end)

-----------------------------------------------------------
-- INPUT BLOCK LOOP
-- Only runs every frame while a restriction is active
-----------------------------------------------------------

CreateThread(function()

    while true do

        if restriction then

            -- Block E / INPUT_CONTEXT
            DisableControlAction(0, 38, true)
            DisableControlAction(1, 38, true)
            DisableControlAction(2, 38, true)

            Wait(0)

        else

            Wait(Config.CheckInterval)

        end

    end

end)
