pragma solidity ^0.4.24;

import "./Achievements.sol";

contract Rewards {
    Achievements achievements;

    mapping (bytes32 => mapping (address => uint256)) public deposits;
    mapping (bytes32 => address[]) public witnesses;

    constructor(address _achievements) public {
        achievements = Achievements(_achievements);
    }

    function hash(string _link)
        public returns (bytes32)
    {
        return keccak256(abi.encodePacked(_link));
    }

    function getRewardAmount(string _link, address _witness)
        public view returns (uint256)
    {
        bytes32 linkHash = hash(_link);

        return deposits[linkHash][_witness];
    }

    function support(string _link)
        external payable returns (bool)
    {
        bytes32 linkHash = hash(_link);

        // require(achievements.exists(linkHash));

        address beneficiary = achievements.getAchievementCreator(linkHash);

        beneficiary.transfer(msg.value);

        emit Support(beneficiary, _link, msg.sender, msg.value);

        return true;
    }

    function deposit(string _link, address _witness)
        external payable returns (bool)
    {
        bytes32 linkHash = hash(_link);

        // require(achievements.exists(linkHash));

        deposits[linkHash][_witness] += msg.value;
        witnesses[linkHash].push(_witness);

        address beneficiary = achievements.getAchievementCreator(linkHash);

        emit Deposit(beneficiary, _link, msg.sender, msg.value, _witness);

        return true;
    }

    function withdraw(string _link, address _witness)
        external returns (bool)
    {
        bytes32 linkHash = hash(_link);

        // require(achievements.exists(linkHash));
        // require(achievements.confirmedBy(linkHash, _witness));
        // require(deposits[linkHash][_witness] > 0);

        address beneficiary = achievements.getAchievementCreator(linkHash);

        uint256 value = deposits[linkHash][_witness];
        deposits[linkHash][_witness] = 0;

        beneficiary.transfer(value);

        emit Withdraw(beneficiary, _link, value, _witness);

        return true;
    }

    event Support(address wallet, string object, address user, uint256 amount);
    event Deposit(address wallet, string object, address user, uint256 amount, address witness);
    event Withdraw(address wallet, string object, uint256 amount, address witness);
}
