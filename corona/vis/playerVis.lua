local cardVisModule = require('vis.cardVis')

local playerVisTemplate = {
	index = 0,
	model = nil,
	images = nil, --note: container for all images and display groups. used to keep positioning relative to hand position center
	cardVisuals = {} --todo: needs to be an array of cardVis
}

--todo: mod the render based on isLocal player or not. just use index==1
-- the flipCard needs to be different and the locations need to be different, everything else should be the same 
-- (the cardVis can be a different lighter object that has the same interface. maybe.. for now use the same. dont flip flip the image or add touch listeners)
function playerVisTemplate:render(drawFunc, onAnimationEnd)

	--todo: display avatar, player name, status (needs to be based on perspective. not the same render for local player and enemy player)
		
	self.images.x, self.images.y = self:calcHandXY()

	local orderedFuncs = {}
	
	local cardCount = #self.model.hand.cards
	
	--note: this must be in reverse so that the index for the vis array lines up with the dataModel array
	for cardIndex = cardCount, 1, -1 do
		
		table.insert(orderedFuncs, function()
			local previousFunc = orderedFuncs[cardCount-cardIndex] or onAnimationEnd
			self:draw(cardIndex, drawFunc, previousFunc)
		end)
	end
	
	orderedFuncs[#orderedFuncs]()
end

--animates a card draw to the playerVis hand AND readjusts existing cards
--todo: split out realignment
function playerVisTemplate:draw(cardIndex, drawFunc, onAnimationEnd)
	
	local card = self.model.hand.cards[cardIndex]
	
	local moveToX, moveToY = self:calcCardXY(#self.model.hand.cards)
	
	moveToX, moveToY = moveToX+self.images.x , moveToY+self.images.y
	
	drawFunc(moveToX, moveToY, self:flipCard(card,
			function() 
				self:alignHand()
				if(onAnimationEnd)then onAnimationEnd() end
	end))
end

function playerVisTemplate:alignHand()
	for i=1, self.images.numChildren, 1 do
		
		local moveToX, moveToY = self:calcCardXY(i)
			
		transition.to(self.images[i], {time=200+i*math.random(1,50), x=moveToX, y=moveToY})
		
	end
end

--todo: no longer need in flip now that card stores index locally on self
function playerVisTemplate:flipCard(card, onAnimationEnd)
	
	--todo: make generic curry
	
	return function(deckCardImage)
		
		return function()
	
			local cardsInHand = #self.model.hand.cards
			local rotateTo = self:calcCardRotation(card.index)
	
			--this last transition can either be skipped, or i can manip the cardVis init
			transition.to(deckCardImage, {time=core.flipDelay, width=0, height=core.cardPixelHeight, rotation=rotateTo, onComplete=function()
				
				deckCardImage:removeSelf() deckCardImage = nil
			
				local cardVis = cardVisModule.create(card, self)
				
				local x, y = self:calcCardXY(cardsInHand+1)--always slide
				
				cardVis:render({x=x, y=y, r=rotateTo}, onAnimationEnd)
				table.insert(self.cardVisuals, cardVis)
			end})
		end
	end
	
	-- somehow
	-- shrink card image inward horizontal from deckVis
	-- destroy card image and ref with nil set i think there is a displayGroup:remove(cardView)
	-- create faceup card and expand horizontally in the same place
	-- conform card to hand positioning
	-- attach the touch listeners to the card.
end


function playerVisTemplate:calcHandXY()
	
	local meah = {
		--1: bottom
		function() return display.contentCenterX, display.actualContentHeight end,
		--2: top
		function() return display.contentCenterX, 0 end,
		--3: left
		function() return 0, display.contentCenterY end,
		--4: right
		function() return display.actualContentWidth, display.contentCenterY end
	}

	return meah[self.index]()
end

--todo, add in rotation?
function playerVisTemplate:calcCardXY(cardIndex)
	local calc = {
		--1: bottom
		function() return ((self.images.numChildren*core.cardPixelWidth)*-.5) + (core.cardPixelWidth*cardIndex) - (core.cardPixelWidth*.5), 0 end,
		--2: top
		function() return ((self.images.numChildren*core.cardPixelWidth)*-.5) + (core.cardPixelWidth*cardIndex) - (core.cardPixelWidth*.5), 0 end
	}
	
	return calc[self.index]()
end

--todo: add to calcCardXYR ?
function playerVisTemplate:calcCardRotation(cardIndex)
	local calc = {
		function() return (-4.5*(#self.model.hand.cards*.5)) + (cardIndex*4.5) end,
		function() return 180 + (-4.5*(#self.model.hand.cards*.5)) + (cardIndex*4.5) end
	}
	return calc[self.index]()
end

-------------------------------------------------------------------------------------------------
return {
	create = function(model)
		local vis = table.deepCopy(playerVisTemplate)
		vis.index = model.index
		vis.model = model
		vis.images = display.newGroup()
		return vis
	end
}