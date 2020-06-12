#### Entropy by Hashelot

**Entropy by Hashelot** is a simple smart contract that returns a mimicking randomness value.

You can check out the code: [hashelot\_entropy\_1.0.sol](solidity/hashelot_entropy_1.0.sol).

Transaction hash: [0x80d370b1466d132c545ba234eef018d2ac21fbfa18bf7b2221578f2f978ae329](https://etherscan.io/tx/0x80d370b1466d132c545ba234eef018d2ac21fbfa18bf7b2221578f2f978ae329)

###### Methods and variables

- ```randomics()``` - A public function which returns a value between 0 and 2^256-1, mimicking randomness. The function takes ```msg.sender```, among other parameters, in order to evaluate the return.
