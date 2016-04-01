local deckVisTemplate = {
	model = nil,
	images = nil,
	banishImages = nil,
	discardImages = nil,
	nextIndex = 0
}

function deckVisTemplate:render(deckX, deckY, onAnimationEnd)

	self.images.x, self.images.y = deckX, deckY
	self.banishImages.x, self.banishImages.y = deckX, deckY-core.cardPixelHeight*.55
	
	local dropCardAnimation = {
		width=core.cardPixelWidth*.5,
		height=core.cardPixelHeight*.5, 
	}
	
	for i=1, self.model.cardLimit, 1 do
		local cardImage
		cardImage = display.newImage(self.images, core.cardBackImg)
		cardImage.width, cardImage.height = core.cardPixelWidth*3, core.cardPixelHeight*3
		cardImage.rotation = math.random(-30, 30)
		cardImage.x, cardImage.y = 0, -i
		
		dropCardAnimation.time = 333 + (i*75)
		dropCardAnimation.rotation=-45 + math.random(-20, 20)
		
		if(i == self.model.cardLimit and onAnimationEnd) then
			dropCardAnimation.onComplete = onAnimationEnd
			transition.to(cardImage, dropCardAnimation)
		else
			transition.to(cardImage, dropCardAnimation)
		end
	end
end

function deckVisTemplate:draw(toX, toY, onAnimationEnd)
	local topCard = self.images[self:next()]
	--transition.cancel(topCard)
	transition.to(topCard, {time=core.slideDelay, x=toX-self.images.x, y=toY-self.images.y, onComplete=onAnimationEnd(topCard)})
end

function deckVisTemplate:banish(index)
	
	local topCard = self.images[self:next()]
	
	--todo: apply a filter to the card to clearly show its banishment, slight rotation and slight y+ offset
	
	transition.to(topCard, {time=core.slideDelay, x=0, y=0, onComplete=function() 
		
		topCard:removeSelf() topCard = nil
		local banned = display.newImage(self.banishImages, self.model.banishPile[index].img)
		--sound effect of banished units
		banned.fill.effect = "filter.sobel"
		banned.width, banned.height = core.cardPixelWidth*.5, core.cardPixelHeight*.5
		banned.rotation = math.random(-30, 30)
		banned.x, banned.y = 0, -index
	end})
end

function deckVisTemplate:next()
	self.nextIndex = self.nextIndex-1
	return self.nextIndex+1
end

-------------------------------------------------------------------------------------------------

return {
	create = function(model)
		local deckVis = table.deepCopy(deckVisTemplate)
		deckVis.model = model
		deckVis.banishImages = display.newGroup()
		deckVis.discardImages = display.newGroup()
		deckVis.images = display.newGroup()
		deckVis.nextIndex = model.cardLimit
		return deckVis
	end
}