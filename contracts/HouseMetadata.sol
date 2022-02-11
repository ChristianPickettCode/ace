// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

library HouseMetadata {
    struct CardAttributes {
        uint256 cardIndex;
        string name;
        string suit;
        string number;
        string imageURI;
        uint256 tokenId;
        uint256[] traits;
    }

    function tokenUri(CardAttributes memory cardAttributes) pure internal returns (string memory) {
        return Base64.encode(
            abi.encodePacked(
                '{"name": "',
                cardAttributes.name,
                '", "description": "House of Cards", "image": "',
                cardAttributes.imageURI,
                '", "cardIndex": "',
                Strings.toString(cardAttributes.cardIndex),
                '", "attributes": [ { "trait_type": "Suit", "value": "',
                cardAttributes.suit,
                '"}, { "trait_type": "Number", "value": "',
                cardAttributes.number,
                '"}, { "trait_type": "Trait 1", "value": "',
                Strings.toString(cardAttributes.traits[0]),
                '"}, { "trait_type": "Trait 2", "value": "',
                Strings.toString(cardAttributes.traits[1]),
                '"}, { "trait_type": "Trait 3", "value": "',
                Strings.toString(cardAttributes.traits[2]),
                '"} ]}'
            )
        );
    }
}