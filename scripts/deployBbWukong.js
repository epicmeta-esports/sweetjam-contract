const hre = require("hardhat")

async function main() {
  const BbWukong = await hre.ethers.getContractFactory("BbWukong");
  const bbWukong = await BbWukong.deploy();

  await bbWukong.deployed();

  console.log("BbWukong deployed to:", bbWukong.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
