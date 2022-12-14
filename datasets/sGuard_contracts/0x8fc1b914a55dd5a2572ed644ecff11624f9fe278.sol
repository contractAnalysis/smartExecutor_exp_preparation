pragma solidity 0.4.25;



interface IRedButton {
        function isEnabled() external view returns (bool);
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




contract RedButton is IRedButton, Claimable {
    string public constant VERSION = "1.0.0";

    bool public enabled;

    event RedButtonEnabledSaved(bool _enabled);

        function isEnabled() external view returns (bool) {
        return enabled;
    }

        function setEnabled(bool _enabled) external onlyOwner {
        enabled = _enabled;
        emit RedButtonEnabledSaved(_enabled);
    }
}