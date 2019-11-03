pragma solidity ^0.5.8;

import "../ERC721.sol";


contract IKitty is ERC721 {
    function createKitty(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    )
    public
    returns (uint);
}