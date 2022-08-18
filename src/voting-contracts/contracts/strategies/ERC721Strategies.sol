// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ERC721Strategies {

  error ERC721Error(string err);

  modifier zeroAddress(address addr) {
    require(addr != address(0), 'zero address');
    _;
  }

  /** 
    returns token balance of voter for given erc721 contract
    @dev requires NFT contract to support both 165 and 721 
  */
  function erc721Balance(address voter, address contractAddr) 
    external 
    view 
    zeroAddress(voter) 
    zeroAddress(contractAddr) 
    returns(uint) 
  {
    // check support for 721 and 165 interfaces
    require(IERC721(contractAddr).supportsInterface(0x80ac58cd), "ERC721Strategies: contract not supproted");
    // get balance from contract
    try IERC721(contractAddr).balanceOf(voter) returns (uint balance) {
      return balance;
    } catch {
      revert ERC721Error("ERC721Strategies: error fetching balance");
    }
  }
}
