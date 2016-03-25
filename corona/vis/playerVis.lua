local playerVisTemplate = {
	index = 0,
	model = nil,
	handImages = nil
}

function playerVisTemplate:render(drawCardThen)

	self.handImages = display.newGroup()
		
	self.handImages.x, self.handImages.y = display.contentCenterX, display.actualContentHeight--todo: core.calcHandXY(self.index)

	local orderedFuncs = {}
	
	for position, card in ipairs(self.model.hand.cards) do
		
		table.insert(orderedFuncs, function()
			local moveToX = self.handImages.x + core.calcCardPoint(#self.model.hand.cards, position)
			local moveToY = self.handImages.y -- its possible for me to do a double tier hand. for now don't do this. shrink cardsize instead
			
			local previousFunc = orderedFuncs[position-1]
			drawCardThen(moveToX, moveToY, self:flipCard(card, position, previousFunc))
		end)
	end
	
	orderedFuncs[#orderedFuncs]()
end

function playerVisTemplate:flipCard(card, position, onAnimationEnd)
	
	--todo: make generic curry
	
	return function(deckCardImage)
		
		return function()
	
			local cardsInHand = #self.model.hand.cards
			local rotateTo = core.calcCardRotation(cardsInHand, position)
	
			transition.to(deckCardImage, {time=175, width=0, height=core.cardPixelHeight, rotation=rotateTo, onComplete=function()
				
				deckCardImage:removeSelf() deckCardImage = nil
			
				local cardView--instead of managing the cards like this. create a cardVis to handle the events, init, position, rotation
				print("flipping over: "..card.name)
				cardView = display.newImageRect(self.handImages, card.img, core.cardPixelWidth, core.cardPixelHeight)
				cardView.data = card --todo: this should be depricated with the vis series
				
				cardView.x = core.calcCardPoint(cardsInHand, position)
				cardView.rotation = rotateTo
				--cardView:addEventListener('touch', onCardHover)
				cardView.width, cardView.height = 0, core.cardPixelHeight
				transition.to(cardView, {time=175, width=core.cardPixelWidth, onComplete=onAnimationEnd})
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

-------------------------------------------------------------------------------------------------

return {
	create = function(model)
		local vis = table.deepCopy(playerVisTemplate)
		vis.index = model.index
		vis.model = model
		return vis
	end
}