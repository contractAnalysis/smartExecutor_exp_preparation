pragma solidity ^0.6.0;



interface AccountInterface {
    function enable(address) external;
    function disable(address) external;
}

interface EventInterface {
    function emitEvent(uint _connectorType, uint _connectorID, bytes32 _eventCode, bytes calldata _eventData) external;
}


contract Basics {

    
    function getEventAddr() public pure returns (address) {
        return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97;
    }

     
    function connectorID() public pure returns(uint _type, uint _id) {
        (_type, _id) = (1, 10);
    }

}


contract Auth is Basics {

    event LogAddAuth(address indexed _msgSender, address indexed _authority);
    event LogRemoveAuth(address indexed _msgSender, address indexed _authority);

    
    function add(address authority) public payable {
        AccountInterface(address(this)).enable(authority);

        emit LogAddAuth(msg.sender, authority);

        bytes32 _eventCode = keccak256("LogAddAuth(address,address)");
        bytes memory _eventParam = abi.encode(msg.sender, authority);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    
    function remove(address authority) public payable {
        AccountInterface(address(this)).disable(authority);

        emit LogRemoveAuth(msg.sender, authority);

        bytes32 _eventCode = keccak256("LogRemoveAuth(address,address)");
        bytes memory _eventParam = abi.encode(msg.sender, authority);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

}


contract ConnectAuth is Auth {
    string public constant name = "Auth-v1";
}