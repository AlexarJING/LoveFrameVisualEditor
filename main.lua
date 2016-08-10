require "lib/util"
Tween = require("lib/tween")
loveframes = require("lib.loveframes")
loveframes2= require("lib.loveframes")
function love.load()
	ui=require "ui"
end

function love.update(dt)	
	ui:update(dt)
end

function love.draw()
	ui:draw()
end

function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
	ui:mousepressed(x,y, button)
end

function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function love.keypressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
	ui:keypressed(key)
end

function love.keyreleased(key)
	loveframes.keyreleased(key)
	
end

function love.textinput(text)
	loveframes.textinput(text)
end