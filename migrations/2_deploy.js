const KittyOwnership = artifacts.require("KittyOwnership.sol");

module.exports = async function(deployer) {
  const instance = await deployer.deploy(KittyOwnership);
  console.log(instance);
};
