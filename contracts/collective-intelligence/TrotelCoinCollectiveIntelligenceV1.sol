// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../token/TrotelCoinV2.sol";
import "../staking/TrotelCoinStakingV2.sol";
import "../interfaces/ITrotelCoinCollectiveIntelligenceV1.sol";

contract TrotelCoinCollectiveIntelligenceV1 is
    ITrotelCoinCollectiveIntelligenceV1,
    AccessControl
{
    // contracts
    TrotelCoinV2 public trotelcoin;
    TrotelCoinStakingV2 public trotelcoinstaking;

    // variables
    uint256 public maxVotingPeriodsDuration;
    uint256 public maxSubmissionFee;
    uint256[] public votingPeriodsDuration; // beginner, intermediate, expert durations
    uint256 public submissionFee;
    uint256 public totalCourses;

    // mappings
    mapping(uint256 => Course) public courses;
    mapping(uint256 => mapping(address => bool)) public votes;
    mapping(address => int8) public reputation;
    mapping(address => Creator) public creators;

    // modifiers
    modifier isValidVotingPeriod(uint256 _votingPeriod) {
        require(
            _votingPeriod <= maxVotingPeriodsDuration,
            "Invalid voting period"
        );
        _;
    }

    modifier isValidSubmissionFee(uint256 _fee) {
        require(_fee <= maxSubmissionFee, "Invalid submission fee");
        _;
    }

    modifier onlyCreator(uint256 _courseId) {
        require(courses[_courseId].creator == msg.sender, "Only creator");
        _;
    }

    modifier onlyDuringVotingPeriod(uint256 _courseId) {
        require(
            courses[_courseId].voteEndTime > 0,
            "Voting period not started"
        );
        require(
            block.timestamp < courses[_courseId].voteEndTime,
            "Voting period ended"
        );
        _;
    }

    modifier onlyFeeCollector(address _feeCollector) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _feeCollector),
            "Only fee collector"
        );
        _;
    }

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Only admin"
        );
        _;
    }

    constructor(address _trotelcoinaddress,
        address _trotelcoinstaking) {
        // trotelcoin
        trotelcoin = TrotelCoinV2(_trotelcoinaddress);

        // trotelcoin staking
        trotelcoinstaking = TrotelCoinStakingV2(_trotelcoinstaking);

        // constants
        maxVotingPeriodsDuration = 30 days;
        maxSubmissionFee = 10000 * 10 ** trotelcoin.decimals();

        // voting periods duration
        votingPeriodsDuration.push(15 days);
        votingPeriodsDuration.push(7 days);
        votingPeriodsDuration.push(3 days);

        // submission fee
        submissionFee = 1000 * 10 ** trotelcoin.decimals();
    }

    function submitCourse(
        string memory _title,
        string memory _ipfsHash,
        uint256 _voteEndTime
    ) external override {
        require(
            _voteEndTime <= maxVotingPeriodsDuration,
            "Invalid voting period"
        );
        require(
            trotelcoin.balanceOf(msg.sender) >= submissionFee,
            "Insufficient balance"
        );

        uint256 courseId = totalCourses + 1;
        totalCourses = courseId;

        courses[courseId] = Course({
            title: _title,
            ipfsHash: _ipfsHash,
            creator: msg.sender,
            submissionTime: block.timestamp,
            state: CourseState.Pending,
            votes: Votes(0, 0, 0),
            voteEndTime: _voteEndTime
        });

        trotelcoin.transferFrom(msg.sender, address(this), submissionFee);

        emit CourseSubmitted(courseId, msg.sender, _ipfsHash, block.timestamp);

        if (creators[msg.sender].reputation == 0) {
            creators[msg.sender] = Creator({
                reputation: 0,
                numberOfCourses: 0,
                courses: new uint256[](0)
            });
        }

        creators[msg.sender].numberOfCourses++;
        creators[msg.sender].courses.push(courseId);
    }

    function getCourse(
        uint256 _courseId
    ) external view override returns (Course memory) {
        return courses[_courseId];
    }

    function voteCourse(
        uint256 _courseId,
        bool _vote
    ) external override onlyDuringVotingPeriod(_courseId) {
        require(!votes[_courseId][msg.sender], "Already voted");

        votes[_courseId][msg.sender] = true;

        if (_vote) {
            courses[_courseId].votes.approve = courses[_courseId].votes.approve++;
        } else {
            courses[_courseId].votes.reject = courses[_courseId].votes.reject++;
        }
        courses[_courseId].votes.total = courses[_courseId].votes.total++;

        emit VoteCast(_courseId, msg.sender, _vote);
    }

    function hasVoted(
        uint256 _courseId,
        address _voter
    ) external view override returns (bool) {
        return votes[_courseId][_voter];
    }

    function getVotingPeriod(
        address _user
    ) external view override returns (uint256) {
        TrotelCoinStakingV2.UserStaking memory stakings = trotelcoinstaking
            .getStakings(_user);
        uint256 userStakingAmount = stakings.totalAmount;

        if (userStakingAmount >= 50000 * 10 ** trotelcoin.decimals()) {
            return votingPeriodsDuration[2];
        } else if (userStakingAmount >= 10000 * 10 ** trotelcoin.decimals()) {
            return votingPeriodsDuration[1];
        } else {
            return votingPeriodsDuration[0];
        }
    }

    function finalizeCourse(
        uint256 _courseId
    ) external override onlyAdmin {
        require(
            courses[_courseId].voteEndTime > 0,
            "Voting period not started"
        );
        require(
            block.timestamp >= courses[_courseId].voteEndTime,
            "Voting period not ended"
        );

        if (
            courses[_courseId].votes.approve > courses[_courseId].votes.reject
        ) {
            courses[_courseId].state = CourseState.Approved;
            adjustReputation(_courseId, true);
            emit CourseApproved(_courseId);
        } else {
            courses[_courseId].state = CourseState.Rejected;
            adjustReputation(_courseId, false);
            emit CourseRejected(_courseId);
        }
    }

    function setVotingPeriodsDuration(
        uint256 _votingPeriodsDuration
    ) external override onlyAdmin {
        maxVotingPeriodsDuration = _votingPeriodsDuration;
    }

    function setSubmissionFee(uint256 _fee) external override onlyAdmin {
        submissionFee = _fee;
    }

    function withdrawFees(
        address _feeCollector
    ) external override onlyFeeCollector(_feeCollector) {
        uint256 balance = trotelcoin.balanceOf(address(this));
        trotelcoin.transfer(_feeCollector, balance);

        emit FeeCollected(_feeCollector, balance);
    }

    function updateReputation(
        address _user,
        int8 _reputation
    ) external override onlyAdmin {
        reputation[_user] = _reputation;

        emit ReputationUpdated(_user, _reputation);
    }

    function getReputation(
        address _user
    ) external view override returns (int8) {
        return reputation[_user];
    }

    function adjustReputation(
        uint256 _courseId,
        bool _approved
    ) public override onlyAdmin {
        address creator = courses[_courseId].creator;
        int8 reputationAdjustment = _approved ? int8(1) : int8(-1);

        reputation[creator] = reputation[creator] + reputationAdjustment;

        emit ReputationUpdated(creator, reputation[creator]);
    }

    function getNumberOfCourses(
        address _user
    ) external view override returns (uint256) {
        return creators[_user].numberOfCourses;
    }

    function getCourses(
        address _user
    ) external view override returns (uint256[] memory) {
        return creators[_user].courses;
    }

    function getCreator(
        uint256 _courseId
    ) external view override returns (Creator memory) {
        return creators[courses[_courseId].creator];
    }

    function getCreatorByAddress(
        address _creator
    ) external view override returns (Creator memory) {
        return creators[_creator];
    }

    function getCreatorReputation(
        address _creator
    ) external view override returns (int8) {
        return creators[_creator].reputation;
    }

    function getCreatorNumberOfCourses(
        address _creator
    ) external view override returns (uint256) {
        return creators[_creator].numberOfCourses;
    }

    function updateTrotelCoin(
        address _trotelcoinaddress
    ) external override onlyAdmin {
        trotelcoin = TrotelCoinV2(_trotelcoinaddress);
    }

    function updateTrotelCoinStaking(
        address _trotelcoinstaking
    ) external override onlyAdmin {
        trotelcoinstaking = TrotelCoinStakingV2(_trotelcoinstaking);
    }
}