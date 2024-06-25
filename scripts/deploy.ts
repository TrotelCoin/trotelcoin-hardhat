import { ethers, upgrades } from "hardhat";

async function main() {
  const TrotelCoinV2 = await ethers.getContractFactory("TrotelCoinV2");
  console.log("Deploying TrotelCoin...");
  const trotelCoinV2 = await upgrades.deployProxy(
    TrotelCoinV2,
    ["TrotelCoin", "TROTEL"],
    { initializer: "initialize" }
  );
  await trotelCoinV2.deployed();
  console.log("TrotelCoin deployed to:", trotelCoinV2.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
