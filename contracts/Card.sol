// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./chainlink/VRFConsumerBaseUpgradeable.sol";
import "./Metadata.sol";

contract Card is Initializable, ERC721Upgradeable, VRFConsumerBaseUpgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Metadata.Attributes[] private defaultCards;
    mapping(uint256 => Metadata.Attributes) private tokenIdToAttributes;
    mapping(bytes32 => address) private requestToSender;

    bytes32 internal keyHash;
    uint256 internal fee;

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
    string[] memory _cardSuits
  ) public initializer {

    __VRFConsumerBase_init(_vrfCoordinator, _link);
    __ERC721_init("Card", "CARD");

    for (uint256 i = 0; i < _cardNames.length; i++) {
      uint256[] memory t = new uint256[](5);
      defaultCards.push(
        Metadata.Attributes({
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
  }

  function mintCard() public returns (bytes32) {
    require(
        LINK.balanceOf(address(this)) >= fee,
        "Not enough LINK"
    );
    bytes32 requestId = requestRandomness(keyHash, fee);
    requestToSender[requestId] = msg.sender;
    return requestId;
  }

  function mint(uint256 cardIndex) public {
    uint256 newTokenId = _tokenIds.current();
    uint256[] memory t = new uint256[](5);
    t[0] = 1;
    t[1] = 2;
    t[2] = 3;
    tokenIdToAttributes[newTokenId] = Metadata.Attributes({
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

  function getAttributes(uint256 tokenId) external view returns (Metadata.Attributes memory) {
      return tokenIdToAttributes[tokenId];
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    uint256 newTokenId = _tokenIds.current();
    uint256 cardIndex = (randomness % defaultCards.length);

    uint256[] memory traits = new uint[](3);
    traits[0] = ((randomness % 10000) / 100);
    traits[1] = ((randomness % 1000000) / 10000);
    traits[2] = ((randomness % 100000000) / 1000000);

    tokenIdToAttributes[newTokenId] = Metadata.Attributes({
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
    Metadata.Attributes memory attributes = tokenIdToAttributes[_tokenId];
    return string(
      abi.encodePacked("data:application/json;base64,", Metadata.tokenUri(attributes))
    );
  }

}