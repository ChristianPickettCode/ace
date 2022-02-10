// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

contract HouseToken is ERC721 {

    struct CardAttributes {
        uint256 cardIndex;
        string name;
        string suit;
        string number;
        string imageURI;
        uint256 tokenId;
        uint256[] traits;
    }

    CardAttributes attributes;

    constructor(
        uint256 _cardIndex,
        string memory _name,
        string memory _suit,
        string memory _number,
        string memory _imageURI,
        uint256 _tokenId,
        uint256[] memory _traits
    ) ERC721("House", "HOUSE") {

        attributes.cardIndex = _cardIndex;
        attributes.name = _name;
        attributes.suit = _suit;
        attributes.number = _number;
        attributes.imageURI = _imageURI;
        attributes.tokenId = _tokenId;
        attributes.traits = _traits;

    }

    function mint(uint256 randomness) public {

    }

}

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// import "./libraries/Base64.sol";

// import "hardhat/console.sol";

// contract House is ERC721, VRFConsumerBase {
//   struct CardAttributes {
//     uint256 cardIndex;
//     string name;
//     string suit;
//     string number;
//     string imageURI;
//     uint256 tokenId;
//     uint256[] traits;
//   }

//   using Counters for Counters.Counter;
//   Counters.Counter private _tokenIds;

//   CardAttributes[] defaultCards;
//   mapping(uint256 => CardAttributes) public nftHolderAttributes;
//   mapping(address => uint256[]) public nftHolders;
//   event CardNFTMinted(address sender, uint256 tokenId, uint256 cardIndex);

//   mapping(bytes32 => address) public requestToSender;

//   bytes32 internal keyHash;
//   uint256 internal fee;

//   constructor(
//     address _vrfCoordinator,
//     address _link,
//     bytes32 _keyHash,
//     string[] memory _cardNames,
//     string[] memory _cardImageURIs,
//     string[] memory _cardNumbers,
//     string[] memory _cardSuits
//   ) ERC721("House", "HOUSE") VRFConsumerBase(_vrfCoordinator, _link) {

//     uint256[] memory defaultTraits = new uint[](5);

//     for (uint256 i = 0; i < _cardNames.length; i++) {
//       defaultCards.push(
//         CardAttributes({
//           cardIndex: i,
//           name: _cardNames[i],
//           suit: _cardSuits[i],
//           number: _cardNumbers[i],
//           imageURI: _cardImageURIs[i],
//           tokenId: _tokenIds.current(),
//           traits: defaultTraits
//         })
//       );

//       CardAttributes memory c = defaultCards[i];
//       console.log(
//         "Done initializing %s , img %s",
//         c.name,
//         c.imageURI
//       );
//     }
//     _tokenIds.increment();
    
//     keyHash = _keyHash;
//     fee = 0.1 * 10 ** 18;
//   }

//   function mintCard() public returns (bytes32) {
//     require(
//         LINK.balanceOf(address(this)) >= fee,
//         "Not enough LINK - fill contract with faucet"
//     );
//     bytes32 requestId = requestRandomness(keyHash, fee);
//     requestToSender[requestId] = msg.sender;
//     return requestId;
//   }

//   function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
//     uint256 newTokenId = _tokenIds.current();
//     uint256 cardIndex = ((randomness % defaultCards.length) % 18);

//     uint256[] memory traits = new uint[](5);
    
//     traits[0] = (((randomness % 10000) / 100) % 18);
//     traits[1] = (((randomness % 1000000) / 10000) % 18);
//     traits[2] = (((randomness % 100000000) / 1000000) % 18);
//     traits[3] = (((randomness % 10000000000) / 100000000) % 18);
//     traits[4] = (((randomness % 1000000000000) / 10000000000) % 18);

//     nftHolderAttributes[newTokenId] = CardAttributes({
//       cardIndex: cardIndex,
//       name: defaultCards[cardIndex].name,
//       suit: defaultCards[cardIndex].suit,
//       number: defaultCards[cardIndex].number,
//       imageURI: defaultCards[cardIndex].imageURI,
//       tokenId: newTokenId,
//       traits: traits
//     });

