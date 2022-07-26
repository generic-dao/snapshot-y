const { constants, expectRevert, BN } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const { expect } = require("chai");

const EthereumStrategies = artifacts.require("EthereumStrategies");

contract("EthereumStrategies", function (accounts) {

  const deployer = accounts[0];

  describe("strategy: ethereum balance", () => {
    before(async () => {
      this.ethStrategy = await EthereumStrategies.deployed();
    });
  
    it("should return ethereum balance of given address", async () => {
      const balanceFromCall = new BN(await this.ethStrategy.getEthBalance(deployer));
      const balanceFromWeb3 = new BN(await web3.eth.getBalance(deployer));
      expect(balanceFromWeb3).to.be.bignumber.equal(balanceFromCall);
    });

    it("should handle zero address", async () => {
      await expectRevert.unspecified(this.ethStrategy.getEthBalance(constants.ZERO_ADDRESS));
    });
  });

  describe("strategy: min eth balance", () => {

    it("should return true if eth balance of address is more than min balance", async () => {
      const userBalance = new BN(await web3.eth.getBalance(deployer));
      const retVal = await this.ethStrategy.minEthBalance(deployer, userBalance.subn(1));
      assert.equal(retVal, true);
    });

    it("should handle zero address", async () => {
      await expectRevert.unspecified(this.ethStrategy.minEthBalance(constants.ZERO_ADDRESS, 0));
    }); 
  });
});
