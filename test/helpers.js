const KittyOwnership = artifacts.require('KittyOwnership.sol');
const PlayerRepo = artifacts.require('./PlayerRepo.sol');
const Item = artifacts.require('./ItemOwnership.sol');
const Battle = artifacts.require('./Battle.sol');
const Proxy = artifacts.require('./Proxy.sol');

export const createKittyContract = () => KittyOwnership.new();

export const createPlayerRepo = ({
  kittyContract,
  owner,
  itemContract,
}) => PlayerRepo.new(
  kittyContract.address,
  itemContract.address,
  { from: owner }
);

export const deployProxy = ({
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

export const createKitties = async ({
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

export const deployItemContract = async () => Item.new();

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

export const setupGameWithTwoPlayers = async ({
  owner,
  kittyOneOwner,
  kittyTwoOwner,
}) => {
  const kittyContract = await createKittyContract();
  const itemContract = await deployItemContract({
    owner,
  });
  const playerRepo = await createPlayerRepo({
    kittyContract,
    itemContract,
    owner,
  });
  const proxyContract = await deployProxy({
    owner,
    playerRepoContract: playerRepo,
    itemContract,
    kittyContract,
  });

  await proxyContract.join({ from: kittyOneOwner });
  const logsOne = await playerRepo.getPastEvents('PlayerAdded');
  await proxyContract.join({ from: kittyTwoOwner });
  const logsTwo = await playerRepo.getPastEvents('PlayerAdded');


  const argsOneArr = logsOne
    .filter(e => e.event === 'PlayerAdded')
    .map(({ args }) => args);
  const kittyIdOne = argsOneArr.find(({ playerAddress }) => playerAddress === kittyOneOwner).kittyId;
  const argsTwoArr = logsTwo
    .filter(e => e.event === 'PlayerAdded')
    .map(({ args }) => args);
  const kittyIdTwo = argsTwoArr.find(({ playerAddress }) => playerAddress === kittyTwoOwner).kittyId;

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

export const generateNumsAndHashesArr = () => {
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
