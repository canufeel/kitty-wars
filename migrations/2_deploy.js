const KittyOwnership = artifacts.require("KittyOwnership.sol");
const PlayerRepo = artifacts.require('./PlayerRepo.sol');
const ItemOwnership = artifacts.require('./ItemOwnership.sol');
const Battle = artifacts.require('./Battle.sol');

module.exports = async function(deployer) {
  await deployer.deploy(KittyOwnership);
  await deployer.deploy(ItemOwnership);
  await deployer.deploy(PlayerRepo, KittyOwnership.address, ItemOwnership.address);
  await deployer.deploy(Battle, PlayerRepo.address);
};
