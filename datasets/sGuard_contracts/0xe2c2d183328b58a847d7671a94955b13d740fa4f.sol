pragma solidity ^0.5.17;


 
contract Vault {
    
    ERC20 constant VSO = ERC20(0x456AE45c0CE901E2e7c99c0718031cEc0A7A59Ff);
    ERC20 constant liquidityToken = ERC20(0x8d7c9Fa808151D8A0Cc6B11E8f15CED337586c54);
    
    address owner = 0x6e92Da3B81201Da47a01c4FA004E7d058cF64460;
    uint256 public VaultCreation = now;
    uint256 public lastWithdrawal;
    
    uint256 public migrationLock;
    address public migrationRecipient;

    event liquidityMigrationStarted(address recipient, uint256 unlockTime);
    
    
    
    function withdrawLiquidity(address recipient, uint256 amount) external {
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        require(amount < (2 * liquidityBalance / 100)); 
        require(lastWithdrawal + 48 hours < now); 
        require(msg.sender == owner);
        
        liquidityToken.transfer(recipient, amount);
        lastWithdrawal = now;
    } 
    
    
    
    function startLiquidityMigration(address recipient) external {
        require(msg.sender == owner);
        migrationLock = now + 30 days;
        migrationRecipient = recipient;
        emit liquidityMigrationStarted(recipient, migrationLock);
    }
    
    
    
    function processMigration() external {
        require(msg.sender == owner);
        require(migrationRecipient != address(0));
        require(now > migrationLock);
        
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(migrationRecipient, liquidityBalance);
    }
    
    
    
    function withdrawVSO(address recipient, uint256 amount) external {
        require(msg.sender == owner);
        require(now > VaultCreation + 120 days);
        VSO.transfer(recipient, amount);
    } 
    
}





interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}