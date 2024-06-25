import hre from "hardhat";

async function main() {
  const contractAddress = "0xB236F4d65836A0F1Da596F34363b4b8a0DE12521";
  const contractPath = "contracts/shop/TrotelCoinShop.sol:TrotelCoinShop";

  const constructorArguments: any[] = [];

  await hre.run("verify:verify", {
    address: contractAddress,
    constructorArguments: constructorArguments,
    contract: contractPath,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });