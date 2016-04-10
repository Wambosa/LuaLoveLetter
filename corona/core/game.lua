local deck = require('core.deck')
local player = require('core.player')

--note: this is specific to LoveLetter
local game = {
	state = 'none', --none beginRound turn endRound over
	players = {},
	currentPlayerIndex = 0,
	deck = nil,
	startingHandAmount = 0,
    selection = 0 --this will likely need some improvement over time. for now, it can simply be an index of a player/card
}

local gameOptionsTemplate = {
	playerNames = {'player 1', 'player 2'},
	startingHandAmount = 1,
	turnDrawAmount = 1,
}
--note: the game is local. this is not client-server designed
function game:init(gameOptions)
		
		print_r('gameOptions', gameOptions)
		
		assert(#gameOptions.playerNames > 1, 'gameOptions requires at least 2 players to be set')
		assert(gameOptions.startingHandAmount, 'gameOptions requires startingHandAmount to be set')
		
		self.startingHandAmount = gameOptions.startingHandAmount
		
		--create players
		for i=1, #gameOptions.playerNames do
			table.insert(self.players, player.newPlayer(i, gameOptions.playerNames[i]))
		end
		
		print_r('game.players', self.players)
		--todo: blocking this will always cause the playerIndex to be 1
		--self.currentPlayerIndex = math.random(#gameOptions.playerNames)
end

--
function game:nextPlayer()
	if(self.currentPlayerIndex ~= 0) then
		self.players[self.currentPlayerIndex].state = 'wait'
	end
	self.currentPlayerIndex = self.currentPlayerIndex < #self.players and self.currentPlayerIndex+1 or 1
	self.players[self.currentPlayerIndex].state = 'turn'
end
--
function game:beginRound()
	
	self.state = 'beginRound'
	
	--note: need a deck:renew() or deck.newDeck(cardsArray) for multiple decks
	self.deck = deck.newDeck()
	self.deck:shuffle()
	
	--banish n number of cards where n = 4 if playerCount = 2
	for i=1, (#self.players == 2 and 4 or 1) do
		self.deck:banishTopCard()
	end
	
	--deal n cards to players
	for i=1, #self.players do
		for j=1, self.startingHandAmount do
			self.players[i].hand:addCard(self.deck:draw())
		end
	end
	
	self:nextPlayer()
end
--
function game:beginTurn()
	
	self.state = 'turn'
	print('it is '..self.players[self.currentPlayerIndex].name.."'s turn")
	self.players[self.currentPlayerIndex].hand:addCard(self.deck:draw())
end
--
function game:endTurn()
	
	if(#self.deck.playPile == 0) then
		self:endRound()
	else
		self:nextPlayer()
	end
end
--
function game:endRound()
	
	--hmmmm...
	--add wins to victor
	self.state = 'endRound'
	
end
--
function game:endGame()
	--call when someone has 3 rounds
end

return game