pragma solidity ^0.4.24;

contract Users {
    address public oracle = msg.sender;

    modifier onlyOracle() {
        require(msg.sender == oracle);
        _;
    }

    struct User {
        address userAddress;
        string userAccount;
        string userName;
        bool exists;
    }

    mapping (address => User) users;
    mapping (string => address) accounts;
    address[] usersList;

    mapping (address => string) addressToName;
    mapping (address => string) addressToAccount;
    mapping (string => address) accountToAddress;

    function getUsersCount()
        public view returns (uint256)
    {
        return usersList.length;
    }

    function getUser(address _user)
        public view returns (address userAddress, string userAccount, string userName)
    {
        userAddress = users[_user].userAddress;
        userAccount = users[_user].userAccount;
        userName = users[_user].userName;
    }

    function register(address _userAddress, string _userAccount, string _userName)
        external onlyOracle
    {
        require(users[_userAddress].exists == false);
        require(accounts[_userAccount] == address(0));

        User memory user = User(_userAddress, _userAccount, _userName, true);

        users[_userAddress] = user;
        accounts[_userAccount] = _userAddress;
        usersList.push(_userAddress);

        emit Register(_userAddress, _userAccount, _userName);
    }

    function getAccountByAddress(address _user)
        public view returns (string)
    {
        return users[_user].userAccount;
    }

    function getAddressByAccount(string _user)
        public view returns (address)
    {
        return accounts[_user];
    }

    function getNameByAddress(address _user)
        public view returns (string)
    {
        return users[_user].userName;
    }

    function exists(address _user)
        public view returns (bool)
    {
        return users[_user].exists;
    }

    function accountExists(string _user)
        public view returns (bool)
    {
        if (accounts[_user] == address(0)) {
            return false;
        } else {
            return true;
        }
    }

    event Register(address _userAddress, string _userAccount, string _userName);
}
