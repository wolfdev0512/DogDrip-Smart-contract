// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./erc721a/contracts/ERC721A.sol";


contract DogDrip is ERC721A, Ownable {
    using Strings for uint256;
        
    uint256 public PRICE = 0.01 ether;
    
    uint256 public MAX_PER_WALLET = 5;
    uint256 public constant MAX_SUPPLY = 10000;
    
    string public baseExtension = '.json';
    string private _baseTokenURI;
 
    mapping(address => uint256) public _owners;

    constructor() ERC721A("Dogdrip", "DD") {}

    function mint(uint256 quantity) external payable {
        require(quantity > 0, "quantity of tokens cannot be less than or equal to 0");
        require(totalSupply() + quantity <= MAX_SUPPLY, "exceed max supply of tokens");
        require(_owners[msg.sender] + quantity <= MAX_PER_WALLET, "exceed max supply of per wallet amount");
        require(msg.value >= PRICE * quantity, "insufficient ether value");
        
        _owners[msg.sender] += quantity;
        _safeMint(msg.sender, quantity);
    }


    function tokenURI(uint256 tokenID) public view virtual override returns (string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");
        string memory base = _baseURI();
        require(bytes(base).length > 0, "baseURI not set");
        return string(abi.encodePacked(base, tokenID.toString(), baseExtension));
    }


    /* ****************** */
    /* INTERNAL FUNCTIONS */
    /* ****************** */

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    /* *************** */
    /* OWNER FUNCTIONS */
    /* *************** */

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }
    
    function setBaseExtension(string memory _newExtension) public onlyOwner {
        baseExtension = _newExtension;
    }

    function updateMaxPerWallet(uint256 newLimit) external onlyOwner {
        MAX_PER_WALLET = newLimit;
    }

    function changePrice(uint256 price) external onlyOwner {
        PRICE = price;
    }

     function close(address payable _to) public onlyOwner{ 
         selfdestruct(_to);   
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}