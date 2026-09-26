-- ===================================================
-- CONFIGURATION
-- ===================================================

local sizeX = 4       -- Number of rows
local sizeY = 4       -- Number of layers
local sizeZ = 4       -- Length of each row

local FUEL_CHECK_INTERVAL = 10
local MIN_FUEL = 50

-- ===================================================
-- FUEL
-- ===================================================

local blocksMoved = 0

local function refuel()

    if turtle.getFuelLevel() == "unlimited" then
        return
    end

    print("Fuel low! Refueling...")

    for slot = 1, 16 do

        turtle.select(slot)

        if turtle.refuel(0) then
            turtle.refuel(64)
        end
    end

    turtle.select(1)

    print("Fuel after refueling: " .. tostring(turtle.getFuelLevel()))
end


local function checkFuel()

    if turtle.getFuelLevel() == "unlimited" then
        return
    end

    if turtle.getFuelLevel() < MIN_FUEL then
        refuel()
    end

    if turtle.getFuelLevel() < MIN_FUEL then
        error("Not enough fuel!")
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

    checkFuel()

    while not turtle.forward() do
        turtle.dig()
        turtle.attack()
        sleep(0.2)
    end

    countBlock()
end


local function down()

    checkFuel()

    while not turtle.down() do
        turtle.digDown()
        turtle.attackDown()
        sleep(0.2)
    end

    countBlock()
end


local function up()

    checkFuel()

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


local function turnAround()
    turtle.turnRight()
    turtle.turnRight()
end

-- ===================================================
-- START
-- ===================================================

print("================================")
print("4x4x4 Mining Turtle")
print("================================")

print("Checking fuel...")

checkFuel()

print("Starting fuel: " .. tostring(turtle.getFuelLevel()))

-- ===================================================
-- MOVE TO FIRST LAYER
-- ===================================================

print("Moving down to first layer...")

down()

-- ===================================================
-- MINE CUBE
-- ===================================================

for layer = 1, sizeY do

    print("================================")
    print("Mining layer " .. layer .. " / " .. sizeY)
    print("================================")

    for row = 1, sizeX do

        print("Row " .. row .. " / " .. sizeX)

        -- -------------------------------------------
        -- Mine the row
        -- -------------------------------------------

        for block = 1, sizeZ - 1 do
            forward()
        end

        -- -------------------------------------------
        -- Move to next row
        -- -------------------------------------------

        if row < sizeX then

            if layer % 2 == 1 then

                -- ===================================
                -- ODD LAYERS
                -- ===================================
                --
                -- Row 1: →
                -- Row 2: ←
                -- Row 3: →
                -- Row 4: ←

                if row % 2 == 1 then

                    -- →
                    -- Turn toward next row
                    turnRight()
                    forward()
                    turnRight()

                else

                    -- ←
                    -- Turn toward next row
                    turnLeft()
                    forward()
                    turnLeft()

                end

            else

                -- ===================================
                -- EVEN LAYERS
                -- ===================================
                --
                -- Row 1: ←
                -- Row 2: →
                -- Row 3: ←
                -- Row 4: →

                if row % 2 == 1 then

                    -- ←
                    -- Turn toward next row
                    turnLeft()
                    forward()
                    turnLeft()

                else

                    -- →
                    -- Turn toward next row
                    turnRight()
                    forward()
                    turnRight()

                end
            end
        end
    end

    -- =================================================
    -- MOVE TO NEXT LAYER
    -- =================================================

    if layer < sizeY then

        print("Moving down to layer " .. (layer + 1))

        -- Move down one block
        down()

        -- Turn around so the next layer travels
        -- in the opposite direction.
        print("Turning around for next layer")

        turnAround()
    end
end

-- ===================================================
-- RETURN HOME
-- ===================================================

print("================================")
print("Mining complete!")
print("Returning home...")
print("================================")

-- Return to starting height.
for i = 1, sizeY do
    up()
end

-- ===================================================
-- DONE
-- ===================================================

print("================================")
print("Returned to starting position!")
print("Final fuel: " .. tostring(turtle.getFuelLevel()))
print("================================")
