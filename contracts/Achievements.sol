pragma solidity ^0.4.24;

import "./Users.sol";

contract Achievements {
    address oracle = msg.sender;

    struct Achievement {
        address creator;
        bytes32 linkHash;
        bytes32 previousLinkHash;
        bool exists;
        bool active;
    }

    mapping (bytes32 => Achievement) achievements;
    bytes32[] achievementsList;

    mapping (bytes32 => mapping(address => bool)) confirmed;
    mapping (bytes32 => address[]) witnesses;
    mapping (bytes32 => bool) links;

    Users public users;

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
        require(users.exists(_user));

        bytes32 linkHash = hash(_link);

        require(exists(linkHash) == false);

        bytes32 previousLinkHash = hash(_previousLink);

        // User can create new chain of achievements or append achievement to existing chain
        if (bytes(_previousLink).length == 0) {
            emit Create(_user, _link, _title, _contentHash);
        } else {
            require(links[previousLinkHash] == false);
            require(exists(previousLinkHash) == true);
            require(getAchievementCreator(previousLinkHash) == _user);

            links[previousLinkHash] = true;
            achievements[previousLinkHash].active = false;

            emit Update(_user, _link, _title, _contentHash, _previousLink);
        }

        Achievement memory achievement = Achievement(
            _user,
            linkHash,
            previousLinkHash,
            true,
            true
        );

        achievements[linkHash] = achievement;
        achievementsList.push(linkHash);

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

        require(confirmedBy(linkHash, _user) == false);
        require(achievements[linkHash].exists == true);

        confirmed[linkHash][_user] = true;
        witnesses[linkHash].push(_user);

        address creator = getAchievementCreator(linkHash);

        emit Confirm(creator, _link, _user);

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
        public view returns (address creator, bytes32 linkHash, bytes32 previousLinkHash, bool active)
    {
        creator = achievements[_linkHash].creator;
        linkHash = achievements[_linkHash].linkHash;
        previousLinkHash = achievements[_linkHash].previousLinkHash;
        active = achievements[_linkHash].active;
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
        public view returns (address creator, bytes32 linkHash, bytes32 previousLinkHash, bool active)
    {
        return getAchievement(hash(_link));
    }

    event Create(address wallet, string object, string title, bytes32 contentHash);
    event Update(address wallet, string object, string title, bytes32 contentHash, string previousLink);
    event Confirm(address wallet, string object, address user);
}
