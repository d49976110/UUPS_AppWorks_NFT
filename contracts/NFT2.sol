// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

contract AppWorks_Upgrade is Initializable, ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using StringsUpgradeable for uint256;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _nextTokenId;

    uint256 public price;
    uint256 public maxSupply;

    bool public mintActive ;
    bool public earlyMintActive ;
    bool public revealed ;

    string public baseURI;
    string public notRevealedUri;
    bytes32 public merkleRoot;

    mapping(uint256 => string) private _tokenURIs;

    function initialize(string calldata _name , string memory _symbol) public initializer {
        __ERC721_init(_name, _symbol);
        __Ownable_init();
        __UUPSUpgradeable_init();
        price = 0.01 ether;
        maxSupply = 100;
    }

    modifier basicCheck(uint256 _mintAmount, bool _isActive) {
        //Current state is available for Public Mint
        require(_isActive, "Not Active");
        //Check how many NFTs are available to be minted
        require(totalSupply() + _mintAmount <= maxSupply, "Over Max Supply");
        //Check user has sufficient funds
        require(msg.value >= price * _mintAmount, "Not Enough Ethers");
        _;
    }

    // Set mint per user limit to 10 and owner limit to 20 - Week 8
    modifier checkLimit(uint256 _mintAmount) {
        uint256 limit = balanceOf(msg.sender) + _mintAmount;
        if (msg.sender == owner()) {
            require(limit <= 20, "Owner Max Amount Is 20");
        } else {
            require(limit <= 10, "User Max Amount Is 10");
        }
        _;
    }

    // Public mint function - week 8
    function mint(uint256 _mintAmount)
        public
        payable
        basicCheck(_mintAmount, mintActive)
        checkLimit(_mintAmount)
    {
        //Mint
        uint256 nextTokenId = _nextTokenId.current(); // save gas
        for (uint256 i = 0; i < _mintAmount; i++) {
            _mint(msg.sender, nextTokenId);
            nextTokenId++;
        }

        //Change state
        _nextTokenId._value = nextTokenId;
    }

    // Implement totalSupply() Function to return current total NFT being minted - week 8
    function totalSupply() public view returns (uint256) {
        return _nextTokenId.current();
    }

    // Implement withdrawBalance() Function to withdraw funds from the contract - week 8
    function withdrawBalance(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Not Enough Balance");
        (bool success, ) = payable(owner()).call{ value: _amount }("");
        require(success, "Fail Withdraw");
    }

    // Implement setPrice(price) Function to set the mint price - week 8
    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }


    // Implement toggleMint() Function to toggle the public mint available or not - week 8
    function toggleMint() external onlyOwner {
        mintActive = !mintActive;
    }

    // Implement toggleReveal() Function to toggle the blind box is revealed - week 9
    function toggleReveal() external onlyOwner {
        revealed = !revealed;
    }

    // Implement setBaseURI(newBaseURI) Function to set BaseURI - week 9
    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    // Function to return the base URI
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        if(revealed == false){
            return notRevealedUri;
        }

        string memory baseURI_ = _baseURI();
        return bytes(baseURI_).length > 0 ? string(abi.encodePacked(baseURI_, tokenId.toString())) : "";
    }

    // Early mint function for people on the whitelist - week 9
    function earlyMint(bytes32[] calldata _merkleProof, uint256 _mintAmount)
        public
        payable
        basicCheck(_mintAmount, earlyMintActive)
        checkLimit(_mintAmount)
    {
        //Check user is in the whitelist - use merkle tree to validate
        require(merkleRoot != 0x0, "Not Set The Merkle Root");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        bool result = MerkleProofUpgradeable.verify(
            _merkleProof,
            merkleRoot,
            leaf
        );
        require(result, "Not In The White List");

        //Mint
        uint256 nextTokenId = _nextTokenId.current(); // save gas
        for (uint256 i = 0; i < _mintAmount; i++) {
            _mint(msg.sender, nextTokenId);
            nextTokenId++;
        }
        //Change state
        _nextTokenId._value = nextTokenId;
    }

    // Implement toggleEarlyMint() Function to toggle the early mint available or not - week 9
    function toggleEarlyMint() external onlyOwner {
        earlyMintActive = !earlyMintActive;
    }

    // Implement setMerkleRoot(merkleRoot) Function to set new merkle root - week 9
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }
    // Let this contract can be upgradable, using openzepplin proxy library - week 10
    // Try to modify blind box images by using proxy
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
