# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

The difference between contract NFT & NFT2 is :

```js
// NFT
function setNotRevealedURI() public onlyOwner {
    notRevealedUri = "https://erc721Upgradeable.com/";
}

// NFT2
function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
}
```
