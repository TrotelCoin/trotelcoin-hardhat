import { ethers, upgrades, network } from "hardhat";

async function main() {
  const Contract = await ethers.getContractFactory("TrotelCoinV2");

  console.log("Deploying contract on", network.name);

  const contract = await upgrades.deployProxy(
    Contract,
    ["TrotelCoin", "TROTEL"],
    { initializer: "initialize" }
  );
  await contract.deployed();

  console.log("Contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
