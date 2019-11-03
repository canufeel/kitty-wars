pragma solidity ^0.5.8;


contract IPlayerRepo {
    function getPlayer(address playerAddress) public view returns (
        uint256 weaponId,
        uint256 armorId,
        uint256 kittyId,
        bool enabled
    );
}