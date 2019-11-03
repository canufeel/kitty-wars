pragma solidity ^0.5.8;

import "./IItemBase.sol";
import "./IPlayerRepo.sol";

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
        IItemBase itemFactoryContract = IItemBase(itemFactory);
        uint256 weaponId = itemFactoryContract.forge(ItemType.WEAPON, weaponPower);
        uint256 armorId = itemFactoryContract.forge(ItemType.ARMOR, weaponPower);
        itemFactoryContract.approve(playerRepo, weaponId);
        itemFactoryContract.approve(playerRepo, armorId);
        IPlayerRepo playerRepoContract = IPlayerRepo(playerRepo);
        playerRepoContract.assignItem(
            weaponId,
            msg.sender
        );
        playerRepoContract.assignItem(
            armorId,
            msg.sender
        );
    }
}
