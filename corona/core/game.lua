local deck = require('core.deck')
local player = require('core.player')

--note: this is specific to LoveLetter
local game = {
	
	gameState = {
		none = 0,
		beginRound = 1,
		turn = 2,
		endRound = 3,
		over = 4
    },
	
	state = 0,
	
	players = {},
	
	currentPlayerTurn = 0,
	
	deck = deck.newDeck()
}

local gameOptionsTemplate = {
	playerCount = 2,
	playerNames = {'player 1', 'player 2'},
	startingHandAmount = 1,
	turnDrawAmount = 1,
}
--note: this might only work if the game is local or this is the server. i'll need to sync changes later
function game:init(gameOptions)
		
		print_r('BUG: gameOptions.playerCount', gameOptions.playerCount)
		print_r('gameOptions', gameOptions)
		
		assert(gameOptions.playerCount, 'gameOptions requires playerCount to be set')
		assert(gameOptions.startingHandAmount, 'gameOptions requires startingHandAmount to be set')
		
		self.deck:shuffle()
		
		-- banish n number of cards where n = 4 if playerCount = 2
		for i=1, (gameOptions.playerCount == 2 and 4 or 1) do
			self.deck:banishTopCard()
		end

		--create players and give them n cards
		for i=1, gameOptions.playerCount do
			table.insert(self.players, player.newPlayer(gameOptions.playerNames[i]))
		
			for j=1, gameOptions.startingHandAmount do
				self.players[i].hand:addCard(self.deck:draw())
			end
		end
		
		-- determine who goes first
		self.currentPlayerTurn = math.random(gameOptions.playerCount)
		
		print_r('game.players', self.players)
		print('first player '.. self.currentPlayerTurn)
		
		--ready to begin round
		self.state = 1
	end

function game:beginRound() end
	
function game:beginTurn() end
	
function game:endTurn() end
	
function game:endRound() end

return game