-- ===================================================
-- CONFIGURATION
-- ===================================================

local sizeX = 4  -- Width
local sizeY = 4  -- Layers downward
local sizeZ = 4  -- Length

local FUEL_CHECK_INTERVAL = 10
local MIN_FUEL = 50

-- ===================================================
-- FUEL
-- ===================================================

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

-- ===================================================
-- MOVEMENT
-- ===================================================

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

-- Completely refuel before starting
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

-- Move down into the first layer
down()

for layer = 1, sizeY do

    print("Mining layer " .. layer .. " / " .. sizeY)

    -- 4 rows
    for row = 1, sizeX do

        -- Move 3 blocks forward
        for block = 1, sizeZ - 1 do
            forward()
        end

        -- Move to next row
        if row < sizeX then
            if row % 2 == 1 then
                -- Facing forward
                turnRight()
                forward()
                turnRight()
            else
                -- Facing backward
                turnLeft()
                forward()
                turnLeft()
            end
        end
    end

    -- At the end of the layer, return to
    -- the starting corner of that layer.
    if layer < sizeY then

        -- Face back toward the starting side
        if (sizeX % 2) == 0 then
            turnRight()
            turnRight()
        end

        -- Move back across the rows
        for i = 1, sizeX - 1 do
            forward()
        end

        -- Move down one layer
        down()
    end
end

-- ===================================================
-- RETURN HOME
-- ===================================================

print("Mining complete!")
print("Returning home...")

-- After the final row, the turtle is at
-- the opposite side of the 4x4 layer.
--
-- For a 4x4 grid, the turtle is 3 blocks
-- to the right and facing backwards.
--
-- Turn around to face toward the starting side.
turnRight()
turnRight()

-- Move back 3 blocks
for i = 1, sizeX - 1 do
    forward()
end

-- Move back to the original height.
-- We went down sizeY times, so go up sizeY times.
for i = 1, sizeY do
    up()
end

-- Restore original direction
turnRight()
turnRight()

print("Returned to starting position!")
print("Final fuel: " .. tostring(turtle.getFuelLevel()))
