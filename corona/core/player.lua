local hand = require('core.hand')

local playerTemplate = {
	index = 0,
	name = 'scoundrel',
	state = 'none', -- none wait turn lose win
	wins = 0,
	deck = { --todo: actually use the deck module in a more complex game
		playPile = {}
	},
	hand = hand.newHand()
}

function playerTemplate:discard(cardIndex)
	print('discarding', self.hand.cards[cardIndex].name)
	self.hand:discard(cardIndex, self.deck.playPile)
end

return {
	newPlayer = function(index, name)
		local player = table.deepCopy(playerTemplate)
		player.index = index
		player.name = name:upper()
		player.state = 'wait'
		return player
	end
}