pragma solidity ^0.5.8;

import "./ItemTypeDataType.sol";


contract IPlayerRepo is ItemTypeDataType {
    event PlayerAdded(
        uint256 kittyId,
        address indexed playerAddress
    );

    event ItemAssigned(
        uint256 kittyId,
        uint256 itemId,
        ItemType itemType
    );

    function getPlayer(address playerAddress) public view returns (
        uint256 weaponId,
        uint256 armorId,
        uint256 kittyId,
        bool enabled
    );

    function assignItem(
        uint256 itemId,
        address toPlayer
    ) public;

    function addPlayer(
        uint256 kittyId,
        address toPlayer
    ) public;
}
