import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGON_SCAN_API_KEY as string,
      amoy: process.env.POLYGONSCAN_API_KEY as string,
    },
    customChains: [
      {
        network: "amoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com/",
        },
      },
    ],
  },
  solidity: {
    compilers: [
      {
        version: "0.8.24",
      },
    ],
  },
  networks: {
    polygon: {
      url: "https://polygon-rpc.com",
      accounts: [process.env.PRIVATE_KEY as string],
    },
    amoy: {
      url: "https://rpc-amoy.polygon.technology/",
      accounts: [process.env.PRIVATE_KEY as string],
    },
  },
};

export default config;