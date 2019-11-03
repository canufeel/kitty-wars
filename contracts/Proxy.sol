pragma solidity ^0.5.8;

import "./IItemBase.sol";
import "./KittyBase.sol";
import "./PlayerRepo.sol";

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
        PlayerRepo(playerRepo).addPlayer(kittyId, msg.sender);
    }

    function loot(
        uint256 weaponPower,
        uint256 armorPower
    ) public {
        IItemBase(itemFactory).forge(ItemType.WEAPON, weaponPower);
        IItemBase(itemFactory).forge(ItemType.ARMOR, weaponPower);
    }
}
