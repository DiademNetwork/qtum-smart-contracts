pragma solidity ^0.4.24;

import "./Users.sol";

contract Achievements {
    struct Achievement {
        address creator;
        string link;
        bytes32 linkHash;
        bytes32 contentHash;
        bool exists;
    }

    mapping (bytes32 => Achievement) achievements;
    Achievement[] achievementsList;

    mapping (bytes32 => mapping(address => bool)) confirmed;
    mapping (bytes32 => address[]) witnesses;

    Users users;

    constructor(address _users) public {
        users = Users(_users);
    }

    function create(string _link, bytes32 _contentHash)
        external returns(bool)
    {
        require(users.exists(msg.sender));

        bytes32 linkHash = keccak256(abi.encodePacked(_link));

        require(achievements[linkHash].exists == false);

        Achievement memory achievement = Achievement(
            msg.sender,
            _link,
            linkHash,
            _contentHash,
            true
        );

        achievements[linkHash] = achievement;
        achievementsList.push(achievement);
    }

    function confirmInternal(string _link, address _user)
        internal returns(bool)
    {
        require(users.exists(_user));

        bytes32 linkHash = keccak256(abi.encodePacked(_link));

        require(achievements[linkHash].exists == true);

        confirmed[linkHash][_user] = true;
        witnesses[linkHash].push(_user);

        return true;
    }

    function confirm(string _link)
        external returns (bool)
    {
        return confirmInternal(_link, msg.sender);
    }

    function confirmFrom(address _user, string _link, uint8 v, bytes32 r, bytes32 s)
        external returns (bool)
    {
        bytes32 hash = keccak256(abi.encodePacked(_user, _link));

        address signer = ecrecover(hash, v, r, s);

        require(signer == _user);

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
}