const KittyOwnership = artifacts.require("KittyOwnership.sol");
const PlayerRepo = artifacts.require('./PlayerRepo.sol');
const Item = artifacts.require('./ItemOwnership.sol');
const Battle = artifacts.require('./Battle.sol');
const Proxy = artifacts.require('./Proxy.sol');

const BigNumber = web3.utils.BN;

const weaponType = 0;
const armorType = 1;
const hundred = new BigNumber(100);

const createKittyContract = () => KittyOwnership.new();

const createPlayerRepo = ({
  kittyContract,
  owner,
  itemContract,
}) => PlayerRepo.new(
  kittyContract.address,
  itemContract.address,
  { from: owner }
);

const deployProxy = ({
  owner,
  itemContract,
  playerRepoContract,
  kittyContract
}) => Proxy.new(
  itemContract.address,
  playerRepoContract.address,
  kittyContract.address,
  {
    from: owner,
  }
);

const createKitties = async ({
  kittyOneOwner,
  kittyTwoOwner,
  owner,
  kittyContract,
}) => {
  const {
    logs: [{
      args: {
        kittyId: kittyIdOne
      }
    }]
  } = await kittyContract.createKitty(
    1, // uint256 _matronId,
    1, // uint256 _sireId,
    1, // uint256 _generation,
    1, // uint256 _genes,
    kittyOneOwner, // address _owner
    { from: owner }
  );
  const {
    logs: [{
      args: {
        kittyId: kittyIdTwo
      }
    }]
  } = await kittyContract.createKitty(
    2, // uint256 _matronId,
    2, // uint256 _sireId,
    1, // uint256 _generation,
    2, // uint256 _genes,
    kittyTwoOwner, // address _owner
    { from: owner }
  );
  return {
    kittyIdOne,
    kittyIdTwo
  };
};

const deployItemContract = async () => {
  const itemContract = await Item.new();
  return itemContract;
};

const onePlayerFullEquip = async ({
  proxyContract,
  playerAddress,
  weaponPower,
  armorPower
}) => {
  await proxyContract.loot(weaponPower, armorPower, {
    from: playerAddress,
  });
};

const deployBattleContract = async ({
  owner,
  playerRepo,
  itemContract
}) => Battle.new(playerRepo.address, itemContract.address, { from: owner });

const setupGameWithTwoPlayers = async ({
  owner,
  kittyOneOwner,
  kittyTwoOwner,
}) => {
  const kittyContract = await createKittyContract();
  const {
    kittyIdOne,
    kittyIdTwo
  } = await createKitties({
    owner,
    kittyContract,
    kittyOneOwner,
    kittyTwoOwner,
  });
  const itemContract = await deployItemContract({
    owner,
  });
  const playerRepo = await createPlayerRepo({
    kittyContract,
    itemContract,
    owner,
  });
  await kittyContract.approve(
    playerRepo.address,
    kittyIdOne,
    { from: kittyOneOwner }
  );
  await kittyContract.approve(
    playerRepo.address,
    kittyIdTwo,
    { from: kittyTwoOwner }
  );
  await playerRepo.addPlayer(kittyIdTwo, { from: kittyTwoOwner });
  await playerRepo.addPlayer(kittyIdOne, { from: kittyOneOwner });

  const proxyContract = await deployProxy({
    owner,
    playerRepoContract: playerRepo,
    itemContract,
  });

  await onePlayerFullEquip({
    proxyContract,
    playerAddress: kittyOneOwner,
    weaponPower: 7,
    armorPower: 3
  });
  await onePlayerFullEquip({
    proxyContract,
    playerAddress: kittyTwoOwner,
    weaponPower: 5,
    armorPower: 4
  });

  const battle = await deployBattleContract({
    playerRepo,
    owner,
    itemContract
  });
  return {
    battle,
    playerRepo,
    itemContract,
    kittyIdOne,
    kittyIdTwo,
  };
};

const generateRandomNum = () => web3.utils.randomHex(32);
const getNumSha = (hashNum) => web3.utils.sha3(hashNum);

const generateNumsAndHashesArr = () => {
  const arr = new Array(10).fill(0);
  const valuesArr = arr.map(() => {
    const num = generateRandomNum();
    const hash = getNumSha(num);
    return {
      num,
      hash,
    };
  });
  const numsArr = valuesArr.map(({ num }) => num);
  const hashesArr = valuesArr.map(({ hash }) => hash);
  return {
    numsArr,
    hashesArr,
  };
};

