local hand = require('core.hand')

local playerTemplate = {
	name = 'scoundrel',
	wins = 0,
	status = 0,
	hand = hand.newHand()
}


return {
	
	playerStatus = {
        none = 0,
        inPlay = 1,
        lose = 2,
        win = 3
    },
	
	newPlayer = function(name)
		local aPlayer = table.deepCopy(playerTemplate)
		aPlayer.name = name
		return aPlayer
	end
}