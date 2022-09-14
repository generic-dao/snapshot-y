const { BN } = require("bn.js");
const ERC721Strategies = artifacts.require("ERC721Strategies")
const VoteNFT = artifacts.require("VoteNFT");

module.exports = function(deployer) {
  deployer.deploy(VoteNFT, "Vote Token", "VOTE").then(()=> {
    deployer.deploy(ERC721Strategies, VoteNFT.address, new BN(1));
  })
};