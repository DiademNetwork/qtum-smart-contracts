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
        bool active;
        string previousLink;
        bytes32 previousLinkHash;
    }

    mapping (bytes32 => Achievement) achievements;
    bytes32[] achievementsList;

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

    function create(string _link, bytes32 _contentHash, string _title, string _previousLink)
        external returns (bool)
    {
        return createInternal(msg.sender, _link, _contentHash, _title, _previousLink);
    }

    function createFrom(address _user, string _link, bytes32 _contentHash, string _title, string _previousLink)
        external onlyOracle returns (bool)
    {
        return createInternal(_user, _link, _contentHash, _title, _previousLink);
    }

    function createInternal(address _user, string _link, bytes32 _contentHash, string _title, string _previousLink)
        internal returns (bool)
    {
        // require(users.exists(_user));

        bytes32 linkHash = hash(_link);

        require(achievements[linkHash].exists == false);

        // if user wanna to append achievement to existing chain of achievements
        if (bytes(_previousLink).length != 0) {
            bytes32 previousLinkHash = hash(_previousLink);

            require(exists(previousLinkHash));
            require(getAchievementCreator(previousLinkHash) == _user);

            achievements[previousLinkHash].active = false;
        }

        Achievement memory achievement = Achievement(
            _user,
            _link,
            linkHash,
            _contentHash,
            _title,
            true,
            true,
            _previousLink,
            previousLinkHash
        );

            achievements[linkHash] = achievement;
        achievementsList.push(linkHash);

        emit Create(_link, msg.sender);

        return true;
    }

    function hash(string _link)
        public returns (bytes32)
    {
        return keccak256(abi.encodePacked(_link));
    }

    function confirmInternal(string _link, address _user)
        internal returns (bool)
    {
        require(users.exists(_user));

        bytes32 linkHash = hash(_link);

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
        public view returns (bool)
    {
        return achievements[_linkHash].exists;
    }

    function getAchievementCreator(bytes32 _linkHash)
        public view returns (address)
    {
        return achievements[_linkHash].creator;
    }

    function getAchievement(bytes32 _linkHash)
        public view returns (address creator, string link, bytes32 linkHash, bytes32 contentHash, string title, string previousLink, bytes32 previousLinkHash, bool active)
    {
        if (achievements[_linkHash].exists == true) {
            creator = achievements[_linkHash].creator;
            link = achievements[_linkHash].link;
            linkHash = achievements[_linkHash].linkHash;
            contentHash = achievements[_linkHash].contentHash;
            title = achievements[_linkHash].title;
            previousLink = achievements[linkHash].previousLink;
            previousLinkHash = achievements[linkHash].previousLinkHash;
            active = achievements[linkHash].active;
        }
    }

    function confirmedBy(bytes32 _linkHash, address _witness)
        public view returns (bool)
    {
        return confirmed[_linkHash][_witness];
    }

    function existsRaw(string _link)
        public view returns (bool)
    {
        bytes32 linkHash = hash(_link);
        return exists(linkHash);
    }

    function getAchievementCreatorRaw(string _link)
        public view returns (address)
    {
        bytes32 linkHash = hash(_link);
        return getAchievementCreator(linkHash);
    }

    function confirmedByRaw(string _link, address _witness)
        public view returns (bool)
    {
        bytes32 linkHash = hash(_link);
        return confirmedBy(linkHash, _witness);
    }

    function getAchievementRaw(string _link)
        public view returns (address creator, string link, bytes32 linkHash, bytes32 contentHash, string title, string previousLink, bytes32 previousLinkHash, bool active)
    {
        return getAchievement(hash(_link));
    }

    event Create(string link, address creator);
    event Confirm(string link, address witness);
}