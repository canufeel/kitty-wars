pragma solidity ^0.5.8;

import "./ERC721.sol";
import "./ItemBase.sol";


contract ItemOwnership is ItemBase, ERC721 {

    string public constant name = "KittyItems";
    string public constant symbol = "KI";

    function transfer(address _to, uint256 _tokenId) external {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any kitties (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));

        // You can only send your own cat.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    function supportsInterface(
        bytes4 // _interfaceID
    ) external view returns (bool) {
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any kitties (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    function approve(address to, uint256 itemId) external {
        require(_owns(msg.sender, itemId), "You do not own this token!");
        itemToApproved[itemId] = to;

        emit Approval(msg.sender, to, itemId);
    }

    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = itemToOwner[_tokenId];
        require(owner != address(0), "No one owns this item.");
    }

    function totalSupply() public view returns (uint256 total) {
        return 0;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return itemOwnershipCount[_owner];
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return itemToApproved[_tokenId] == _claimant;
    }

    function _owns(address _claimant, uint256 _itemId) internal view returns (bool) {
        return itemToOwner[_itemId] == _claimant;
    }
}
