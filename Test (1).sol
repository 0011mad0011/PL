// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Privacy {
    string public constant name = "Privacy";
    string public constant symbol = "PRIV";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 30 * 10**9 * 10**decimals;
    address public rewardAddress = 0x9A1eee9eB775021ff120d87D9530D379c96C9326;
    uint256 public constant buyLimit = totalSupply / 100;
    uint256 public constant sellLimit = totalSupply / 100;
    mapping (address => uint256) private balances;
    mapping (address => bool) private fullyHeld;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid recipient address");
        require(_value <= balances[msg.sender], "Insufficient balance");
        
        if (fullyHeld[msg.sender]) {
            balances[_to] = balances[_to] + _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function buy() public payable {
        require(msg.value == 0, "Ether not accepted");
        require(balances[msg.sender] + buyLimit <= totalSupply / 100, "Buy limit exceeded");
        balances[msg.sender] = balances[msg.sender] + buyLimit;
        balances[rewardAddress] = balances[rewardAddress] + buyLimit / 50;
        emit Transfer(address(0), msg.sender, buyLimit);
        emit Transfer(address(0), rewardAddress, buyLimit / 50);
    }
    
    function sell(uint256 _value) public {
        require(_value > 0, "Invalid amount to sell");
        require(_value <= balances[msg.sender], "Insufficient balance to sell");
        require(balances[msg.sender] - _value + sellLimit >= totalSupply / 100, "Sell limit exceeded");
        
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[rewardAddress] = balances[rewardAddress] + _value / 50;
        payable(msg.sender).transfer(_value / 1000000000000000000);
        emit Transfer(msg.sender, address(0), _value);
        emit Transfer(msg.sender, rewardAddress, _value / 50);
    }
    
    function fullyHold() public {
        require(!fullyHeld[msg.sender], "Already fully holding");
        require(balances[msg.sender] >= totalSupply, "Insufficient balance to fully hold");
        fullyHeld[msg.sender] = true;
    }
    
    function unhold() public {
        require(fullyHeld[msg.sender], "Not fully holding");
        fullyHeld[msg.sender] = false;
    }
}