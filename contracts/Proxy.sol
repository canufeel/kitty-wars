pragma solidity ^0.5.8;

import "./IItemBase.sol";

contract Proxy {

    address itemFactory;
    address playerRepo;

    constructor (
        address _itemFactory,
        address _playerRepo
    ) public {
        require(_playerRepo != address(0));
        require(__itemFactory != address(0));
        itemFactory = _itemFactory;
        playerRepo = _playerRepo;
    }

    function loot(
        uint256 weaponPower,
        uint256 armorPower
    ) public {
        IItemBase(itemFactory).forge(ItemType.WEAPON, weaponPower);
        IItemBase(itemFactory).forge(ItemType.ARMOR, weaponPower);
    }
}
