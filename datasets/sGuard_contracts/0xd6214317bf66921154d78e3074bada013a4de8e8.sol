pragma solidity ^0.5.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns (uint);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface Controller {
    function vaults(address) external view returns (address);
}

interface MStable {
    function mint(address, uint) external;
    function redeem(address, uint) external;
}

interface mSavings {
    function depositSavings(uint) external;
    function creditBalances(address) external view returns (uint);
    function redeem(uint) external;
    function exchangeRate() external view returns (uint);
}



contract StrategyMStableSavingsTUSD {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0x0000000000085d4780B73119b644AE5ecd22b376);
    address constant public mUSD = address(0xe2f2a5C287993345a840Db3B0845fbC70f5935a5);
    address constant public mSave = address(0xcf3F73290803Fc04425BEE135a4Caeb2BaB2C2A1);

    address public governance;
    address public controller;
    
    constructor(address _controller) public {
        governance = msg.sender;
        controller = _controller;
    }
    
    function getName() external pure returns (string memory) {
        return "StrategyMStableSavingsTUSD";
    }
    
    function deposit() external {
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance > 0) {
            IERC20(want).safeApprove(address(mUSD), 0);
            IERC20(want).safeApprove(address(mUSD), _balance);
            MStable(mUSD).mint(want, _balance);
        }
        _balance = IERC20(mUSD).balanceOf(address(this));
        if (_balance > 0) {
            IERC20(mUSD).safeApprove(address(mSave), 0);
            IERC20(mUSD).safeApprove(address(mSave), _balance);
            mSavings(mSave).depositSavings(_balance);
        }
    }
    
    
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(address(_asset) != address(mUSD), "!musd");
        require(address(_asset) != address(want), "!want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        if (_amount > 0) {
            address _vault = Controller(controller).vaults(address(want));
            require(_vault != address(0), "!vault"); 
            IERC20(want).safeTransfer(_vault, _amount);
        }
        
    }
    
    
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();
        balance = IERC20(want).balanceOf(address(this));
        if (balance > 0) {
            address _vault = Controller(controller).vaults(address(want));
            require(_vault != address(0), "!vault"); 
            IERC20(want).safeTransfer(_vault, balance);
        }
        
    }
    
    function _withdrawAll() internal {
        uint _credit = mSavings(mSave).creditBalances(address(this));
        if (_credit > 0) {
            mSavings(mSave).redeem(_credit);
        }
        uint _balance = IERC20(mUSD).balanceOf(address(this));
        if (_balance > 0) {
            MStable(mUSD).redeem(want, _balance);
        }
    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        uint256 b = balanceSavings();
        uint256 bT = balanceSavingsInToken();
        require(bT >= _amount, "insufficient funds");
        
        uint256 amount = (b.mul(_amount).div(bT)).add(1);
        uint _before = IERC20(mUSD).balanceOf(address(this));
        _withdrawSavings(amount);
        uint _after = IERC20(mUSD).balanceOf(address(this));
        uint _wBefore = IERC20(want).balanceOf(address(this));
        MStable(mUSD).redeem(want, _after.sub(_before));
        uint _wAfter = IERC20(want).balanceOf(address(this));
        return _wAfter.sub(_wBefore);
    }
    
    function balanceOf() public view returns (uint) {
        return IERC20(want).balanceOf(address(this))
                .add(IERC20(mUSD).balanceOf(address(this)))
                .add(balanceSavingsInToken());
    }
    
    function _withdrawSavings(uint amount) internal {
        mSavings(mSave).redeem(amount);
    }
    
    function balanceSavingsInToken() public view returns (uint256) {
        
        uint256 b = balanceSavings();
        if (b > 0) {
            b = b.mul(mSavings(mSave).exchangeRate()).div(1e18);
        }
        return b;
    }
    
    function balanceSavings() public view returns (uint256) {
        return mSavings(mSave).creditBalances(address(this));
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}