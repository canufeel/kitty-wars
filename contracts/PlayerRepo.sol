pragma solidity ^0.5.8;

import "./ERC721.sol";


contract PlayerRepo {

    event BattleCreated (
        address player,
        uint256 battleId
    );

    event BattleJoined (
        address player,
        uint256 battleId
    );

    struct Player {
        uint256 weapon;
        uint256 armor;
        uint256 kittyId;
        bool enabled;
    }

    struct Battle {
        address playerOne;
        address playerTwo;
        bool created;
        bool started;
        bool finished;
    }

    struct BattleParams {
        bytes32[10] playerOneHashes;
        bytes32[10] playerTwoHashes;
        uint256[10] playerOneRolls;
        uint256[10] playerTwoRolls;
    }

    mapping (address => Player) players;
    mapping (address => bool) isBattling;

    address public kittyToken;
    address public weaponAddress;
    address public armorAddress;

    Battle[] public battles;
    BattleParams[] public battleParams;

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

    function startBattle(uint256 battleId) public {
        require(players[msg.sender].enabled == true, "Player not found");
        require(isBattling[msg.sender] == false, "Can not participate in 2 battles");
        isBattling[msg.sender] = true;
        if (battleId == 0) {
            Battle memory battle = Battle({
                playerOne: msg.sender,
                playerTwo: address(0),
                created: true,
                started: false,
                finished: false
            });
            battles.push(battle);
            emit BattleCreated(msg.sender, battles.length);
        } else {
            require(battles[battleId].created == true, "Battle id does not exist");
            battles[battleId].playerTwo = msg.sender;
            battles[battleId].started = true;
            emit BattleJoined(msg.sender, battleId);
        }
    }

    function commitBattleParams(
        bytes32[10] params
    ) public {
        for (uint256 i = 0; i < 10; i++) {

        }
    }
}