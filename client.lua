local notificationShown = false
local currentRestriction = nil

-----------------------------------------------------------
-- NOTIFICATION
-----------------------------------------------------------

local function notify(message)

    -- Use ox_lib if available
    if GetResourceState("ox_lib") == "started" then
        exports.ox_lib:notify({
            title = "Mechanic",
            description = message,
            type = "error"
        })

        return
    end

    -- Fallback to GTA notification
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

-----------------------------------------------------------
-- CHECK IF PLAYER IS INSIDE MECHANIC LOCATION
-----------------------------------------------------------

local function isInsideLocation(coords, location)

    local distance = #(coords - location.coords)

    return distance <= (location.size / 2)
end

-----------------------------------------------------------
-- FIND CURRENT MECHANIC
-----------------------------------------------------------

local function getCurrentMechanic()

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for mechanicId, mechanic in pairs(Config.Mechanics) do

        if mechanic.locations then

            for _, location in ipairs(mechanic.locations) do

                if isInsideLocation(coords, location) then
                    return mechanicId, mechanic
                end

            end

        end

    end

    return nil, nil
end

-----------------------------------------------------------
-- GET VEHICLES NEAR PLAYER
-----------------------------------------------------------

local function getVehiclesNearby()

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)

    local vehicles = {}

    -------------------------------------------------------
    -- VEHICLE PLAYER IS CURRENTLY IN
    -------------------------------------------------------

    if IsPedInAnyVehicle(ped, false) then

        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            vehicles[#vehicles + 1] = vehicle
        end

        return vehicles
    end

    -------------------------------------------------------
    -- FIND NEARBY VEHICLES
    -------------------------------------------------------

    local handle, vehicle = FindFirstVehicle()

    if handle == -1 then
        return vehicles
    end

    local success = true

    while success do

        if vehicle ~= 0 and DoesEntityExist(vehicle) then

            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(playerCoords - vehicleCoords)

            if distance <= Config.VehicleSearchDistance then
                vehicles[#vehicles + 1] = vehicle
            end

        end

        success, vehicle = FindNextVehicle(handle)

    end

    EndFindVehicle(handle)

    return vehicles
end

-----------------------------------------------------------
-- GET CLOSEST VEHICLE
-----------------------------------------------------------

local function getNearbyVehicle()

    local vehicles = getVehiclesNearby()

    if #vehicles == 0 then
        return nil
    end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)

    local closestVehicle = nil
    local closestDistance = math.huge

    for _, vehicle in ipairs(vehicles) do

        if DoesEntityExist(vehicle) then

            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(playerCoords - vehicleCoords)

            if distance < closestDistance then

                closestDistance = distance
                closestVehicle = vehicle

            end

        end

    end

    return closestVehicle
end

-----------------------------------------------------------
-- GET VEHICLE TYPE
-----------------------------------------------------------

local function getVehicleType(vehicle)

    if not vehicle or vehicle == 0 then
        return "other"
    end

    if not DoesEntityExist(vehicle) then
        return "other"
    end

    local vehicleClass = GetVehicleClass(vehicle)

    -------------------------------------------------------
    -- MOTORCYCLES
    -- GTA VEHICLE CLASS 8
    -------------------------------------------------------

    if vehicleClass == 8 then
        return "bike"
    end

    -------------------------------------------------------
    -- BICYCLES
    -- GTA VEHICLE CLASS 13
    -------------------------------------------------------

    if vehicleClass == 13 then
        return "other"
    end

    -------------------------------------------------------
    -- CARS / ROAD VEHICLES
    -------------------------------------------------------

    if vehicleClass == 0
        or vehicleClass == 1
        or vehicleClass == 2
        or vehicleClass == 3
        or vehicleClass == 4
        or vehicleClass == 5
        or vehicleClass == 6
        or vehicleClass == 7
        or vehicleClass == 9
        or vehicleClass == 10
        or vehicleClass == 11
        or vehicleClass == 12
        or vehicleClass == 17
        or vehicleClass == 18
        or vehicleClass == 19
        or vehicleClass == 20 then

        return "car"
    end

    return "other"
end

-----------------------------------------------------------
-- CHECK IF VEHICLE IS ALLOWED
-----------------------------------------------------------

local function isVehicleAllowed(mechanic, vehicle)

    if not mechanic then
        return true
    end

    if not vehicle then
        return true
    end

    local vehicleType = getVehicleType(vehicle)

    -------------------------------------------------------
    -- BOTH
    -- Allows CARS + MOTORCYCLES
    -------------------------------------------------------

    if mechanic.type == "both" then

        if vehicleType == "car" or vehicleType == "bike" then
            return true
        end

        return false
    end

    -------------------------------------------------------
    -- CAR ONLY
    -------------------------------------------------------

    if mechanic.type == "car" then

        return vehicleType == "car"
    end

    -------------------------------------------------------
    -- MOTORCYCLE ONLY
    -------------------------------------------------------

    if mechanic.type == "bike" then

        return vehicleType == "bike"
    end

    -------------------------------------------------------
    -- UNKNOWN TYPE
    -------------------------------------------------------

    return true
end

-----------------------------------------------------------
-- GET RESTRICTION MESSAGE
-----------------------------------------------------------

local function getRestrictionMessage(mechanic)

    if mechanic.type == "bike" then
        return "This mechanic only services motorcycles."
    end

    if mechanic.type == "car" then
        return "This mechanic only services cars."
    end

    return "This mechanic cannot service this vehicle."
end

-----------------------------------------------------------
-- RESET RESTRICTION
-----------------------------------------------------------

local function resetRestriction()

    currentRestriction = nil
    notificationShown = false
end

-----------------------------------------------------------
-- MAIN RESTRICTION LOOP
-----------------------------------------------------------

CreateThread(function()

    while true do

        local sleep = Config.CheckInterval

        ---------------------------------------------------
        -- FIND CURRENT MECHANIC
        ---------------------------------------------------

        local mechanicId, mechanic = getCurrentMechanic()

        if mechanic then

            ------------------------------------------------
            -- FIND VEHICLE
            ------------------------------------------------

            local vehicle = getNearbyVehicle()

            if vehicle then

                ------------------------------------------------
                -- CHECK VEHICLE TYPE
                ------------------------------------------------

                local allowed = isVehicleAllowed(
                    mechanic,
                    vehicle
                )

                ------------------------------------------------
                -- WRONG VEHICLE
                ------------------------------------------------

                if not allowed then

                    currentRestriction = {
                        mechanic = mechanicId,
                        vehicle = vehicle,
                        type = mechanic.type
                    }

                    ------------------------------------------------
                    -- BLOCK E / INPUT_CONTEXT
                    ------------------------------------------------

                    DisableControlAction(0, 38, true)
                    DisableControlAction(1, 38, true)
                    DisableControlAction(2, 38, true)

                    ------------------------------------------------
                    -- SHOW ONLY ONCE
                    ------------------------------------------------

                    if not notificationShown then

                        notify(
                            getRestrictionMessage(mechanic)
                        )

                        notificationShown = true

                    end

                    sleep = 0

                else

                    ------------------------------------------------
                    -- CORRECT VEHICLE
                    ------------------------------------------------

                    resetRestriction()

                end

            else

                ------------------------------------------------
                -- NO VEHICLE
                ------------------------------------------------

                resetRestriction()

            end

        else

            ---------------------------------------------------
            -- OUTSIDE MECHANIC
            ---------------------------------------------------

            resetRestriction()

        end

        Wait(sleep)

    end

end)