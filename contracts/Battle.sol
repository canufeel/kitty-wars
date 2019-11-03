pragma solidity ^0.5.8;

import "./IPlayerRepo.sol";


contract Battle {
    bytes32 private constant ZERO_BYTES32 = bytes32(0);
    uint256 private constant ZERO_UINT256 = uint256(0);

    uint256 private constant PLAYER_HITPOINTS = uint256(100);

    event BattleWon (
        address winner,
        uint256 battleId
    );

    event BattleCreated (
        address player,
        uint256 battleId
    );

    event BattleJoined (
        address player,
        uint256 battleId
    );

    struct BattleStruct {
        address playerOne;
        address playerTwo;
        bool created;
        bool canResolve;
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
        bool firstRollsSubmitted;
    }

    BattleStruct[] public battles;
    BattleParams[] public battleParamsArr;

    mapping (address => bool) isBattling;

    address public playerRepo;
    address public itemOwnership;

    constructor (
        address _playerRepo,
        address _itemOwnership
    ) public {
        require(_playerRepo != address(0));
        require(_itemOwnership != address(0));
        playerRepo = _playerRepo;
        itemOwnership = _itemOwnership;
        battles.push(BattleStruct({
            playerOne: address(0),
            playerTwo: address(0),
            created: false,
            started: false,
            canResolve: false,
            finished: false,
            battleParamsIdx: 0
        }));
        bytes32[10] memory emptyBytes = [
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
        ];
        uint256[10] memory emptyValues = [
            ZERO_UINT256,
            ZERO_UINT256,
            ZERO_UINT256,
            ZERO_UINT256,
            ZERO_UINT256,
            ZERO_UINT256,
            ZERO_UINT256,
            ZERO_UINT256,
            ZERO_UINT256,
            ZERO_UINT256
        ];
        BattleParams memory battleParams = BattleParams({
            created: false,
            firstRollsSubmitted: false,
            playerOneHashes: emptyBytes,
            playerTwoHashes: emptyBytes,
            playerOneRolls: emptyValues,
            playerTwoRolls: emptyValues
        });
        battleParamsArr.push(battleParams);
    }

    function startBattle(uint256 battleId) public {
        (
            ,
            ,
            ,
            bool enabled
        ) = IPlayerRepo(playerRepo).getPlayer(msg.sender);
        require(enabled == true, "Player not found");
        require(
            isBattling[msg.sender] == false,
            "Can not participate in 2 battles"
        );
        isBattling[msg.sender] = true;
        if (battleId == 0) {
            battles.push(BattleStruct({
                playerOne: msg.sender,
                playerTwo: address(0),
                created: true,
                started: false,
                canResolve: false,
                finished: false,
                battleParamsIdx: battles.length
            }));
            emit BattleCreated(msg.sender, battles.length - 1);
        } else {
            require(
                battles[battleId].created == true,
                "Battle id does not exist"
            );
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
        if (battleParamsArr.length == battleId) {
            bytes32[10] memory emptyBytes = [
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
            ];
            uint256[10] memory emptyValues = [
                ZERO_UINT256,
                ZERO_UINT256,
                ZERO_UINT256,
                ZERO_UINT256,
                ZERO_UINT256,
                ZERO_UINT256,
                ZERO_UINT256,
                ZERO_UINT256,
                ZERO_UINT256,
                ZERO_UINT256
            ];
            BattleParams memory battleParams = BattleParams({
                created: true,
                firstRollsSubmitted: false,
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

            battleParamsArr.push(battleParams);
        } else if (battleParamsArr.length > battleId) {
            if (msg.sender == battles[battleId].playerOne) {
                battleParamsArr[battleId].playerOneHashes = hashes;
            } else if (msg.sender == battles[battleId].playerTwo) {
                battleParamsArr[battleId].playerTwoHashes = hashes;
            } else {
                revert("Invalid player");
            }
            battles[battleId].canResolve = true;
        } else {
            revert("Invalid battleId");
        }
    }

    function submitBattleResolution(
        uint256[10] memory resolutionValues,
        uint256 battleId
    ) public {
        require(battles[battleId].canResolve == true, "Battle can not be resolved yet");
        require(!battles[battleId].finished, "Battle already finished");
        if (!battleParamsArr[battleId].firstRollsSubmitted) {
            bytes32[10] memory hashes;
            if (msg.sender == battles[battleId].playerOne) {
                battleParamsArr[battleId].playerOneRolls = resolutionValues;
                hashes = battleParamsArr[battleId].playerOneHashes;
            } else if (msg.sender == battles[battleId].playerTwo) {
                battleParamsArr[battleId].playerTwoRolls = resolutionValues;
                hashes = battleParamsArr[battleId].playerTwoHashes;
            } else {
                revert("Invalid player");
            }

            for (uint256 i = 0; i < 10; i++) {
                require(
                    hashes[i] == keccak256(abi.encode(resolutionValues[i])),
                    "Submitted value does not match preimage"
                );
            }
            battleParamsArr[battleId].firstRollsSubmitted = true;
        } else {
            bytes32[10] memory hashes;
            if (msg.sender == battles[battleId].playerOne) {
                hashes = battleParamsArr[battleId].playerOneHashes;
            } else if (msg.sender == battles[battleId].playerTwo) {
                hashes = battleParamsArr[battleId].playerTwoHashes;
            } else {
                revert("Invalid player");
            }

            for (uint256 i = 0; i < 10; i++) {
                require(
                    hashes[i] == keccak256(abi.encode(resolutionValues[i])),
                    "Submitted value does not match preimage"
                );
            }
            battles[battleId].finished = true;
            emit BattleWon(
                determineWinner(resolutionValues, battleId),
                battleId
            );
        }
    }

    function determineWinner(
        uint256[10] memory resolutionValues,
        uint256 battleId
    ) internal view returns (address) {
        uint256[10] existingRolls;
        if (msg.sender == battles[battleId].playerOne) {
            existingRolls = battleParamsArr[battleId].playerTwoRolls;
        } else if (msg.sender == battles[battleId].playerTwo) {
            existingRolls = battleParamsArr[battleId].playerOneRolls;
        } else {
            revert("Invalid player");
        }

        (
            uint256 weaponId1,
            uint256 armorId1,
            ,
            ,
        ) = IPlayerRepo(playerRepo).getPlayer(battles[battleId].playerOne);
        (
            uint256 weaponId2,
            uint256 armorId2,
            ,
            ,
        ) = IPlayerRepo(playerRepo).getPlayer(battles[battleId].playerOne);

        uint256[] memory rounds = new uint256[](10);
        uint256[] memory modifiers = new uint256[](4);

        // TODO: import Item contract above
        (, modifiers[0]) = ItemOwnership(itemOwnership).getItem(weaponId1);
        (, modifiers[1]) = ItemOwnership(itemOwnership).getItem(armorId1);
        (, modifiers[2]) = ItemOwnership(itemOwnership).getItem(weaponId2);
        (, modifiers[3]) = ItemOwnership(itemOwnership).getItem(armorId2);

        uint256 round;
        uint256 totalDamageOne = 0;
        uint256 totalDamageTwo = 0;
        uint256 currentDamage = 0;

        for (uint256 i = 0; i < resolutionValues.length; i++) {
            round = existingRolls[i] + resolutionValues[i];
            if (round > 100) round == 100;

            if (i % 2 != 0) {
                currentDamage = round * modifiers[0] - round * modifiers[1];
                currentDamage = currentDamage <= 0 ? 0 : currentDamage;
                totalDamageOne = totalDamageOne + currentDamage;
            } else {
                currentDamage = round * modifiers[2] - round * modifiers[3];
                currentDamage = currentDamage <= 0 ? 0 : currentDamage;
                totalDamageTwo = totalDamageTwo + currentDamage;
            }
        }

        address winner;
        if (totalDamageOne > totalDamageTwo) {
            winner = battles[battleId].playerOne;
        } else if (totalDamageOne < totalDamageTwo) {
            winner = battles[battleId].playerTwo;
        }

        return winner;
    }
}
