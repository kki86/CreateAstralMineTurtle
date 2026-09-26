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
        print("Not enough fuel!")
        return false
    end

    return true
end

-- Move forward while digging
local function forward()
    if not checkFuel() then
        error("Out of fuel!")
    end

    turtle.dig()

    while not turtle.forward() do
        turtle.dig()
        sleep(0.1)
    end
end

-- Move down while digging
local function down()
    if not checkFuel() then
        error("Out of fuel!")
    end

    turtle.digDown()

    while not turtle.down() do
        turtle.digDown()
        sleep(0.1)
    end
end

-- Turn around
local function turnAround()
    turtle.turnRight()
    turtle.turnRight()
end

-- Mine one 4x4 layer
local function mineLayer()

    for row = 1, SIZE do

        for col = 1, SIZE - 1 do
            forward()
        end

        -- Move to next row
        if row < SIZE then

            if row % 2 == 1 then
                turtle.turnRight()
                forward()
                turtle.turnLeft()
            else
                turtle.turnLeft()
                forward()
                turtle.turnRight()
            end

        end
    end
end

-- Return to starting position of the layer
local function returnToStart()

    turnAround()

    -- Move across the last row
    for i = 1, SIZE - 1 do
        forward()
    end

    -- Move back to the first row
    turtle.turnLeft()

    for i = 1, SIZE - 1 do
        forward()
    end

    turtle.turnRight()
end

-- Initial refuel
refuel()

if not checkFuel() then
    return
end

-- Mine 4 layers downward
for layer = 1, SIZE do

    print("Mining layer " .. layer .. " of " .. SIZE)

    mineLayer()

    -- Return to the starting corner
    returnToStart()

    -- Move down to the next layer
    if layer < SIZE then
        down()
    end
end

print("Mining complete!")
print("Fuel remaining: " .. turtle.getFuelLevel())
