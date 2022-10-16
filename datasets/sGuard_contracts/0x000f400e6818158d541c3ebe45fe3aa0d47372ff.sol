pragma solidity 0.5.16;


contract ArbitraryCaller {
    function sendCall(
        address target,
        bytes calldata callData)
        external
        payable
    {
        (bool success,) = target.call.value(msg.value)(callData);
        assembly {
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            if eq(success, 0) { revert(ptr, size) }
            return(ptr, size)
        }
    }
}