pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Shalabuck 
 * Creature - a contract for my non-fungible creatures.
 */
contract Shalabuck is TradeableERC721Token {
  constructor(address _proxyRegistryAddress) TradeableERC721Token("Shalabuck", "OSC", _proxyRegistryAddress) public {  }

  function baseTokenURI() public view returns (string memory) {
    return "https://opensea-creatures-api.herokuapp.com/api/creature/";
    /* Ask Dani */
  }
}
