pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/// @title Shalabuck
/// @author Ali Shalabi
/// @dev Must create TradeableERC721Token.sol file (not built-in in open zepplin)
contract Shalabuck is TradeableERC721Token {
  constructor(address _proxyRegistryAddress) TradeableERC721Token("Shalabuck", "OSC", _proxyRegistryAddress) public {  }

  /// @return baseTokenURI (string)- important for rendering front-end
  function baseTokenURI() public view returns (string memory) {
    return "https://opensea-creatures-api.herokuapp.com/api/creature/";
    /* Ask Dani */
  }
}
