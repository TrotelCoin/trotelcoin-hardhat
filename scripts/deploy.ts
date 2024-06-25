import { ethers, network } from "hardhat";

async function main() {
  const Contract = await ethers.getContractFactory("TrotelCoinEarlyNFT");

  console.log("Deploying contract on", network.name);

  const contract = await Contract.deploy();

  await contract.waitForDeployment();

  console.log("Contract deployed to:", await contract.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
