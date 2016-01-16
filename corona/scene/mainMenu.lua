local widget = require('widget')
local composer = require('composer')

local scene = composer.newScene()
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )
	-- Initialize the scene here.
	-- Example: add display objects to "sceneGroup", add touch listeners, etc.

	local sceneGroup = self.view
   
	local back = display.newImage('img/background.png')
	back.x, back.y = display.contentCenterX, display.contentCenterY
	back.width, back.height = display.actualContentWidth, display.actualContentHeight
	
	local practiceButton = widget.newButton{
		defaultFile = 'img/buttonYellow.png',
		overFile = 'img/buttonYellowOver.png',
		label = 'Practice',
		emboss = true,
		onPress = function() end,
		onRelease = function() composer.gotoScene('scene.sandbox') end
	}
	
	local multiPlayerButton = widget.newButton{
		defaultFile = 'img/buttonYellow.png',
		overFile = 'img/buttonYellowOver.png',
		label = 'Multiplayer',
		emboss = true,
		onPress = function() end,
		onRelease = function() end
	}
	
	local campaignButton = widget.newButton{
		defaultFile = 'img/buttonYellow.png',
		overFile = 'img/buttonYellowOver.png',
		label = 'Campaign',
		emboss = true,
		onPress = function() end,
		onRelease = function() end
	}
	
	local settingsButton = widget.newButton{
		defaultFile = 'img/buttonYellow.png',
		overFile = 'img/buttonYellowOver.png',
		label = 'Settings',
		emboss = true,
		onPress = function() end,
		onRelease = function() end
	}
	
	-- todo: add a button for running test cases.
	
	practiceButton.x = display.contentCenterX
	multiPlayerButton.x = display.contentCenterX
	campaignButton.x = display.contentCenterX
	settingsButton.x = display.contentCenterX
	
	practiceButton.y = display.contentCenterY * .6
	multiPlayerButton.y = display.contentCenterY * .9
	campaignButton.y = display.contentCenterY * 1.2
	settingsButton.y = display.contentCenterY * 1.5
	
	sceneGroup:insert(back)
	sceneGroup:insert(practiceButton)
	sceneGroup:insert(multiPlayerButton)
	sceneGroup:insert(campaignButton)
	sceneGroup:insert(settingsButton)
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