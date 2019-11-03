pragma solidity ^0.5.8;


contract ItemBase {
    event ItemCreated(
        uint256 itemId,
        ItemType itemType,
        uint256 itemPower
    );
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    enum ItemType { WEAPON, ARMOR }

    struct PlayerItemStruct {
        ItemType itemType;
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
        PlayerItemStruct memory zeroItem = PlayerItemStruct(ItemType.WEAPON, 0);
        allItems.push(zeroItem);
    }

    function forge(ItemType itemType, uint256 power) public returns (uint256 itemId) {
        require(power <= 10, "Power has to be <= 10.");
        require(
            itemType == ItemType.WEAPON || itemType == ItemType.ARMOR,
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

    /// @dev Assigns ownership of a specific Item to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of items is capped to 2^32 we can't overflow this
        itemOwnershipCount[_to]++;
        // transfer ownership
        itemToOwner[_tokenId] = _to;
        // When creating new items _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            itemOwnershipCount[_from]--;
            // once the item is transferred also clear sire allowances
            delete itemToApproved[_tokenId];
        }
        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }
}
