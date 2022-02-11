// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./chainlink/VRFConsumerBaseUpgradeable.sol";
import "./HouseMetadata.sol";

import "hardhat/console.sol";

contract House is Initializable, ERC721Upgradeable, VRFConsumerBaseUpgradeable {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  HouseMetadata.CardAttributes[] private defaultCards;
  mapping(uint256 => HouseMetadata.CardAttributes) public nftHolderAttributes;
  mapping(bytes32 => address) private requestToSender;

  bytes32 internal keyHash;
  uint256 internal fee;
  string[] private setImages;
  string private deckImage;

  event CardNFTMinted(address sender, uint256 tokenId, uint256 cardIndex);
  event SetNFTMinted(address sender, uint256 tokenId);
  event DeckNFTMinted(address sender, uint256 tokenId);

  function initialize(
    address _vrfCoordinator,
    address _link,
    bytes32 _keyHash,
    string[] memory _cardNames,
    string[] memory _cardImageURIs,
    string[] memory _cardNumbers,
    string[] memory _cardSuits,
    string[] memory _setImageURIs,
    string memory _deckImage
  ) public initializer {

    __VRFConsumerBase_init(_vrfCoordinator, _link);
    __ERC721_init("House", "HOUSE");

    for (uint256 i = 0; i < _cardNames.length; i++) {
      uint256[] memory t = new uint256[](5);
      defaultCards.push(
        HouseMetadata.CardAttributes({
          cardIndex: i,
          name: _cardNames[i],
          suit: _cardSuits[i],
          number: _cardNumbers[i],
          imageURI: _cardImageURIs[i],
          tokenId: _tokenIds.current(),
          traits: t
        })
      );
    }
    _tokenIds.increment();
    keyHash = _keyHash;
    fee = 0.1 * 10 ** 18;
    setImages = _setImageURIs;
    deckImage = _deckImage;
  }

  // function mintCard() public returns (bytes32) {
  //   require(
  //       LINK.balanceOf(address(this)) >= fee,
  //       "Not enough LINK"
  //   );
  //   bytes32 requestId = requestRandomness(keyHash, fee);
  //   requestToSender[requestId] = msg.sender;
  //   return requestId;
  // }

  function mint(uint256 cardIndex) public {
    uint256 newTokenId = _tokenIds.current();
    uint256[] memory t = new uint256[](5);
    t[0] = 1;
    t[1] = 2;
    t[2] = 3;
    nftHolderAttributes[newTokenId] = HouseMetadata.CardAttributes({
      cardIndex: cardIndex,
      name: defaultCards[cardIndex].name,
      suit: defaultCards[cardIndex].suit,
      number: defaultCards[cardIndex].number,
      imageURI: defaultCards[cardIndex].imageURI,
      tokenId: newTokenId,
      traits: t
    });
    _safeMint(msg.sender, newTokenId);
    _tokenIds.increment();
    emit CardNFTMinted(msg.sender, newTokenId, cardIndex);
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    uint256 newTokenId = _tokenIds.current();
    uint256 cardIndex = (randomness % defaultCards.length);

    uint256[] memory traits = new uint[](3);
    traits[0] = ((randomness % 10000) / 100);
    traits[1] = ((randomness % 1000000) / 10000);
    traits[2] = ((randomness % 100000000) / 1000000);

    nftHolderAttributes[newTokenId] = HouseMetadata.CardAttributes({
      cardIndex: cardIndex,
      name: defaultCards[cardIndex].name,
      suit: defaultCards[cardIndex].suit,
      number: defaultCards[cardIndex].number,
      imageURI: defaultCards[cardIndex].imageURI,
      tokenId: newTokenId,
      traits: traits
    });

    _safeMint(requestToSender[requestId], newTokenId);
    _tokenIds.increment();
    emit CardNFTMinted(requestToSender[requestId], newTokenId, cardIndex);
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    HouseMetadata.CardAttributes memory cardAttributes = nftHolderAttributes[_tokenId];
    return string(
      abi.encodePacked("data:application/json;base64,", HouseMetadata.tokenUri(cardAttributes))
    );
  }

  function mintSet(uint256[] memory tokenIdList) public {
    uint256[] memory traits = validate(tokenIdList, 0);
    uint256 newItemId = _tokenIds.current();
    uint256 setIndex = getSuit(nftHolderAttributes[tokenIdList[0]].cardIndex);
    _safeMint(msg.sender, newItemId);
    nftHolderAttributes[newItemId] = HouseMetadata.CardAttributes({
      cardIndex: setIndex,
      name: nftHolderAttributes[tokenIdList[0]].suit,
      suit: nftHolderAttributes[tokenIdList[0]].suit,
      number: "",
      imageURI: setImages[setIndex],
      tokenId: newItemId,
      traits: traits
    });
    _tokenIds.increment();
    emit SetNFTMinted(msg.sender, newItemId);
    for (uint256 index = 0; index < tokenIdList.length; index++) {
      _burn(tokenIdList[index]);
    }
  }

  function getSuit(uint256 cardIndex) pure private returns (uint256) {
    if (cardIndex < 13) {
      return 0;
    } else if (cardIndex < 26) {
      return 1;
    } else if (cardIndex < 39) {
      return 2;
    } else {
      return 3;
    }
  }

  function validate(uint256[] memory tokenIdList, uint256 option) private view returns (uint256[] memory) {
    bool[] memory valid;
    uint256[] memory traits = new uint[](3);
    if (option == 0) {
      require(tokenIdList.length == 13, "Not 13");
      valid = new bool[](13);
      for (uint256 index = 0; index < 13; index++) {
        valid[index] = false;
      }
      for (uint256 index = 0; index < tokenIdList.length; index++) {
        require(msg.sender == ownerOf(tokenIdList[index]), "Not owner");
        valid[nftHolderAttributes[tokenIdList[index]].cardIndex % 13] = true;
        traits[0] += nftHolderAttributes[tokenIdList[index]].traits[0];
        traits[1] += nftHolderAttributes[tokenIdList[index]].traits[1];
        traits[2] += nftHolderAttributes[tokenIdList[index]].traits[2];
      }
      for (uint256 index = 0; index < 13; index++) {
        require(valid[index], "Not Full");
      }
    } 
    // else if(option == 1) {
    //   require(tokenIdList.length == 4, "Not 4");
    //   valid = new bool[](4);
    //   for (uint256 index = 0; index < 4; index++) {
    //     valid[index] = false;
    //   }
    //   for (uint256 index = 0; index < tokenIdList.length; index++) {
    //     require(msg.sender == ownerOf(tokenIdList[index]), "Not owner");
    //     valid[nftHolderAttributes[tokenIdList[index]].cardIndex % 4] = true;
    //     traits[0] += nftHolderAttributes[tokenIdList[index]].traits[0];
    //     traits[1] += nftHolderAttributes[tokenIdList[index]].traits[1];
    //     traits[2] += nftHolderAttributes[tokenIdList[index]].traits[2];
    //   }
    //   for (uint256 index = 0; index < 4; index++) {
    //     require(valid[index], "Not Full");
    //   }
    // }
    return traits;
  }

  // function mintDeck(uint256[] memory tokenIdList) public {
  //   uint256[] memory traits = validate(tokenIdList, 1);
  //   uint256 newItemId = _tokenIds.current();
  //   _safeMint(msg.sender, newItemId);
  //   nftHolderAttributes[newItemId] = CardAttributes({
  //     cardIndex: 0,
  //     name: "Deck",
  //     suit: "",
  //     number: "",
  //     imageURI: deckImage,
  //     tokenId: newItemId,
  //     traits: traits
  //   });
  //   _tokenIds.increment();
  //   emit DeckNFTMinted(msg.sender, newItemId);
  //   for (uint256 index = 0; index < tokenIdList.length; index++) {
  //     _burn(tokenIdList[index]);
  //   }
  // }
}