contract('Kitty', function ([
  owner,
  kittyOneOwner,
  kittyTwoOwner,
]) {
  it('deploy kitties', async function () {
    const kittyContract = await createKittyContract();
    const {
      kittyIdOne,
      kittyIdTwo
    } = await createKitties({
      owner,
      kittyContract,
      kittyOneOwner,
      kittyTwoOwner,
    });
    assert.ok(!!kittyIdOne.toString());
    assert.ok(!!kittyIdTwo.toString());
  });

  it('create player', async function () {
    await setupGameWithTwoPlayers({
      owner,
      kittyOneOwner,
      kittyTwoOwner,
    });
    assert.ok(true);
  });

  it('can submit battle values up to commitBattleParams', async function () {
    const {
      battle,
      playerRepo,
      itemContract,
      kittyIdOne,
      kittyIdTwo,
    } = await setupGameWithTwoPlayers({
      owner,
      kittyOneOwner,
      kittyTwoOwner,
    });

    await battle.startBattle(0, {
      from: kittyOneOwner,
    });

    await battle.startBattle(1, {
      from: kittyTwoOwner,
    });

    const {
      numsArr: numsOneArr,
      hashesArr: hashesOneArr,
    } = generateNumsAndHashesArr();
    await battle.commitBattleParams(
      hashesOneArr,
      1,
      { from: kittyOneOwner }
    );
    const {
      numsArr: numsTwoArr,
      hashesArr: hashesTwoArr,
    } = generateNumsAndHashesArr();
    await battle.commitBattleParams(
      hashesTwoArr,
      1,
      { from: kittyTwoOwner }
    );
  });

  it('can assign both weapons for both players', async function () {
    const {
      battle,
      playerRepo,
      itemContract,
      kittyIdOne,
      kittyIdTwo,
    } = await setupGameWithTwoPlayers({
      owner,
      kittyOneOwner,
      kittyTwoOwner,
    });
  });

  it('can submit battle values up and determine winner correctly', async function () {
    const {
      battle,
      playerRepo,
      itemContract,
      kittyIdOne,
      kittyIdTwo,
    } = await setupGameWithTwoPlayers({
      owner,
      kittyOneOwner,
      kittyTwoOwner,
    });

    await battle.startBattle(0, {
      from: kittyOneOwner,
    });

    await battle.startBattle(1, {
      from: kittyTwoOwner,
    });

    const {
      numsArr: numsOneArr,
      hashesArr: hashesOneArr,
    } = generateNumsAndHashesArr();
    await battle.commitBattleParams(
      hashesOneArr,
      1,
      { from: kittyOneOwner }
    );
    const {
      numsArr: numsTwoArr,
      hashesArr: hashesTwoArr,
    } = generateNumsAndHashesArr();
    await battle.commitBattleParams(
      hashesTwoArr,
      1,
      { from: kittyTwoOwner }
    );

    await battle.submitBattleResolution(
      numsOneArr,
      1,
      {
        from: kittyOneOwner,
      }
    );
    await battle.submitBattleResolution(
      numsTwoArr,
      1,
      {
        from: kittyTwoOwner,
      }
    );

    const logs = await battle.getPastEvents('BattleWon');
    const {
      winner: winnerFromContract
    } = logs.find(e => e.event === 'BattleWon').args;

    const modifiers = [];
    for (let i = 0; i < 4; i++) {
      const {
        itemPower: power
      } = await itemContract.getItem(i+1);
      modifiers[i] = power;
    }

    const rounds = numsOneArr.map(
        (cur, idx) => {
          return new BigNumber(cur)
              .mod(hundred)
              .add(
                  new BigNumber(numsTwoArr[idx])
                      .mod(hundred)
              )
              .mod(hundred)
        }
    );

    let curDamage;
    let totalDamageOne = new BigNumber(0);
    let totalDamageTwo = new BigNumber(0);
    rounds.forEach(
        (cur, idx) => {
          if (idx % 2 !== 0) {
            curDamage = cur.mul(modifiers[0]).sub(
                cur.mul(modifiers[1])
            );
            curDamage = curDamage.lt(new BigNumber(0)) ? new BigNumber(0) : curDamage;
            totalDamageOne = totalDamageOne.add(curDamage);
          } else {
            curDamage = cur.mul(modifiers[2]).sub(
                cur.mul(modifiers[3])
            );
            curDamage = curDamage.lt(new BigNumber(0)) ? new BigNumber(0) : curDamage;
            totalDamageTwo = totalDamageTwo.add(curDamage);
          }
        }
    );

    let testWinner;
    if (totalDamageOne.gt(totalDamageTwo)) {
      testWinner = kittyOneOwner;
    } else if (totalDamageOne.lt(totalDamageTwo)) {
      testWinner = kittyTwoOwner;
    } else {
      throw Error('Draw!');
    }

    assert.equal(winnerFromContract, testWinner);
  });

  it('player can join', async function () {
    const kittyContract = await createKittyContract();
    const itemContract = await deployItemContract();
    const playerRepoContract = await createPlayerRepo({
      kittyContract,
      owner,
      itemContract
    });
    const proxyContract = await deployProxy({
      owner,
      itemContract,
      playerRepoContract,
      kittyContract
    });

    await proxyContract.join();

    const logs = await playerRepoContract.getPastEvents('PlayerAdded');
    const { kittyId } = logs.find(e => e.event === 'PlayerAdded').args;

    assert(!!kittyId);
  });
});
