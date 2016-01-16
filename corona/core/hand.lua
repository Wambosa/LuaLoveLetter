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

function handTemplate:randomDiscard()
	--todo: prolly not this card game
end

return {
	newHand = function(...)
		local aHand = table.deepCopy(handTemplate)
		
		if not arg then
			for _, aCard in ipairs(arg) do
				aHand:addCard(aCard)
			end
		end
		
		return aHand
	end
}