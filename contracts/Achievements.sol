pragma solidity ^0.4.24;

import "./Users.sol";

contract Achievements {
    address oracle = msg.sender;

    struct Achievement {
        address creator;
        string link;
        bytes32 linkHash;
        bytes32 contentHash;
        string title;
        bool exists;
    }

    mapping (bytes32 => Achievement) achievements;
    Achievement[] achievementsList;

    mapping (bytes32 => mapping(address => bool)) confirmed;
    mapping (bytes32 => address[]) witnesses;

    Users users;

    modifier onlyOracle() {
        require(msg.sender == oracle);
        _;
    }

    constructor(address _users) public {
        users = Users(_users);
    }

    function create(string _link, bytes32 _contentHash, string _title)
        external returns (bool)
    {
        return createInternal(msg.sender, _link, _contentHash, _title);
    }

    function createFrom(address _user, string _link, bytes32 _contentHash, string _title)
        external onlyOracle returns (bool)
    {
        return createInternal(_user, _link, _contentHash, _title);
    }

    function createInternal(address _user, string _link, bytes32 _contentHash, string _title)
        internal returns (bool)
    {
        require(users.exists(_user));

        bytes32 linkHash = keccak256(abi.encodePacked(_link));

        require(achievements[linkHash].exists == false);

        Achievement memory achievement = Achievement(
            msg.sender,
            _link,
            linkHash,
            _contentHash,
            _title,
            true
        );

        achievements[linkHash] = achievement;
        achievementsList.push(achievement);

        emit Create(_link, msg.sender);

        return true;
    }

    function confirmInternal(string _link, address _user)
        internal returns (bool)
    {
        require(users.exists(_user));

        bytes32 linkHash = keccak256(abi.encodePacked(_link));

        require(achievements[linkHash].exists == true);

        confirmed[linkHash][_user] = true;
        witnesses[linkHash].push(_user);

        emit Confirm(_link, _user);

        return true;
    }

    function confirm(string _link)
        external returns (bool)
    {
        return confirmInternal(_link, msg.sender);
    }

    function confirmFrom(address _user, string _link)
        external onlyOracle returns (bool)
    {
        return confirmInternal(_link, _user);
    }

    function getTotalAchievements()
        public view returns (uint256)
    {
        return achievementsList.length;
    }

    function exists(bytes32 _linkHash)
        external view returns (bool)
    {
        return achievements[_linkHash].exists;
    }

    function getAchievementCreator(bytes32 _linkHash)
        external view returns (address)
    {
        return achievements[_linkHash].creator;
    }

    function getAchievement(bytes32 _linkHash)
        external view returns (address creator, string link, bytes32 linkHash, bytes32 contentHash, string title)
    {
        creator = achievements[_linkHash].creator;
        link = achievements[_linkHash].link;
        linkHash = achievements[_linkHash].linkHash;
        contentHash = achievements[_linkHash].contentHash;
        title = achievements[_linkHash].title;
    }

    function confirmedBy(bytes32 _linkHash, address _witness)
        public view returns (bool)
    {
        return confirmed[_linkHash][_witness];
    }

    event Create(string link, address creator);
    event Confirm(string link, address witness);
}