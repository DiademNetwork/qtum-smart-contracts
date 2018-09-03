pragma solidity ^0.4.24;

contract Users {
    address public oracle = msg.sender;

    modifier onlyOracle() {
        require(msg.sender == oracle);
        _;
    }

    mapping (address => string) public accounts;

    function register(address _userAddress, string _userAccount)
        external onlyOracle
    {
        accounts[_userAddress] = _userAccount;
    }

    function getAccountByAddress(address _user)
        public view returns(string)
    {
        return accounts[_user];
    }

    function exists(address _user)
        public view returns(bool)
    {
        if (bytes(accounts[_user]).length == 0) {
            return false;
        } else {
            return true;
        }
    }
}