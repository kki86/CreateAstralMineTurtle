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

    -- Mine each row
    for row = 1, sizeX do

        -- Move across the row
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

    -- Return to starting corner of this layer
    if layer < sizeY then

        -- For an even number of rows,
        -- turtle is facing backward.
        -- Turn left to face the starting side.
        if sizeX % 2 == 0 then
            turnLeft()
        else
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
