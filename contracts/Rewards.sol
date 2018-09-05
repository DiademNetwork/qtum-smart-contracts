pragma solidity ^0.4.24;

import "./Achievements.sol";

contract Rewards {
    Achievements achievements;

    mapping (bytes32 => mapping (address => uint256)) deposits;

    constructor(address _achievements) public {
        achievements = Achievements(_achievements);
    }

    function deposit(string _link, address _witness)
        external payable returns (bool)
    {
        bytes32 linkHash = keccak256(abi.encodePacked(_link));

        require(achievements.exists(linkHash));

        deposits[linkHash][_witness] += msg.value;

        emit Deposit(linkHash, _witness);

        return true;
    }

    function withdraw(string _link, address _witness)
        external returns (bool)
    {
        bytes32 linkHash = keccak256(abi.encodePacked(_link));

        require(achievements.exists(linkHash));
        require(achievements.confirmedBy(linkHash, _witness));
        require(deposits[linkHash][_witness] > 0);

        address beneficiary = achievements.getAchievementCreator(linkHash);

        uint256 value = deposits[linkHash][_witness];
        deposits[linkHash][_witness] = 0;

        beneficiary.transfer(value);

        emit Withdraw(linkHash, _witness, value, beneficiary);

        return true;
    }

    event Deposit(bytes32 linkHash, address _witness);
    event Withdraw(bytes32 linkHash, address _witness, uint256 _value, address _user);
}