pragma solidity ^0.5.0;


contract Proxy {
  
  function () payable external {
    _fallback();
  }

  
  function _implementation() internal view returns (address);

  
  function _delegate(address implementation) internal {
    assembly {
      
      
      
      calldatacopy(0, 0, calldatasize)

      
      
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      
      returndatacopy(0, 0, returndatasize)

      switch result
      
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  
  function _willFallback() internal {
  }

  
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}



contract UpgradeabilityProxy is Proxy {
  
  event Upgraded(address implementation);

  
  bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  
  constructor(address _implementation) public payable {
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));

    _setImplementation(_implementation);
  }

  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
 
  
  function _implementation() internal view returns (address impl) {
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  
  function _setImplementation(address newImplementation) private {
    require(isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}



contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
  
  event AdminChanged(address previousAdmin, address newAdmin);

  
  bytes32 private constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  
  modifier ifAdmin() {
    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  
  constructor(address _implementation) UpgradeabilityProxy(_implementation) public {
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));

    _setAdmin(msg.sender);
  }

  
  function admin() external ifAdmin returns (address) {
    return _admin();
  }

  
  function implementation() external ifAdmin returns (address) {
    return _implementation();
  }

  
  function changeAdmin(address newAdmin) external ifAdmin {
    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  
  function upgradeTo(address newImplementation) external ifAdmin {
    _upgradeTo(newImplementation);
  }

  
  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  
  function _setAdmin(address newAdmin) internal {
    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  
  function _willFallback() internal {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}


contract ContractGateway is AdminUpgradeabilityProxy {
  constructor(address _implementation) public AdminUpgradeabilityProxy(_implementation) {
  }
}