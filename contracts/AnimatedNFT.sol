// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract AnimatedNFT is ERC721URIStorage {

  using Strings for uint256;
  using Counters for Counters.Counter;

  uint32 public maxSupply = 5;

  struct Statistics {
    uint256 strength;
    uint256 durability;
    uint256 attack;
  }

  Counters.Counter private tokenIds;

  mapping(uint256 => uint256) public tokenIdToLevels;
  mapping(uint256 => Statistics) public tokenIdToStatistics;


  constructor() ERC721("Robocop NFTs", "RCOP") {}


  // ********* PUBLIC INTERFACE ************
  function mint() external cap {
    tokenIds.increment();
    uint256 newTokenID = tokenIds.current();

    _safeMint(msg.sender, newTokenID);

    tokenIdToStatistics[newTokenID] = Statistics({
      strength: 15,
      durability: 30,
      attack: 27
    });

    _setTokenURI(newTokenID, formatTokenURI(newTokenID));
  }

  function upgrade(uint256 tokenId) external {
    require(msg.sender == ownerOf(tokenId), "Only NFT owner can upgrade");
    
    Statistics storage stats = tokenIdToStatistics[tokenId];

    stats.strength += 10;
    stats.durability += 10;
    stats.attack += 7;

    _setTokenURI(tokenId, formatTokenURI(tokenId));
  }

  // ********* HELPERS ************
  function formatTokenURI(uint256 tokenId) internal view returns(string memory tokenURI) {

    string memory baseURL = "data:application/json;base64,";

    tokenURI = string(abi.encodePacked( 
      baseURL,
      Base64.encode(
        bytes(abi.encodePacked(
          '{', 
            '"name": "Robocop #', tokenId.toString(), '",',
            '"description": "We are 10.000 decentralised Robocops",',
            '"animation_url": "ipfs://QmeNVHw82DiWEE4BESpEVT6wU7FNkhHKgEJJpcvMYHCsZZ/index.html",',
            '"attributes": [',
              '{ "trait_type": "T-Shirt number", "value": "9" },',
              '{ "trait_type": "Bag", "value": "Reebok" },',
              '{ "trait_type": "Sneakers", "value": "Nike" },',
              '{ "display_type": "boost_number", "trait_type": "Strength", "value": "', tokenIdToStatistics[tokenId].strength.toString(), '" },',
              '{ "display_type": "boost_percentage", "max_value": "100", "trait_type": "Durability", "value": "', tokenIdToStatistics[tokenId].durability.toString(), '" },',
              '{ "display_type": "number", "trait_type": "Attack", "value": "', tokenIdToStatistics[tokenId].attack.toString(), '" }',
            '],',
            '"image": "', getImageURI(tokenId),'"',
          '}'
        ))
      )
    ));
  }

  function getImageURI(uint256 tokenId) internal pure returns(string memory image) {
    image = string(abi.encodePacked(
      "ipfs://QmS5n6tzaZdTrVLzh6NJag8rm1cDdoTmKmQHHukRyBJdx4/",
      tokenId.toString(),
      ".png"
    ));
  }





  modifier cap() {
    require(tokenIds.current() < maxSupply, "Max supply reached");
    _;
  }
}