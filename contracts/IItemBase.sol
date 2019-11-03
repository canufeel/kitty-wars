pragma solidity ^0.5.8;

import "./ItemTypeDataType.sol";


contract IItemBase is ItemTypeDataType {
    function getItem(uint256 itemId) public view returns (
        ItemType itemType,
        uint256 itemPower
    );
}