pragma solidity ^0.5.8;


contract Battle {
    bytes32 private constant ZERO_BYTES32 = bytes32(0);

    event BattleCreated (
        address player,
        uint256 battleId
    );

    event BattleJoined (
        address player,
        uint256 battleId
    );

    struct Battle {
        address playerOne;
        address playerTwo;
        bool created;
        bool started;
        bool finished;
        uint256 battleParamsIdx;
    }

    struct BattleParams {
        bytes32[10] playerOneHashes;
        bytes32[10] playerTwoHashes;
        uint256[10] playerOneRolls;
        uint256[10] playerTwoRolls;
        bool created;
    }

    Battle[] public battles;
    BattleParams[] public battleParamsArr;

    mapping (address => bool) isBattling;

    address public playerRepo;

    constructor (address _playerRepo) public {
        require(_playerRepo != address(0));
        playerRepo = _playerRepo;
    }

    function startBattle(uint256 battleId) public {
        require(playerRepo.players[msg.sender].enabled == true, "Player not found");
        require(isBattling[msg.sender] == false, "Can not participate in 2 battles");
        isBattling[msg.sender] = true;
        if (battleId == 0) {
            Battle memory battle = Battle({
                playerOne: msg.sender,
                playerTwo: address(0),
                created: true,
                started: false,
                canResolve: false,
                finished: false,
                battleParamsIdx: battles.length
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
        bytes32[10] memory hashes,
        uint256 battleId
    ) public {
        require(battles[battleId].started == true, "Battle has not started or does not exist");
        if (!battleParamsArr[battleId].created) {
            bytes32[10] memory emptyBytes = new bytes32[10](
                ZERO_BYTES32,
                ZERO_BYTES32,
                ZERO_BYTES32,
                ZERO_BYTES32,
                ZERO_BYTES32,
                ZERO_BYTES32,
                ZERO_BYTES32,
                ZERO_BYTES32,
                ZERO_BYTES32,
                ZERO_BYTES32
            );
            uint256[10] memory emptyValues = new uint256[10](0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            BattleParams memory battleParams = BattleParams({
                created: true,
                playerOneHashes: emptyBytes,
                playerTwoHashes: emptyBytes,
                playerOneRolls: emptyValues,
                playerTwoRolls: emptyValues
                });
            if (msg.sender == battles[battleId].playerOne) {
                battleParams.playerOneHashes = hashes;
            } else if (msg.sender == battles[battleId].playerTwo) {
                battleParams.playerTwoHashes = hashes;
            } else {
                revert("Invalid player");
            }

            battleParamsArr[battleId] = battleParams;
        } else {
            if (msg.sender == battles[battleId].playerOne) {
                battleParamsArr[battleId].playerOneHashes = hashes;
            } else if (msg.sender == battles[battleId].playerTwo) {
                battleParamsArr[battleId].playerTwoHashes = hashes;
            } else {
                revert("Invalid player");
            }
            battle[battleId].canResolve = true;
        }
    }

    function submitBattleResolution(
        uint256[10] resolutionValues,
        uint256 battleId
    ) {

    }
}