pragma solidity ^0.5.8;

import "./ERC721.sol";


contract Item is ERC721 {

    event ItemCreated(
        uint256 itemId,
        Type itemType,
        uint256 itemPower
    );

    enum Type { WEAPON, ARMOR }

    struct Item {
        Type type;
        uint256 power;
    }

    Item[] public allItems;

    function create(Type type, uint256 power) public returns (uint256 itemId) {
        require(power <= 10, "Power has to be <= 10.");
        require(
            type == Type.WEAPON || type == Type.ARMOR,
            "Wrong item type. Only Weapon (0) or Armor (1) available"
        );

        Item newItem = new Item(type, power);
        allItems.push(newItem);
        itemId = allItems.length - 1;

        emit ItemCreated(
            itemId,
            type,
            power
        );
    }
}
