// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

import "hardhat/console.sol";

import "./HouseToken.sol";

contract HouseFactory is VRFConsumerBase {

    struct CardAttributes {
        uint256 cardIndex;
        string name;
        string suit;
        string number;
        string imageURI;
        uint256 tokenId;
        uint256[] traits;
    }

    CardAttributes[] defaultCards;

    bytes32 internal keyHash;
    uint256 internal fee;

    mapping(bytes32 => address) public requestToSender;

    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        string[] memory _cardNames,
        string[] memory _cardImageURIs,
        string[] memory _cardNumbers,
        string[] memory _cardSuits
    ) VRFConsumerBase(_vrfCoordinator, _link) {

        uint256[] memory defaultTraits = new uint[](5);

        for (uint256 i = 0; i < _cardNames.length; i++) {
            defaultCards.push(
                CardAttributes({
                cardIndex: i,
                name: _cardNames[i],
                suit: _cardSuits[i],
                number: _cardNumbers[i],
                imageURI: _cardImageURIs[i],
                tokenId: 0,
                traits: defaultTraits
                })
            );

            CardAttributes memory c = defaultCards[i];
            console.log(
                "Done initializing %s , img %s",
                c.name,
                c.imageURI
            );
        }
    
        keyHash = _keyHash;
        fee = 0.1 * 10 ** 18;

    }

    function mintCard() public returns (bytes32) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestToSender[requestId] = msg.sender;
        return requestId;
    } 

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 cardIndex = ((randomness % defaultCards.length) % 18);

        uint256[] memory traits = new uint[](5);
        
        traits[0] = (((randomness % 10000) / 100) % 18);
        traits[1] = (((randomness % 1000000) / 10000) % 18);
        traits[2] = (((randomness % 100000000) / 1000000) % 18);
        traits[3] = (((randomness % 10000000000) / 100000000) % 18);
        traits[4] = (((randomness % 1000000000000) / 10000000000) % 18);

        // CardAttributes newCard = CardAttributes({
        //     cardIndex: cardIndex,
        //     name: defaultCards[cardIndex].name,
        //     suit: defaultCards[cardIndex].suit,
        //     number: defaultCards[cardIndex].number,
        //     imageURI: defaultCards[cardIndex].imageURI,
        //     traits: traits
        // });


        // nftHolders[requestToSender[requestId]].push(newTokenId);
        // _safeMint(requestToSender[requestId], newTokenId);
        // _tokenIds.increment();
        // emit CardNFTMinted(requestToSender[requestId], newTokenId, cardIndex);
    }


}

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// // Helper functions OpenZeppelin provides.
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

// import "./libraries/Base64.sol";

// import "hardhat/console.sol";

// contract HouseFactory is ERC721, VRFConsumerBase {
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
//   event SetNFTMinted(address sender, uint256 tokenId);

//   bytes32 internal keyHash;
//   uint256 internal fee;
  
//   uint256 public randomResult;

//   mapping(bytes32 => address) public requestToSender;

//   string[] setImages;

//   constructor(
//     address _vrfCoordinator,
//     address _link,
//     bytes32 _keyHash,
//     string[] memory _cardNames,
//     string[] memory _cardImageURIs,
//     string[] memory _cardNumbers,
//     string[] memory _cardSuits,
//     string[] memory _setImageURIs
//   ) 
//     ERC721("House", "HOUSE") 
//     VRFConsumerBase(_vrfCoordinator, _link) {

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
//     fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
//     setImages = _setImageURIs;
//   }

//   function requestNewRandomCard() public returns (bytes32) {
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

//   function withdrawLink() external {
//     LINK.transferFrom(address(this), msg.sender, LINK.balanceOf(address(this)));
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

//   function mintCard() external {
    
//     uint256 newItemId = _tokenIds.current();
//     uint256 cardIndex = pickRandomCardIndex(newItemId);
//     uint256[] memory defaultTraits = new uint[](5);
    
//     _safeMint(msg.sender, newItemId);

//     nftHolderAttributes[newItemId] = CardAttributes({
//       cardIndex: cardIndex,
//       name: defaultCards[cardIndex].name,
//       suit: defaultCards[cardIndex].suit,
//       number: defaultCards[cardIndex].number,
//       imageURI: defaultCards[cardIndex].imageURI,
//       tokenId: newItemId,
//       traits: defaultTraits
//     });

//     console.log(
//       "Minted NFT %s w/ tokenId %s and cardIndex %s",
//       defaultCards[cardIndex].name,
//       newItemId,
//       cardIndex
//     );

//     nftHolders[msg.sender].push(newItemId);

//     _tokenIds.increment();
//     emit CardNFTMinted(msg.sender, newItemId, cardIndex);
//   }

//   function mintSet(uint256[] memory tokenIdList) public {
//     validateSet(tokenIdList);
//     uint256 suit = getCardSuit(tokenIdList[0]);

//     uint256 newItemId = _tokenIds.current();
//     _safeMint(msg.sender, newItemId);

//     uint256[] memory defaultTraits = new uint[](5);
//     string memory setName = string(abi.encodePacked("Set of " , nftHolderAttributes[tokenIdList[0]].suit));

//     nftHolderAttributes[newItemId] = CardAttributes({
//       cardIndex: 0,
//       name: setName,
//       suit: nftHolderAttributes[tokenIdList[0]].suit,
//       number: "0",
//       imageURI: setImages[suit],
//       tokenId: newItemId,
//       traits: defaultTraits
//     });

//     console.log(
//       "A SET NFT w/ ID %s has been minted to %s",
//       newItemId,
//       msg.sender
//     );
//     _tokenIds.increment();
//     emit SetNFTMinted(msg.sender, newItemId);

//     for (uint256 index = 0; index < tokenIdList.length; index++) {
//       console.log("Burning CARD with ID %s.", tokenIdList[index]);
//       _burn(tokenIdList[index]);
//     }
//   }

//   function getCardSuit(uint256 tokenId) private view returns (uint256) {
//     uint256 cardIndex = nftHolderAttributes[tokenId].cardIndex;
//     if (cardIndex < 13) {
//       return 0;
//     } else if (cardIndex < 26) {
//       return 1;
//     } else if (cardIndex < 39) {
//       return 2;
//     } else {
//       return 3;
//     }
//   }

//   function validateSet(uint256[] memory tokenIdList) private view {
//     require(tokenIdList.length == 13, "Not 13 cards");
//     bool[] memory valid = new bool[](13);
//     for (uint256 index = 0; index < 13; index++) {
//       valid[index] = false;
//     }
//     for (uint256 index = 0; index < tokenIdList.length; index++) {
//       require(msg.sender == ownerOf(tokenIdList[index]), "Not all your tokens");
//       uint256 suitIndex = nftHolderAttributes[tokenIdList[index]].cardIndex;
//       valid[suitIndex % 13] = true;
//     }
//     for (uint256 index = 0; index < 13; index++) {
//       require(valid[index], "Not a full set");
//     }
//   }

//   function pickRandomCardIndex(uint256 tokenId) internal view returns (uint256) {
//     uint256 rand = random(
//       string(abi.encodePacked("CARD", Strings.toString(tokenId)))
//     );
//     rand = rand % defaultCards.length;
//     return rand;
//   }

//   function random(string memory input) internal pure returns (uint256) {
//     return uint256(keccak256(abi.encodePacked(input)));
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
