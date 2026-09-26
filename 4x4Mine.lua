-- ===================================================
-- CONFIGURATION
-- Dimensions of the cube to mine (Width x Height x Length)
-- ===================================================
local sizeX = 4  -- Width  (columns to the right)
local sizeY = 4  -- Height (layers up)
local sizeZ = 4  -- Length (blocks forward)
-- ===================================================

-- Tracking position relative to start position (0,0,0)
local currentX, currentY, currentZ = 0, 0, 0
local heading = 0 -- 0: +Z (forward), 1: +X (right), 2: -Z (back), 3: -X (left)

-- Consumes fuel from inventory
local function tryRefuel()
    if turtle.getFuelLevel() == "unlimited" then return end
    for slot = 1, 16 do
        turtle.select(slot)
        if turtle.refuel(0) then
            turtle.refuel()
        end
    end
    turtle.select(1)
end

-- Checks fuel level against required return travel distance
local function ensureFuel(neededFuel)
    if turtle.getFuelLevel() == "unlimited" then return end
    while turtle.getFuelLevel() < neededFuel do
        tryRefuel()
        if turtle.getFuelLevel() < neededFuel then
            print("LOW FUEL! Needs at least " .. neededFuel .. " fuel.")
            print("Place fuel into turtle inventory...")
            sleep(5)
        end
    end
end

-- Navigation and dig utilities
local function turnRight()
    turtle.turnRight()
    heading = (heading + 1) % 4
end

local function turnLeft()
    turtle.turnLeft()
    heading = (heading + 3) % 4
end

local function forward()
    local distHome = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(distHome)
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

local function up()
    local distHome = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(distHome)
    while not turtle.up() do
        turtle.digUp()
        turtle.attackUp()
        sleep(0.3)
    end
    currentY = currentY + 1
end

local function down()
    local distHome = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(distHome)
    while not turtle.down() do
        turtle.digDown()
        turtle.attackDown()
        sleep(0.3)
    end
    currentY = currentY - 1
end

-- Shifts 1 block sideways to start the next row
local function shiftX()
    if currentX < sizeX - 1 and currentX >= 0 then
        if heading == 0 then
            turnRight()
            forward()
            turnRight()
        elseif heading == 2 then
            turnLeft()
            forward()
            turnLeft()
        end
    elseif currentX > 0 then
        if heading == 0 then
            turnLeft()
            forward()
            turnLeft()
        elseif heading == 2 then
            turnRight()
            forward()
            turnRight()
        end
    end
end

-- Returns directly to (0,0,0) facing original direction
local function returnHome()
    print("Mining complete! Returning home...")
    while currentY > 0 do
        down()
    end
    
    if currentX > 0 then
        while heading ~= 3 do turnRight() end -- Face -X
        while currentX > 0 do forward() end
    end

    if currentZ > 0 then
        while heading ~= 2 do turnRight() end -- Face -Z
        while currentZ > 0 do forward() end
    end

    while heading ~= 0 do turnRight() end -- Face initial direction (+Z)
    print("Returned to home position!")
end

-- ===================================================
-- MAIN EXECUTION
-- ===================================================
print("Checking fuel...")
tryRefuel()
print("Starting fuel level: " .. tostring(turtle.getFuelLevel()))

local isFirstRun = true

for y = 1, sizeY do
    for x = 1, sizeX do
        -- The very first strip starts from Z=0 outside the box, so it takes sizeZ steps.
        -- Every subsequent strip starts inside the box, taking sizeZ - 1 steps.
        local steps = isFirstRun and sizeZ or (sizeZ - 1)
        isFirstRun = false

        for z = 1, steps do
            forward()
        end

        if x < sizeX then
            shiftX()
        end
    end

    if y < sizeY then
        up()
        turnRight()
        turnRight()
    end
end

returnHome()
