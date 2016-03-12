local game = require('core.game')
local composer = require('composer')
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

local function onTouch( event )
	local card = event.target
	
	-- Print info about the event. For actual production code, you should
	-- not call this function because it wastes CPU resources.
	print('x:'..card.x, 'y:'..card.y)
	
	local phase = event.phase
	if "began" == phase then
		-- Make target the top-most object
		local parent = card.parent
		parent:insert( card )
		display.getCurrentStage():setFocus( card )
		
		-- Spurious events can be sent to the target, e.g. the user presses 
		-- elsewhere on the screen and then moves the finger over the target.
		-- To prevent this, we add this flag. Only when it's true will "move"
		-- events be sent to the target.
		card.isFocus = true
		
		-- Store initial position
		card.x0 = event.x - card.x
		card.y0 = event.y - card.y
	elseif card.isFocus then
		if "moved" == phase then
			-- Make object move (we subtract t.x0,t.y0 so that moves are
			-- relative to initial grab point, rather than object "snapping").
			card.x = event.x - card.x0
			card.y = event.y - card.y0
			
			-- Gradually show the shape's stroke depending on how much pressure is applied.
			if ( event.pressure ) then
				card:setStrokeColor( 0, 255, 0, event.pressure )
			end
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			card:setStrokeColor( 1, 1, 1, 0 )
			card.isFocus = false
		end
	end

	-- Important to return true. This tells the system that the event
	-- should not be propagated to listeners of any objects underneath.
	return true
end

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )

    print_r('LOG: Loading Sandbox with game state', game.state)

	-- in practice mode, the game will create itself. later on, ill need to server to send initial gamestate and updates to the client
	
    local gameOptions = {
        playerCount = 2,
        playerNames = {'James', 'Bill'},
        startingHandAmount = 1,
        turnDrawAmount = 1
    }

    game:init(gameOptions)

    print_r('LOG: game has beeen initialized successfully')

    for _, player in ipairs(game.players) do
        
        for __, card in ipairs(player.hand.cards) do
            --todo: set player color and touch restriction(only make touchable cards for yourself)

			local cardView

			if(player.name == 'James') then
				
				cardView = display.newImage(card.img)
				cardView:addEventListener('touch', onTouch)
			else
				cardView = display.newImage('img/cards/000_back.png')
			end
			
			cardView.width, cardView.height = 71, 100
        end
    end
end




-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
      
   elseif ( phase == "did" ) then
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