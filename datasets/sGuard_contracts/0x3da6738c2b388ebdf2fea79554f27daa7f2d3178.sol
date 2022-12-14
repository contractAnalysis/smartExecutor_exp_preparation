pragma solidity ^0.5.0;

contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address payable msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.5.0;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.5.0;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        
        
        
        
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        
        require(_notEntered, "ReentrancyGuard: reentrant call");

        
        _notEntered = false;

        _;

        
        
        _notEntered = true;
    }
}



pragma solidity ^0.5.0;







interface UniSwap_Zap_Contract{
    function LetsInvest() external payable;
}









contract ServiceProvider_UniSwap_Zap is Ownable, ReentrancyGuard {
    using SafeMath for uint;

    UniSwap_Zap_Contract public UniSwap_Zap_ContractAddress;
    IERC20 public DAI_TokenContractAddress;
    IERC20 public UniSwapDAIExchangeContractAddress;
    
    address internal ServiceProviderAddress;

    uint public balance = address(this).balance;
    uint private TotalServiceChargeTokens;
    uint private serviceChargeInBasisPoints = 0;
    
    event TransferredToUser_liquidityTokens_residualDAI(uint, uint);
    event ServiceChargeTokensTransferred(uint);

    constructor (
        UniSwap_Zap_Contract _UniSwap_Zap_ContractAddress, 
        IERC20 _DAI_TokenContractAddress, 
        IERC20 _UniSwapDAIExchangeContractAddress, 
        address _ServiceProviderAddress) 
        public {
        UniSwap_Zap_ContractAddress = _UniSwap_Zap_ContractAddress;
        DAI_TokenContractAddress = _DAI_TokenContractAddress;
        UniSwapDAIExchangeContractAddress = _UniSwapDAIExchangeContractAddress;
        ServiceProviderAddress = _ServiceProviderAddress;
    }

     
    bool private stopped = false;

    
    modifier stopInEmergency {if (!stopped) _;}
    
    
    function toggleContractActive() public onlyOwner {
    stopped = !stopped;
    }

    
    
    function set_UniSwap_Zap_ContractAddress(UniSwap_Zap_Contract _new_UniSwap_Zap_ContractAddress) public onlyOwner  {
        UniSwap_Zap_ContractAddress = _new_UniSwap_Zap_ContractAddress;
    }
  
    
    function set_DAI_TokenContractAddress (IERC20 _new_DAI_TokenContractAddress) public onlyOwner {
        DAI_TokenContractAddress = _new_DAI_TokenContractAddress;
    }

    
    function set_UniSwapDAIExchangeContractAddress (IERC20 _new_UniSwapDAIExchangeContractAddress) public onlyOwner {
        UniSwapDAIExchangeContractAddress = _new_UniSwapDAIExchangeContractAddress;
    }

 
    
    function get_ServiceProviderAddress() public view onlyOwner returns (address) {
        return ServiceProviderAddress;
    }
    
    
    function set_ServiceProviderAddress (address _new_ServiceProviderAddress) public onlyOwner  {
        ServiceProviderAddress = _new_ServiceProviderAddress;
    }

    
    function get_serviceChargeRate () public view onlyOwner returns (uint) {
        return serviceChargeInBasisPoints;
    }
    
    
    function set_serviceChargeRate (uint _new_serviceChargeInBasisPoints) public onlyOwner {
        require (_new_serviceChargeInBasisPoints <= 10000, "Setting Service Charge more than 100%");
        serviceChargeInBasisPoints = _new_serviceChargeInBasisPoints;
    }


    function LetsInvest() public payable stopInEmergency nonReentrant returns (bool) {
        UniSwap_Zap_ContractAddress.LetsInvest.value(msg.value)();
        

        
        uint DAILiquidityTokens = UniSwapDAIExchangeContractAddress.balanceOf(address(this));
        uint residualDAIHoldings = DAI_TokenContractAddress.balanceOf(address(this));

        
        if (serviceChargeInBasisPoints > 0) {
            uint ServiceChargeTokens = SafeMath.div(SafeMath.mul(DAILiquidityTokens,serviceChargeInBasisPoints),10000);
            TotalServiceChargeTokens = TotalServiceChargeTokens + ServiceChargeTokens;
            uint UserLiquidityTokens = SafeMath.sub(DAILiquidityTokens,ServiceChargeTokens);
            require(UniSwapDAIExchangeContractAddress.transfer(msg.sender, UserLiquidityTokens), "Failure to send Liquidity Tokens to User");
            require(DAI_TokenContractAddress.transfer(msg.sender, residualDAIHoldings), "Failure to send residual DAI holdings");
            emit TransferredToUser_liquidityTokens_residualDAI(UserLiquidityTokens, residualDAIHoldings);
            return true;
        } else {
            require(UniSwapDAIExchangeContractAddress.transfer(msg.sender, DAILiquidityTokens), "Failure to send Liquidity Tokens to User");    
            require(DAI_TokenContractAddress.transfer(msg.sender, residualDAIHoldings), "Failure to send residual DAI holdings");
            emit TransferredToUser_liquidityTokens_residualDAI(DAILiquidityTokens, residualDAIHoldings);
            return true;
        }
        
        
        
        
    }


    
    function get_TotalServiceChargeTokens() public view onlyOwner returns (uint) {
        return TotalServiceChargeTokens;
    }
    
    
    function withdrawServiceChargeTokens(uint _amountInUnits) public onlyOwner {
        require(_amountInUnits <= TotalServiceChargeTokens, "You are asking for more than what you have earned");
        TotalServiceChargeTokens = SafeMath.sub(TotalServiceChargeTokens,_amountInUnits);
        require(UniSwapDAIExchangeContractAddress.transfer(ServiceProviderAddress, _amountInUnits), "Failure to send ServiceChargeTokens");
        emit ServiceChargeTokensTransferred(_amountInUnits);
    }


    
    function withdrawAnyOtherERC20Token(IERC20 _targetContractAddress) public onlyOwner {
        uint OtherTokenBalance = _targetContractAddress.balanceOf(address(this));
        _targetContractAddress.transfer(_owner, OtherTokenBalance);
    }
    

    
    function withdrawDAI() public onlyOwner {
        uint StuckDAIHoldings = DAI_TokenContractAddress.balanceOf(address(this));
        DAI_TokenContractAddress.transfer(_owner, StuckDAIHoldings);
    }
    
    function withdrawDAILiquityTokens() public onlyOwner {
        uint StuckDAILiquityTokens = UniSwapDAIExchangeContractAddress.balanceOf(address(this));
        UniSwapDAIExchangeContractAddress.transfer(_owner, StuckDAILiquityTokens);
    }

    
    
    
    
    function depositETH() public payable onlyOwner {
        balance += msg.value;
    }
    
    
    function() external payable {
        if (msg.sender == _owner) {
            depositETH();
        } else {
            LetsInvest();
        }
    }
    
    
    function withdraw() public onlyOwner {
        _owner.transfer(address(this).balance);
    }


}