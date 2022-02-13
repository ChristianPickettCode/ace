// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Metadata.sol";
import "./Set.sol";

contract Deck is Initializable, ERC721Upgradeable, IERC721Receiver {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string private deckImage;

    mapping(uint256 => Metadata.Attributes) private tokenIdToAttributes;
    mapping(uint256 => uint256[]) private deckIdToSetsId;
    event DeckNFTMinted(address sender, uint256 tokenId);

    address private cardAddr;
    address private setAddr;

    function initialize(
        string memory _deckImage,
        address _cardAddr,
        address _setAddr
    ) public initializer {
        __ERC721_init("Deck", "DECK");
        deckImage = _deckImage;
        cardAddr = _cardAddr;
        setAddr = _setAddr;
        _tokenIds.increment();
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function mintDeck(uint256[] memory tokenIdList) public {
        uint256[] memory traits = validate(tokenIdList);
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToAttributes[newItemId] =  Metadata.Attributes({
            cardIndex: 0,
            name: "Deck",
            suit: "",
            number: "",
            imageURI: deckImage,
            tokenId: newItemId,
            traits: traits
        });
        _tokenIds.increment();
        
        for (uint256 index = 0; index < tokenIdList.length; index++) {
            Set(setAddr).safeTransferFrom(msg.sender, address(this), tokenIdList[index]);
            deckIdToSetsId[newItemId].push(tokenIdList[index]);
        }
        emit DeckNFTMinted(msg.sender, newItemId);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        Metadata.Attributes memory attributes = tokenIdToAttributes[_tokenId];
        return string(abi.encodePacked("data:application/json;base64,", Metadata.tokenUri(attributes)));
    }

    function validate(uint256[] memory tokenIdList) private view returns (uint256[] memory) {
        require(tokenIdList.length == 4, "Not 4");

        bool[] memory valid = new bool[](4);
        uint256[] memory traits = new uint[](3);

        for (uint256 index = 0; index < 4; index++) {
            valid[index] = false;
        }

        for (uint256 index = 0; index < tokenIdList.length; index++) {
            require(msg.sender == Set(setAddr).ownerOf(tokenIdList[index]), "Not owner");
            Metadata.Attributes memory card = Set(setAddr).getAttributes(tokenIdList[index]);
            valid[card.cardIndex % 4] = true;
            traits[0] += card.traits[0];
            traits[1] += card.traits[1];
            traits[2] += card.traits[2];
        }

        for (uint256 index = 0; index < 4; index++) {
            require(valid[index], "Not Full");
        }

        return traits;
    }

    function getAttributes(uint256 tokenId) external view returns (Metadata.Attributes memory) {
        return tokenIdToAttributes[tokenId];
    }
}