pragma solidity 0.5.16;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}





pragma solidity 0.5.16;


contract DedgeGeneralManager {
    function () external payable {}

    constructor() public {}

    function transferETH(address recipient, uint amount) public {
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "gen-mgr-transfer-eth-failed");
    }

    function transferERC20(address recipient, address erc20Address, uint amount) public {
        require(
            IERC20(erc20Address).transfer(recipient, amount),
            "gen-mgr-transferperc20-failed"
        );
    }
}