-- ===================================================
-- MINING TURTLE CONFIGURATION
-- Change these numbers to set your mining cube size:
-- ===================================================
local sizeX = 4  -- Width  (columns to the right)
local sizeY = 4  -- Depth  (layers DOWN)
local sizeZ = 4  -- Length (blocks forward)
-- ===================================================

-- Position tracking relative to starting position (0, 0, 0)
local currentX, currentY, currentZ = 0, 0, 0
local heading = 0 -- 0: +Z (Forward), 1: +X (Right), 2: -Z (Back), 3: -X (Left)

-- Refuel function: consumes fuel items from inventory
local function tryRefuel()
    local refueled = false
    for slot = 1, 16 do
        turtle.select(slot)
        if turtle.refuel(0) then
            while turtle.getItemCount(slot) > 0 do
                if turtle.refuel(1) then
                    refueled = true
                else
                    break
                end
            end
        end
    end
    turtle.select(1)
    return refueled
end

-- Checks fuel level against required travel distance home
local function checkFuel()
    if turtle.getFuelLevel() == "unlimited" then return end
    local requiredFuel = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    while turtle.getFuelLevel() < requiredFuel do
        print("LOW FUEL! Level: " .. turtle.getFuelLevel() .. " / Needs: " .. requiredFuel)
        print("Refueling from inventory...")
        tryRefuel()
        if turtle.getFuelLevel() < requiredFuel then
            print("Please place fuel into turtle inventory...")
            sleep(4)
        end
    end
end

-- Rotation controls
local function turnRight()
    turtle.turnRight()
    heading = (heading + 1) % 4
end

local function turnLeft()
    turtle.turnLeft()
    heading = (heading + 3) % 4
end

local function face(targetHeading)
    while heading ~= targetHeading do
        turnRight()
    end
end

-- Robust movement utilities using your reference pattern
local function moveForward()
    checkFuel()
    while not turtle.forward() do
        turtle.dig()
        turtle.attack()
        sleep(0.4)
    end
    if heading == 0 then currentZ = currentZ + 1
    elseif heading == 1 then currentX = currentX + 1
    elseif heading == 2 then currentZ = currentZ - 1
    elseif heading == 3 then currentX = currentX - 1
    end
end

local function moveDown()
    checkFuel()
    while not turtle.down() do
        turtle.digDown()
        turtle.attackDown()
        sleep(0.4)
    end
    currentY = currentY - 1
end

local function moveUp()
    checkFuel()
    while not turtle.up() do
        turtle.digUp()
        turtle.attackUp()
        sleep(0.4)
    end
    currentY = currentY + 1
end

-- Return to X=0, Z=0 inside the currently cleared layer air space
local function returnToLayerStart()
    face(2) -- Face -Z (Backward)
    while currentZ > 0 do
        moveForward()
    end

    face(3) -- Face -X (Left)
    while currentX > 0 do
        moveForward()
    end

    face(0) -- Face +Z (Forward)
end

-- Complete return to starting origin (0, 0, 0)
local function returnHome()
    print("Mining complete! Returning home...")
    returnToLayerStart()

    while currentY < 0 do
        moveUp()
    end

    face(0)
    print("Returned to home position!")
end

-- ===================================================
-- MAIN EXECUTION
-- ===================================================
print("Checking fuel on start...")
tryRefuel()
print("Starting Fuel Level: " .. tostring(turtle.getFuelLevel()))

print("Starting excavation (" .. sizeX .. " wide, " .. sizeY .. " deep down, " .. sizeZ .. " long)...")

for y = 1, sizeY do
    print("Mining layer " .. y .. " of " .. sizeY .. "...")
    
    for x = 1, sizeX do
        local steps = (x == 1) and sizeZ or (sizeZ - 1)
        for z = 1, steps do
            moveForward()
        end

        if x < sizeX then
            if heading == 0 then
                turnRight()
                moveForward()
                turnRight()
            else
                turnLeft()
                moveForward()
                turnLeft()
            end
        end
    end

    -- Prepare for the next layer down if not finished
    if y < sizeY then
        returnToLayerStart()
        moveDown()
    end
end

returnHome()
