#### Rings by Hashelot

![If you like it, then you shoulda put a ring on it.](images/hashelot_rings_nbg.png)

**Rings by Hashelot** is a stacking game written in Solidity and deployed on the [Ethereum](https://ethereum.org/) main network.

You can check out the code: [hashelot\_rings.sol](solidity/hashelot_rings.sol).

- MD5: 5ab41fd104bdf8046e1b1a04b4a7411e
- SHA1: 9dc61fb07e38f9e415bfc7446ee46af79d050ad4
- SHA256: 59cb8435a5ed0ea8ea4708ea7fb8b16293f6974fa075c1cb74a214ae846b087e

Transaction hash: [0xdb0077a1c9cb3379226ed852a938fa61a6559eb696b79176fa57be87d7f5ce7b](https://etherscan.io/tx/0xdb0077a1c9cb3379226ed852a938fa61a6559eb696b79176fa57be87d7f5ce7b)

##### Rules
The very first round of Rings by Hashelot starts when a player deposits his bet on the empty stack. The bet needs to be equal to or higher than 1 Finney (0.001 Ether).

From the moment his transaction - ```depositStack()``` call - is confirmed in a certain block *X*, the round goes on for *127* other blocks - ```stackWait=127``` -, during which any other player can take part in the bet and stack the exact same amount.

If a player tries to deposit a bet which is lower than the current value - ```stackValue``` -, said bet won't be added to the stack and the value returned to the player.

If a player deposits a bet which is higher than the current ```stackValue``` a change will be returned to the player once the bet is added to the stack.

The number of blocks, *127*, has been chosen as a prime number (out of pure mathematical fun) to make a round hypothetically last around 24 hours.

After the *(X+127)*<sup>th</sup> block has been mined a winner can be declared, either calling ```closeBet()``` or starting a new round with ```depositStack()```. The winner is the user whose address, concatenated with the last blockhash for which it was possible to enter the bet and passed through the hash function ```keccak256``` and converted to an unsigned value - ```uint``` - returns the lowest value, or in other code words:

```
uint(keccak256(abi.encodePacked(blockhash(stackTime+stackWait), playerAddress)))
```

rolling playerAddress among the addresses of all the players who entered the bet to find the minimum.

The winner takes 98% of the stack.

2% of the stack goes to the **owner**, to finance research and development of (*hopefully less frivolous*) decentralized ventures.

The **owner** of the hashelot_rings smart contract may declare a winner with ```dustStack()```, but only if there are no ongoing bets.

##### Methods and variables
- ```stackValue``` - A public unsigned integer that shows the current value for entering the bet. Updated at every round.
- ```stackTime``` - A public unsigned integer that shows the block number at which the round has been started. Updated at every round.
- ```stackWait``` - A public unsigned integer set by the **owner** to *127*, once and for all.
- ```stackPlayers``` - A public array containing the addresses of the players currently involved in a round.
- ```stackSoFar``` - A public unsigned integer that shows the total amount of winnings so far.
- ```depositStack()``` - A public payable function anyone can call to enter (or start) a bet. When starting a new bet it closes a previous one for which a winner has not been declared yet.
- ```checkBalance()``` - A public function which returns the current balance of the smart contract address.
- ```checkPlayers()``` - A public function which returns the number of player currently involved in a round.
- ```closeBet()``` - A public payable function anyone can call to declare a bet if there are no more available blocks to play.
- ```dustStack()``` - A public payable function that only the **owner** can call to declare a winner of an ended round.
