// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

// TODO: import relative path, probably two package.json
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Proposal.sol";

contract ProposalFactory {
    //R/ why is this private - this should maybe 
    address private proposalImplementation;
    //R/ log events using indexed keyword i.e event CreatedProposal(string indexed guid, address indexed clonedProposal);
    //R/ 'opinion' : event can be better named as ProposalCreation
    event CreatedProposal(string guid, address clonedProposal);
    //R/ as per convention constructor args have postfix underscore not prefix
    //R/ (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f491e98d37adb4684552b46c51510d18dd714702/contracts/token/ERC721/ERC721.sol#L44)
    constructor(address _implementation) {
        // proposalImplementation = address(new Proposal());
        proposalImplementation = _implementation;
    }

    /** 
        create a new proposal with provided details
    */
    //R/ In solidity as per Openzepplin normally only private variables or functions names are prefixed with underscore _ and not function args.

    function createProposal(
        address _strategiesContract,
        string memory _guid,
        string memory _title,
        string memory _uri,
        string[] memory _options,
        uint256 _startOffset,
        uint256 _stopOffset,
        Proposal.VotingTypes _votingType
    ) external returns (address) {
        //R/ no reqruire checks on params are these all optionals ?
        //R/ register strategies interface and use supportinterface to verify upon each proposal creation or atleast 
        //R/ check strategiesContract != EOA see link below
        //R/ https://stackoverflow.com/questions/37644395/how-to-find-out-if-an-ethereum-address-is-a-contract#:~:text=There%20is%20no%20way%20in,with%20humans%20and%20other%20contracts.
        address clonedProposal = Clones.clone(proposalImplementation);
        //R/ how do we know this proposalImplementation exists better we check its not initialized to 0 address => require(proposalImplementation != address(0))
        //R/ not 100% sure if its applicable here but we need to see if our externals contracts calls are prone to reentrancy attacks 
        //R/ if yes then we should use https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard 
        Proposal(clonedProposal).init(
            msg.sender,
            _strategiesContract,
            _guid,
            _title,
            _uri,
            _options,
            _startOffset,
            _stopOffset,
            _votingType
        );
        emit CreatedProposal(_guid, clonedProposal);
        //R/ assuming we are using this returned proposal addresss somewhere otherwise this is redundant
        return clonedProposal;
    }
}