# LuaLoveLetter
-----
_Love Letter in Lua + Corona_

[![Demo Work Video](http://img.youtube.com/vi/49fpZfi2Gfo/0.jpg)](https://youtu.be/49fpZfi2Gfo)
-----

## The Static Deck
-----
_It never changes. It is shared with all players._ 


```nodejs
var deck = [
    {name: "Guard", perk: "accuse" },
    {name: "Guard", perk: "accuse" },
    {name: "Guard", perk: "accuse" },
    {name: "Guard", perk: "accuse" },
    {name: "Guard", perk: "accuse" },
    {name: "Priest", perk: "spy" },
    {name: "Priest", perk: "spy" },
    {name: "Baron", perk: "debate" },
    {name: "Baron", perk: "debate" },
    {name: "Handmaid", perk: "protect" },
    {name: "Handmaid", perk: "protect" },
    {name: "Prince", perk: "policy" },
    {name: "Prince", perk: "policy" },
    {name: "King", perk: "mandate" },
    {name: "Countess", perk: "subvert" },
    {name: "Princess", perk: "favor" }
];
```

### Understanding the matrix format
-----
Each **target matrix** will consist of at least 6 factors.

**wins** is a light factor in deciding on an action, yet it matters because this action can be quite risky. The closer my foe is to winning a 3rd time, the more appealing this action becomes. If I succeed, then we get to play another round.

**handMask** is the cards in hand _(bitmask form)_ of myself and the foe. Since we don't know what is in the foeHand really, I must speculate using the discard piles.

**discardCount** is simply a count of how many cards have been played. This is used to card count and better speculate what my foes are holding.

> example of a targets matrix

player|wins | handMask | discardCount
------|:---:|:--------:|:-----------:
self  |2    | 129      | 3
target|2    | 0        | 4

An **ideal action** matrix is merely the _most ideal_ factors for the greatest gain.
Currently, I have imposed my own values to reflect my own strategy on each possible action.
_In the future, I want to have these factors tweaked in order to discover the best factors programatically._

> Here is an **ideal** matrix for the **guard** card _(with **accuse** perk)_

owner|wins | handMask | discardCount
-----|:---:|:--------:|:-----------:
self |-1   | 128      | 3
foe  |2    | 32       | 8

## The Risk Algorithm
-----

$ |W - w| + (?todo?)*-1 + |D - d|$

There are 3 calculations performed on the **target** and **ideal** matrices

- risk += **math.absolute(target.wins - ideal.wins)**
- risk += **math.hammingWeight(target.hand & ideal.hand) \* _impact_ \* -1**
    + ideal cards will _reduce_ risk instead of increase it
    + impact is an integer that should be toggleable between 1-5
- risk += **math.absolute(target.discard - ideal.discard)**
    + it would be far more accurate to actually store a bitmask _(65536)_ for each possible card in the deck, however. I think that this would be too accurate for the game _(and does not scale to larger card games)_

Because of the calculations, I have choosen to store the **ideal action** matrix at a pivot.
> this is what you will see in the code examples

```javascript
[
    [selfWins, tarWins],
    [selfHand, tarHand],
    [selfDis, foeDiscard]
]

//action
[2, 2],
[129, 0],
[3, 4]

//ideal
[-1, 2],
[128, 32],
[3, 8]
```

## Card Perks
-----
_various effects that change the flow of a match_

**mask** is a reference to a perk's bitMask value.  
**t** is what can be targetted by this perk _(this does not have to be coupled to the perk in all games)_  
**m** the aforementioned **ideal matrix** for this perk/action 


```nodejs
var perk = {
    "accuse": { desc: "guess player strategy, if true, that player loses the round (guilty!/You there!)",
        mask: 1,
        t: 2,
        m: [[-1, 2],
            [128, 32],
            [3, 8]
        ]
    },
    "spy": { desc: "view target player hand (i'll find out/wonder whats going on...)",
        mask: 2,
        t: 2,
        m: [
            [2, -1],
            [53, 127],
            [-1, -1]
        ]
    },
    "debate": { desc: "force a comparison of hands. low card loses the round (daaym orcs.../Strawman!)",
        mask: 4,
        t: 2,
        m: [
            [2, -1],
            [240, 15],
            [3, 8]
        ]
    },
    "protect": { desc: "cannot be targeted until next turn (psst! hide here)",
        mask: 8,
        t: 1,
        m: [
            [0, 0],
            [192, 0],
            [-1, -1]
        ]
    },
    "policy": { desc: "a sudden change in policy causes the selected player to discard hand and draw a card (pompously: do you like my hat)",
        mask: 16,
        t: 3,
        m: [
            [0, 2],
            [99, 224],
            [3, 8]
        ]
    },
    "mandate": { desc: "trade hands with target player (you select the card) (pompously: king me!)",
        mask: 32,
        t: 2,
        m: [
            [2, -1],
            [6, 208],
            [3, 8]
        ]
    },
    "subvert":{ desc: "cannot exist with rank 5 or 6 in player hand. forces discard of this (seductive: hello)",
        mask: 64,
        t: 1,
        m: [
            [2, 0],
            [48, 49],
            [0, 0]
        ]
    },
    "favor": { desc: "curry favor with a ruler (just... let it go)",
        mask: 128,
        t: 1,
        m: [
            [3, -1],
            [0, 0],
            [4, 16]
        ]
    }
}
```

## Matrix Functions
-----



```nodejs
"use strict";
// different personalities can guess using different algorithms 
// such as mode, or a more complex examination of which card was drawn last

function speculate(deck, discard, hand) {
    let possible = Object.create(deck);
    let known = hand.concat(discard);
    
    known.forEach(function(k){
        possible.splice(possible.indexOf(k), 1);
    });
    
    let guess = Math.floor((Math.random() * possible.length) + 0);

    return possible[guess];
}

function computeRisk(target, action){
    target = math.matrix(target);
    action = math.matrix(action);
    ignorables = math.and(math.ceil(target), math.ceil(action))
    target = math.dotMultiply(target, ignorables)
    
    //there are 3 ish steps here
    let w = math.index(0, [0,1]); // difference the wins
    let c = math.index(1, [0,1]); // bit compare the cards
    let n = math.index(2, [0,1]); // difference the counts
    
    let risk = 10; //inherent risk
    risk += risk = math.sum(math.abs(math.subtract(target.subset(w), action.subset(w))));
    risk += risk = math.sum(math.abs(math.subtract(target.subset(n), action.subset(n))));
    
    // i actually want to do hamming weight for more complex games.
    // The hamming weight can only ever be 1 or 0 for this game.
    // the preferred card decreses risk instead of reduces it.
    
    let bitAnd = math.bitAnd(target.subset(c), action.subset(c))._data[0]; //todo: hamming weight * impact
    risk += bitAnd[0] && -2;
    risk += bitAnd[1] && -2;
    
    return risk;
}
```




    "use strict"



### Card Game Rules

I am learning that there is not a generalized matrix that i can make for complex strategies. Some values will need to represent combinations in the form of bitmask whilst other calculations can be simply difference.

My other card game and Love Letter have drastically different rules. So the matrix for love letter has less factors, yet is more complicated in its algorithm.

Since there are only **8** card types with a known number of 16 cards per deck, known number of cards per hand, and known discard. The logic can now focus on less generalized aspects. We can get into _the most likely_ card in opponents hand combined with various factor weights. 

# Turn One
-----
_we find ourselves in a heated match against the training AI_

- there are two players
- it is my turn to go (it is the very first turn)
- my hand is **guard** and **priest**

> I expect that the priest is more favorable, since there are no cards in the discard

_Lets Play_


```nodejs
var deck = [128, 64, 32, 16, 16, 8, 8, 4, 4, 2, 2, 1, 1, 1, 1, 1];
var discard = [];
var myHand = [
    1, //guard
    2 //priest
];

foeHand = speculate(deck, discard, myHand);

// it shoudld be posible to add n number of seperate targets,
// it should also be possible to later to compute all targets 
// (simply clone the last column n number of times on the ideal matrix to match shape)
var target = {
    uuid: "Billy-Bob",
    m: [
        [0, 0],       //neither of us has won a round yet
        [3, foeHand], //i know my hand, and can speculate what the foe hand could be
        [0, 0] //no one has played anything yet. I am going first
    ]
};

function decide(targets, choices) {
    var actions = [];
    
    targets.forEach(function(t){
        choices.forEach(function(c){
            actions.push({
                risk: computeRisk(t.m, c.m),
                target: t.uuid,
                action: c.uuid
            });
        });
    });
    
    return actions.sort(function(a, b){
        return a.risk > b.risk;
    })[0];
}

decide([target], [
    {uuid: "priest", m: perk.spy.m},
    {uuid: "guard", m: perk.accuse.m}
]);
```




    {"risk":11,"target":"Billy-Bob","action":"priest"}



The priest was the best option as designed! Because the priest allows you to view a foeHand, it is the more powerful option when very few cards are known.

# An evening with friends
-----
_after a few shots and rounds of smash bros, the wives decide its time for a group game_

- there are 4 players
- it is my turn to go (it is the 5th turn)
- my hand is **handmaiden** and **baron**

> Not sure what to expect, the handmaiden should only target self, and the baron is only good with a higher card

_Lets Play_


```nodejs
var discard = [64, 16, 2, 1];

var myHand = [
    8, //handmaiden
    4 //baron
];

var gameState = [
    {
        uuid: "thine own self",
        t: 1,
        m: [
            [0, 0],   // first round.
            [12, 12], // is this going to work???
            [1, 3]    // i played on the first turn, now it is my turn again
        ]
    },{
        uuid: "Myra-Sue",
        t: 2,
        m: [
            [0, 0],
            [12, speculate(deck, discard, myHand)],
            [1, 3]
        ]
    },{
        uuid: "Jackson",
        t: 2,
        m: [
            [0, 0],
            [12, speculate(deck, discard, myHand)],
            [1, 3]
        ]
    },{
        uuid: "Jenny-Beth",
        t: 2,
        m: [
            [0, 0],
            [12, speculate(deck, discard, myHand)],
            [1, 3]
        ]
    }
    
];

function think(targets, choices) {
    var actions = [];
    
    choices.forEach(function(c){
        targets.filter(function(tar){
            return !tar.isImmune && tar.t & c.t;
        }).forEach(function(tar){
            actions.push({
                risk: computeRisk(tar.m, c.m),
                target: tar.uuid,
                action: c.uuid
            });
        });
    });
    
    return actions.sort(function(a, b){
        return a.risk > b.risk;
    });
}

think(gameState, [
    {uuid: "handmaiden", t: perk.protect.t, m: perk.protect.m},
    {uuid: "baron", t: perk.debate.t, m: perk.debate.m}
]);
```




    [Array] [{"risk":16,"target":"thine own self","action":"handmaiden"},{"risk":18,"target":"Jackson","action":"baron"},{"risk":20,"target":"Myra-Sue","action":"baron"},{"risk":20,"target":"Jenny-Beth","action":"baron"}]



Success! Handmaiden is the better option with more unknowns. Albiet not by much.

This test has made me realize that i need a good way to identify valid targets.

The player will know the target type in the **gameState**. Each action may have different targets since some actions are only applicable to certain targets or even all targets.

The handmaiden can only ever target the main player. Some players are also immune in certain conditions.

# I hold the Princess's heart!
-----
_after losing every match thus far, you find yourself holding the most powerful card in the game_

- there are 3 players
- it is the 1st turn (my turn)
- my hand is the **princess** and **king**

> i hope that the princess is not appealing to play ever. it is also undesireable to give the princess away, but it should be the only option


```nodejs
var discard = [];
var myHand = [
    128, //princess
    32 //king
];

var gameState = [
    {
        uuid: "thine own self",
        t: 1,
        m: [
            [0, 0],
            [160, 160],
            [0, 0]
        ]
    },{
        uuid: "Plo-Koon",
        t: 2,
        m: [
            [0, 2],
            [160, speculate(deck, discard, myHand)],
            [0, 0]
        ]
    },{
        uuid: "Obi-Wan",
        t: 2,
        m: [
            [0, 2],
            [160, speculate(deck, discard, myHand)],
            [0, 0]
        ]
    }
];

think(gameState, [
    {uuid: "princess", t: perk.favor.t, m: perk.favor.m},
    {uuid: "king", t: perk.mandate.t, m: perk.mandate.m}
]);
```




    [Array] [{"risk":23,"target":"Plo-Koon","action":"king"},{"risk":23,"target":"Obi-Wan","action":"king"},{"risk":34,"target":"thine own self","action":"princess"}]



excellent! the princess was the least favorable action :)  
true, that the match is not looking so hot, but perhaps we can be redeemed with a different kind of **speculate()** which accounts for knowing the card in a foeHand

# I have you now!
-----
_It appears that Plo-Koon still has the princess and it is your turn again..._

- There are 2 players left _(Plo-Koon used the baron to rid the game of Obi-Wan)_
- It is the 3rd turn
- my hand is **king** and **guard** _(you recieved a king from last action, and drew the guard this turn)_
- you know Plo-Koons hand!

> it should be favorable to end the game with the guard. Otherwise Plo-Koon may be able to win next turn.


```nodejs
var discard = [32, 4];
var myHand = [
    32, //king
    1  //guard
];

var shortTerm = {
    "Plo-Koon": 128
};

var gameState = [
    {
        uuid: "thine own self",
        t: 1,
        m: [
            [0, 0],
            [33, 33],
            [1, 1]
        ]
    },{
        uuid: "Plo-Koon",
        t: 2,
        m: [
            [0, 2],
            [33, shortTerm["Plo-Koon"] || speculate(deck, discard, myHand)],
            [1, 1]
        ]
    }
];

think(gameState, [
    {uuid: "king", t: perk.mandate.t, m: perk.mandate.m},
    {uuid: "guard", t: perk.accuse.t, m: perk.accuse.m}
]);
```




    [Array] [{"risk":20,"target":"Plo-Koon","action":"guard"},{"risk":22,"target":"Plo-Koon","action":"king"}]



nooooo! the AI foolishly chooses to use the king!
It is a single point of difference:

```javascript
[
    {"risk":19,"target":"Plo-Koon","action":"king"},
    {"risk":20,"target":"Plo-Koon","action":"guard"}
]
```

I adjusted the win factors in order to better handle the situation where we are losing, and less willing to take extended risk.
Now we get a better result, ending the round in a victory.
```javascript
[
    {"risk":20,"target":"Plo-Koon","action":"guard"},
    {"risk":22,"target":"Plo-Koon","action":"king"}
]
```



```nodejs

```
