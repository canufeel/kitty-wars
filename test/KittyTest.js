const KittyOwnership = artifacts.require("KittyOwnership.sol");
const PlayerRepo = artifacts.require('./PlayerRepo.sol');
const Item = artifacts.require('./ItemOwnership.sol');

const createKittyContract = () => KittyOwnership.new();

const createPlayerRepo = ({
  kittyContract,
  owner,
  weaponContract,
  armorContract
}) => PlayerRepo.new(
  kittyContract.address,
  weaponContract.address,
  armorContract.address,
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

const deployPlayerItems = async ({
  owner,
}) => {
  const armorContract = await Item.new();
  const weaponContract = await Item.new();
  return {
    weaponContract,
    armorContract,
  };
};

const deployBattleContract = async ({
  owner,
}) => {

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
    console.log(kittyIdOne.toString());
    console.log(kittyIdTwo.toString());
  });

  it('create player', async function () {
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
    const {
      weaponContract,
      armorContract,
    } = await deployPlayerItems({
      owner,
    });
    const playerRepo = await createPlayerRepo({
      kittyContract,
      weaponContract,
      armorContract,
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
    debugger;
  });
});
