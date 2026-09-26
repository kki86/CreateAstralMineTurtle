-- CONFIGURATION

local sizeX = 4
local sizeY = 4
local sizeZ = 4

local FUEL_CHECK_INTERVAL = 10
local MIN_FUEL = 50

-- FUEL

local blocksMoved = 0

local function tryRefuel()
    if turtle.getFuelLevel() == "unlimited" then
        return
    end

    for slot = 1, 16 do
        turtle.select(slot)

        if turtle.refuel(0) then
            turtle.refuel()
        end
    end

    turtle.select(1)
end

local function checkFuel()
    if turtle.getFuelLevel() == "unlimited" then
        return
    end

    if turtle.getFuelLevel() < MIN_FUEL then
        print("Fuel low! Refueling...")
        tryRefuel()
        print("Fuel: " .. tostring(turtle.getFuelLevel()))
    end
end

local function countBlock()
    blocksMoved = blocksMoved + 1

    if blocksMoved >= FUEL_CHECK_INTERVAL then
        checkFuel()
        blocksMoved = 0
    end
end

-- MOVEMENT

local function forward()
    while not turtle.forward() do
        turtle.dig()
        turtle.attack()
        sleep(0.2)
    end

    countBlock()
end

local function down()
    while not turtle.down() do
        turtle.digDown()
        turtle.attackDown()
        sleep(0.2)
    end

    countBlock()
end

local function up()
    while not turtle.up() do
        turtle.digUp()
        turtle.attackUp()
        sleep(0.2)
    end

    countBlock()
end

local function turnRight()
    turtle.turnRight()
end

local function turnLeft()
    turtle.turnLeft()
end

-- ===================================================
-- MAIN
-- ===================================================

print("Checking fuel...")

tryRefuel()

print("Starting fuel: " .. tostring(turtle.getFuelLevel()))

-- ---------------------------------------------------
-- Move down into the first layer
-- ---------------------------------------------------

print("Moving down to first layer...")

down()

-- ---------------------------------------------------
-- Mine the cube
-- ---------------------------------------------------

for layer = 1, sizeY do

    print("Mining layer " .. layer .. " / " .. sizeY)

    for row = 1, sizeX do

        for block = 1, sizeZ - 1 do
            forward()
        end

        if row < sizeX then

            if row % 2 == 1 then
                turnRight()
                forward()
                turnRight()
            else
                turnLeft()
                forward()
                turnLeft()
            end

        end
    end

    -- Move down to next layer
    if layer < sizeY then
        down()

        -- Turn around so the next layer goes
        -- back across the cube
        turnRight()
        turnRight()
    end
end
-- ===================================================
-- RETURN HOME
-- ===================================================

print("Mining complete!")
print("Returning home...")

-- At the end of the final layer,
-- return to the starting corner.

if sizeX % 2 == 0 then
    turnLeft()
else
    turnRight()
end

for i = 1, sizeX - 1 do
    forward()
end

-- Return to starting height
for i = 1, sizeY do
    up()
end

print("Returned to starting position!")
print("Final fuel: " .. tostring(turtle.getFuelLevel()))
