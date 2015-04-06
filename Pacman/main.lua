logic = {
	characters = {
		pinky = { position = { x = 12, y = 12 }, state = "alive", direction = "right", runanimationtime = 0, running = false, },
		pacman = {position = { x = 14, y = 18 }, direction = "right", nextdirection = "right", time = 0, maxtime = 0.2, runanimationtime = 0, running = false}
	},
	ghosts = {haunting = false, blinktime = 0, blinksubstate = 0, runtime = 0, maxblinktime = 0.1, maxruntime = 0.2},
}
function love.load ()
	graphics = {images = {}}
	dofile "map.lua"
	graphics.properties = { tileSize = 15, }
	love.window.setTitle("Pacman by Erica Riello")
	love.window.setMode(graphics.properties.tileSize*(#graphics.map[1]), graphics.properties.tileSize*(#graphics.map))
	graphics.images.BlueGoshtImg0 = love.graphics.newImage("images//blueghost_0.gif")
	graphics.images.BlueGoshtImg1 = love.graphics.newImage("images//blueghost_1.gif")
	graphics.images.Pacman_right = love.graphics.newImage("images//pacman_right.png")
	graphics.images.Pacman_left = love.graphics.newImage("images//pacman_left.png")
	graphics.images.Pacman_up = love.graphics.newImage("images//pacman_up.png")
	graphics.images.Pacman_down = love.graphics.newImage("images//pacman_down.png")
end
function love.draw()
    love.graphics.setColor(1, 111, 111);
    for x = 0, #(graphics.map[1])-1 do
    	for y = 0, #graphics.map-1 do
    		if graphics.map[y+1][x+1] == -1 then
    			setGraphicColor("grey")
    			love.graphics.rectangle('fill', x*graphics.properties.tileSize, y*graphics.properties.tileSize, graphics.properties.tileSize, graphics.properties.tileSize)
    		elseif graphics.map[y+1][x+1] == 1 then
    			setGraphicColor("white")
    			love.graphics.circle('fill', x*graphics.properties.tileSize+graphics.properties.tileSize/2, y*graphics.properties.tileSize+graphics.properties.tileSize/2, graphics.properties.tileSize/16)
    		elseif graphics.map[y+1][x+1] == 2 then
    			setGraphicColor("white")
    			love.graphics.circle('fill', x*graphics.properties.tileSize+graphics.properties.tileSize/2, y*graphics.properties.tileSize+graphics.properties.tileSize/2, graphics.properties.tileSize/4)
    		end
    	end
    end
    drawPacman()
    drawGhost(logic.characters.pinky) 
end
function setGraphicColor (color)
	if color == "blue" then
		love.graphics.setColor(0, 0, 255)
	elseif color == "white" then
		love.graphics.setColor(255, 255, 255)
	elseif color == "grey" then
		love.graphics.setColor(55, 55, 55)
	elseif color == "red" then
		love.graphics.setColor(255, 0, 0)
	elseif color == "yellow" then
		love.graphics.setColor(255, 255, 0)
	end
end
function drawGhost (ghost)
	if ghost.state == "dead" then
		return
	end
	local px = (ghost.position.x-1)*graphics.properties.tileSize
	local py = (ghost.position.y-1)*graphics.properties.tileSize
	if ghost.running == true then
		if ghost.direction == "up" then
			py = py + graphics.properties.tileSize*(1-ghost.runanimationtime/logic.ghosts.maxruntime)
		elseif ghost.direction == "down" then
			py = py - graphics.properties.tileSize*(1-ghost.runanimationtime/logic.ghosts.maxruntime)
		elseif ghost.direction == "left" then
			px = px + graphics.properties.tileSize*(1-ghost.runanimationtime/logic.ghosts.maxruntime)
		elseif ghost.direction == "right" then
			px = px - graphics.properties.tileSize*(1-ghost.runanimationtime/logic.ghosts.maxruntime)
		end
	end
	if logic.ghosts.haunting==false and logic.ghosts.blinksubstate == 0 then
    	setGraphicColor("blue")
    	love.graphics.draw(graphics.images.BlueGoshtImg0, px, py)
    elseif logic.ghosts.haunting==false and logic.ghosts.blinksubstate == 1 then
    	setGraphicColor("white")
    	love.graphics.draw(graphics.images.BlueGoshtImg1, px, py)
    end
end
function drawPacman ()
	local px = (logic.characters.pacman.position.x-1)*graphics.properties.tileSize
	local py = (logic.characters.pacman.position.y-1)*graphics.properties.tileSize
    if logic.characters.pacman.running == true then
    	local delta = graphics.properties.tileSize*(1-logic.characters.pacman.runanimationtime/logic.characters.pacman.maxtime)
    	if logic.characters.pacman.direction == "up" then
			py = py + delta
		elseif logic.characters.pacman.direction == "down" then
			py = py - delta
		elseif logic.characters.pacman.direction == "left" then
			px = px + delta
		elseif logic.characters.pacman.direction == "right" then
			px = px - delta
		end
    end
    setGraphicColor("yellow")
    love.graphics.draw(graphics.images["Pacman_"..logic.characters.pacman.direction], px, py)
end
function love.update (dt)
	logic.ghosts.blinktime = logic.ghosts.blinktime + dt
	if logic.ghosts.blinktime > logic.ghosts.maxblinktime then
		logic.ghosts.blinktime, logic.ghosts.blinksubstate = 0, 1 - logic.ghosts.blinksubstate
	end
	logic.ghosts.runtime = logic.ghosts.runtime + dt
	if logic.ghosts.runtime > logic.ghosts.maxruntime then
		logic.ghosts.runtime = 0
		randommove (logic.characters.pinky)
	end
	updateGhostAnimation(logic.characters.pinky, dt)
	local pacman = logic.characters.pacman
	pacman.time = pacman.time + dt
	if pacman.time > pacman.maxtime then
		pacman.time = 0
		moveCharacter(pacman, pacman.nextdirection)
		pacman.direction = pacman.nextdirection
		graphics.map[pacman.position.y][pacman.position.x] = 0
	end
	updatePacmanAnimation(dt)
end
function updateGhostAnimation (ghost, dt)
	ghost.runanimationtime = ghost.runanimationtime + dt
end
function updatePacmanAnimation (dt)
	local pacman = logic.characters.pacman
	pacman.runanimationtime = pacman.runanimationtime + dt
end
function love.keypressed (key, isrepeat)
	if isrepeat then
		return
	end
	if key == "up" or key == "down" or key == "right" or key == "left" then
		if moveIsPossible(logic.characters.pacman.position, key) then
			logic.characters.pacman.nextdirection = key
		end
	end
end
function randommove (character)
--[[	if moveIsPossible(character.position, character.direction) then
		moveCharacter(character, character.direction)
		return
	end]]
	local allDirections, directions = {"up", "down", "left", "right"}, {}
	for _, v in ipairs (allDirections) do
		if getBackwards(v) ~= character.direction then
			table.insert(directions, v)
		end
	end
	local possibleMoves = getPossibleMoves(character, directions)
	for _, v in ipairs (possibleMoves) do
		print (v)
	end
	local direction = possibleMoves[math.random(#possibleMoves)]
	print("next direction", direction)
	moveCharacter(character, direction)
end
function getBackwards(direction)
	if direction == "up" then
		return "down"
	elseif direction == "down" then
		return "up"
	elseif direction == "right" then
		return "left"
	elseif direction == "left" then
		return "right"
	end
end
function getPossibleMoves (character, directions)
	local possibleMoves = {}
	for _, direction in ipairs(directions) do
		if moveIsPossible(character.position, direction) then
			table.insert(possibleMoves, direction)
		end
	end
	return possibleMoves
end
function moveIsPossible (position, direction)
	return not( (direction == "up"    and graphics.map[position.y-1] and graphics.map[position.y-1][position.x] == -1) or
	            (direction == "down"  and graphics.map[position.y-1] and graphics.map[position.y+1][position.x] == -1) or
	            (direction == "left"  and graphics.map[position.y][position.x-1] == -1) or
	            (direction == "right" and graphics.map[position.y][position.x+1] == -1) )
end
function moveCharacter (character, direction)
	local position = character.position
	local positionValue = false
	if moveIsPossible(character.position, direction) then
		if direction == "up" then
			character.position.y = character.position.y-1
		elseif direction == "down" then
			character.position.y = character.position.y+1
		elseif direction == "left" then
			character.position.x = character.position.x-1
		elseif direction == "right" then
			character.position.x = character.position.x+1
		end
		if character.position.y == 0 then
			character.position.y = #(graphics.map)
		elseif character.position.y > #(graphics.map) then
			character.position.y = 1
		elseif character.position.x == 0 then
			character.position.x = #(graphics.map[1])
		elseif character.position.x > #(graphics.map[1]) then
			character.position.x = 1
		end
		character.direction = direction
		character.running = true

		if character.runanimationtime then
			character.runanimationtime = 0
		end
	else
		character.running = false
	end
end
