pragma solidity ^0.5.8;

import "./ERC721.sol";


contract PlayerRepo {

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
        Player memory player = Player({
            weapon: uint256(0),
            armor: uint256(0),
            kittyId: kittyId,
            enabled: true
        });
        players[msg.sender] = Player;
        emit PlayerAdded(
            kittyId
        );
    }
}