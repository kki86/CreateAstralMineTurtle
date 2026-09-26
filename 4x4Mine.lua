-- ===================================================
-- CONFIGURATION
-- ===================================================
local sizeX = 4
local sizeY = 4
local sizeZ = 4
-- ===================================================

local currentX = 0
local currentY = 0
local currentZ = 0

-- 0 = +Z, 1 = +X, 2 = -Z, 3 = -X
local heading = 0


-- ===================================================
-- FUEL
-- ===================================================

local function tryRefuel()
    if turtle.getFuelLevel() == "unlimited" then
        return
    end

    for slot = 1, 16 do
        turtle.select(slot)

        if turtle.refuel(0) then
            while turtle.getItemCount(slot) > 0 do
                turtle.refuel(1)
            end
        end
    end

    turtle.select(1)
end


local function ensureFuel()
    if turtle.getFuelLevel() == "unlimited" then
        return
    end

    while turtle.getFuelLevel() < 1 do
        tryRefuel()

        if turtle.getFuelLevel() < 1 then
            print("LOW FUEL!")
            print("Put fuel into the turtle.")
            sleep(5)
        end
    end
end


-- ===================================================
-- TURNING
-- ===================================================

local function turnRight()
    turtle.turnRight()
    heading = (heading + 1) % 4
end


local function turnLeft()
    turtle.turnLeft()
    heading = (heading + 3) % 4
end


-- ===================================================
-- MOVEMENT
-- ===================================================

local function forward()
    ensureFuel()

    while not turtle.forward() do
        turtle.dig()
        turtle.attack()
        sleep(0.2)
    end

    if heading == 0 then
        currentZ = currentZ + 1
    elseif heading == 1 then
        currentX = currentX + 1
    elseif heading == 2 then
        currentZ = currentZ - 1
    elseif heading == 3 then
        currentX = currentX - 1
    end
end


local function down()
    ensureFuel()

    while not turtle.down() do
        turtle.digDown()
        turtle.attackDown()
        sleep(0.2)
    end

    currentY = currentY - 1
end


local function up()
    ensureFuel()

    while not turtle.up() do
        turtle.digUp()
        turtle.attackUp()
        sleep(0.2)
    end

    currentY = currentY + 1
end


-- ===================================================
-- MINE ONE 4x4 LAYER
-- ===================================================

local function mineLayer()
    print("Mining layer at Y = " .. currentY)

    for x = 1, sizeX do

        -- Move forward across the row
        for z = 1, sizeZ - 1 do
            forward()
        end

        -- Move to next row
        if x < sizeX then

            if x % 2 == 1 then
                -- Facing +Z
                turnRight()
                forward()
                turnRight()

            else
                -- Facing -Z
                turnLeft()
                forward()
                turnLeft()
            end
        end
    end
end


-- ===================================================
-- RETURN TO THE FRONT OF CURRENT LAYER
-- ===================================================

local function returnToLayerStart()

    -- The turtle ends at the opposite side
    -- of the 4x4 layer.

    if currentX > 0 then
        -- Face -X
        while heading ~= 3 do
            turnRight()
        end

        while currentX > 0 do
            forward()
        end
    end

    if currentZ > 0 then
        -- Face -Z
        while heading ~= 2 do
            turnRight()
        end

        while currentZ > 0 do
            forward()
        end
    end

    -- Face original direction
    while heading ~= 0 do
        turnRight()
    end
end


-- ===================================================
-- RETURN HOME
-- ===================================================

local function returnHome()

    print("Returning home...")

    -- Return to X/Z starting position
    returnToLayerStart()

    -- Move back up to starting height
    while currentY < 0 do
        up()
    end

    -- Restore original direction
    while heading ~= 0 do
        turnRight()
    end

    print("Returned home!")
end


-- ===================================================
-- MAIN
-- ===================================================

print("Checking fuel...")
tryRefuel()

print("Starting fuel: " .. tostring(turtle.getFuelLevel()))

-- IMPORTANT:
-- Move down BEFORE mining the first layer.
print("Moving down to layer 1...")
down()

-- Mine all 4 layers
for y = 1, sizeY do

    print("==========")
    print("Layer " .. y .. " / " .. sizeY)
    print("==========")

    mineLayer()

    -- Return to the same corner before going down
    returnToLayerStart()

    -- Move down to the next layer
    if y < sizeY then
        print("Moving down to next layer...")
        down()
    end
end

-- Return to original position
returnHome()

print("Mining complete!")
