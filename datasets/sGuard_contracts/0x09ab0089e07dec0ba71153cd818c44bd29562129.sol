pragma solidity ^0.4.25;




library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract Token {

    
    function totalSupply() public constant returns (uint256 supply) {}

    
    
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferrealestate(address _to, uint256 _value, bytes data) returns (bool success) {}
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success) {}

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TransferRealEstate(address indexed _from, address indexed _to, uint256 _value, bytes data);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}






contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

contract StandardToken is Token {
    using SafeMath for uint;
    function transfer(address _to, uint256 _value) returns (bool success) {
        
        
        
        
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    
    function transferrealestate(address _to, uint256 _value, bytes data) returns (bool success) {
        
        
        
        
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    
    
   
   
   
   
  
  function transferForMultiAddresses(address[] _addresses, uint256[] _amounts) public returns (bool) {
    for (uint256 i = 0; i < _addresses.length; i++) {
      require(_addresses[i] != address(0));
      require(_amounts[i] <= balances[msg.sender]);
      require(_amounts[i] > 0);
      
      balances[msg.sender] = balances[msg.sender].sub(_amounts[i]);
      balances[_addresses[i]] = balances[_addresses[i]].add(_amounts[i]);
      Transfer(msg.sender, _addresses[i], _amounts[i]);
    }
    return true;
  }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}



contract MEYToken is StandardToken {

   function () public payable {
        revert();
    }

    

    
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       

    
    function MEYToken() {
        name = "MEY V2.2 - REAL ESTATE ECOSYSTEM";        
        decimals = 18;                     
        symbol = "MEY";                   
        balances[msg.sender] = 2300000000 * (10 ** uint256(decimals));      
		totalSupply = 2300000000 * (10 ** uint256(decimals));               
    }
    
    
    
    
    
    
}