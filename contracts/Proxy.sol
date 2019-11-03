pragma solidity ^0.5.8;

import "./IItemBase.sol";
import "./KittyBase.sol";
import "./IPlayerRepo.sol";

contract Proxy {

    address itemFactory;
    address playerRepo;
    address kittyToken;

    constructor (
        address _itemFactory,
        address _playerRepo,
        address _kittyToken
    ) public {
        require(_playerRepo != address(0));
        require(_itemFactory != address(0));
        require(_kittyToken != address(0));
        itemFactory = _itemFactory;
        playerRepo = _playerRepo;
        kittyToken = _kittyToken;
    }

    function join() public {
        uint256 kittyId = KittyBase(kittyToken).createKitty(1, 1, 1, 1, msg.sender);
        KittyBase(kittyToken).approve(msg.sender, kittyId);
        IPlayerRepo(playerRepo).addPlayer(kittyId, msg.sender);
    }

    function loot(
        uint256 weaponPower,
        uint256 armorPower
    ) public {
        IItemBase itemFactoryContract = IItemBase(itemFactory);
        uint256 weaponId = itemFactoryContract.forge(ItemTypeDataType.ItemType.WEAPON, weaponPower);
        uint256 armorId = itemFactoryContract.forge(ItemTypeDataType.ItemType.ARMOR, weaponPower);
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
