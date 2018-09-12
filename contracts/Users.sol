pragma solidity ^0.4.24;

contract Users {
    address public oracle = msg.sender;

    modifier onlyOracle() {
        require(msg.sender == oracle);
        _;
    }

    mapping (address => string) addressToName;
    mapping (address => string) addressToAccount;
    mapping (string => address) accountToAddress;

    function register(address _userAddress, string _userAccount, string _userName)
        external onlyOracle
    {
        require(bytes(addressToAccount[_userAddress]).length == 0);
        require(accountToAddress[_userAccount] == address(0));

        addressToAccount[_userAddress] = _userAccount;
        accountToAddress[_userAccount] = _userAddress;
        addressToName[_userAddress] = _userName;

        emit Register(_userAddress, _userAccount, _userName);
    }

    function getAccountByAddress(address _user)
        public view returns (string)
    {
        return addressToAccount[_user];
    }

    function getAddressByAccount(string _user)
        public view returns (address)
    {
        return accountToAddress[_user];
    }

    function getNameByAddress(address _user)
        public view returns (string)
    {
        return addressToName[_user];
    }

    function exists(address _user)
        public view returns (bool)
    {
        if (bytes(addressToAccount[_user]).length == 0) {
            return false;
        } else {
            return true;
        }
    }

    function accountExists(string _user)
        public view returns (bool)
    {
        if (accountToAddress[_user] == address(0)) {
            return false;
        } else {
            return true;
        }
    }

    event Register(address _userAddress, string _userAccount, string _userName);
}
