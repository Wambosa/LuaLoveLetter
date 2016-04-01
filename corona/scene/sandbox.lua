local composer = require('composer')
local scene = composer.newScene()
local game = require('core.game')
local deckVisModule = require('vis.deckVis')
local playerVisModule = require('vis.playerVis')

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here


function scene:showTableTop()
	local back = display.newRect(self.tableVis, display.contentCenterX, display.contentCenterY, display.contentWidth*1.5, display.contentHeight )

	--show table background.
	--todo: try to only set for this one display object
	display.setDefault( "textureWrapX", "repeat" )
	display.setDefault( "textureWrapY", "repeat" )
	back.fill = { type="image", filename="img/tableWood.png"}

	local scaleFactorX = 1 ; local scaleFactorY = 1
	if ( back.width > back.height ) then
		scaleFactorY = back.width / back.height
	else
		scaleFactorX = back.height / back.width
	end
	
	back.fill.scaleX = 0.35 * scaleFactorX
	back.fill.scaleY = 0.35 * scaleFactorY

end


---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )

    print_r('LOG: Loading Sandbox with game state', game.state)

    local gameOptions = {
        playerCount = 2,
        playerNames = {'Fat Hat', 'Ghandi'},--, 'Rumpelstiltskin', 'Zeus'},
        startingHandAmount = 4, --todo: this is really one. change back to 1 later
        turnDrawAmount = 1
	}

	game:init(gameOptions)
	game:beginRound()
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
		-- Called when the scene is still off screen (but is about to come on screen).
      
		self.tableVis = display.newGroup()
		
		self:showTableTop()
		
		self.buttons = display.newGroup()
		
		self.deckVis = deckVisModule.create(game.deck)
		
		self.playerVisuals = {} --todo: try to convert this into a display group, that way i can control who is on top visually
		
		for i=1, #game.players, 1 do
			table.insert(self.playerVisuals, playerVisModule.create(game.players[i]))
		end
	
   elseif ( phase == "did" ) then
		
		local visualizeTheRestOfTheStuff = function()
			print('should only be called once!')
			
			local showcaseBanished = display.newImageRect(self.buttons, 'img/invisible.png', core.cardPixelWidth*.5, core.cardPixelHeight*.5)
			showcaseBanished.x, showcaseBanished.y = display.contentCenterX+100, display.contentCenterY-(core.cardPixelHeight*.5)
			
			game:beginTurn()
			
			local p = game.currentPlayerIndex
			
			--todo: loop draw n cards where n = gameOptions.turnDrawAmount
			self.playerVisuals[p]:draw(#game.players[p].hand.cards, bind(self.deckVis, 'draw'))
			
			showcaseBanished:addEventListener('touch', function(event)
				local button = event.target
				local phase = event.phase
				print('todo: create view for graveyard')
				-- if game.state == 'turn' or game.state ~= 'none'
				-- for i=1, #game.deck.banishPile, 1 do
				-- detect position like hand, except move it to screen center.
				-- have horizontal scroll functionality with chain border
				-- (fade the background with transparent cover) touching the cover will cancel the banish view
			end)
		end
		
		local visDealCards = function()
			
			--then show banished pile in a sort of deadzone fire rect
			for i=1, #game.players == 2 and 4 or 1, 1 do
				self.deckVis:banish(i)
			end
			
			local finally
			
			for i=1, #self.playerVisuals, 1 do
				
				if i == #self.playerVisuals then  finally = visualizeTheRestOfTheStuff end
				
				self.playerVisuals[i]:render(bind(self.deckVis, 'draw'), finally)
			end
			
			-- hmmm. add event listeners? need to stall for
			-- game:beginTurn()
			-- show some fancy start turn banner
			-- self.deckVis
		end
		
		self.deckVis:render(display.contentCenterX+100, display.contentCenterY, visDealCards)

      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene