-- ===================================================
-- MINING TURTLE CONFIGURATION
-- Change these numbers to set your mining cube size:
-- ===================================================
local sizeX = 4  -- Width  (columns / right)
local sizeY = 4  -- Height (layers / up)
local sizeZ = 4  -- Length (rows / forward)
-- ===================================================

-- Tracking local position relative to starting spot (0,0,0)
local currentX, currentY, currentZ = 0, 0, 0
local dir = 0 -- 0: +Z (Forward), 1: +X (Right), 2: -Z (Back), 3: -X (Left)

-- Consumes fuel from inventory if available
local function tryRefuel()
    if turtle.getFuelLevel() == "unlimited" then return true end
    for slot = 1, 16 do
        turtle.select(slot)
        if turtle.refuel(0) then
            while turtle.getItemCount(slot) > 0 do
                if not turtle.refuel(1) then break end
            end
        end
    end
    turtle.select(1)
end

-- Checks fuel level and pauses if fuel is critically low
local function ensureFuel(requiredFuel)
    if turtle.getFuelLevel() == "unlimited" then return end
    while turtle.getFuelLevel() < requiredFuel do
        tryRefuel()
        if turtle.getFuelLevel() < requiredFuel then
            print("LOW FUEL! Needs at least " .. requiredFuel .. " fuel.")
            print("Current Fuel: " .. turtle.getFuelLevel() .. " / " .. turtle.getFuelLimit())
            print("Please place fuel into turtle inventory...")
            sleep(5)
        end
    end
end

-- Rotational utilities
local function turnRight()
    turtle.turnRight()
    dir = (dir + 1) % 4
end

local function turnLeft()
    turtle.turnLeft()
    dir = (dir + 3) % 4
end

local function face(targetDir)
    while dir ~= targetDir do
        turnRight()
    end
end

-- Movement utilities with auto-digging (handles gravel/sand)
local function moveForward()
    local neededFuel = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(neededFuel)
    
    while not turtle.forward() do
        turtle.dig()
        turtle.attack()
        sleep(0.3)
    end

    if dir == 0 then currentZ = currentZ + 1
    elseif dir == 1 then currentX = currentX + 1
    elseif dir == 2 then currentZ = currentZ - 1
    elseif dir == 3 then currentX = currentX - 1
    end
end

local function moveUp()
    local neededFuel = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(neededFuel)

    while not turtle.up() do
        turtle.digUp()
        turtle.attackUp()
        sleep(0.3)
    end
    currentY = currentY + 1
end

local function moveDown()
    local neededFuel = math.abs(currentX) + math.abs(currentY) + math.abs(currentZ) + 10
    ensureFuel(neededFuel)

    while not turtle.down() do
        turtle.digDown()
        turtle.attackDown()
        sleep(0.3)
    end
    currentY = currentY - 1
end

-- Navigate directly to a specific target coordinate adjacent to current position
local function goTo(tx, ty, tz)
    while currentY < ty do moveUp() end
    while currentY > ty do moveDown() end

    if tx > currentX then
        face(1)
        while currentX < tx do moveForward() end
    elseif tx < currentX then
        face(3)
        while currentX > tx do moveForward() end
    end

    if tz > currentZ then
        face(0)
        while currentZ < tz do moveForward() end
    elseif tz < currentZ then
        face(2)
        while currentZ < tz do moveForward() end
    end
end

-- ===================================================
-- MAIN MINING EXECUTION
-- ===================================================
print("Starting initial refuel check...")
tryRefuel()
print("Current fuel: " .. tostring(turtle.getFuelLevel()))

print("Beginning excavation (" .. sizeX .. "x" .. sizeY .. "x" .. sizeZ .. ")...")

for y = 0, sizeY - 1 do
    local xStart, xEnd, xStep
    if y % 2 == 0 then
        xStart, xEnd, xStep = 0, sizeX - 1, 1
    else
        xStart, xEnd, xStep = sizeX - 1, 0, -1
    end

    for x = xStart, xEnd, xStep do
        local zStart, zEnd, zStep
        if currentZ == 0 then
            zStart, zEnd, zStep = 0, sizeZ - 1, 1
        else
            zStart, zEnd, zStep = sizeZ - 1, 0, -1
        end

        for z = zStart, zEnd, zStep do
            goTo(x, y, z)
        end
    end
end

-- Return Home Procedure
print("Mining complete! Returning to home position...")
goTo(0, 0, 0)
face(0)
print("Returned home safely!")
