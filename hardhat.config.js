require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.4",
    networks: {
        goerli: {
            url: process.env.RCP_URL,
            chainId: 5,
            gas: 15000000,
            accounts: (process.env.PRIVATE_KEY || "").split(" "),
        },
    },
    etherscan: {
        apiKey: {
            goerli: process.env.ETHERSCAN_API_KEY,
        },
    },
};
