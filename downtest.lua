print("Fuel: " .. tostring(turtle.getFuelLevel()))

print("Trying to move down...")

while not turtle.down() do
    print("Down blocked. Digging...")
    turtle.digDown()
    turtle.attackDown()
    sleep(0.5)
end

print("Moved down!")

sleep(2)

print("Moving back up...")

while not turtle.up() do
    print("Up blocked. Digging...")
    turtle.digUp()
    turtle.attackUp()
    sleep(0.5)
end

print("Back at starting position!")
