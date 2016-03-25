local makeReadonlyTable = function(aTable)
	return setmetatable({}, {
		__metatable = false, --prevents messing with the metatable like i am doing now
		__index = aTable,
		__newindex = function()error("Attempt to modify read-only table")end
	})
end

local cardPixelWidth, cardPixelHeight = 71, 100

core = makeReadonlyTable({
	cardPixelWidth = cardPixelWidth,
	cardPixelHeight = cardPixelHeight,
	--todo: most likely move this to one of the vis module as private funcs
	-- also need to add a switch that determines if it is upsidedown or not.
	calcHandXY = function(playerIndex) return playerIndex == 1 and display.contentCenterX, display.actualContentHeight or display.contentCenterX, 0 end,
	calcCardPoint = function(cardCount, pos) return ((cardCount*cardPixelWidth)*-.5) + (cardPixelWidth*pos) - (cardPixelWidth*.5)end,
	calcCardRotation = function(cardCount, pos) return (-4.5*(cardCount*.5)) + (pos*4.5) end
})