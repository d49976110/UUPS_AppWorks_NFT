const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@openzeppelin/test-helpers");
const {
    Contract,
} = require("hardhat/internal/hardhat-network/stack-traces/model");

describe("NFTCore", function () {
    let erc721;

    before(async () => {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        const Erc721 = await ethers.getContractFactory("AppWorks_NFT");
        erc721 = await Erc721.deploy();
        erc721.initialize("BC", "BC");
    });

    describe("Early mint", async () => {
        /*
        merkle tree accounts = [
            "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", //owner
            "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", //addr1
            "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"  //addr2
        ]

        merkleRoot = "0xfbc2f54de92972c0f2c6bbd5003031662aa9b8240f4375dc03d3157d8651ec45";

        merkleProof = ["0x343750465941b29921f50a28e0e43050e5e1c2611a3ea8d7fe1001090d5e1436"];
        */

        it("set merkle root", async () => {
            let merkleRoot =
                "0xfbc2f54de92972c0f2c6bbd5003031662aa9b8240f4375dc03d3157d8651ec45";
            await erc721.setMerkleRoot(merkleRoot);

            expect(await erc721.merkleRoot()).to.be.eq(merkleRoot);
        });

        it("early mint active", async () => {
            await erc721.toggleEarlyMint();
        });

        it("early mint", async () => {
            let merkleProof = [
                "0x343750465941b29921f50a28e0e43050e5e1c2611a3ea8d7fe1001090d5e1436",
            ];
            await erc721.earlyMint(merkleProof, 1, {
                value: ethers.utils.parseEther("1"),
            });
        });
    });

    describe("Mint", async () => {
        it("toggle reveal", async () => {
            await erc721.toggleMint();
            expect(await erc721.mintActive()).to.be.eq(true);
        });

        it("mint", async () => {
            await erc721.mint(10, { value: ethers.utils.parseEther("1") });
            let balance = await erc721.balanceOf(owner.address);
            expect(balance).to.be.eq(11);
        });
    });
});
