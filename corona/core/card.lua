local cardTemplate = {
	index = 0,
	name = 'card name',
	rank = 0,
	img = 'img/cards/000_back',
	abilitys = {}
}

function cardTemplate:use(player, callback)
	--todo: might* make game global so that i can trigger the event here.
	Runtime:dispatchEvent({
		name = 'useCard',
		card = self,
		player = player,
		visCallback = callback
	})
end


return {
	
	cardAbility = {
        none = 0,
        accuse = 1,		-- guess player strategy, if true, that player loses the round (guilty!)
        spy = 2,		-- view target player hand (i'll find out)
        debate = 3,		-- force a comparison of hands. low card loses the round (daaym orcs...)
        protect = 4,	-- cannot be targeted until next turn (psst! hide here)
        policy = 5,		-- a sudden change in policy causes the selected player to discard hand and draw a card (pompously: do you like my hat)
        mandate = 6,	-- trade hands with target player (you select the card) (pompously: king me!)
		subvert = 7,	-- cannot exist with rank 5 or 6 in player hand. forces discard of either this or that (seductive: hello)
		favor = 8,		-- curry favor with a ruler (just... let it go)
    },
	
	newCard = function(name, rank, img, ability)
		local card = table.deepCopy(cardTemplate)
		card.name = name
		card.rank = rank
		card.img = img
		table.insert(card.abilitys, ability)
		return card
	end
}