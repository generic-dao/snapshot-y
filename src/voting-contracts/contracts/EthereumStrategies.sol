// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract EthereumStrategies {

  modifier zeroAddress(address addr) {
    require(addr != address(0), 'zero address');
    _;
  }

  /**
    @notice returns balance of given address in wei
    https://github.com/snapshot-labs/snapshot-strategies/tree/master/src/strategies/eth-balance
  */
  function getEthBalance(address addr) public view zeroAddress(addr) returns (uint) {
    return addr.balance;
  }

  /** 
    https://github.com/snapshot-labs/snapshot-strategies/tree/master/src/strategies/eth-with-balance
  */
  function minEthBalance(address addr, uint minAmount) external view zeroAddress(addr) returns (bool) {
    return (addr.balance >= minAmount) ? true : false; 
  }   
}
