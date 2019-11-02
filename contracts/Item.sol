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

    struct Item {
        Type type;
        uint256 power;
    }

    Item[] public allItems;
    // address => amount of tokens (items)
    mapping (address => uint256) itemOwnershipCount;
    // itemID => owner address
    mapping (uint256 => address) itemToOwner;
    // itemId => address
    mapping (uint256 => address) itemToApproved;

    constructor() public {
        Item zeroItem = new Item(Type.WEAPON, 0);
        allItems.push(zeroItem);
    }

    function transfer(address _to, uint256 _tokenId) external {
        require(_to != address(0), "No zero address!");
        require(_owns(msg.sender, _tokenId), "You do not own this cat!");

        itemOwnershipCount[_to]++;
        itemToOwner[_tokenId] = _to;

        if (from != address(0)) {
            itemOwnershipCount[to]--;
            delete itemToApproved[_tokenId];
        }

        emit Transfer(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_to != address(0), "No Zero address in transferFrom().");
        require(_to != address(this), "Not this contract.");

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

    function create(Type type, uint256 power) public returns (uint256 itemId) {
        require(power <= 10, "Power has to be <= 10.");
        require(
            type == Type.WEAPON || type == Type.ARMOR,
            "Wrong item type. Only Weapon (0) or Armor (1) available"
        );

        Item newItem = new Item(type, power);
        allItems.push(newItem);
        itemId = allItems.length - 1;

        emit ItemCreated(
            itemId,
            type,
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
        return itemToApproves[_tokenId] == _claimant;
    }

    function _owns(address _claimant, uint256 _itemId) internal view returns (bool) {
        return itemToOwner[itemId] == _claimant;
    }
}
