-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------


local text = display.newText("Lua Love Letter", display.contentCenterX, display.contentCenterY, "Arial", 20)

--changes to top left anchoring (default is center anchor 0.5 0.5)
text.anchorX = 0
text.anchorY = 0

text:setFillColor(1, 0, 1)

print(text.anchorX)


function screenTap()
  local r,g,b = math.random(0,100*.01), math.random(0,100*.01), math.random(0,100*.01)
  text:setFillColor(r,g,b)
end

display.currentStage:addEventListener("tap", screenTap)