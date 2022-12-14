pragma solidity ^0.4.15;





library SafeMath {
    function add(uint a, uint b) internal returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}





contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}





contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}





contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}






contract ReapToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public tokensBurnt;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    event Burn(uint tokens);

    function ReapToken() public {
        symbol = "REAP";
        name = "Reap Token";
        decimals = 18;
        _totalSupply = 50000000 * 10**uint(decimals);
        tokensBurnt = 0;
        balances[owner] = _totalSupply;
        Transfer(address(0), owner, _totalSupply);
    }

    
    
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply - tokensBurnt;
    }

    
    
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }

    function burn(uint tokens) onlyOwner public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        tokensBurnt = tokensBurnt.add(tokens);
        Burn(tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    
    
    
    function () public payable {
        revert();
    }

    
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}