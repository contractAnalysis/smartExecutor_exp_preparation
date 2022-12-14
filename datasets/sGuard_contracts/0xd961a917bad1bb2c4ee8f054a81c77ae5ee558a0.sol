pragma solidity 0.4.25;



interface IWalletsTradingLimiter {
        function updateWallet(address _wallet, uint256 _value) external;
}



interface IWalletsTradingDataSource {
        function updateWallet(address _wallet, uint256 _value, uint256 _limit) external;
}



interface IWalletsTradingLimiterValueConverter {
        function toLimiterValue(uint256 _sgaAmount) external view returns (uint256);
}



interface ITradingClasses {
        function getInfo(uint256 _id) external view returns (uint256, uint256, uint256);

        function getActionRole(uint256 _id) external view returns (uint256);

        function getSellLimit(uint256 _id) external view returns (uint256);

        function getBuyLimit(uint256 _id) external view returns (uint256);
}



interface IContractAddressLocator {
        function getContractAddress(bytes32 _identifier) external view returns (address);

        function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);
}



contract ContractAddressLocatorHolder {
    bytes32 internal constant _IAuthorizationDataSource_ = "IAuthorizationDataSource";
    bytes32 internal constant _ISGNConversionManager_    = "ISGNConversionManager"      ;
    bytes32 internal constant _IModelDataSource_         = "IModelDataSource"        ;
    bytes32 internal constant _IPaymentHandler_          = "IPaymentHandler"            ;
    bytes32 internal constant _IPaymentManager_          = "IPaymentManager"            ;
    bytes32 internal constant _IPaymentQueue_            = "IPaymentQueue"              ;
    bytes32 internal constant _IReconciliationAdjuster_  = "IReconciliationAdjuster"      ;
    bytes32 internal constant _IIntervalIterator_        = "IIntervalIterator"       ;
    bytes32 internal constant _IMintHandler_             = "IMintHandler"            ;
    bytes32 internal constant _IMintListener_            = "IMintListener"           ;
    bytes32 internal constant _IMintManager_             = "IMintManager"            ;
    bytes32 internal constant _IPriceBandCalculator_     = "IPriceBandCalculator"       ;
    bytes32 internal constant _IModelCalculator_         = "IModelCalculator"        ;
    bytes32 internal constant _IRedButton_               = "IRedButton"              ;
    bytes32 internal constant _IReserveManager_          = "IReserveManager"         ;
    bytes32 internal constant _ISagaExchanger_           = "ISagaExchanger"          ;
    bytes32 internal constant _IMonetaryModel_               = "IMonetaryModel"              ;
    bytes32 internal constant _IMonetaryModelState_          = "IMonetaryModelState"         ;
    bytes32 internal constant _ISGAAuthorizationManager_ = "ISGAAuthorizationManager";
    bytes32 internal constant _ISGAToken_                = "ISGAToken"               ;
    bytes32 internal constant _ISGATokenManager_         = "ISGATokenManager"        ;
    bytes32 internal constant _ISGNAuthorizationManager_ = "ISGNAuthorizationManager";
    bytes32 internal constant _ISGNToken_                = "ISGNToken"               ;
    bytes32 internal constant _ISGNTokenManager_         = "ISGNTokenManager"        ;
    bytes32 internal constant _IMintingPointTimersManager_             = "IMintingPointTimersManager"            ;
    bytes32 internal constant _ITradingClasses_          = "ITradingClasses"         ;
    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = "IWalletsTLValueConverter"       ;
    bytes32 internal constant _BuyWalletsTradingDataSource_       = "BuyWalletsTradingDataSource"      ;
    bytes32 internal constant _SellWalletsTradingDataSource_       = "SellWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _BuyWalletsTradingLimiter_SGATokenManager_          = "BuyWalletsTLSGATokenManager"         ;
    bytes32 internal constant _SellWalletsTradingLimiter_SGATokenManager_          = "SellWalletsTLSGATokenManager"         ;
    bytes32 internal constant _IETHConverter_             = "IETHConverter"   ;
    bytes32 internal constant _ITransactionLimiter_      = "ITransactionLimiter"     ;
    bytes32 internal constant _ITransactionManager_      = "ITransactionManager"     ;
    bytes32 internal constant _IRateApprover_      = "IRateApprover"     ;

    IContractAddressLocator private contractAddressLocator;

        constructor(IContractAddressLocator _contractAddressLocator) internal {
        require(_contractAddressLocator != address(0), "locator is illegal");
        contractAddressLocator = _contractAddressLocator;
    }

        function getContractAddressLocator() external view returns (IContractAddressLocator) {
        return contractAddressLocator;
    }

        function getContractAddress(bytes32 _identifier) internal view returns (address) {
        return contractAddressLocator.getContractAddress(_identifier);
    }



        function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {
        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);
    }

        modifier only(bytes32 _identifier) {
        require(msg.sender == getContractAddress(_identifier), "caller is illegal");
        _;
    }

}



interface IAuthorizationDataSource {
        function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);

        function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256);

        function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256);


        function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);

        function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);
}



contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


    constructor() public {
    owner = msg.sender;
  }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

    function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

    function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

    function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}



contract Claimable is Ownable {
  address public pendingOwner;

    modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

    function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

    function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}