//     console.log(
//       "Minted NFT %s w/ RANDOM CL tokenId %s and cardIndex %s",
//       defaultCards[cardIndex].name,
//       newTokenId,
//       cardIndex
//     );

//     nftHolders[requestToSender[requestId]].push(newTokenId);
//     _safeMint(requestToSender[requestId], newTokenId);
//     _tokenIds.increment();
//     emit CardNFTMinted(requestToSender[requestId], newTokenId, cardIndex);
//   }

//   function tokenURI(uint256 _tokenId) public view override returns (string memory) {
//     CardAttributes memory cardAttributes = nftHolderAttributes[_tokenId];

//     string memory json = Base64.encode(
//       abi.encodePacked(
//         '{"name": "',
//         cardAttributes.name,
//         '", "description": "House of Cards", "image": "',
//         cardAttributes.imageURI,
//         '", "attributes": [ { "trait_type": "Suit", "value": "',
//         cardAttributes.suit,
//         '"}, { "trait_type": "Number", "value": "',
//         cardAttributes.number,
//         '"}, { "trait_type": "Trait 1", "value": "',
//         Strings.toString(cardAttributes.traits[0]),
//         '"}, { "trait_type": "Trait 2", "value": "',
//         Strings.toString(cardAttributes.traits[1]),
//         '"}, { "trait_type": "Trait 3", "value": "',
//         Strings.toString(cardAttributes.traits[2]),
//         '"}, { "trait_type": "Trait 4", "value": "',
//         Strings.toString(cardAttributes.traits[3]),
//         '"}, { "trait_type": "Trait 5", "value": "',
//         Strings.toString(cardAttributes.traits[4]),
//         '"} ]}'
//       )
//     );

//     string memory output = string(
//       abi.encodePacked("data:application/json;base64,", json)
//     );

//     return output;
//   }

//   function checkIfUserHasNFT() public view returns (CardAttributes[] memory) {
//     uint256 numOfNfts = nftHolders[msg.sender].length;
//     if (numOfNfts > 0) {
//       CardAttributes[] memory arr = new CardAttributes[](numOfNfts);
//       for (uint256 index = 0; index < numOfNfts; index++) {
//         uint256 tokenId = nftHolders[msg.sender][index];
//         arr[index] = nftHolderAttributes[tokenId];
//       }
//       return arr;
//     } else {
//       CardAttributes[] memory emptyArray;
//       return emptyArray;
//     }
//   }

//   function getAllDefaultCards() public view returns (CardAttributes[] memory) {
//     return defaultCards;
//   }

//   function changeHolder( address from, address to, uint256 tokenId) private {
//     for (uint256 i = 0; i < nftHolders[from].length; i++) {
//       if (nftHolders[from][i] == tokenId) {
//         nftHolders[to].push(tokenId);
//         nftHolders[from][i] = nftHolders[from][nftHolders[from].length - 1];
//         nftHolders[from].pop();
//         return;
//       }
//     }
//   }

//   function transferFrom( address from, address to, uint256 tokenId) public override {
//     require(
//       _isApprovedOrOwner(_msgSender(), tokenId),
//       "ERC721: transfer caller is not owner nor approved"
//     );
//     _transfer(from, to, tokenId);
//     changeHolder(from, to, tokenId);
//   }

//   function safeTransferFrom(address from,address to, uint256 tokenId) public override {
//     require(
//       _isApprovedOrOwner(_msgSender(), tokenId),
//       "ERC721: transfer caller is not owner nor approved"
//     );
//     safeTransferFrom(from, to, tokenId, "");
//   }

//   function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
//     require(
//       _isApprovedOrOwner(_msgSender(), tokenId),
//       "ERC721: transfer caller is not owner nor approved"
//     );
//     _safeTransfer(from, to, tokenId, _data);
//     changeHolder(from, to, tokenId);
//   }
// }
