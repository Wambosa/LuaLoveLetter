local makeReadonlyTable = function(aTable)
	return setmetatable({}, {
		__metatable = false, --prevents messing with the metatable like i am doing now
		__index = aTable,
		__newindex = function()error("Attempt to modify read-only table")end
	})
end

local cardPixelWidth, cardPixelHeight = 71, 100 --note: these measurements are as seen in hand. (unfocused)

core = makeReadonlyTable({
	cardBackImg = 'img/cards/000_back.png',
	
    tableScratchFont = "secret.ttf",
    
	--size: some common sizes i keep on referencing
	cardPixelWidth = cardPixelWidth,
	cardPixelHeight = cardPixelHeight,
	cardFocusZoom = 2.5,
	cardDragZoom = .75,
    cardTableZoom = .5,
	
	--time: delay in milliseconds
	flipDelay = 150,
	slideDelay = 350
})