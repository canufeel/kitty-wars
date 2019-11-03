const KittyOwnership = artifacts.require("KittyOwnership.sol");
const PlayerRepo = artifacts.require('./PlayerRepo.sol');
const Item = artifacts.require('./ItemOwnership.sol');
const Battle = artifacts.require('./Battle.sol');

const weaponType = 0;
const armorType = 1;

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

const deployItemContract = async ({
  owner,
}) => {
  const itemContract = await Item.new();
  return itemContract;
};

const onePlayerFullEquip = async ({
  itemContract,
  playerContract,
  playerAddress,
  weaponPower,
  armorPower
}) => {
  await itemContract.forge(weaponType, weaponPower, { from: playerAddress });
  let logs = await itemContract.getPastEvents('ItemForged');
  let args = logs.find(e => e.event === 'ItemForged').args;
  const weaponId = args[0];

  await itemContract.forge(armorType, armorPower, { from: playerAddress });
  logs = await itemContract.getPastEvents('ItemForged');
  args = logs.find(e => e.event === 'ItemForged').args;
  const armorId = args[0];

  await playerContract.assignItem(weaponId, { from: playerAddress });
  await playerContract.assignItem(armorId, { from: playerAddress });
};

const deployBattleContract = async ({
  owner,
  playerRepo
}) => Battle.new(playerRepo.address, { from: owner });

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

  await onePlayerFullEquip({
    itemContract,
    playerContract: playerRepo,
    playerAddress: kittyOneOwner,
    weaponPower: 7,
    armorPower: 3
  });
  await onePlayerFullEquip({
    itemContract,
    playerContract: playerRepo,
    playerAddress: kittyTwoOwner,
    weaponPower: 5,
    armorPower: 4
  });

  const battle = await deployBattleContract({
    playerRepo,
    owner,
  });
  return {
    battle,
    playerRepo,
    itemContract,
    kittyIdOne,
    kittyIdTwo,
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

  it('can submit battle values up to determinWinner', async function () {
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
});
