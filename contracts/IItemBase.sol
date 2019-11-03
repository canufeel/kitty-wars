pragma solidity ^0.5.8;

import "./ItemTypeDataType.sol";
import "./ERC721.sol";


contract IItemBase is ItemTypeDataType, ERC721 {
    function getItem(uint256 itemId) public view returns (
        ItemType itemType,
        uint256 itemPower
    );

    function forge(
        ItemType itemType,
        uint256 power
    ) public returns (uint256 itemId);
}