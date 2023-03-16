// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract ERC20 {
    
    uint256 internal _totalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowances;

    constructor() {
        _totalSupply = type(uint256).max;
        balances[msg.sender] = type(uint256).max;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function name() public pure returns (string memory) {
        return "Example Token";
    }

    function symbol() public pure returns (string memory) {
        return "ETK";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        allowances[owner][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address from = msg.sender;
        
        balances[from] -= amount;
        balances[to] += amount;

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = msg.sender;
        //require(allowances[from][spender] >= amount, "ERC20: insufficient allowance");

        allowances[from][spender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

        return true;
    }
}