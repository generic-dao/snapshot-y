const EthereumStrategies = artifacts.require("EthereumStrategies");

module.exports = function(deployer) {
  deployer.deploy(EthereumStrategies);
};
