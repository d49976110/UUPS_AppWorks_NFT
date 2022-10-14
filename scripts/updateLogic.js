const { ethers } = require("hardhat");
const { upgrades } = require("hardhat");

const proxyAddress = "0xba08656c5b0D18b44c20B0B3aBc01e7FAE88CE01";

async function main() {
    console.log("指定的Proxy 合約地址", proxyAddress);

    const NFTV2 = await ethers.getContractFactory("AppWorks_Upgrade");

    console.log("正在發佈 NFT Upgrade ...");
    const proxy = await upgrades.upgradeProxy(proxyAddress, NFTV2);

    console.log("Proxy 合約地址", proxy.address);
    console.log("等待兩個網路確認 ... ");
    const receipt = await proxy.deployTransaction.wait(2);

    console.log(
        "管理合約地址: ",
        await upgrades.erc1967.getAdminAddress(proxy.address)
    );
    console.log(
        "邏輯合約地址: ",
        await upgrades.erc1967.getImplementationAddress(proxy.address)
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
