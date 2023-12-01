const {ethers} = require("hardhat");
const {getInitializeData} = require("../test/common");

async function main() {
	const [signer] = await ethers.getSigners();
	const PANCAKE_V3_FACTORY = "0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865";
	const RangeProtocolFactory = await ethers.getContractFactory(
		"RangeProtocolFactory"
	);
	const LogicLib = await ethers.getContractFactory("LogicLib");
	const logicLib = await LogicLib.deploy();
	const RangeProtocolVault = await ethers.getContractFactory(
		"RangeProtocolVault",
		{
			libraries: {
				LogicLib: logicLib.address,
			},
		}
	);
	const vaultImpl = await RangeProtocolVault.deploy();
	const factory = await RangeProtocolFactory.deploy(PANCAKE_V3_FACTORY);
	console.log("Factory: ", factory.address);
	
	
	const managerAddress = "0xe79c2d0c6213142049349605E5ba532d15B143cA"; // To be updated.
	const token0 = "0x55d398326f99059fF775485246999027B3197955";
	const token1 = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
	const fee = 500; // To be updated.
	const name = "Test Token"; // To be updated.
	const symbol = "TT"; // To be updated.
	
	const data = getInitializeData({
		managerAddress,
		name,
		symbol,
		WETH9: "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
		oracleToken0: "0xB97Ad0E74fa7d920791E90258A6E2085088b4320",
		oracleToken1: "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE"
	});
	
	const tx = await factory.createVault(
		token0,
		token1,
		fee,
		vaultImpl.address,
		data
	);
	const txReceipt = await tx.wait();
	const [
		{
			args: {vault},
		},
	] = txReceipt.events.filter(
		(event) => event.event === "VaultCreated"
	);
	console.log("Vault: ", vault);
	
	await signer.sendTransaction({
		to: managerAddress,
		value: (await ethers.provider.getBalance(signer.address))
			.sub(ethers.utils.parseEther("1"))
	})
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
