// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/@openzeppelin/contracts/access/ownable.sol";

/// Sample NFT contract to test ERC721 strategies
contract VoteNFT is ERC721, Ownable {

  constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable() {}

  error ZeroAddress();

  modifier zeroAddress(address addr) {
    if(addr == address(0)) {
      revert ZeroAddress();
    }
    _;
  }

  function mint(address to, uint tokenId) external onlyOwner zeroAddress(to) {
    _mint(to, tokenId);
  }

  function burn(uint tokenId) external {
    _burn(tokenId);
  }
}


