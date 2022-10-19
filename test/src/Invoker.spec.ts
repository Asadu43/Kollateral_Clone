import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract, BigNumber, Signer, utils, constants } from "ethers";
import { parseEther, poll } from "ethers/lib/utils";
import hre, { ethers, network } from "hardhat";
import { Impersonate } from "../utils/utilities";
import { expect, use } from "chai";

describe("I Invoker ", function () {
  let signer: SignerWithAddress;
  let user: SignerWithAddress;

  let user2: any;
  let invoker: Contract;
  let proxy: Contract;
  let testInvokable: Contract;
  let kEther: Contract;
  let kERC20: Contract;

  const ETHER_TOKEN_ADDRESS = "0x0000000000000000000000000000000000000001";

  before(async () => {
    user = await Impersonate("0x1B7BAa734C00298b9429b518D621753Bb0f6efF2");
    user2 = await Impersonate("0x5a52E96BAcdaBb82fd05763E25335261B270Efcb");
    signer = await Impersonate("0x604981db0C06Ea1b37495265EDa4619c8Eb95A3D");

    hre.tracer.nameTags[signer.address] = "ADMIN";

    const Invoker = await ethers.getContractFactory("Invoker",signer);
    invoker = await Invoker.deploy();

    const KErc20 = await ethers.getContractFactory("KErc20");
    kERC20 = await KErc20.deploy();

    const KEther = await ethers.getContractFactory("KEther");
    kEther = await KEther.deploy();

    const TestInvokable = await ethers.getContractFactory("TestInvokable");
    testInvokable = await TestInvokable.deploy();

    const KollateralLiquidityProxy = await ethers.getContractFactory("KollateralLiquidityProxy");
    proxy = await KollateralLiquidityProxy.deploy();
  });

  it("Should Revert: Invoker: no liquidity for token ", async () => {
    const invokeTo = testInvokable.address;
    await expect(invoker.invoke(invokeTo, [], ETHER_TOKEN_ADDRESS, parseEther("43"), { value: parseEther("1") })).to.be.revertedWith(
      "Invoker: no liquidity for token"
    );
  });

  it("Should Revert: Invoker: no liquidity for token ", async () => {
    const invokeTo = testInvokable.address;
    await kEther.connect(signer).mint({ value: parseEther("126") });

    await expect(invoker.invoke(invokeTo, [], ETHER_TOKEN_ADDRESS, parseEther("43"), { value: parseEther("1") })).to.be.revertedWith(
      "Invoker: no liquidity for token"
    );
  });

  it("Should Revert:Invoker: not enough liquidity", async () => {
    const invokeTo = testInvokable.address;
    await invoker.setLiquidityProxies(ETHER_TOKEN_ADDRESS, [proxy.address]);
    await expect(invoker.invoke(invokeTo, [], ETHER_TOKEN_ADDRESS, parseEther("43"), { value: parseEther("1") })).to.be.revertedWith(
      "Invoker: not enough liquidity"
    );
  });

  it("Invoke", async () => {
    const invokeTo = testInvokable.address;
    await proxy.registerPool(ETHER_TOKEN_ADDRESS, kEther.address);

    await invoker.invoke(invokeTo, [], ETHER_TOKEN_ADDRESS, parseEther("43"), { value: parseEther("1") });
  });

  /**
   * When We Not Set Platform Reward And Pool Reward then platform reward and pool reward is equal to 0.
   */
  it("Should Revert: Ownable: caller is not the owner", async () => {
    await expect(kEther.connect(user).setPlatformReward(5)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(kEther.connect(user).setPoolReward(5)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(kEther.connect(user2).setPlatformVaultAddress(signer.address)).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("Set Reward & platFromVaultAddress", async () => {
    await kEther.setPlatformReward(5);
    await kEther.setPoolReward(5);
    await kEther.setPlatformVaultAddress(signer.address);
  });

  it("Invoke", async () => {
    const invokeTo = testInvokable.address;
    await invoker.invoke(invokeTo, [], ETHER_TOKEN_ADDRESS, parseEther("10"), { value: parseEther("1") });
  });

  /**
   * When We Not Set Invoke Platform Reward And Invoke Pool Reward then platform reward and pool reward is equal to 0.
   */

  it("Should Revert: Ownable: caller is not the owner", async () => {
    await expect(invoker.connect(user).setPlatformReward(1)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(invoker.connect(user).setPoolReward(4)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(invoker.connect(user).setPoolRewardAddress(ETHER_TOKEN_ADDRESS, kEther.address)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(invoker.connect(user).setPlatformVaultAddress(signer.address)).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("Set Reward & platFromVaultAddress", async () => {
    await invoker.setPlatformReward(1);
    await invoker.setPoolReward(4);
    await invoker.setPoolRewardAddress(ETHER_TOKEN_ADDRESS, kEther.address);
    await invoker.setPlatformVaultAddress(signer.address);
  });

  it("Invoke", async () => {
    const invokeTo = testInvokable.address;
    await invoker.invoke(invokeTo, [], ETHER_TOKEN_ADDRESS, parseEther("10"), { value: parseEther("1") });
  });

  it.skip("Should Revert:ExternalCaller: insufficient ether balance", async () => {
    const invokeTo = testInvokable.address;
    await expect(invoker.invoke(invokeTo, [], ETHER_TOKEN_ADDRESS, parseEther("43"))).to.be.revertedWith("ExternalCaller: insufficient ether balance");
  });

  it("Should Revert: Invoker: incorrect repayment amount ", async () => {
    const invokeTo = testInvokable.address;
    const invokeData = encodeExecute(1, ["uint256"], [1]);
    await expect(invoker.invoke(invokeTo, invokeData, ETHER_TOKEN_ADDRESS, parseEther("43"))).to.be.revertedWith("Invoker: incorrect repayment amount");
  });
});

function encodeExecute(testType: any, dataAbi: any, data: any) {
  const encodedData = ethers.utils.defaultAbiCoder.encode(dataAbi, data);
  return ethers.utils.defaultAbiCoder.encode(["uint256", "bytes"], [testType, encodedData]);
}
