const hre = require("hardhat")

async function main() {

  var freeWhitelistAddress = [];
  var whitelistAddress = [];
  var ownerAddress = "";
  const BbWukong = await hre.ethers.getContractFactory("BbWukong");
  const bbWukong = await BbWukong.deploy();

  await bbWukong.deployed();

  console.log("BbWukong deployed to:", bbWukong.address);

  // Whitelist NFTs
  let txn = await bbWukong.setFreeWhitelist(freeWhitelistAddress);
  await txn.wait();
  console.log("Free whitelist set");

  let checkTxn = await bbWukong.setNormalWhitelist(whitelistAddress);
  await checkTxn.wait();
  console.log("Normal whitelist set");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
