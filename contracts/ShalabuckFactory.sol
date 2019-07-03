pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Factory.sol";
import "./Shalabuck.sol";
import "./ShalabuckLootBox.sol";
import "./Strings.sol";

/// @title ShalabuckFactory
/// @author Ali Shalabi
contract ShalabuckFactory is Ownable, Shalabuck {
  /// @dev Strings are used to manipulate string data type (ex: concatination)
  using Strings for string;

  address public proxyRegistryAddress;
  address public nftAddress;
  address public lootBoxNftAddress;
  string public baseURI = "https://opensea-creatures-api.herokuapp.com/api/factory/";

  /// @dev Caps Shalabuck supply to 100 total tokens
  uint256 SHALABUCK_SUPPLY = 100;

  /// @notice Defines options for token creation
  uint256 NUM_OPTIONS = 3;
  uint256 SINGLE_SHALABUCK_OPTION = 0;
  uint256 MULTIPLE_SHALABUCK_OPTION = 1;
  uint256 LOOTBOX_OPTION = 2;
  uint256 NUM_SHALABUCK_IN_MULTIPLE_SHALABUCK_OPTION = 4;

  /// @dev Correlates with the TradeableERC721Token contract
  constructor(address _proxyRegistryAddress, address _nftAddress) public {
    proxyRegistryAddress = _proxyRegistryAddress;
    nftAddress = _nftAddress;
    lootBoxNftAddress = address(new ShalabuckLootBox(_proxyRegistryAddress, address(this)));
  }

  /// @returns String
  function name() external view returns (string memory) {
    return "OpenSeaCreature Item Sale";
  }

  /// @returns String
  function symbol() external view returns (string memory) {
    return "CPF";
  }

  /// @returns Boolean
  function supportsFactoryInterface() public view returns (bool) {
    return true;
  }

  /// @returns Uint256
  function numOptions() public view returns (uint256) {
    return NUM_OPTIONS;
  }

  /// @notice Function that allows our contract to mint tokens
  /// @dev Relies on the inherited mintTo() method from TradeableERC721Token.sol
  function mint(uint256 _optionId, address _toAddress) public {
    // Must be sent from the owner proxy or owner.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    assert(address(proxyRegistry.proxies(owner())) == msg.sender || owner() == msg.sender || msg.sender == lootBoxNftAddress);
    require(canMint(_optionId));

    Shalabuck shalabuck = Shalabuck(nftAddress);
    if (_optionId == SINGLE_SHALABUCK_OPTION) {
      shalabuck.mintTo(_toAddress);
    } else if (_optionId == MULTIPLE_SHALABUCK_OPTION) {
      for (uint256 i = 0; i < NUM_SHALABUCK_IN_MULTIPLE_SHALABUCK_OPTION; i++) {
        shalabuck.mintTo(_toAddress);
      }
    } else if (_optionId == LOOTBOX_OPTION) {
      ShalabuckLootBox shalabuckLootBox = ShalabuckLootBox(lootBoxNftAddress);
      shalabuckLootBox.mintTo(_toAddress);
    }
  }

  /// @notice Ensures that mint request is valid (cannot create duplicates)
  /// @returns Boolean
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

  /// @dev Designed to work directly with OpenSea.io
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    mint(_tokenId, _to);
  }

  /// @dev Designed to work directly with OpenSea.io
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

  /// @dev Designed to work directly with OpenSea.io
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return owner();
  }
}
