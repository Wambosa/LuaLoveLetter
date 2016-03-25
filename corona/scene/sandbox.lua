local game = require('core.game')
local composer = require('composer')
local scene = composer.newScene()
local deckVisModule = require('vis.deckVis')
local playerVisModule = require('vis.playerVis')

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

local selCard

--todo: make this a part of the cardView so that i don't have to keep a selCard global
local function unTiltCard()
    if(selCard.isFocus) then
		local unTilt = .9
		--todo: try transition for a more clear meaning
        selCard.path.x1, selCard.path.x2, selCard.path.x3 ,selCard.path.x4 = selCard.path.x1*unTilt, selCard.path.x2*unTilt, selCard.path.x3*unTilt ,selCard.path.x4*unTilt
        selCard.path.y1, selCard.path.y2, selCard.path.y3 ,selCard.path.y4 = selCard.path.y1*unTilt, selCard.path.y2*unTilt, selCard.path.y3*unTilt ,selCard.path.y4*unTilt
    end
end

local function onCardHover( event )
	local card = event.target
	
	local phase = event.phase
	
	print(event.phase.." detected on "..card.data.name)
	
	
	local deselectCard = function(obj)
		display.getCurrentStage():setFocus( nil )
		obj.isFocus = false
		--transition back down to origin position
		card.fill.effect = nil
		card.strokeWidth = 0
		transition.cancel(obj)
		transition.to(obj, {time=100, y=0, width=71, height=100})
	end
	
	if "moved" == phase or "began" == phase then
	
		-- Make target the top-most object
		local parent = card.parent
		parent:insert( card )
		
		display.getCurrentStage():setFocus( card )
		
		if(not card.isFocus) then
			card.y = -100
			card.width, card.height = 142, 200
			
			--card.stroke.effect = "generator.marchingAnts"
			local reStroke, unStroke
			reStroke = function() transition.to(card, {time=50, strokeWidth=5, onComplete=unStroke}) end
			unStroke = function() transition.to(card, {time=50, strokeWidth=.1, onComplete=reStroke}) end

			reStroke()
			 --can play with the glow speed according to the power of the card
			transition.to(card, {time=3000, y=-120, width=142, height=200})
			
			card.strokeWidth=.1
			card:setStrokeColor(57,255,20, 1)
			-- try a stroke effect tranparent fade
			
			--card.fill.effect = "filter.swirl"
			--transition.to(card.fill.effect, {time=2500, intensity=10})
			--highlight somehow
		end
		
		-- To prevent this, we add this flag. Only when it's true will "move"
		card.isFocus = true
		
		local trueX, trueY = card:localToContent(0,0)
		local relX, relY = event.x-trueX, event.y-trueY
		
		print("relative", relX, relY)
		
		--try to detect upward movement
		if(relY < -50) then
			--transition out of handMode and into free mode
			print("todo: begin free mode for "..card.data.name)
		end
		
		if(math.abs(relX) > 75) then
			deselectCard(card)
		end
            
	elseif "ended" == phase or "cancelled" == phase then
		deselectCard(card)
	end
	
	return true
end

local function onTouch( event )
	local card = event.target
	
    
	local phase = event.phase
	if "began" == phase then
		-- Make target the top-most object
		--local parent = card.parent
		--parent:insert( card )
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
			--todo: only want this behavior in free drag mode (after users has snapped the card out of hand for use)
            if((newX+newY) ~= math.ceil(oldX+oldY)) then
                
                local lessX = (card.contentWidth * .0075) + math.abs((card.path.x1+card.path.x2+card.path.x3+card.path.x4)*.5)
                local lessY = (card.contentHeight * .005) + math.abs((card.path.y1+card.path.y2+card.path.y3+card.path.y4)*.5)
                
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
                card.path.y2 = (dragLeft*-xMod) + dragDown
                
				card.path.x3 = dragRight + (dragDown*yMod)
                card.path.x4 = dragRight + (dragUp*-yMod)
				card.path.y3 = (dragRight*xMod) + dragDown
                card.path.y4 = (dragRight*-xMod) + dragUp
            end
			
            transition.cancel(card) -- seems like a good perf boost. there was some serious lag with abusive drag motions
            transition.to( card, { time=35, x=newX, y=newY } )
			print("move", "x:"..newX, "y:"..newY)
            
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

    local gameOptions = {
        playerCount = 2,
        playerNames = {'James', 'Bill'},
        startingHandAmount = 5, --todo: this is really one. change back to 1 later
        turnDrawAmount = 1
	}

	game:init(gameOptions)

	game.deckVis = deckVisModule.create(game.deck)
	game.playerVis = playerVisModule.create(game.players[1]) --this is gonna be cool, since i can animate the name and hand on render. I just need to trigger
	
	--todo: create an array of player cardGroups. same as player number to access the group

end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
      
   elseif ( phase == "did" ) then
		
		local showPlayerVis = function()
			game.playerVis:render(bind(game.deckVis, 'draw'))
		end
		
		game.deckVis:render(display.contentCenterX+100, display.contentCenterY, showPlayerVis)
		

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