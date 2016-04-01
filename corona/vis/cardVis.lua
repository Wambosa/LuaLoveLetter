local cardVisTemplate = {
	state = 'inHand', -- inHand, inMotion, inPlay
	model = nil,
	images = nil,
	parent = nil,
	--todo: move out of declaration so that i can use bind and remove the self arg
	touchHandler = {
		inHand = function(self, touchPos, img, phase)
			
			if "moved" == phase or "began" == phase then
				if(not img.isFocus) then
					img.isFocus = true
					--note: make target the top-most object (remember that this may get more complex as more objects are added to the scene)
					
					--todo: scene.images:insert(self.parent.images)
					self.parent.images:insert( self.images )
					display.getCurrentStage():setFocus( img )
					
					self:anim_slowHandRise()
					--self:anim_edgeFlash()
				end
				
				local trueX, trueY = img:localToContent(0,0)
				local relX, relY = touchPos.x-trueX, touchPos.y-trueY
				
				
				--if the touch moves too far sideways, then blur
				if(math.abs(relX) > core.cardPixelWidth) then
					self:blur(img)
				end
				
				--warn: nothing inHand can happen after this is triggered! (detect upward movement && transition state)
				if(relY < -core.cardPixelHeight*.25 and self.parent.model.state == 'turn') then
					print("cardState: inMotion for "..self.model.name)
					self.state = 'inMotion'
				end

			elseif "ended" == phase or "cancelled" == phase then
				self:blur(img)
				self.state = 'inHand'
			end		
		end,
		
		inMotion = function(self, touchPos, img, phase)
			--can inMotion begin without first being focused from inHand ??? currently no.
 
			if "began" == phase then
				self.state = 'inHand'
				self:blur(img)				
				--error('touchHandler.inMotion began phase should never be hit!!!')
			end
			
			if "moved" == phase then
				
				if(not img.isMoving) then
					img.isMoving = true
					--todo: this works right now because the card is a single object. will have to see if the group can have its path altered
					self.enterFrame = function() self:unTiltCard() end
					
					Runtime:addEventListener("enterFrame", self.enterFrame)
				
					-- Store initial position. i hope that i do not need this anymore
					img.x0 = touchPos.x - self.images.x
					img.y0 = touchPos.y - self.images.y
				end
				
				if(img.isMoving) then
					-- Make object move (we subtract t.x0,t.y0 so that moves are
					-- relative to initial grab point, rather than object "snapping").
					local oldX = self.images.x
					local oldY = self.images.y
					local newX = touchPos.x - img.x0
					local newY = touchPos.y - img.y0

					--if there is any drag movement from the touch then tilt the card immediately (no transition)
					self:tiltCard({x=oldX, y=oldY}, {x=newX, y=newY})

					if(self.images.xScale == core.cardFocusZoom) then
						transition.to( self.images, { time=200, xScale=core.cardDragZoom, yScale=core.cardDragZoom } )
					elseif(self.images.xScale == core.cardDragZoom) then
						transition.cancel(self.images) --perf: there was some serious lag with abusive drag motions
					end
					
					transition.to( self.images, { time=35, x=newX, y=newY } )
				end

			elseif "ended" == phase or "cancelled" == phase then

				print('todo: activate effect if in play zone and isPlayable', img:localToContent(0,0))

				display.getCurrentStage():setFocus( nil )
				Runtime:removeEventListener("enterFrame", self.enterFrame)

				self.state = 'inHand'
				self:blur(img)
			end
		end
	}
}

function cardVisTemplate:render(xyr, onAnimationEnd)
	
	
	print("flipping over: "..self.model.name)

	local cardFileName = self.parent.model.index == 1 and self.model.img or core.cardBackImg

	--todo: each card will be its own display group (not just a pre baked image)
	local cardView
	cardView = display.newImageRect(self.images, cardFileName, core.cardPixelWidth, core.cardPixelHeight)
	
	if self.parent.model.index == 1 then
		cardView:addEventListener('touch', bind(self, 'onCardTouch'))
	end
	
	cardView.width, cardView.height = 0, core.cardPixelHeight
	
	self.images.x = xyr.x
	self.images.rotation = xyr.r
	
	-- note: a test sibling object that i need to consider later on. the tilt requires much more positional computing to look right.
	-- only make one piece of the card move/tilt (like the seperatable piece) then shift the rest off screen
	-- display.newRect(self.images, -core.cardPixelWidth*.5, -cardView.contentHeight*.5, 7, 7)
	
	transition.to(cardView, {time=core.flipDelay, width=core.cardPixelWidth, onComplete=onAnimationEnd})
end

--note: points to a dictionary of touch handlers
function cardVisTemplate:onCardTouch( event )
	--todo: change the way this behaves based on the state. dictionary mapping string-func or something
	local img = event.target
	--prolly dont need to do this img set anymore since the self, should contain the img
	
	local phase = event.phase
	
	self.touchHandler[self.state](self, {x=event.x, y=event.y}, img, phase)
	
	return true --this prevents event bubble up
