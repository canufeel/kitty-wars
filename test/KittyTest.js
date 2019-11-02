const KittyOwnership = artifacts.require("KittyOwnership.sol");

contract('Kitty', function ([owner, kittyOneOwner, kittyTwoOwner]) {
  it('flow', async function () {
    const kittyContract = await KittyOwnership.new();
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
    console.log(kittyIdOne.toString());
    console.log(kittyIdTwo.toString());
  })
});