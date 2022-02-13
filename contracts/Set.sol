// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./Metadata.sol";
import "./Card.sol";

contract Set is Initializable, ERC721Upgradeable, IERC721Receiver {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string[] private setImages;
    address private cardAddr;
    mapping(uint256 => Metadata.Attributes) private tokenIdToAttributes;
    mapping(uint256 => uint256[]) private setIdToCardsId;

    event SetNFTMinted(address sender, uint256 tokenId);

    function initialize(
        string[] memory _setImageURIs,
        address _cardAddr
    ) public initializer {
        __ERC721_init("Set", "SET");
        setImages = _setImageURIs;
        cardAddr = _cardAddr;
        _tokenIds.increment();
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function mintSet(uint256[] memory tokenIdList) public {
        uint256[] memory traits = validate(tokenIdList);
        uint256 newItemId = _tokenIds.current();

        Metadata.Attributes memory first = Card(cardAddr).getAttributes(tokenIdList[0]);
        uint256 setIndex = getSuit(first.cardIndex);

        _safeMint(msg.sender, newItemId);

        tokenIdToAttributes[newItemId] = Metadata.Attributes({
            cardIndex: setIndex,
            name: first.suit,
            suit: first.suit,
            number: "",
            imageURI: setImages[setIndex],
            tokenId: newItemId,
            traits: traits
        });
        _tokenIds.increment();
        
        for (uint256 index = 0; index < tokenIdList.length; index++) {
            Card(cardAddr).safeTransferFrom(msg.sender, address(this), tokenIdList[index]);
            setIdToCardsId[newItemId].push(tokenIdList[index]);
        }

        emit SetNFTMinted(msg.sender, newItemId);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        Metadata.Attributes memory attributes = tokenIdToAttributes[_tokenId];
        return string(abi.encodePacked("data:application/json;base64,", Metadata.tokenUri(attributes)));
    }

    function getAttributes(uint256 tokenId) external view returns (Metadata.Attributes memory) {
        return tokenIdToAttributes[tokenId];
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

    function validate(uint256[] memory tokenIdList) private view returns (uint256[] memory) {
        require(tokenIdList.length == 13, "Not 13");

        bool[] memory valid = new bool[](13);
        uint256[] memory traits = new uint[](3);

        for (uint256 index = 0; index < 13; index++) {
            valid[index] = false;
        }

        for (uint256 index = 0; index < tokenIdList.length; index++) {
            require(msg.sender == Card(cardAddr).ownerOf(tokenIdList[index]), "Not owner");
            Metadata.Attributes memory card = Card(cardAddr).getAttributes(tokenIdList[index]);
            valid[card.cardIndex % 13] = true;
            traits[0] += card.traits[0];
            traits[1] += card.traits[1];
            traits[2] += card.traits[2];
        }

        for (uint256 index = 0; index < 13; index++) {
            require(valid[index], "Not Full");
        }

        return traits;
    }
    
}