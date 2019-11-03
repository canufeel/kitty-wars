pragma solidity ^0.5.8;

import "./ERC721.sol";


contract Item is ERC721 {

    string public constant name = "KittyItems";
    string public constant symbol = "KI";

    event ItemCreated(
        uint256 itemId,
        Type itemType,
        uint256 itemPower
    );

    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    enum Type { WEAPON, ARMOR }

    struct PlayerItemStruct {
        Type itemType;
        uint256 power;
    }

    PlayerItemStruct[] public allItems;
    // address => amount of tokens (items)
    mapping (address => uint256) itemOwnershipCount;
    // itemID => owner address
    mapping (uint256 => address) itemToOwner;
    // itemId => address
    mapping (uint256 => address) itemToApproved;

    constructor() public {
        PlayerItemStruct memory zeroItem = PlayerItemStruct(Type.WEAPON, 0);
        allItems.push(zeroItem);
    }

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

    /// @dev Assigns ownership of a specific Kitty to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of kittens is capped to 2^32 we can't overflow this
        itemOwnershipCount[_to]++;
        // transfer ownership
        itemToOwner[_tokenId] = _to;
        // When creating new kittens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            itemOwnershipCount[_from]--;
            // once the kitten is transferred also clear sire allowances
            delete itemToApproved[_tokenId];
        }
        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
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

    function create(Type itemType, uint256 power) public returns (uint256 itemId) {
        require(power <= 10, "Power has to be <= 10.");
        require(
            itemType == Type.WEAPON || itemType == Type.ARMOR,
            "Wrong item itemType. Only Weapon (0) or Armor (1) available"
        );

        PlayerItemStruct memory newItem = PlayerItemStruct(itemType, power);
        allItems.push(newItem);
        itemId = allItems.length - 1;

        emit ItemCreated(
            itemId,
            itemType,
            power
        );

        return itemId;
    }

    function totalSupply() public view returns (uint256 total) {
        return 0;
    }

    function balanceOf(address _owner) public view returns (uint256 count) {
        return itemOwnershipCount[_owner];
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return itemToApproved[_tokenId] == _claimant;
    }

    function _owns(address _claimant, uint256 _itemId) internal view returns (bool) {
        return itemToOwner[_itemId] == _claimant;
    }
}
