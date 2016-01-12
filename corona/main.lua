-- entry point
--require("mobdebug").start()

local composer = require('composer')

local main = {
    splash = nil,
    text = nil,
}

local function run()
    
    print("Runnning LuaLoveLetter")
    
    main:showSplashScreen()
    
    timer.performWithDelay(3000, main)
end

function main:showSplashScreen()
    -- the splash screen is interactive in that it has an event listener attached to the text object. I want it to be like the dbz game loading screens. Interactive.
    
    self.splash = display.newImage("img/splash.png")
    
    self.splash.x = display.contentCenterX * .75
    
    self.text = display.newText(
    "Lua Love Letter", 
    display.contentCenterX * 1.1, 
    display.contentCenterY * .9, 
    "Arial", 
    30)

    --changes to top left anchoring (default is center anchor 0.5 0.5)
    self.text.anchorX = 0
    self.text.anchorY = 0
    self.text.onScreenTap = function() self.text:setFillColor(self.getRandomRGB()) end

    self.text:setFillColor(1, 1, 0)
    
    display.currentStage:addEventListener("tap", self.text.onScreenTap)
    
end

function main.getRandomRGB()
  return math.random(0,100*.01), math.random(0,100*.01), math.random(0,100*.01)
end

--
--begin game!
function main:timer()
    print("Begin Game")
    display.currentStage:removeEventListener("tap", self.text.onScreenTap)
    self.splash:removeSelf()
    self.text:removeSelf()
    self.splash = nil
    self.text = nil
    
    composer.gotoScene('scene.mainMenu', {
        effect = 'fade',
        time = 500
    })
end

run()