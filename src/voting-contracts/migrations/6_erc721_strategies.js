const ERC721Strategies = artifacts.require("ERC721Strategies")

module.exports = function(deployer) {
  deployer.deploy(ERC721Strategies);
};
