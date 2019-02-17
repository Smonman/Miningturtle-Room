local args = {...}

-- VARIABLES

local torchSpace = 4

local torchSlot = 16
local chestSlot = 15

local roomWidth = nil
local roomHeight = nil
local roomDepth = nil
local roomAmount = nil

local expectedFuelPoins = nil
local expectedCoalAmount = nil
local expectedTorchAmount = nil

function Input(question)
	print(question)
	answer = read()
	Clear()
	return answer
end

function Clear()
	term.clear()
	term.setCursorPos(1, 1)
end

function Dig3HSegment()
	while turtle.detect() do
		turtle.dig()
	end
	while not turtle.forward() do
		turtle.dig()
	end
	while turtle.detectUp() do
		turtle.digUp()
	end
	while turtle.detectDown() do
		turtle.digDown()
	end
end

function DigXHSegment(h)
	while turtle.detect() do
		turtle.dig()
	end
	while not turtle.forward() do
		turtle.dig()
	end
	if h - 3 >= 0 then
		while turtle.detectUp() do
			turtle.digUp()
		end
		for i = 1, h - 3 do
			turtle.up()
			while turtle.detectUp() do
				turtle.digUp()
			end
		end
		for i = 1, h - 3 do
			turtle.down()
		end
	end
	while turtle.detectDown() do
		turtle.digDown()
	end
end

function PlaceTorch()
	turtle.select(torchSlot)
	turtle.placeDown()
end

function StepLeft()
	turtle.turnLeft()
	while not turtle.forward() do
		turtle.dig()
	end
	turtle.turnRight()
end

function StepRight()
	turtle.turnRight()
	while not turtle.forward() do
		turtle.dig()
	end
	turtle.turnLeft()
end

function MoveLeft(steps)
	turtle.turnLeft()
	for i = 1, steps do
		while not turtle.forward() do
			turtle.dig()
		end
	end
	turtle.turnRight()
end

function MoveRight(steps)
	turtle.turnRight()
	for i = 1, steps do
		while not turtle.forward() do
			turtle.dig()
		end
	end
	turtle.turnLeft()
end

function Revolve()
	turtle.turnLeft()
	turtle.turnLeft()
end

function CheckFuel()
	expectedFuelPoins = roomWidth * roomDepth * (roomHeight - 3) * 2 + 10
	expectedCoalAmount = math.ceil(expectedFuelPoins / 80)
	fuel = turtle.getFuelLevel()
	if fuel <= expectedFuelPoins then
		print(string.format("Error: Low fuel level: %s.", tostring(fuel)))
		print(string.format("Needed fuel level: %s.", tostring(expectedFuelPoins)))
		print(string.format("Needed coal: %s.", tostring(expectedCoalAmount)))
		for i = 1, 14 do -- the last 2 slots are preserves for chests and torches
			turtle.select(i)
			turtle.refuel()
		end
	end
end

function Fuel()
	for i = 1, 14 do -- the last 2 slots are preserves for chests and torches
		turtle.select(i)
		turtle.refuel()
	end
	CheckFuel()
end

function Tunnel()
	-- expected fuel points: 10
	-- place turtle in the center of the 3x3 corridor
	-- move from center to left
	StepLeft()
	for i = 1, 3 do
		Dig3HSegment()
		turtle.turnRight()
		for i = 1, 2 do
			Dig3HSegment()
		end
		turtle.turnLeft()
		if i ~= 3 then
			MoveLeft(2)
		else
			MoveLeft(1)
		end
	end
end

function HalfRoom(j)
	for i = 1, halfRoomW do
		DigXHSegment(roomHeight)
	end
	Revolve()
	for i = 1, halfRoomW do
		if i % torchSpace == 0 and j % torchSpace == 0 then
			PlaceTorch()
		end
		while not turtle.forward() do
			turtle.dig()
		end
	end
end

function Room()
	-- expected fuel points cost: w * d * (h - 2) * 2
	halfRoomW = math.floor(roomWidth / 2)
	DigXHSegment(roomHeight)

	for i = 1, roomDepth do
		turtle.turnLeft()

		HalfRoom(i)
		HalfRoom(i)

		if i % torchSpace == 0 then
			PlaceTorch()
		end

		turtle.turnRight()

		if i ~= roomDepth then
			DigXHSegment(roomHeight)
		end
	end
end

function Build()
	Fuel()
	if turtle.getFuelLevel() > 0 then
		Tunnel()
		Room()
	end
end

-- START

Clear()

print(string.format("Torches in slot %d", torchSlot))
print(string.format("Chests in slot %d", chestSlot))
Input("Press any key to continue...")

roomWidth = tonumber(Input("Room width <13>: ")) or 13
roomHeight = tonumber(Input("Room height <3>: ")) or 3
roomDepth = tonumber(Input("Room depth <13>: ")) or 13
roomAmount = tonumber(Input("Room amount <1>: ")) or 1

expectedFuelPoins = (roomWidth * roomDepth * (roomHeight - 2) * 2 + 10) * roomAmount
expectedCoalAmount = math.ceil(expectedFuelPoins / 80)

expectedTorchAmount = (math.floor(roomWidth / torchSpace) + math.floor(roomDepth / torchSpace)) * roomAmount

print(string.format("Building %d [%d x %d x %d] room(s).", roomAmount, roomWidth, roomHeight, roomDepth))

print(string.format("Needed fuel level: %d.", expectedFuelPoins))
print(string.format("Needed coal: %d.", expectedCoalAmount))
print(string.format("Needed torches: %d.", expectedTorchAmount))

Input("Press any key to start...")

for i = 1, roomAmount do
	Build()
end
