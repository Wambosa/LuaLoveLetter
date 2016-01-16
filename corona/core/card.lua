local cardTemplate = {
	name = 'card name',
	rank = 0,
	img = 'img/cards/008_princess',
	use = function(foo) end,
	discard = function(something) end,
	abilitys = {}
}

--todo: touch functions ?


return {
	
	cardAbility = {
        none = 0,
        accuse = 1,     -- guess player strategy, if true, that player loses the round
        spy = 2,        -- view target player hand
        debate = 3,     -- force a comparison of hands. low card loses the round
        protect = 4,    -- cannot be targeted until next turn
        policy = 5,     -- a sudden change in policy causes the selected player to discard hand and draw a card
        mandate = 6,    -- trade hands with target player (you select the card)
		subvert = 7,	-- cannot exist with rank 5 or 6 in player hand. forces discard of either this or that
		favor = 8,		-- curry favor with a ruler
    },
	
	newCard = function(name, rank, img, ability)
		local aCard = table.deepCopy(cardTemplate)
		aCard.name = name
		aCard.rank = rank
		aCard.img = img
		table.insert(aCard.abilitys, ability)
		return aCard
	end
}