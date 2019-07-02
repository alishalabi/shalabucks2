pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Factory.sol";
import "./Shalabuck.sol";
import "./ShalabuckLootBox.sol";
import "./Strings.sol";

contract ShalabuckFactory is Shalabuck, Ownable {
  using Strings for string;

  address public proxyRegistryAddress;
  address public nftAddress;
  address public lootBoxNftAddress;
  string public baseURI = "https://opensea-creatures-api.herokuapp.com/api/factory/";

  /**
   * Enforce the existence of only 100 OpenSea creatures.
   */
  uint256 SHALABUCK_SUPPLY = 100;

  /**
   * Three different options for minting Creatures (basic, premium, and gold).
   */
  uint256 NUM_OPTIONS = 3;
  uint256 SINGLE_SHALABUCK_OPTION = 0;
  uint256 MULTIPLE_SHALABUCK_OPTION = 1;
  uint256 LOOTBOX_OPTION = 2;
  uint256 NUM_SHALABUCK_IN_MULTIPLE_SHALABUCK_OPTION = 4;

  constructor(address _proxyRegistryAddress, address _nftAddress) public {
    proxyRegistryAddress = _proxyRegistryAddress;
    nftAddress = _nftAddress;
    lootBoxNftAddress = address(new ShalabuckLootBox(_proxyRegistryAddress, address(this)));
  }

  function name() external view returns (string memory) {
    return "OpenSeaCreature Item Sale";
  }

  function symbol() external view returns (string memory) {
    return "CPF";
  }

  function supportsFactoryInterface() public view returns (bool) {
    return true;
  }

  function numOptions() public view returns (uint256) {
    return NUM_OPTIONS;
  }

  function mint(uint256 _optionId, address _toAddress) public {
    // Must be sent from the owner proxy or owner.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    assert(address(proxyRegistry.proxies(owner())) == msg.sender || owner() == msg.sender || msg.sender == lootBoxNftAddress);
    require(canMint(_optionId));

    Shalabuck shalabuck = creature(nftAddress);
    if (_optionId == SINGLE_SHALABUCK_OPTION) {
      shalabuck.mintTo(_toAddress);
    } else if (_optionId == MULTIPLE_SHALABUCK_OPTION) {
      for (uint256 i = 0; i < NUM_SHALABUCKS_IN_MULTIPLE_SHALABUCK_OPTION; i++) {
        shalabuck.mintTo(_toAddress);
      }
    } else if (_optionId == LOOTBOX_OPTION) {
      ShalabuckLootBox shalabuckLootBox = ShalabuckLootBox(lootBoxNftAddress);
      shalabuckLootBox.mintTo(_toAddress);
    }
  }

  function canMint(uint256 _optionId) public view returns (bool) {
    if (_optionId >= NUM_OPTIONS) {
      return false;
    }

    Shalabuck shalabuck = Shalabuck(nftAddress);
    uint256 shalabuckSupply = shalabuck.totalSupply();

    uint256 numItemsAllocated = 0;
    if (_optionId == SINGLE_SHALABUCK_OPTION) {
      numItemsAllocated = 1;
    } else if (_optionId == MULTIPLE_SHALABUCK_OPTION) {
      numItemsAllocated = NUM_SHALABUCK_IN_MULTIPLE_SHALABUCK_OPTION;
    } else if (_optionId == LOOTBOX_OPTION) {
      ShalabuckLootBox shalabuckLootBox = ShalabuckLootBox(lootBoxNftAddress);
      numItemsAllocated = shalabuckLootBox.itemsPerLootbox();
    }
    return shalabuckSupply < (SHALABUCK_SUPPLY - numItemsAllocated);
  }

  function tokenURI(uint256 _optionId) external view returns (string memory) {
    return Strings.strConcat(
        baseURI,
        Strings.uint2str(_optionId)
    );
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use transferFrom so the frontend doesn't have to worry about different method names.
   */
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    mint(_tokenId, _to);
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    if (owner() == _owner && _owner == _operator) {
      return true;
    }

    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (owner() == _owner && address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return false;
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return owner();
  }
}
