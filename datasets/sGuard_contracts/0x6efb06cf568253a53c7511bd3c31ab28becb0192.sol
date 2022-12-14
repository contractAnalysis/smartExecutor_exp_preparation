pragma solidity ^0.5.0;





contract NiftyBuilderMaster {
    
    
    
    modifier onlyOwner() {
      require((msg.sender) == contractOwner);
      _;
    }
    
    
    
    
    
    uint public numNiftiesCurrentlyInContract;
    
    
    uint public contractId;
    
    address public contractOwner;
    address public tokenTransferProxy;
    
    
    uint topLevelMultiplier = 100000000;
    uint midLevelMultiplier = 10000;
    
    
    
    
    mapping (address => bool) public ERC20sApproved;
    mapping (address => uint) public ERC20sDec;
    
    

    constructor() public { 
    }
    
    function changeTokenTransferProxy(address newTokenTransferProxy) onlyOwner public {
        tokenTransferProxy = newTokenTransferProxy;
    }
    
    function changeOwnerKey(address newOwner) onlyOwner public {
        contractOwner = newOwner;
    }
    
    
    
    function getContractId(uint tokenId) public view returns (uint) {
        return (uint(tokenId/topLevelMultiplier));
    }
    
    function getNiftyTypeId(uint tokenId) public view returns (uint) {
        uint top_level = getContractId(tokenId);
        return uint((tokenId-(topLevelMultiplier*top_level))/midLevelMultiplier);
    }
    
    function getSpecificNiftyNum(uint tokenId) public view returns (uint) {
         uint top_level = getContractId(tokenId);
         uint mid_level = getNiftyTypeId(tokenId);
         return uint(tokenId - (topLevelMultiplier*top_level) - (mid_level*midLevelMultiplier));
    }
    
    function encodeTokenId(uint contractIdCalc, uint niftyType, uint specificNiftyNum) public view returns (uint) {
        return ((contractIdCalc * topLevelMultiplier) + (niftyType * midLevelMultiplier) + specificNiftyNum);
    }
    
      
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) public view returns (string memory) {
      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      bytes memory _bc = bytes(_c);
      bytes memory _bd = bytes(_d);
      bytes memory _be = bytes(_e);
      string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
      for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
      for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
      for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
      for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
      return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) public view returns (string memory) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) public view returns (string memory) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) public view returns (string memory) {
        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint _i) public pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

}