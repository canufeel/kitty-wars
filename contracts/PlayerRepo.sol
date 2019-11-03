pragma solidity ^0.5.8;

import "./ERC721.sol";
import "./ItemTypeDataType.sol";
import "./IItemBase.sol";


contract PlayerRepo is ItemTypeDataType {

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
        uint256 itemId,
        address toPlayer
    ) public {
        ERC721 itemToken = ERC721(itemAddress);

        require(
            itemToken.ownerOf(itemId) == msg.sender,
            "You have to own the Item."
        );
        itemToken
            .transferFrom(
                msg.sender,
                address(this),
                itemId
            );

        require(players[toPlayer].enabled, "Player does not exist");
        uint256 kittyId = players[toPlayer].kittyId;

        (
            ItemType itemType,
        ) = IItemBase(itemAddress).getItem(itemId);
        if (itemType == ItemType.WEAPON) {
            players[toPlayer].weaponId = itemId;
        } else {
            players[toPlayer].armorId = itemId;
        }

        emit ItemAssigned(
            kittyId,
            itemId,
            itemType
        );
    }
}
