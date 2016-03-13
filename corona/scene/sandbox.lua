local game = require('core.game')
local composer = require('composer')
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

local selCard

local function unTiltCard()
    if(selCard.isFocus) then
        selCard.path.x1, selCard.path.x2, selCard.path.x3 ,selCard.path.x4 = selCard.path.x1*.9, selCard.path.x2*.9, selCard.path.x3*.9 ,selCard.path.x4*.9
        selCard.path.y1, selCard.path.y2, selCard.path.y3 ,selCard.path.y4 = selCard.path.y1*.9, selCard.path.y2*.9, selCard.path.y3*.9 ,selCard.path.y4*.9
    end
end

local function onTouch( event )
	local card = event.target
	
    
	local phase = event.phase
	if "began" == phase then
		-- Make target the top-most object
		local parent = card.parent
		parent:insert( card )
		display.getCurrentStage():setFocus( card )
		
        selCard = card
        Runtime:addEventListener("enterFrame", unTiltCard)
        -- add event listener for every frame
        
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
            local oldX = card.x
            local oldY = card.y
            local newX = event.x - card.x0
            local newY = event.y - card.y0
            
            --if there is any drag movement from the touch then tilt the card
            if((newX+newY) ~= math.ceil(oldX+oldY)) then
                
                print("old:"..oldY, "new"..newY)
                
                local lessX = (card.contentWidth * .0025) + math.abs((card.path.x1+card.path.x2+card.path.x3+card.path.x4)*.5)
                local lessY = (card.contentHeight * .0025) + math.abs((card.path.y1+card.path.y2+card.path.y3+card.path.y4)*.5)
                
                local dragLeft = 0
                local dragRight = 0
                if(math.abs(oldX-newX) > 1.5) then
                    dragLeft = math.clamp(math.sign(oldX-newX) * lessX, 0, card.contentWidth*.5)
                    dragRight = math.clamp(math.sign(oldX-newX) * lessX, -card.contentWidth*.5, 0)
                end

                local dragUp = math.clamp(math.sign(oldY-newY) * lessY, 0, card.contentHeight*.1)
                local dragDown = math.clamp(math.sign(oldY-newY) * lessY, -card.contentHeight*.1, 0)          
                
                local xMod = .3
                local yMod = .2
                
                card.path.x1 = dragLeft + (dragUp*yMod)
                card.path.x2 = dragLeft + (dragDown*-yMod)
                card.path.y1 = (dragLeft*xMod) + dragUp
                card.path.y2 = dragLeft*-xMod + dragDown
                
                card.path.x4 = dragRight + (dragUp*-yMod)
                card.path.x3 = dragRight + (dragDown*yMod)
                card.path.y4 = dragRight*-xMod + dragUp
                card.path.y3 = dragRight*xMod + dragDown
            end
            
            transition.to( card, { time=35, x=newX, y=newY } )
            
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			card.isFocus = false
            
            card.path.x1, card.path.x2, card.path.x3 ,card.path.x4 = 0,0,0,0
            card.path.y1, card.path.y2, card.path.y3 ,card.path.y4 = 0,0,0,0
            Runtime:removeEventListener("enterFrame", unTiltCard)
            -- remove animation event
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
                cardView.x = display.contentCenterX
                cardView.y = display.contentCenterY
				cardView:addEventListener('touch', onTouch)
			else
				cardView = display.newImage('img/cards/000_back.png')
                cardView.x = display.contentCenterX
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