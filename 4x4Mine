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

-- Move up while digging
local function up()
    if not checkFuel() then
        error("Out of fuel!")
    end

    turtle.digUp()

    while not turtle.up() do
        turtle.digUp()
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

-- Initial refuel
refuel()

if not checkFuel() then
    return
end

-- Mine 4 layers
for layer = 1, SIZE do

    print("Mining layer " .. layer .. " of " .. SIZE)

    mineLayer()

    if layer < SIZE then

        -- Return to starting position
        turnAround()

        for i = 1, SIZE - 1 do
            forward()
        end

        turtle.turnLeft()

        for i = 1, SIZE - 1 do
            forward()
        end

        turtle.turnRight()

        -- Move up to next layer
        up()
    end
end

print("Mining complete!")
print("Fuel remaining: " .. turtle.getFuelLevel())