contract WalletsTradingLimiterBase is IWalletsTradingLimiter, ContractAddressLocatorHolder, Claimable {
    string public constant VERSION = "1.1.0";

    bytes32 public walletsTradingDataSourceIdentifier;

        constructor(IContractAddressLocator _contractAddressLocator, bytes32 _walletsTradingDataSourceIdentifier) ContractAddressLocatorHolder(_contractAddressLocator) public {
        walletsTradingDataSourceIdentifier = _walletsTradingDataSourceIdentifier;
    }

        function getAuthorizationDataSource() public view returns (IAuthorizationDataSource) {
        return IAuthorizationDataSource(getContractAddress(_IAuthorizationDataSource_));
    }

        function getTradingClasses() public view returns (ITradingClasses) {
        return ITradingClasses(getContractAddress(_ITradingClasses_));
    }

        function getWalletsTradingDataSource() public view returns (IWalletsTradingDataSource) {
        return IWalletsTradingDataSource(getContractAddress(walletsTradingDataSourceIdentifier));
    }

        function getWalletsTradingLimiterValueConverter() public view returns (IWalletsTradingLimiterValueConverter) {
        return IWalletsTradingLimiterValueConverter(getContractAddress(_IWalletsTradingLimiterValueConverter_));
    }

        function getUpdateWalletPermittedContractLocatorIdentifier() public pure returns (bytes32);

        function getOverrideTradeLimitAndClass(address _wallet) public view returns (uint256, uint256);

        function getTradeLimit(uint256 _tradeClassId) public view returns (uint256);

        function getLimiterValue(uint256 _value) public view returns (uint256);


        function updateWallet(address _wallet, uint256 _value) external only(getUpdateWalletPermittedContractLocatorIdentifier()) {
        uint256 limiterValue = getLimiterValue(_value);

        (uint256 overrideTradeLimit, uint256 tradeClassId) = getOverrideTradeLimitAndClass(_wallet);

        uint256 tradeLimit = overrideTradeLimit > 0 ? overrideTradeLimit : getTradeLimit(tradeClassId);

        getWalletsTradingDataSource().updateWallet(_wallet, limiterValue, tradeLimit);
    }
}



interface IMintManager {
        function getIndex() external view returns (uint256);
}



interface ISGNConversionManager {
        function sgn2sga(uint256 _amount, uint256 _index) external view returns (uint256);
}



library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
    
    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
  }
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




contract SGNWalletsTradingLimiter is WalletsTradingLimiterBase {
    string public constant VERSION = "1.1.0";

    using SafeMath for uint256;
    using Math for uint256;

        uint256 public constant MAX_RESOLUTION = 0x10000000000000000;

    uint256 public sequenceNum = 0;
    uint256 public sgnMinimumLimiterValueN = 0;
    uint256 public sgnMinimumLimiterValueD = 0;

    event SGNMinimumLimiterValueSaved(uint256 _sgnMinimumLimiterValueN, uint256 _sgnMinimumLimiterValueD);
    event SGNMinimumLimiterValueNotSaved(uint256 _sgnMinimumLimiterValueN, uint256 _sgnMinimumLimiterValueD);

        constructor(IContractAddressLocator _contractAddressLocator) WalletsTradingLimiterBase(_contractAddressLocator, _BuyWalletsTradingDataSource_) public {}

        function getSGNConversionManager() public view returns (ISGNConversionManager) {
        return ISGNConversionManager(getContractAddress(_ISGNConversionManager_));
    }

        function getMintManager() public view returns (IMintManager) {
        return IMintManager(getContractAddress(_IMintManager_));
    }

        function getLimiterValue(uint256 _value) public view returns (uint256){
        uint256 sgnMinimumLimiterValue = calcSGNMinimumLimiterValue(_value);
        uint256 sgnConversionValue = calcSGNConversionValue(_value);

        return sgnConversionValue.max(sgnMinimumLimiterValue);
    }

        function getUpdateWalletPermittedContractLocatorIdentifier() public pure returns (bytes32){
        return _ISGNTokenManager_;
    }

        function getOverrideTradeLimitAndClass(address _wallet) public view returns (uint256, uint256){
        return getAuthorizationDataSource().getBuyTradeLimitAndClass(_wallet);
    }

        function getTradeLimit(uint256 _tradeClassId) public view returns (uint256){
        return getTradingClasses().getBuyLimit(_tradeClassId);
    }

        function calcSGNMinimumLimiterValue(uint256 _sgnAmount) public view returns (uint256) {
        assert(sgnMinimumLimiterValueN > 0 && sgnMinimumLimiterValueD > 0);
        return _sgnAmount.mul(sgnMinimumLimiterValueN) / sgnMinimumLimiterValueD;
    }

        function setSGNMinimumLimiterValue(uint256 _sequenceNum, uint256 _sgnMinimumLimiterValueN, uint256 _sgnMinimumLimiterValueD) external onlyOwner {
        require(1 <= _sgnMinimumLimiterValueN && _sgnMinimumLimiterValueN <= MAX_RESOLUTION, "SGN minimum limiter value numerator is out of range");
        require(1 <= _sgnMinimumLimiterValueD && _sgnMinimumLimiterValueD <= MAX_RESOLUTION, "SGN minimum limiter value denominator is out of range");

        if (sequenceNum < _sequenceNum) {
            sequenceNum = _sequenceNum;
            sgnMinimumLimiterValueN = _sgnMinimumLimiterValueN;
            sgnMinimumLimiterValueD = _sgnMinimumLimiterValueD;
            emit SGNMinimumLimiterValueSaved(_sgnMinimumLimiterValueN, _sgnMinimumLimiterValueD);
        }
        else {
            emit SGNMinimumLimiterValueNotSaved(_sgnMinimumLimiterValueN, _sgnMinimumLimiterValueD);
        }
    }

        function calcSGNConversionValue(uint256 _sgnAmount) private view returns (uint256) {
        uint256 sgaAmount = getSGNConversionManager().sgn2sga(_sgnAmount, getMintManager().getIndex());
        return getWalletsTradingLimiterValueConverter().toLimiterValue(sgaAmount);
    }


}