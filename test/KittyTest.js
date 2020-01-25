import {
  createKitties,
  createKittyContract, createPlayerRepo,
  deployItemContract, deployProxy,
  generateNumsAndHashesArr,
  setupGameWithTwoPlayers
} from './helpers';

const BigNumber = web3.utils.BN;
const hundred = new BigNumber(100);

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
      hashesArr: hashesOneArr,
    } = generateNumsAndHashesArr();
    await battle.commitBattleParams(
      hashesOneArr,
      1,
      { from: kittyOneOwner }
    );
    const {
      hashesArr: hashesTwoArr,
    } = generateNumsAndHashesArr();
    await battle.commitBattleParams(
      hashesTwoArr,
      1,
      { from: kittyTwoOwner }
    );
  });

  it('can assign both weapons for both players', async function () {
    await setupGameWithTwoPlayers({
      owner,
      kittyOneOwner,
      kittyTwoOwner,
    });
  });

  it('can submit battle values up and determine winner correctly', async function () {
    const {
      battle,
      itemContract,
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
      } = await itemContract.getItem(i + 1);
      modifiers[i] = power;
    }

    const rounds = numsOneArr.map(
      (cur, idx) => {
        return new BigNumber(cur.slice(2), 16)
          .mod(hundred)
          .add(
            new BigNumber(numsTwoArr[idx].slice(2), 16)
              .mod(hundred)
          )
          .mod(hundred);
      }
    );

    let curDamage;
    let totalDamageOne = new BigNumber(0);
    let totalDamageTwo = new BigNumber(0);
    for (let idx = 0; idx < 10; idx += 2) {
      const roundA = rounds[idx];
      const roundD = rounds[idx + 1];

      if (idx % 4 !== 0 && idx !== 9) {
        curDamage = roundA.mul(modifiers[0]);
        curDamage = curDamage.lte(roundD.mul(modifiers[1])) ? new BigNumber(0) : curDamage.sub(roundD.mul(modifiers[1]));
        totalDamageOne = totalDamageOne.add(curDamage);
      } else if (idx !== 9) {
        curDamage = roundA.mul(modifiers[2]);
        curDamage = curDamage.lte(roundD.mul(modifiers[3])) ? new BigNumber(0) : curDamage.sub(roundD.mul(modifiers[3]));
        totalDamageTwo = totalDamageTwo.add(curDamage);
      } else {
        totalDamageOne = totalDamageOne.add(roundA.mul(modifiers[0]));
        totalDamageTwo = totalDamageTwo.add(roundD.mul(modifiers[2]));
      }
    }

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

    assert.ok(!!kittyId);
  });
});
