// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./IStrategies.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";

contract Proposal is Pausable {
    enum VotingTypes {
        SingleChoiceVoting,
        RankedChoiceVoting
    }

    struct ProposalDetails {
        string guid;
        string title;
        string uri;
        string[] votingOptions; // TODO: set fixed length to 10
        uint256 startBlock;
        uint256 stopBlock;
        VotingTypes votingType;
    }

    struct Vote {
        string votingOption;
        uint256 votingPower;
        bool hasVoted;
    }

    ProposalDetails internal proposal;
    IStrategies private strategies;

    address private owner;

    bool private initialized;

    uint256 private totalVotes;

    mapping(address => Vote) public votes;
    mapping(string => uint256) public optionCounts;

    event VoteCast(string guid, address voter, string choice, uint256 votingPower);

    constructor() Pausable() {}

    /** 
        init function to set proposal details 
        NOTE: using init because clone factory 
        requires it. 
        TODO: use struct as param instead of elements
    */
    function init(
        address _owner,
        address _strategiesContract,
        string memory _guid,
        string memory _title,
        string memory _uri,
        string[] memory _options,
        uint256 _startOffset,
        uint256 _stopOffset,
        VotingTypes _votingType
    ) external {
        require(!initialized, 'Already initialized');
        uint256 _startBlock = block.number + _startOffset;
        owner = _owner;
        strategies = IStrategies(_strategiesContract);
        proposal = ProposalDetails(
            _guid,
            _title,
            _uri,
            _options,
            _startBlock,
            _startBlock + _stopOffset,
            _votingType
        );
        initialized = true;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, 'Only owner');
        _;
    }

    /// proposal details are editable till start block height is not reached
    modifier isEditable() {
        require(block.number < proposal.startBlock, 'proposal editing period is over');
        _;
    }

    function pauseContract() external onlyOwner isEditable whenNotPaused {
        _pause();
    }

    function unpauseContract() external onlyOwner whenPaused {
        _unpause();
    }

    function isPaused() external view returns (bool) {
        return paused();
    }

    /// returns owner / deployer address
    function getOwner() external view returns (address) {
        return owner;
    }

    /// returns proposal struct
    function getProposalDetails()
        external
        view
        returns (
            string memory,
            string memory,
            string memory,
            string[] memory,
            uint256,
            uint256,
            VotingTypes,
            bool
        )
    {
        return (
            proposal.guid,
            proposal.title,
            proposal.uri,
            proposal.votingOptions,
            proposal.startBlock,
            proposal.stopBlock,
            proposal.votingType,
            paused()
        );
    }

    function getTotalVotes() external view returns(uint256) {
        return totalVotes;
    }

    function setProposalTitle(string memory _title)
        external
        onlyOwner
        isEditable
    {
        proposal.title = _title;
    }

    function setProposalDetailsURI(string memory _uri)
        external
        onlyOwner
        isEditable
        returns (bool)
    {
        proposal.uri = _uri;
        return true;
    }

    function getProposalDetailsURI() external view returns (string memory) {
        return proposal.uri;
    }

    function setVotingOptions(string[] memory _options)
        external
        onlyOwner
        isEditable
        returns (bool)
    {
        proposal.votingOptions = _options;
        return true;
    }

    function setVotingPeriod(uint256 _start, uint256 _stop)
        external
        onlyOwner
        isEditable
        returns (bool)
    {
        checkVotingPeriod(_start, _stop);
        proposal.startBlock = _start;
        proposal.stopBlock = _stop;
        return true;
    }

    function setVotingType(VotingTypes _votingType)
        external
        onlyOwner
        isEditable
    {
        proposal.votingType = _votingType;
    }

    function updateProposalDetails(
        string memory _guid,
        string memory _title,
        string memory _uri,
        string[] memory _options,
        uint256 _startBlock,
        uint256 _stopBlock,
        VotingTypes _votingType
    ) external onlyOwner isEditable {
        checkVotingPeriod(_startBlock, _stopBlock);
        proposal = ProposalDetails(
            _guid,
            _title,
            _uri,
            _options,
            _startBlock,
            _stopBlock,
            _votingType
        );
    }

    function castSingleChoiceVote(string memory _choice)
        external
        whenNotPaused
    {
        require(!votes[msg.sender].hasVoted, 'Already Voted');
        require(indexOfVotingOptions(_choice) >= 0, 'Invalid choice selected');
        require(!isVotingPeriodNotActive(), 'Voting period is not active');
        require(strategies.evaluateGatingStrategies(msg.sender), 'Not eligible to vote');

        uint256 power = strategies.evaluateVotingPower(msg.sender);
        votes[msg.sender] = Vote(_choice, power, true);
        optionCounts[_choice] += power;
        totalVotes += power;
        emit VoteCast(proposal.guid, msg.sender, _choice, power);
    }

    function indexOfVotingOptions(string memory _option)
        private
        view
        returns (int256)
    {
        for (uint256 i; i < proposal.votingOptions.length; i++) {
            if (
                keccak256(bytes(proposal.votingOptions[i])) ==
                keccak256(bytes(_option))
            ) {
                return int256(i);
            }
        }
        return -1;
    }

    function isVotingPeriodNotActive() private view returns (bool) {
        return (block.number < proposal.startBlock ||
            block.number > proposal.stopBlock);
    }

    function checkVotingPeriod(uint256 _start, uint256 _stop) private view {
        require(_start > block.number && _stop > _start, 'Must be endblock > startblock > current block');
    }
}
