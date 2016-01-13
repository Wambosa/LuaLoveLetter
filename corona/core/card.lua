local cardTemplate = {
	name = 'card name',
	rank = 0,
	img = 'img/cards/008_princess',
	use = function() end,
	discard = function() end,
	abilitys = {
		['0'] = 0,
	}
}

return {
	
	cardAbility = {
        none = 0,
        accuse = 1,     -- guess player strategy, if true, that player loses the round
        spy = 2,        -- view target player hand
        debate = 3,     -- force a comparison of hands. low card loses the round
        protect = 4,    -- cannot be targeted until next turn
        policy = 5,     -- a sudden change in policy causes the selected player to discard hand and draw a card
        mandate = 6     -- trade hands with target player (you select the card)
    },
	
	newCard = function(name, rank, img, abilitys) 
		
		--todo. honor args and move forward!
		local aCard = cardTemplate
		
		return aCard
	end
	
}