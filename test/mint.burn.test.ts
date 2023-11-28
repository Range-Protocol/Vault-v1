import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import {
  IERC20,
  IPancakeV3Factory,
  IPancakeV3Pool,
  RangeProtocolVault,
  RangeProtocolFactory,
  LogicLib,
  IWETH9,
} from "../typechain";
import {
  bn,
  encodePriceSqrt,
  getInitializeData,
  parseEther,
  position,
  setStorageAt,
} from "./common";
import { expect } from "chai";

let user: SignerWithAddress;
let factory: RangeProtocolFactory;
let vault: RangeProtocolVault;
let token0: IERC20;
let token1: IERC20;
let logicLib: LogicLib;
const WETH9 = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
const USDT = "0x55d398326f99059fF775485246999027B3197955";
const poolFee = 10000;
let isToken0Native: boolean;

describe.only("RangeProtocolVault: mint-burn test", () => {
  before(async () => {
    [user] = await ethers.getSigners();
    const pancakeFactory = (await ethers.getContractAt(
      "IPancakeV3Factory",
      "0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865"
    )) as IPancakeV3Factory;
    const factory = (await (
      await ethers.getContractFactory("RangeProtocolFactory")
    ).deploy(pancakeFactory.address)) as RangeProtocolFactory;
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    token0 = (await ethers.getContractAt("IWETH9", WETH9)) as IWETH9;
    token1 = (await ethers.getContractAt("MockERC20", USDT)) as IERC20;
    await setStorageAt(
      token0.address,
      ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
          ["address", "uint256"],
          [user.address, 3]
        )
      ),
      ethers.utils.hexlify(ethers.utils.zeroPad("0x152D02C7E14AF6800000", 32))
    );

    await setStorageAt(
      token1.address,
      ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
          ["address", "uint256"],
          [user.address, 1]
        )
      ),
      ethers.utils.hexlify(ethers.utils.zeroPad("0x152D02C7E14AF6800000", 32))
    );
    if (bn(token0.address).gt(bn(token1.address)))
      [token0, token1] = [token1, token0];

    // await pancakeFactory.createPool(token0.address, token1.address, poolFee);
    const pool = (await ethers.getContractAt(
      "IPancakeV3Pool",
      await pancakeFactory.getPool(token0.address, token1.address, poolFee)
    )) as IPancakeV3Pool;
    // await pool.initialize(encodePriceSqrt("1", "1"));
    // await pool.increaseObservationCardinalityNext("15");
    logicLib = (await (
      await ethers.getContractFactory("LogicLib")
    ).deploy()) as LogicLib;
    const vaultImpl = await (
      await ethers.getContractFactory("RangeProtocolVault", {
        libraries: {
          LogicLib: logicLib.address,
        },
      })
    ).deploy();
    const initializeData = getInitializeData({
      managerAddress: user.address,
      name: "TEST",
      symbol: "TEST Token",
      WETH9: WETH9,
      oracleToken0: "0xB97Ad0E74fa7d920791E90258A6E2085088b4320",
      oracleToken1: "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE",
    });
    await factory.createVault(
      token0.address,
      token1.address,
      poolFee,
      vaultImpl.address,
      initializeData
    );
    vault = (await ethers.getContractAt(
      "RangeProtocolVault",
      (
        await factory.getVaultAddresses(0, 0)
      )[0]
    )) as RangeProtocolVault;
    isToken0Native = (await vault.token0()) === WETH9;
    await vault.updateTicks(-200, 200);
    await token0.transfer(vault.address, ethers.utils.parseEther("1000"));
    await token1.transfer(vault.address, ethers.utils.parseEther("1000"));
    console.log(vault.address)

  });

  it("should mint with ERC20 tokens", async () => {
    await vault.rebalance("0xc7cd97480000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000012000000000000000000000000008e84438e78b07a3add460339032d9a318f6128a0000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000007aa94ac1d0d2cc758000000000000000000000000067297ee4eb097e072b4ab6f1620268061ae804640000000000000000000000002397d2fde31c5704b02ac1ec9b770f23d70d8ec4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000320000000000000000000000000000000000000000000000000000000000000014900000000000000000000000000000000000000000000000000147d4f18c124252008b6c3d07b061a84f790c035c2f6dc11a0be703d130bf4686b3d4b6eb91a8e26ac629c5bea608208e84438e78b07a3add460339032d9a318f6128a55d398326f99059ff775485246999027b3197955bb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c00000000000000000000000000000000000000000000007be67a0ec36ae862000000000000000000000000000000000000000000000000008ac7230489e80000000000000000000000000000000000000000000000000000000000006565e07908e84438e78b07a3add460339032d9a318f6128accea69cf01144823a7c8d1f419c87f1f009a9615ed1d8767a3d0828e1e5826d37614ece393017fce304f53189b13534d2aba4dc9873b1b595ab374af45a53a80a4febaa7e4622f97bf83ca4374ad64e51b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000412bd9d794fa11710f0284c26c46aab8365f88e94196d498ef33f64865f04f7e271919304846f4928d17a61c4cc89bceac583d66fd2b4a3079a0ed8811621d8d701b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");

    const maxAmount0 = ethers.utils.parseEther("2000");
    // const maxAmount1 = ethers.utils.parseEther("3000");
    // const { amount0, amount1, mintAmount } = await vault.getMintAmounts(
    //   maxAmount0,
    //   maxAmount1
    // );
    // await token0.approve(vault.address, amount0);
    // await token1.approve(vault.address, amount1);
    //
    // console.log("*** BEFORE ***");
    // console.log(
    //   "token0: ",
    //   ethers.utils.formatEther(await token0.balanceOf(user.address))
    // );
    // console.log(
    //   "token1: ",
    //   ethers.utils.formatEther(await token1.balanceOf(user.address))
    // );
    // console.log(
    //   "balance: ",
    //   ethers.utils.formatEther(await vault.balanceOf(user.address))
    // );
    // await vault["mint(uint256,bool,uint256[2])"](mintAmount, false, [
    //   amount0,
    //   amount1,
    // ]);
    // console.log("*** AFTER ***");
    // console.log(
    //   "token0: ",
    //   ethers.utils.formatEther(await token0.balanceOf(user.address))
    // );
    // console.log(
    //   "token1: ",
    //   ethers.utils.formatEther(await token1.balanceOf(user.address))
    // );
    // console.log(
    //   "balance: ",
    //   ethers.utils.formatEther(await vault.balanceOf(user.address))
    // );
  });

  // it.skip("should revert sending native asset when minting with ERC20 tokens", async () => {
  //   const maxAmount0 = ethers.utils.parseEther("2000");
  //   const maxAmount1 = ethers.utils.parseEther("3000");
  //   const { amount0, amount1, mintAmount } = await vault.getMintAmounts(
  //     maxAmount0,
  //     maxAmount1
  //   );
  //   await expect(
  //     vault["mint(uint256,bool,uint256[2])"](
  //       mintAmount,
  //       false,
  //       [amount0, amount1],
  //       {
  //         value: ethers.utils.parseEther("1"),
  //       }
  //     )
  //   ).to.be.revertedWithCustomError(logicLib, "NativeTokenSent");
  // });
  //
  // it("should mint with native asset", async () => {
  //   const maxAmount0 = ethers.utils.parseEther("1");
  //   const maxAmount1 = ethers.utils.parseEther("2");
  //   const { amount0, amount1, mintAmount } = await vault.getMintAmounts(
  //     maxAmount0,
  //     maxAmount1
  //   );
  //   isToken0Native
  //     ? await token1.approve(vault.address, amount1)
  //     : await token0.approve(vault.address, amount0);
  //   console.log("*** BEFORE ***");
  //   console.log(
  //     "token0: ",
  //     ethers.utils.formatEther(await token0.balanceOf(user.address))
  //   );
  //   console.log(
  //     "token1: ",
  //     ethers.utils.formatEther(await token1.balanceOf(user.address))
  //   );
  //   console.log(
  //     "balance: ",
  //     ethers.utils.formatEther(await vault.balanceOf(user.address))
  //   );
  //   console.log(
  //     "native asset: ",
  //     ethers.utils.formatEther(await ethers.provider.getBalance(user.address))
  //   );
  //   console.log("*** DATA ***");
  //   const nativeAmount = isToken0Native ? amount0 : amount1;
  //   console.log("native amount: ", ethers.utils.formatEther(nativeAmount));
  //   const { cumulativeGasUsed, effectiveGasPrice } = await (
  //     await vault["mint(uint256,bool,uint256[2])"](
  //       mintAmount,
  //       true,
  //       [amount0, amount1],
  //       {
  //         value: nativeAmount,
  //       }
  //     )
  //   ).wait();
  //   console.log(
  //     "native amount consumed in gas: ",
  //     ethers.utils.formatEther(bn(cumulativeGasUsed).mul(bn(effectiveGasPrice)))
  //   );
  //   console.log("*** AFTER ***");
  //   console.log(
  //     "token0: ",
  //     ethers.utils.formatEther(await token0.balanceOf(user.address))
  //   );
  //   console.log(
  //     "token1: ",
  //     ethers.utils.formatEther(await token1.balanceOf(user.address))
  //   );
  //   console.log(
  //     "balance: ",
  //     ethers.utils.formatEther(await vault.balanceOf(user.address))
  //   );
  //   console.log(
  //     "native asset: ",
  //     ethers.utils.formatEther(await ethers.provider.getBalance(user.address))
  //   );
  // });
});
