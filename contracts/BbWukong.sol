// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BbWukong is ERC721, Pausable, Ownable {
    using SafeMath for uint256;

    uint16[88] public Ids;
    uint16 private index;
    uint256 public FREE_MINT_PRICE = 0.00 ether;
    uint256 public WL_PRICE = 0.088 ether;
    uint256 public constant MAX_PER_MINT = 1;
    string public baseTokenURI;
    string private _owner;
    // bool public isWhitelistActive = false;

    mapping(address => bool) private _freewhitelist;
    mapping(address => bool) private _normalwhitelist;

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
        require(ids.length > _count, "Not enough NFTs left!");
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

    function _mintMultipleNFT() private {
        _mintSingle();
    }

    function _freeMint() private {
        _mintSingle();
        _freewhitelist[msg.sender] = false;
    }

    function _whitelistMint() private payable {
        require(
            msg.value >= WL_PRICE.mul(_count),
            "Not enough ether to purchase NFTs."
        );
        _mintSingle();
        _normalwhitelist[msg.sender] = false;
    }

    function checkWhiteList() public {
        require(ids.length > _count, "Not enough NFTs left!");
        uint256 _purchaseAvailability = MAX_PER_MINT - balanceOf(msg.sender);
        require(
            _purchaseAvailability < 1,
            "Max 1 Mint per user"
        );
        if (_freewhitelist[msg.sender]){
            _freeMint();
        }
        else if (_normalwhitelist[msg.sender]){
            _whitelistMint();
        }
        else if (_owner == msg.sender){
            _mintMultipleNFT();
        }
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

    function setFreeMintPrice(uint256 _price) public onlyOwner {
        FREE_MINT_PRICE = _price;
    }

    function setWLPrice(uint256 _price) public onlyOwner {
        WL_PRICE = _price;
    }

    function setIsWhitelistActive(bool _isWhitelistActive) external onlyOwner {
        isWhitelistActive = _isWhitelistActive;
    }

    function setFreeWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _freewhitelist[addresses[i]] = true;
        }
    }

    function setNormalWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _normalwhitelist[addresses[i]] = true;
        }
    }

    function setOwner(string memory address) external onlyOwner {
        _owner = address;
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
