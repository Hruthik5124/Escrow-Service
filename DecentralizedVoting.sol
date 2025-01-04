// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DecentralizedVoting {
    address public admin;
    uint256 private registrationDeadline = 1752451200; // This unix timestamp is for the date 14th July 2025 I made this change to check smartcontract is working.

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        bool isBlacklisted;
        uint256 vote; 
    }

    mapping(address => Voter) public voters;
    mapping(uint256 => uint256) public votesCount;

    event VoterRegistered(address voter);
    event VoteCast(address voter, uint256 vote);
    event VoterBlacklisted(address voter);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyBeforeDeadline() {
        require(block.timestamp <= registrationDeadline, "Registration period has ended");
        _;
    }

    modifier onlyRegistered() {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function register() external onlyBeforeDeadline {
        require(!voters[msg.sender].isRegistered, "You are already registered");
        require(!voters[msg.sender].isBlacklisted, "Blacklisted voters cannot register");

        voters[msg.sender] = Voter({
            isRegistered: true,
            hasVoted: false,
            isBlacklisted: false,
            vote: 0
        });

        emit VoterRegistered(msg.sender);
    }

    function castVote(uint256 _voteChoice) external onlyRegistered {
        Voter storage voter = voters[msg.sender];
        require(!voter.hasVoted, "You have already cast your vote");
        require(!voter.isBlacklisted, "Blacklisted voters cannot vote");
        voter.hasVoted = true;
        voter.vote = _voteChoice;
        votesCount[_voteChoice]++;
        emit VoteCast(msg.sender, _voteChoice);
    }


}
