print("Checking fuel...")
tryRefuel()
print("Starting fuel level: " .. tostring(turtle.getFuelLevel()))

-- Move down into the first layer
print("Moving down into first layer...")
down()

for y = 1, sizeY do
    print("Mining layer " .. y .. " of " .. sizeY)

    for x = 1, sizeX do
        local steps = (x == 1) and sizeZ or (sizeZ - 1)

        for z = 1, steps do
            forward()
        end

        if x < sizeX then
            shiftX()
        end
    end

    -- Move to the next layer
    if y < sizeY then
        print("Moving down to next layer...")
        down()
        turnRight()
        turnRight()
    end
end

returnHome()
