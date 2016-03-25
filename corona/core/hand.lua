local handTemplate = {
	holdLimit = 2,
	cards = {}
}

function handTemplate:addCard(aCard)
	table.insert(self.cards, aCard)
end

function handTemplate:scramble()
	--todo: randomly reorder the cards array
end

function handTemplate:discard(index, cardStack)
	cardStack:insert(table.remove(cards, index))
end

function handTemplate:randomDiscard()
	--todo: prolly not this card game
end

return {
	newHand = function(...)
		local aHand = table.deepCopy(handTemplate)
		
		if not arg then-- wha?? this seems wrong
			for _, aCard in ipairs(arg) do
				aHand:addCard(aCard)
			end
		end
		
		return aHand
	end
}