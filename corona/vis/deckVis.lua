local deckVisTemplate = {
	model = nil,
	images = nil,
	banishImages = nil,
	discardImages = nil,
	nextIndex = 0
}

function deckVisTemplate:render(deckX, deckY, onAnimationEnd)

	self.images.x, self.images.y = deckX, deckY
	self.banishImages.x, self.banishImages.y = deckX -core.cardPixelWidth, deckY
	
	local dropCardAnimation = {
		width=core.cardPixelWidth*.5,
		height=core.cardPixelHeight*.5, --todo: change to scale?
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
		banned.fill.effect = "filter.sepia"
		banned.fill.effect.intensity = 1
		banned.width, banned.height= core.cardPixelWidth*.5, core.cardPixelHeight*.5
		banned.rotation = math.random(-30, 30)
		banned.x, banned.y = 0, -index
	end})
end

function deckVisTemplate:toggleBanishShowcase(event)
	--todo: clean this up
	
	self.banishImages:toFront()

	if (event.phase == "began" and self.isShowcasing) then
		
		self.isShowcasing = false
		
		self.trigBanishShowcase.width, self.trigBanishShowcase.height = core.cardPixelWidth*.5, core.cardPixelHeight*.5
		self.trigBanishShowcase.x, self.trigBanishShowcase.y = self.banishImages.x, self.banishImages.y

		for i=1, self.banishImages.numChildren, 1 do
			--todo: the scale is currently crazy. fix it up from the beginning to be the size adjustor
			transition.to(self.banishImages[i], {time = 250, x = 0, y = 0, rotation = math.random(-30,30), xScale=1, yScale=1})
		end

	else
		self.isShowcasing = true

		local sizeScale = 4

		transition.to(self.trigBanishShowcase, {time=510, x=display.contentCenterX, y=display.contentCenterY, width=display.contentWidth, height=display.contentHeight})

		for i=1, self.banishImages.numChildren, 1 do
			--todo: will have to convert into an image group with all the attachments
			local x, y = self:calcShowcaseCardXY(self.banishImages.numChildren, i, sizeScale)
			
			x, y = x + display.contentCenterX - self.banishImages.x, y + display.contentCenterY - self.banishImages.y
		
			transition.to(self.banishImages[i], {time = 500, x = x, y = y, rotation = 0, xScale=sizeScale, yScale=sizeScale})
		end
	end

	-- for i=1, #game.deck.banishPile, 1 do
	-- calc position like hand, except move it to screen center.
	-- have horizontal scroll functionality with chain border
	-- (fade the background with transparent cover) touching the cover will cancel the banish view
end

--todo: most likely have at least two showcase types.
function deckVisTemplate:calcShowcaseCardXY(cardCount, cardIndex, scale)
		local cardSize = (core.cardPixelWidth*.5)*scale--the .5 is fixed and should not be.
		local shiftRight = cardIndex+1
		--		left offset					position			center offset  y
		return (-cardCount*cardSize) + (cardSize*shiftRight) + (cardSize*.5),  0
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