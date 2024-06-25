// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface ITrotelCoinCollectiveIntelligenceV1 {
    // structs
    struct Votes {
        uint256 approve;
        uint256 reject;
        uint256 total;
    }

    struct Course {
        string title;
        string ipfsHash;
        address creator;
        uint256 submissionTime;
        CourseState state;
        Votes votes;
        uint256 voteEndTime;
    }

    struct Creator {
        int8 reputation;
        uint256 numberOfCourses;
        uint256[] courses;
    }

    // enums
    enum CourseState {
        Pending,
        Approved,
        Rejected
    }

    // events
    event CourseSubmitted(uint256 indexed courseId, address indexed creator, string ipfsHash, uint256 submissionTime);
    event CourseApproved(uint256 indexed courseId);
    event CourseRejected(uint256 indexed courseId);
    event VoteCast(uint256 indexed courseId, address indexed voter, bool vote);
    event FeeCollected(address indexed feeCollector, uint256 amount);
    event ReputationUpdated(address indexed user, int8 reputation);

    // functions

    /**
     * @dev Submit a course to the collective intelligence
     * @param _title The title of the course
     * @param _ipfsHash The IPFS hash of the course
     * @param _voteEndTime The end time of the voting period
     */
    function submitCourse(string memory _title, string memory _ipfsHash, uint256 _voteEndTime) external;

    /**
     * @dev Get a course from its ID
     * @param _courseId The ID of the course
     * @return The course
     */
    function getCourse(uint256 _courseId) external view returns (Course memory);

    /**
     * @dev Vote for a course
     * @param _courseId The ID of the course
     * @param _vote The vote (true for approve, false for reject)
     */
    function voteCourse(uint256 _courseId, bool _vote) external;

    /**
     * @dev Check if a user has voted for a course
     * @param _courseId The ID of the course
     * @param _voter The address of the voter
     * @return True if the user has voted, false otherwise
     */
    function hasVoted(uint256 _courseId, address _voter) external view returns (bool);

    /**
     * @dev Check voting period duration based on user grade
     * @param _user The address of the user
     * @return The voting period duration
     */
    function getVotingPeriod(address _user) external view returns (uint256);

    /**
     * @dev Finalize a course by approving or rejecting it
     * @param _courseId The ID of the course
     */
    function finalizeCourse(uint256 _courseId) external;

    /**
     * @dev Set the voting period duration
     * @param _votingPeriodsDuration The voting period duration
     */
    function setVotingPeriodsDuration(uint256 _votingPeriodsDuration) external;

    /**
     * @dev Set submission fee
     * @param _fee The submission fee
     */
    function setSubmissionFee(uint256 _fee) external; // onlyAdmin

    /**
     * @dev Withdraw fees
     * @param _feeCollector The address of the fee collector
     */
    function withdrawFees(address _feeCollector) external; // onlyAdmin

    /**
     * @dev Set and update reputation
     * @param _user The address of the user
     * @param _reputation The reputation
     */
    function updateReputation(address _user, int8 _reputation) external; // onlyAdmin

    /**
     * @dev Get reputation
     * @param _user The address of the user
     * @return The reputation
     */
    function getReputation(address _user) external view returns (int8);

    /**
     * @dev Adjust the reputation of a user based on the voting result
     * @param _courseId The ID of the course
     * @param _approved True if the course is approved, false otherwise
     */
    function adjustReputation(uint256 _courseId, bool _approved) external; // onlyAdmin

    /**
     * @dev Get the number of courses submitted by a user
     * @param _user The address of the user
     * @return The number of courses
     */
    function getNumberOfCourses(address _user) external view returns (uint256);

    /**
     * @dev Get the courses submitted by a user
     * @param _user The address of the user
     * @return The courses
     */
    function getCourses(address _user) external view returns (uint256[] memory);

    /**
     * @dev Get the creator of a course
     * @param _courseId The ID of the course
     * @return The creator
     */
    function getCreator(uint256 _courseId) external view returns (Creator memory);

    /**
     * @dev Get the creator of a course
     * @param _creator The address of the creator
     * @return The creator
     */
    function getCreatorByAddress(address _creator) external view returns (Creator memory);

    /**
     * @dev Get the creator reputation
     * @param _creator The address of the creator
     * @return The reputation
     */
    function getCreatorReputation(address _creator) external view returns (int8);

    /**
     * @dev Get the creator number of courses
     * @param _creator The address of the creator
     * @return The number of courses
     */
    function getCreatorNumberOfCourses(address _creator) external view returns (uint256);

    /**
     * @dev Update trotelcoin address
     * @param trotelcoinaddress The address of the trotelcoin
     */
    function updateTrotelCoin(address trotelcoinaddress) external; // onlyAdmin

    /**
     * @dev Update trotelcoin staking address
     * @param trotelcoinstaking The address of the trotelcoin staking
     */
    function updateTrotelCoinStaking(address trotelcoinstaking) external; // onlyAdmin
}