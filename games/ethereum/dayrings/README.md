#### [Day] Rings by Hashelot

![If you like it, then you shoulda put a ring on it.](images/hashelot_dayrings_nbg.png)

**[Day] Rings by Hashelot** is a stacking game written in Solidity and deployed on the [Ethereum](https://ethereum.org/) main network, whose game play you can audit <a href="https://etherscan.io/address/0xA8e44bB386766f597a22fCdC14d82a9C700dfb70" target="\_blank">straight out of the blockchain</a>.

You can check out the code: [hashelot\_dayrings\_1.0.sol](solidity/hashelot_dayrings_1.0.sol).

- MD5: 0d029e7b9c356f753fa9354193f1d67a.
- SHA1: 5a73d4d5c18de1517290553b763692384bdf2e40.
- SHA256: 8858b66977717ac1e34c119c3d11a835814205f2a0ff0b5a753748e47c016b40.

Transaction hash: [0x1a8436e60c35d0c6d694e53b65409e6daeee855647a053dfa0439fef673587ca](https://etherscan.io/tx/0x1a8436e60c35d0c6d694e53b65409e6daeee855647a053dfa0439fef673587ca)

###### TL;DR Rules
Someone deposits a certain amount of Ether on the stack and for 5748 blocks anybody else can join in the game depositing the same amount. At the 5749<sup>th</sup> block, 98&percnt; of the Jackpot goes to the address that minimizes the value:

```keccak256(blockhash(block number at the end of the round) + player_address))```

2&percnt; goes to the house.

###### Rules
The very first round of [Day] Rings starts when a player deposits his bet on the empty stack. The bet needs to be equal to or higher than 1 Finney (0.001 Ether).

From the moment his transaction - ```depositStack()``` call - is confirmed in a certain block *X*, the round goes on for *5748* additional blocks - ```stackWait=5748``` -, during which any other player can take part in the bet and stack the exact same amount.

If a player tries to deposit a bet which is lower than the current value - ```stackValue``` -, said bet won't be added to the stack and the value returned to the player.

If a player deposits a bet which is higher than the current ```stackValue``` a change will be returned to the player once the bet is added to the stack.

Once the *(X+5749)<sup>th</sup>* block has been mined, a winner can be declared, either calling ```closeBet()``` or starting a new round with ```depositStack()```. The winner is the user whose address, concatenated with the blockhash of the first block after the last one for which it was possible to enter the bet and passed through the hash function <a href="https://en.wikipedia.org/wiki/SHA-3" target="\_blank">keccak256</a> and converted to an unsigned value - ```uint``` - returns the lowest value, or in other code words:

```uint(keccak256(abi.encodePacked(blockhash(stackTime + stackWait + 1), playerAddress)))```

rolling playerAddress among the addresses of all the players who entered the bet to find the minimum.

The winner takes 98&percnt; of the stack.

2&percnt; of the stack goes to the **owner**, to finance research and development of (*hopefully less frivolous*) decentralized ventures.

The number of blocks, *5749*, has been chosen as a prime number (out of pure mathematical fun) to make a round hypothetically last a day or so.

The **owner** of the hashelot_rings smart contract may declare a winner with ```dustStack()```, but only if there are no ongoing bets.

###### Deployment specs
Transaction hash: [0x8c265...fc5a71971d](https://etherscan.io/tx/0x8c2659ee2c48ca7e80249d290d1da81ea21a281a596375f7fbc941fc5a71971d).
Etherscan contract verification: <a href="https://etherscan.io/address/0xa8e44bb386766f597a22fcdc14d82a9c700dfb70#code" target="\_blank">submitted for verification on 2020-07-15</a>.

###### Methods and variables

- ```stackValue``` - A public unsigned integer that shows the current value for entering the bet. Updated at every round.
- ```stackTime``` - A public unsigned integer that shows the block number at which the round has been started. Updated at every round.
- ```stackWait``` - A public unsigned integer set by the **owner** to *5748*, once and for all.
- ```stackPlayers``` - A public array containing the addresses of the players currently involved in a round.
- ```stackSoFar``` - A public unsigned integer that shows the total amount of winnings so far.
- ```depositStack()``` - A public payable function anyone can call to enter (or start) a bet. When starting a new bet it closes a previous one for which a winner has not been declared yet.
- ```checkBalance()``` - A public function which returns the current balance of the smart contract address.
- ```checkPlayers()``` - A public function which returns the number of player currently involved in a round.
- ```closeBet()``` - A public payable function anyone can call to declare a bet if there are no more available blocks to play.
- ```dustStack()``` - A public payable function that only the **owner** can call to declare a winner of an ended round.
