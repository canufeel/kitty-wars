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
    address public weaponAddress;
    address public armorAddress;

    constructor (
        address _kittyToken,
        address _weaponAddress,
        address _armorAddress
    ) public {
        require(_kittyToken != address(0));
        require(_weaponAddress != address(0));
        require(_armorAddress != address(0));
        kittyToken = _kittyToken;
        weaponAddress = _weaponAddress;
        armorAddress = _armorAddress;
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
        address itemTokenAddress,
        address kittyTokenAddress
    ) public {
        ERC721 itemToken = ERC712(itemTokenAddress);
        ERC721 kittyToken = ERC721(kittyTokenAddress);

        require(
            itemToken.ownerOf(itemId) == msg.sender,
            "You have to own the Item."
        );

        uint256 kittyId = players[msg.sender].kittyId;
        require(
            kittyToken.ownerOf(kittyId) == msg.sender,
            "You have to own the Kitty."
        );

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
