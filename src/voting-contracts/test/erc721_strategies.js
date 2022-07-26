const ERC721Strategies = artifacts.require("ERC721Strategies");
const VoteToken = artifacts.require("VoteNFT");
const ValidERC20 = artifacts.require("ValidERC20");
const { constants, expectRevert } = require("@openzeppelin/test-helpers");

contract("ERC721Strategies", function ( accounts ) {

  const deployer = accounts[0];

  describe("erc721Balance", () => {
    
    before(async () => {
      this.erc721Strategies = await ERC721Strategies.deployed();
      // wait for token contract and mint couple of tokens 
      this.voteToken = await VoteToken.deployed();
      await this.voteToken.mint(deployer, 1);
      await this.voteToken.mint(deployer, 2);
      // wait for a erc20 token contract - to be checked against interface implementation
      this.erc20Token = await ValidERC20.deployed();
    });

    it("should return nft balance of voter", async () => {
      const bal_deployer = await this.erc721Strategies.erc721Balance(deployer, this.voteToken.address);
      const bal_other = await this.erc721Strategies.erc721Balance(accounts[1], this.voteToken.address);
      assert.equal(bal_other.toNumber(), 0);
      return assert.equal(bal_deployer.toNumber(), 2);
    });

    it("should handle zero address for voter", async () => {
      await expectRevert.unspecified(this.erc721Strategies.erc721Balance(constants.ZERO_ADDRESS, this.voteToken.address));
    });
    
    it("should handle zero address for contract", async () => {
      await expectRevert.unspecified(this.erc721Strategies.erc721Balance(deployer, constants.ZERO_ADDRESS));
    });

    it("should handle contracts that don't implement required interfaces", async () => {
      await expectRevert.unspecified(this.erc721Strategies.erc721Balance(deployer, this.erc20Token.address));
    });
  });
});
