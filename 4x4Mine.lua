-- ===================================================
-- CONFIGURATION
-- ===================================================

local sizeX = 4       -- Number of rows
local sizeY = 4       -- Number of layers downward
local sizeZ = 4       -- Length of each row

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

    -- Check every inventory slot
    for slot = 1, 16 do

        turtle.select(slot)

        -- Check if this item is fuel
        if turtle.refuel(0) then

            -- Consume all fuel from this slot
            while turtle.refuel() do
            end

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

        -- Stop if we could not get fuel
        if turtle.getFuelLevel() < MIN_FUEL then
            error("Not enough fuel!")
        end
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

    -- Make sure we have fuel before moving
    checkFuel()

    while not turtle.forward() do

        -- Try to clear the obstruction
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

-- ===================================================
-- START
-- ===================================================

print("Checking fuel...")

tryRefuel()

print("Starting fuel: " .. tostring(turtle.getFuelLevel()))

if turtle.getFuelLevel() ~= "unlimited"
and turtle.getFuelLevel() < MIN_FUEL then

    error("Not enough fuel to start!")

end

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

    -- -----------------------------------------------
    -- Mine each row
    -- -----------------------------------------------

    for row = 1, sizeX do

        print("Row " .. row .. " / " .. sizeX)

        -- -------------------------------------------
        -- Mine across the row
        -- -------------------------------------------

        for block = 1, sizeZ - 1 do
            forward()
        end

        -- -------------------------------------------
        -- Move to next row
        -- -------------------------------------------

        if row < sizeX then

            -- The direction alternates between
            -- layers and rows.
            --
            -- Layer 1:
            --   Row 1 -> 
            --   Row 2 <-
            --   Row 3 ->
            --   Row 4 <-
            --
            -- Layer 2:
            --   Row 1 <-
            --   Row 2 ->
            --   Row 3 <-
            --   Row 4 ->

            if (layer + row) % 2 == 0 then

                -- Turn right
                turnRight()

                -- Move to next row
                forward()

                -- Face down the next row
                turnRight()

            else

                -- Turn left
                turnLeft()

                -- Move to next row
                forward()

                -- Face down the next row
                turnLeft()

            end
        end
    end

    -- -----------------------------------------------
    -- Move down to next layer
    -- -----------------------------------------------

    if layer < sizeY then

        print("Moving down to layer " .. (layer + 1))

        -- ONLY move down.
        --
        -- Do NOT turn here.
        -- The alternating row pattern already
        -- leaves us facing the correct direction
        -- for the next layer.

        down()
    end
end

-- ===================================================
-- RETURN HOME
-- ===================================================

print("================================")
print("Mining complete!")
print("Returning home...")
print("================================")

-- At the end of layer 4:
--
-- Position:
--   Same X/Z corner where we started
--
-- Direction:
--   Same direction where we started
--
-- Therefore NO horizontal movement is needed.

-- Return to original height.
--
-- We moved:
--   1 block down before layer 1
--   1 block down between layers 1/2
--   1 block down between layers 2/3
--   1 block down between layers 3/4
--
-- Total = 4 blocks down.

for i = 1, sizeY do
    up()
end

print("Returned to starting position!")
print("Final fuel: " .. tostring(turtle.getFuelLevel()))