end

--animation: move - lifts the card into focus and magnifies x2
function cardVisTemplate:anim_slowHandRise()
	self.images.y = -core.cardPixelHeight*.5*core.cardFocusZoom
	self.images.xScale, self.images.yScale = core.cardFocusZoom, core.cardFocusZoom
	transition.to(self.images, {time=5000, y=(-core.cardPixelHeight*core.cardFocusZoom)*.55})
end
--animation: custom - in a loud flash of the imageRect edges. seems to always be white?
function cardVisTemplate:anim_edgeFlash()
	local reStroke, unStroke
	reStroke = function() transition.to(self.images, {time=50, strokeWidth=5, onComplete=unStroke}) end
	unStroke = function() transition.to(self.images, {time=50, strokeWidth=.1, onComplete=reStroke}) end

	reStroke()

	img.strokeWidth=.1
	img:setStrokeColor(57,255,20, 1)
end

--note: since the group does not have path manipulation. each image object within the group must be manipulated together.
function cardVisTemplate:tiltCard(old, new)
	--todo: only want this behavior inMotion state (after users has snapped the card out of hand for use)
	if((new.x+new.y) ~= math.ceil(old.x+old.y)) then
		
		for i=1, self.images.numChildren, 1 do
			
			local img = self.images[i]
			
			local lessX = (img.contentWidth * .0075) + math.abs((img.path.x1+img.path.x2+img.path.x3+img.path.x4)*.5)
			local lessY = (img.contentHeight * .005) + math.abs((img.path.y1+img.path.y2+img.path.y3+img.path.y4)*.5)
			
			local dragLeft = 0
			local dragRight = 0
			if(math.abs(old.x-new.x) > 1.5) then
				dragLeft = math.clamp(math.sign(old.x-new.x) * lessX, 0, img.contentWidth*.5)
				dragRight = math.clamp(math.sign(old.x-new.x) * lessX, -img.contentWidth*.5, 0)
			end

			local dragUp = math.clamp(math.sign(old.y-new.y) * lessY, 0, img.contentHeight*.1)
			local dragDown = math.clamp(math.sign(old.y-new.y) * lessY, -img.contentHeight*.1, 0)          
			
			local xMod = .3
			local yMod = .2
			
			img.path.x1 = dragLeft + (dragUp*yMod)
			img.path.x2 = dragLeft + (dragDown*-yMod)
			img.path.y1 = (dragLeft*xMod) + dragUp
			img.path.y2 = (dragLeft*-xMod) + dragDown
			
			img.path.x3 = dragRight + (dragDown*yMod)
			img.path.x4 = dragRight + (dragUp*-yMod)
			img.path.y3 = (dragRight*xMod) + dragDown
			img.path.y4 = (dragRight*-xMod) + dragUp
		end
	end
end
--note: this is pretty rough implmentation, but it works well for a single image. multiple images can get visually tricky
function cardVisTemplate:unTiltCard()
	--note: multiply by .9 every frame to slowly reduce the number to zero (i know its crazy)
	for i=1, self.images.numChildren, 1 do
		local img = self.images[i]
		local tilt = .9
		img.path.x1, img.path.x2, img.path.x3, img.path.x4 = img.path.x1*tilt, img.path.x2*tilt, img.path.x3*tilt, img.path.x4*tilt
		img.path.y1, img.path.y2, img.path.y3, img.path.y4 = img.path.y1*tilt, img.path.y2*tilt, img.path.y3*tilt, img.path.y4*tilt
	end
end
--note: reset styling on focus loss. ever evolving WIP. needs to call another method self:reset that determines what it should currently look like
function cardVisTemplate:blur(img)
	--this is limited to the inHand position as well... need a way to store of generic the position that it returns to. maybe store a default position on the cardVisTemplate. it can be changed based on certain events
	--this blur function does not account for child objects... hmmm
	--this is waay too global. maybe there is a way to only do this if the img object is the current focus
	display.getCurrentStage():setFocus( nil )
	img.isFocus, img.isMoving = false, false
	img.fill.effect = nil
	img.strokeWidth = 0
	
	for i=1, self.images.numChildren, 1 do
		local img = self.images[i]
		img.path.x1, img.path.x2, img.path.x3, img.path.x4 = 0,0,0,0
		img.path.y1, img.path.y2, img.path.y3, img.path.y4 = 0,0,0,0
	end
	--todo: other stuff like style reset
	transition.cancel(self.images)
	
	local x, y = self.parent:calcCardXY(self.index)
	
	transition.to(self.images, {
		time = 100,
		x = x,
		y = y,
		xScale = 1,
		yScale = 1
	})
end

--module: cardVis
return {
	create = function(model, parentVisObject)
		local cardVis = table.deepCopy(cardVisTemplate)
		cardVis.index = model.index--todo: just keep it in the model
		cardVis.model = model
		cardVis.images = display.newGroup()
		cardVis.parent = parentVisObject
		parentVisObject.images:insert(cardVis.images)
		return cardVis
	end
}