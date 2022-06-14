// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BbWukong is ERC721, Pausable, Ownable {
    using SafeMath for uint256;

    uint16[88] public ids;
    uint16 private index;
    uint256 public PRICE = 0.02 ether;
    uint256 public WL_PRICE = 0.01 ether;
    uint256 public constant MAX_PER_MINT = 4;
    string public baseTokenURI;
    bool public isWhitelistActive = false;

    mapping(address => uint256) private _whitelist;

    constructor(string memory baseURI) ERC721("BbWukong", "BBW") {
        setBaseURI(baseURI);
    }

    // random id logic
    function _pickRandomUniqueId(uint256 random) private returns (uint256 id) {
        uint256 len = ids.length - index++;
        require(len > 0, "No NFTs left");
        uint256 randomIndex = random % len;
        id = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
        ids[randomIndex] = uint16(ids[len - 1] == 0 ? len - 1 : ids[len - 1]);
        ids[len - 1] = 0;
    }

    // mint functions
    function _mintSingle() private {
        uint256 _random = uint256(
            keccak256(
                abi.encodePacked(
                    index++,
                    msg.sender,
                    block.timestamp,
                    blockhash(block.number - 1)
                )
            )
        );
        _safeMint(msg.sender, _pickRandomUniqueId(_random) + 1);
    }

    function mintManyNFT(uint256 _count) public payable {
        uint256 _purchaseAvailability = MAX_PER_MINT - balanceOf(msg.sender);
        require(
            _count > 0 && _count <= _purchaseAvailability,
            "Inventory exceeded limit."
        );
        require(ids.length > _count, "Not enough NFTs left!");
        require(
            msg.value >= PRICE.mul(_count),
            "Not enough ether to purchase NFTs."
        );

        for (uint256 i = 0; i < _count; i++) {
            _mintSingle();
        }
    }

    function mintManyWlNFT(uint256 _count) public payable {
        require(isWhitelistActive, "Whitelist is not active!");
        require(
            _count <= _whitelist[msg.sender],
            "Exceeded max available to purchase"
        );
        require(ids.length > _count, "Not enough NFTs left!");
        require(
            msg.value >= WL_PRICE.mul(_count),
            "Not enough ether to purchase NFTs."
        );

        for (uint256 i = 0; i < _count; i++) {
            _mintSingle();
        }
        _whitelist[msg.sender] -= _count;
    }

    // withdraw ether balance from contract
    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // setters
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function setPrice(uint256 _price) public onlyOwner {
        PRICE = _price;
    }

    function setWLPrice(uint256 _price) public onlyOwner {
        WL_PRICE = _price;
    }

    function setIsWhitelistActive(bool _isWhitelistActive) external onlyOwner {
        isWhitelistActive = _isWhitelistActive;
    }

    function setWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _whitelist[addresses[i]] = MAX_PER_MINT;
        }
    }

    // pausable
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // overrides
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
