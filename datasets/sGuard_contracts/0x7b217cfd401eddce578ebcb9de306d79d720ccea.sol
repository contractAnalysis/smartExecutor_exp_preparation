pragma solidity ^0.4.25;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;
  
  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

      constructor() public
    {
       owner = msg.sender;
     
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


    function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Token {

    
    function totalSupply() constant returns (uint256 supply) {}

    
    
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success) {}

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success) {}

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event setNewBlockEvent(string SecretKey_Pre, string Name_New, string TxHash_Pre, string DigestCode_New, string Image_New, string Note_New);
}

contract StandardToken is Token {

    address public note_contract;
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        
        
        
        
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract StockMintToken is StandardToken, Ownable {
  event StockMint(address indexed to, uint256 amount);
  event Burn(address indexed burner, uint256 value);
  event MintFinished();
  using SafeMath for uint256;
  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }
  
    function stockmint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit StockMint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

    function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
  
      function burn(uint256 _value) 
    public 
    {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
}

contract RepaymentToken is StandardToken, Ownable {
  event Repayment(address indexed _debit_contract, uint256 amount);
  using SafeMath for uint256;
  
  modifier hasRepaymentPermission() {
    require(msg.sender == note_contract);
    _;
  }
  
  
  function repayment(
    uint256 _amount
  )
    public
    hasRepaymentPermission
    returns (bool)
  {
    totalSupply = totalSupply.add(_amount);
    balances[owner] = balances[owner].add(_amount);
    emit Repayment(msg.sender, _amount);
    emit Paidto(owner, _amount);
    return true;
  }

  event Paidto(address indexed _to_creditor, uint256 _value);
    
}

contract CreditableToken is StandardToken, Ownable {
    using SafeMath for uint256;
    event Credit(address indexed _debit_contract, uint256 value);

    function credit(uint256 _value) 
    public
    {
        require(_value > 0);
        require(_value <= balances[owner]);
        require(msg.sender == note_contract);
        
        

        
        balances[owner] = balances[owner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Credit(msg.sender, _value);
        emit Drawdown(owner, _value);
    }
    
    event Drawdown(address indexed _from_creditor, uint256 _value);
}


contract MaskAdult is CreditableToken, RepaymentToken, StockMintToken {

    constructor() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    function connectContract(address _note_address ) public onlyOwner {
        note_contract = _note_address;
    }
    
        string public name = "MaskAdult";
    string public symbol = "MaskA";
    uint public constant decimals = 4;
    uint256 public constant INITIAL_SUPPLY = 1000000 * (10 ** uint256(decimals));
    string public Image_root = "https://swarm.chainbacon.com/bzz:/cc314da006df78e3256c8c697904ea1b6e13d80c0a21aacae7439be0a4c36121/";
    string public Note_root = "https://swarm.chainbacon.com/bzz:/53f2a5e941c4eaf6c7da5a2d2135ec7b60a032e97fd2b0989a2038a46e4fa373/";
    string public Document_root = "none";
    string public DigestCode_root = "8f9aa946b66acafc92f76088914f9bd687a961af6929b5e1df2ce52671d86a56";
    function getIssuer() public pure returns(string) { return  "TokenBacon"; }
    function getTrustee() public pure returns(string) { return  "EMask"; }
    string public TxHash_root = "genesis";

    string public ContractSource = "";
    string public CodeVersion = "v0.1";
    
    string public SecretKey_Pre = "";
    string public Name_New = "";
    string public TxHash_Pre = "";
    string public DigestCode_New = "";
    string public Image_New = "";
    string public Note_New = "";
    string public Document_New = "";
    uint256 public CreditRate = 100 * (10 ** uint256(decimals));

    function getName() public view returns(string) { return name; }
    function getDigestCodeRoot() public view returns(string) { return DigestCode_root; }
    function getTxHashRoot() public view returns(string) { return TxHash_root; }
    function getImageRoot() public view returns(string) { return Image_root; }
    function getNoteRoot() public view returns(string) { return Note_root; }
    function getDocumentRoot() public view returns(string) { return Document_root; }
    function getCodeVersion() public view returns(string) { return CodeVersion; }
    function getContractSource() public view returns(string) { return ContractSource; }

    function getSecretKeyPre() public view returns(string) { return SecretKey_Pre; }
    function getNameNew() public view returns(string) { return Name_New; }
    function getTxHashPre() public view returns(string) { return TxHash_Pre; }
    function getDigestCodeNew() public view returns(string) { return DigestCode_New; }
    function getImageNew() public view returns(string) { return Image_New; }
    function getNoteNew() public view returns(string) { return Note_New; }
    function getDocumentNew() public view returns(string) { return Document_New; }
    function updateCreditRate(uint256 _rate) public onlyOwner returns (uint256) {
        CreditRate = _rate;
        return CreditRate;
    }

    function setNewBlock(string _SecretKey_Pre, string _Name_New, string _TxHash_Pre, string _DigestCode_New, string _Image_New, string _Note_New )  returns (bool success) {
        SecretKey_Pre = _SecretKey_Pre;
        Name_New = _Name_New;
        TxHash_Pre = _TxHash_Pre;
        DigestCode_New = _DigestCode_New;
        Image_New = _Image_New;
        Note_New = _Note_New;
        emit setNewBlockEvent(SecretKey_Pre, Name_New, TxHash_Pre, DigestCode_New, Image_New, Note_New);
        return true;
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}