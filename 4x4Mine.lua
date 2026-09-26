local SIZE = 4
local MIN_FUEL = 50

-- Refuel from any fuel in inventory
local function refuel()
    for slot = 1, 16 do
        turtle.select(slot)
        turtle.refuel()
    end
end

-- Make sure we have enough fuel
local function checkFuel()
    if turtle.getFuelLevel() < MIN_FUEL then
        refuel()
    end

    if turtle.getFuelLevel() < MIN_FUEL then
        error("Not enough fuel!")
    end
end

-- Move forward while digging
local function digForward()
    checkFuel()

    turtle.dig()

    while not turtle.forward() do
        turtle.dig()
        sleep(0.1)
    end
end

-- Move down while digging
local function digDown()
    checkFuel()

    turtle.digDown()

    while not turtle.down() do
        turtle.digDown()
        sleep(0.1)
    end
end

-- Move up while digging
local function digUp()
    checkFuel()

    turtle.digUp()

    while not turtle.up() do
        turtle.digUp()
        sleep(0.1)
    end
end

-- Move forward WITHOUT digging
local function moveForward()
    checkFuel()

    while not turtle.forward() do
        sleep(0.1)
    end
end

-- Turn around
local function turnAround()
    turtle.turnRight()
    turtle.turnRight()
end

-- Mine one complete 4x4 layer
local function mineLayer()

    -- Row 1: →
    for i = 1, SIZE - 1 do
        digForward()
    end

    -- Move to row 2
    turtle.turnRight()
    digForward()
    turtle.turnLeft()

    -- Row 2: ←
    for i = 1, SIZE - 1 do
        digForward()
    end

    -- Move to row 3
    turtle.turnLeft()
    digForward()
    turtle.turnRight()

    -- Row 3: →
    for i = 1, SIZE - 1 do
        digForward()
    end

    -- Move to row 4
    turtle.turnRight()
    digForward()
    turtle.turnLeft()

    -- Row 4: ←
    for i = 1, SIZE - 1 do
        digForward()
    end
end

-- Return to the beginning of a layer
local function returnToLayerStart()

    -- After a 4x4 layer we are at:
    --
    -- [S][ ][ ][ ]
    -- [ ][ ][ ][ ]
    -- [ ][ ][ ][ ]
    -- [ ][ ][ ][T]
    --
    -- Turn around and go back 3 blocks.
    turnAround()

    for i = 1, SIZE - 1 do
        moveForward()
    end

    -- We are facing the original direction again.
    turnAround()
end

--------------------------------------------------
-- START
--------------------------------------------------

print("Refueling...")
refuel()

checkFuel()

print("Starting 4x4x4 mine...")

-- Enter the first block of the cube.
-- The turtle starts ABOVE the cube.
digDown()

-- Mine 4 layers
for layer = 1, SIZE do

    print("Mining layer " .. layer .. " / " .. SIZE)

    mineLayer()

    -- Return to the same corner of this layer
    returnToLayerStart()

    -- Go down to the next layer
    if layer < SIZE then
        digDown()
    end
end

print("4x4x4 cube mined!")

-- Return to the original height.
-- We are 4 blocks below where we started.
for i = 1, SIZE do
    digUp()
end

print("Returned to starting location.")
print("Fuel remaining: " .. turtle.getFuelLevel())
