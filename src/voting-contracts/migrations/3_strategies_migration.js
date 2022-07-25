const ValidERC20 = artifacts.require("ValidERC20");
const Strategies = artifacts.require("Strategies");
const { BN } = require("bn.js");

const name = "SampleToken";
const symbol = "ST";
const initialSupply = new BN(50);

const minimumBalance = new BN(6);
module.exports = async function (deployer, accounts) {
  deployer.deploy(ValidERC20, initialSupply, name, symbol).then(() => {
    return deployer.deploy(Strategies, ValidERC20.address, minimumBalance);
  });
};