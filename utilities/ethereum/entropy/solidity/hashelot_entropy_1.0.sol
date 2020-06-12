// Hashelot Entropy - v.1.0
// A decentralized (discrete time) random generator
// ---
// The method randomics will return a
// pseudorandom uint in the range [0, 2**256-1]
// ---
// MIT License
// Copyright (c) 2020 Maurizio Ponti

pragma solidity ^0.6.1;

contract hashelot_entropy{ // Son of a lockdown

  function randomics() public view returns (uint){
    // Start out by simply making good use of msg.sender
    uint randomValue = uint(keccak256(abi.encode(msg.sender)));

    // Not so manipulable as the blockhash
    uint _coinbase = uint(keccak256(abi.encode(block.coinbase)));

    // Searching for randomness elsewhere
    uint _gemini = uint(address(0x07Ee55aA48Bb72DcC6E9D78256648910De513eca).balance);
    uint _kraken = uint(address(0x53d284357ec70cE289D6D64134DfAc8E511c8a3D).balance);
    uint _binance = uint(address(0xBE0eB53F46cd790Cd13851d5EFf43D12404d33E8).balance);
    uint _bitfinex = uint(address(0x742d35Cc6634C0532925a3b844Bc454e4438f44e).balance);
    uint _huobi = uint(address(0xDc76CD25977E0a5Ae17155770273aD58648900D3).balance);

    uint time = uint(keccak256(abi.encodePacked(_gemini, _kraken, _binance, _bitfinex, _huobi)));

    uint backStep = addmod(randomValue, _coinbase, time);

    time = addmod(time, backStep, block.number);
    backStep = addmod(randomValue, _coinbase, 256); // You can go back only as far as 256

    uint scrambler = uint(keccak256(abi.encode(blockhash(block.number-backStep))));

    randomValue = uint(keccak256(abi.encodePacked(randomValue, scrambler)));

    uint alpha = scrambler/10**19;
    alpha = alpha*10**19;
    alpha = uint(keccak256(abi.encode(alpha)));
    scrambler = uint(keccak256(abi.encodePacked(scrambler, alpha)));
    scrambler = addmod(randomValue, alpha, scrambler);

    scrambler = uint(keccak256(abi.encodePacked(scrambler, uint(keccak256(abi.encode(time))))));
    randomValue = uint(keccak256(abi.encodePacked(randomValue, scrambler)));

    alpha = scrambler/10**38;
    alpha = uint(keccak256(abi.encode(alpha)));
    scrambler = uint(keccak256(abi.encodePacked(scrambler, alpha)));
    scrambler = addmod(randomValue, alpha, scrambler);
    time = block.difficulty+time;
    scrambler = uint(keccak256(abi.encodePacked(scrambler, uint(keccak256(abi.encode(time))))));
    randomValue = uint(keccak256(abi.encodePacked(randomValue, scrambler)));

    return randomValue;
  }

}
