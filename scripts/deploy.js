// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const [owner, player1, player2] = await ethers.getSigners();

  console.log("ownerBalance :", await owner.getBalance());

  const nonce = randomString(6);
  const number = Math.floor(Math.random() * 10000);



  const nonceHash = hre.ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["bytes32"], [ethers.utils.formatBytes32String(nonce)]));
  const nonceNumberHash = ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["bytes32", "uint"], [ethers.utils.formatBytes32String(nonce), number]));

  const betAmount = hre.ethers.utils.parseEther("1");

  const Guessnumber = await hre.ethers.getContractFactory("Guessnumber");
  const guessnumber = await Guessnumber.deploy(nonceHash, nonceNumberHash, { value: betAmount });

  await guessnumber.deployed();

}

function randomString(e) {
  e = e || 32;
  let t = "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz";
  let str = "";
  for (i = 0; i < e; i++) {
    str += t.charAt(Math.floor(Math.random() * t.length))
  };
  return str;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
