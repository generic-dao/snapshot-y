// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

// TODO: import relative path, probably two package.json
import "../node_modules/@openzeppelin/contracts/proxy/Clones.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Proposal.sol";

contract ProposalFactory is ReentrancyGuard {
    address private proposalImplementation;
    
    event ProposalCreated(string indexed guid, address indexed clonedProposal);

    constructor(address implementation_) ReentrancyGuard() {
        // proposalImplementation = address(new Proposal());
        proposalImplementation = implementation_;
    }

    /** 
        create a new proposal with provided details
    */
    function createProposal(
        address strategiesContract,
        string memory guid,
        string memory title,
        string memory uri,
        string[] memory options,
        uint256 startOffset,
        uint256 stopOffset,
        Proposal.VotingTypes votingType
    ) 
    external 
    nonReentrant
    returns (address) {
        /** it is advised to check validity of passed contract addresses,
            but there is no way to be 100% sure if the passed address is
            actually a contract address or not. Discussed here ...
            https://stackoverflow.com/questions/37644395/how-to-find-out-if-an-ethereum-address-is-a-contract
            
            For this contract, caller (frontend) is reponsible for passing 
            valid addresses. A third party attempt to call this contract will 
            return a proposal contract address, which will not be shown on 
            frontend or handled by backend. This is because deploying strategy 
            contract and creating a proposal are atomic operation on frontend. 
        */
        address clonedProposal = Clones.clone(proposalImplementation);
        Proposal(clonedProposal).init(
            msg.sender,
            strategiesContract,
            guid,
            title,
            uri,
            options,
            startOffset,
            stopOffset,
            votingType
        );
        emit ProposalCreated(guid, clonedProposal);
        return clonedProposal;
    }
}
