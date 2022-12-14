pragma solidity 0.4.25;


contract IERC20 {
    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath mul error");

    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    require(b > 0, "SafeMath div error");
    uint256 c = a / b;
    

    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath sub error");
    uint256 c = a - b;

    return c;
  }

  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath add error");

    return c;
  }

  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath mod error");
    return a % b;
  }
}


contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    
    function _transfer(address from, address to, uint256 value) internal {
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

contract Tcbcoin is ERC20 {
  using SafeMath for uint;

  string public constant name = 'Tcbcoin';
  string public constant symbol = 'TCFX';
  uint8 public constant decimals = 18;
  uint public totalSupply = (100 * 1e6) * (10 ** uint(decimals));
  uint public releaseAmountEveryYear = (1 * 1e6) * (10 ** uint(decimals));
  uint8 releaseCounter = 0;
  uint lastRelease = now + 156 weeks;
  address admin;

  constructor() public {
    uint intAmount = (90 * 1e6) * (10 ** uint(decimals));
    _balances[msg.sender] = intAmount;
    emit Transfer(address(0x0), msg.sender, intAmount);
    admin = msg.sender;
  }

  function unLock() public {
    require(now > lastRelease, 'Need more time');
    require(releaseCounter < 10, 'No more token to release');
    releaseCounter++;
    lastRelease = now + 52 weeks;
    _balances[admin] = _balances[admin].add(releaseAmountEveryYear);
  }

  function burn(uint _amount) public {
    require(_balances[msg.sender] >= _amount, 'Balance insufficient!!!');
    _balances[msg.sender] = _balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    emit Transfer(msg.sender, address(0x0), _amount);
  }
}