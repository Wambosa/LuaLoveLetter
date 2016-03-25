local card = require('core.card')

local deckTemplate = {
	cardLimit = 16, --todo: the init process manipulates the playPile and its count BEFORE any graphics occur. I need to figure something out
	playPile = {
		card.newCard('Guard', 1, 'img/cards/001_guard.png', 1),
		card.newCard('Guard', 1, 'img/cards/001_guard.png', 1),
		card.newCard('Guard', 1, 'img/cards/001_guard.png', 1),
		card.newCard('Guard', 1, 'img/cards/001_guard.png', 1),
		card.newCard('Guard', 1, 'img/cards/001_guard.png', 1),
		
		card.newCard('Priest', 2, 'img/cards/002_priest.png', 2),
		card.newCard('Priest', 2, 'img/cards/002_priest.png', 2),
		
		card.newCard('Baron', 3, 'img/cards/003_baron.png', 3),
		card.newCard('Baron', 3, 'img/cards/003_baron.png', 3),
		
		card.newCard('Handmaid', 4, 'img/cards/004_handmaiden.png', 4),
		card.newCard('Handmaid', 4, 'img/cards/004_handmaiden.png', 4),
		
		card.newCard('Prince', 5, 'img/cards/005_prince.png', 5),
		card.newCard('Prince', 5, 'img/cards/005_prince.png', 5),
		
		card.newCard('King', 6, 'img/cards/006_king.png', 6),
		
		card.newCard('Countess', 7, 'img/cards/007_countess.png', 7),
		
		card.newCard('Princess', 8, 'img/cards/008_princess.png', 8)
	},
	
	discardPile = {},
	banishPile = {},
}

function deckTemplate:shuffle()
	local count = #self.playPile
	local swap

	for i=count, 2, -1 do
		swap = math.random(i)
		self.playPile[i], self.playPile[swap] = self.playPile[swap], self.playPile[i]
	end
end
	
function deckTemplate:draw()
	--todo: remember that we need to handle the case where the deck is empty
	return table.remove(self.playPile, 1)
end
	
function deckTemplate:dealTo(...)
	for _, player in iPairs(arg) do
		player.hand:addCard(self:draw())
	end
end
	
function deckTemplate:dealToMax(...)
	for _, player in iPairs(arg) do
		for i=1, player.hand.holdLimit do
			player.hand:addCard(self:draw())
		end
	end
end

function deckTemplate:banishTopCard()
		table.insert(self.banishPile, self:draw())
end

function deckTemplate:render(deckX, deckY)

	self.deckImages = display.newGroup()
	
	for i=0, #self.playPile, 1 do
		local cardView
		cardView = display.newImage(self.deckImages, 'img/cards/000_back.png')
		cardView.width, cardView.height = core.cardPixelWidth*3, core.cardPixelHeight*3
		cardView.rotation = math.random(-30, 30)
		cardView.x, cardView.y = deckX, deckY-i
		transition.to(cardView, {time=550+(i*75), width=core.cardPixelWidth*.5, height=core.cardPixelHeight*.5, rotation=-45 + math.random(-20, 20)})
	end
end
--todo: unrender?

local deckModule = {}

function deckModule:newDeck()
	return table.deepCopy(deckTemplate)
end

return deckModule