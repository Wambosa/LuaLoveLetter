local handTemplate = {
	holdLimit = 2,
	cards = {}
}

function handTemplate:addCard(card)
	card.index = #self.cards+1
	table.insert(self.cards, card)
end

function handTemplate:scramble()
	--todo: randomly reorder the cards array
end

function handTemplate:discard(index, cardStack)
	cardStack:insert(table.remove(cards, index))
end

function handTemplate:randomDiscard()
	--todo: prolly not this card game (but for AI target?)
end

return {
	newHand = function(...)
		local aHand = table.deepCopy(handTemplate)
		
		--note: since a empty arg passed is also a table, we have to check the length of that table
		if #arg > 0 then
			for _, aCard in ipairs(arg) do
				aHand:addCard(aCard)
			end
		end
		
		return aHand
	end
}