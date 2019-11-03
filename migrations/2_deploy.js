const KittyOwnership = artifacts.require("KittyOwnership.sol");
const PlayerRepo = artifacts.require('./PlayerRepo.sol');

module.exports = async function(deployer) {
  await deployer.deploy(KittyOwnership);
};
