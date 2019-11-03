pragma solidity ^0.5.8;

import "./ERC721.sol";


contract PlayerRepo {

    event PlayerAdded(
        uint256 kittyId
    );

    struct Player {
        uint256 weapon;
        uint256 armor;
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
            weapon: uint256(0),
            armor: uint256(0),
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
        weaponId = players[playerAddress].weapon;
        armorId = players[playerAddress].armor;
        kittyId = players[playerAddress].kittyId;
        enabled = players[playerAddress].enabled;
    }
}