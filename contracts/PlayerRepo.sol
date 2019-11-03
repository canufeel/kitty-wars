pragma solidity ^0.5.8;

import "./ERC721.sol";
import "./ItemBase.sol";


contract PlayerRepo is ItemBase {

    event PlayerAdded(
        uint256 kittyId
    );
    event ItemAssigned(
        uint256 kittyId,
        uint256 itemId,
        ItemType itemType
    );

    struct Player {
        uint256 weaponId;
        uint256 armorId;
        uint256 kittyId;
        bool enabled;
    }

    mapping (address => Player) players;

    address public kittyToken;
    address public itemAddress;

    constructor (
        address _kittyToken,
        address _itemAddress
    ) public {
        require(_kittyToken != address(0));
        require(_itemAddress != address(0));
        kittyToken = _kittyToken;
        itemAddress = _itemAddress;
    }

    function addPlayer(
        uint256 kittyId
    ) public {
        ERC721(kittyToken)
            .transferFrom(
                msg.sender,
                address(this),
                kittyId
            );
        players[msg.sender] = Player({
            weaponId: uint256(0),
            armorId: uint256(0),
            kittyId: kittyId,
            enabled: true
        });
        emit PlayerAdded(
            kittyId
        );
    }

    function getPlayer(address playerAddress) public view returns (
        uint256 weaponId,
        uint256 armorId,
        uint256 kittyId,
        bool enabled
    ) {
        weaponId = players[playerAddress].weaponId;
        armorId = players[playerAddress].armorId;
        kittyId = players[playerAddress].kittyId;
        enabled = players[playerAddress].enabled;
    }

    function assignItem(
        uint256 itemId
    ) public {
        ERC721 itemToken = ERC721(itemAddress);
        ERC721 kittyToken = ERC721(kittyToken);

        require(
            itemToken.ownerOf(itemId) == msg.sender,
            "You have to own the Item."
        );

        uint256 kittyId = players[msg.sender].kittyId;

        ItemType itemType = allItems[itemId].itemType;
        if (itemType == ItemType.WEAPON) {
            players[msg.sender].weaponId = itemId;
        } else {
            players[msg.sender].armorId = itemId;
        }

        emit ItemAssigned(
            kittyId,
            itemId,
            itemType
        );
    }
}
