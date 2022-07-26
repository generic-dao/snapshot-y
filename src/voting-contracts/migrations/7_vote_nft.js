const VoteNFT = artifacts.require("VoteNFT");

module.exports = function(deployer) {
  deployer.deploy(VoteNFT, "Vote Token", "VOTE");
};
