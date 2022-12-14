pragma solidity ^0.5.7;



interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    event Freeze(address indexed from, uint256 value);
    
    event Unfreeze(address indexed from, uint256 value);
}




library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;
    
    mapping (address => uint256) private _freezeOf;
    
    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }
    
    
    function freezeOf(address owner) public view returns (uint256) {
        return _freezeOf[owner];
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
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    
    function _mint(address account, uint256 value) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    
    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    
    function _freeze(uint256 value) internal {
        require(_balances[msg.sender]>=value); 
        require(value > 0);
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _freezeOf[msg.sender] = _freezeOf[msg.sender].add(value);
        emit Freeze(msg.sender, value);
    }
    
    function _unfreeze(uint256 value) internal{
        require(_freezeOf[msg.sender]>=value); 
		require(value > 0);
        _freezeOf[msg.sender] = _freezeOf[msg.sender].sub(value); 
		_balances[msg.sender] = _balances[msg.sender].add(value);
        emit Unfreeze(msg.sender, value);

    }
    
    
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}



contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account));

        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account));

        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}




contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    
    modifier whenPaused() {
        require(_paused);
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}


contract Lockable is PauserRole{
    

    mapping (address => bool) private lockers;
    

    event LockAccount(address account, bool islock);
    
    
    
    function isLock(address account) public view returns (bool) {
        return lockers[account];
    }
    
    
    function lock(address account, bool islock)  public onlyPauser {
        lockers[account] = islock;
        emit LockAccount(account, islock);
    }
    
}





contract ERC20Pausable is ERC20, Pausable,Lockable {
    
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        require(!isLock(msg.sender));
        require(!isLock(to));
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        require(!isLock(msg.sender));
        require(!isLock(from));
        require(!isLock(to));
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        require(!isLock(msg.sender));
        require(!isLock(spender));
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool) {
        require(!isLock(msg.sender));
        require(!isLock(spender));
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool) {
        require(!isLock(msg.sender));
        require(!isLock(spender));
        return super.decreaseAllowance(spender, subtractedValue);
    }
}


contract AGT is ERC20, ERC20Detailed, ERC20Pausable {
    
    constructor(string memory name, string memory symbol, uint8 decimals,uint256 _totalSupply) ERC20Pausable()  ERC20Detailed(name, symbol, decimals) ERC20() public {
        require(_totalSupply > 0);
        _mint(msg.sender, _totalSupply);
    }
    
    
    function burn(uint256 value) public whenNotPaused {
        require(!isLock(msg.sender));
        _burn(msg.sender, value);
    }
    
    
    function freeze(uint256 value) public whenNotPaused {
        require(!isLock(msg.sender));
        _freeze(value);
    }
    
        
    function unfreeze(uint256 value) public whenNotPaused {
        require(!isLock(msg.sender));
        _unfreeze(value);
    }
    
}