pragma solidity ^0.4.24;

import "./Achievements.sol";

contract Rewards {
    Achievements achievements;

    mapping (bytes32 => mapping (address => uint256)) deposits;

    constructor(address _achievements) public {
        achievements = Achievements(_achievements);
    }

    function deposit(bytes32 _linkHash, address _witness)
        external payable returns (bool)
    {
        require(achievements.exists(_linkHash));

        deposits[_linkHash][_witness] += msg.value;

        emit Deposit(_linkHash, _witness);

        return true;
    }

    function withdraw(bytes32 _linkHash, address _witness)
        external returns (bool)
    {
        require(achievements.exists(_linkHash));
        require(deposits[_linkHash][_witness] > 0);

        address beneficiary = achievements.getAchievementCreator(_linkHash);

        uint256 value = deposits[_linkHash][_witness];
        deposits[_linkHash][_witness] = 0;

        beneficiary.transfer(value);

        emit Withdraw(_linkHash, _witness, value, beneficiary);

        return true;
    }

    event Deposit(bytes32 _linkHash, address _witness);
    event Withdraw(bytes32 _linkHash, address _witness, uint256 _value, address _user);
}