-- ===================================================
-- MINING TURTLE CONFIGURATION
-- Dimensions of the cube to mine (Width x Depth x Length)
-- ===================================================
local sizeX = 4  -- Width  (columns to the right)
local sizeY = 4  -- Depth  (layers DOWN)
local sizeZ = 4  -- Length (blocks forward)
-- ===================================================

-- Position tracking relative to start (0, 0, 0)
local currentX, currentY, currentZ = 0, 0, 0
local heading = 0 -- 0: +Z (Forward), 1: +X (Right), 2: -Z (Back), 3: -X (Left)

-- Safe, standard ComputerCraft refueling
local function tryRefuel()
    if turtle.getFuelLevel() == "unlimited" then return end
    for slot = 1, 16 do
        turtle.select(slot)
        turtle.refuel()
    end
    turtle.select(1)
end

-- Ensures fuel is sufficient for movement + trip home
local function ensureFuel(needed)
    if turtle.getFuelLevel() == "unlimited" then return end
    tryRefuel()
    while turtle.getFuelLevel() < needed do
        print("LOW FUEL! Has: " .. turtle.getFuelLevel() .. " / Needs: " .. needed)
        print("Place coal/charcoal in inventory...")
        sleep(3)
        tryRefuel()
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

-- Movement utilities with auto-dig and attack
local function moveForward()
    local needed = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(needed)
    while not turtle.forward() do
        turtle.dig()
        turtle.attack()
        sleep(0.3)
    end
    if heading == 0 then currentZ = currentZ + 1
    elseif heading == 1 then currentX = currentX + 1
    elseif heading == 2 then currentZ = currentZ - 1
    elseif heading == 3 then currentX = currentX - 1
    end
end

local function moveDown()
    local needed = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(needed)
    while not turtle.down() do
        turtle.digDown()
        turtle.attackDown()
        sleep(0.3)
    end
    currentY = currentY - 1
end

local function moveUp()
    local needed = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(needed)
    while not turtle.up() do
        turtle.digUp()
        turtle.attackUp()
        sleep(0.3)
    end
    currentY = currentY + 1
end

-- Returns to (0, currentY, 0) inside the current layer
local function returnToLayerStart()
    face(2) -- Backwards (-Z)
    while currentZ > 0 do moveForward() end

    face(3) -- Left (-X)
    while currentX > 0 do moveForward() end

    face(0) -- Forward (+Z)
end

-- Returns all the way home to (0, 0, 0)
local function returnHome()
    print("Mining complete! Returning home...")
    returnToLayerStart()

    while currentY < 0 do
        moveUp()
    end

    face(0)
    print("Back at starting position!")
end

-- ===================================================
-- MAIN EXECUTION
-- ===================================================
print("Checking fuel...")
tryRefuel()
print("Fuel level: " .. tostring(turtle.getFuelLevel()))

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

    if y < sizeY then
        returnToLayerStart()
        moveDown()
    end
end

returnHome()
