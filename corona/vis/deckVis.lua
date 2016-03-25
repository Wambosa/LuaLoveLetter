local deckVisTemplate = {
	model = nil,
	images = nil
}

function deckVisTemplate:render(deckX, deckY, onAnimationEnd)

	self.images = display.newGroup()
	self.images.x, self.images.y = deckX, deckY
	
	local dropCardAnimation = {
		time=550,
		width=core.cardPixelWidth*.5,
		height=core.cardPixelHeight*.5, 
	}
	
	for i=1, self.model.cardLimit, 1 do
		local cardImage
		cardImage = display.newImage(self.images, 'img/cards/000_back.png')
		cardImage.width, cardImage.height = core.cardPixelWidth*3, core.cardPixelHeight*3
		cardImage.rotation = math.random(-30, 30)
		cardImage.x, cardImage.y = 0, -i
		
		dropCardAnimation.time = 550+(i*75)
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
	local topCard = self.images[self.images.numChildren]
	--transition.cancel(topCard)
	transition.to(topCard, {time=250, x=toX-self.images.x, y=toY-self.images.y, onComplete=onAnimationEnd(topCard)})
end

-------------------------------------------------------------------------------------------------

return {
	create = function(model)
		local newVisual = table.deepCopy(deckVisTemplate)
		newVisual.model = model
		return newVisual
	end
}