pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface TokenInterface {
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function approve(address, uint) external;
}

interface ListInterface {
    function accountID(address) external view returns (uint64);
}

interface AccountInterface {
    function auth(address) external view returns (bool);
    function cast(
        address[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) external payable;
}

interface IndexInterface {
    function build(
        address _owner,
        uint accountVersion,
        address _origin
    ) external returns (address _account);
    function buildWithCast(
        address _owner,
        uint accountVersion,
        address[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (address _account);
}

interface ManagerLike {
    function owns(uint) external view returns (address);
    function give(uint, address) external;
}


contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}

contract Helpers is DSMath {

    
    function getAddressETH() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; 
    }

    
    function getIndexAddress() internal pure returns (address) {
        return 0x2971AdFa57b20E5a416aE5a708A8655A9c74f723;
    }

    
    function getMcdManager() internal pure returns (address) {
        return 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    }

}

contract MigrateProxy is Helpers {

    event LogMigrate(address dsa, address[] tokens, address[] ctokens, uint[] vaults);

    function migrateVaults(address dsa, uint[] memory vaults) private {
        ManagerLike managerContract = ManagerLike(getMcdManager());
        for (uint i = 0; i < vaults.length; i++) managerContract.give(vaults[i], dsa);
    }

    function migrateAllowances(address dsa, address[] memory tokens) private {
        for (uint i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            TokenInterface tokenContract = TokenInterface(token);
            uint tokenAmt = tokenContract.balanceOf(address(this));
            if (tokenAmt > 0) tokenContract.approve(dsa, tokenAmt);
        }
    }

    function migrateTokens(address dsa, address[] memory tokens) private {
        for (uint i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            TokenInterface tokenContract = TokenInterface(token);
            uint tokenAmt = tokenContract.balanceOf(address(this));
            if (tokenAmt > 0) tokenContract.transfer(dsa, tokenAmt);
        }
    }

    struct MigrateData {
        uint[] vaults;
        address[] tokens;
        address[] ctokens;
    }


    function migrate(
        address auth,
        address[] calldata targets,
        bytes[] calldata calldatas,
        MigrateData calldata migrateData
    ) external payable {
        uint _len = migrateData.ctokens.length;
        address _dsa;
        if (_len > 0) {
            address[] memory _target = new address[](1);
            _target[0] = auth;
            bytes[] memory _callData = new bytes[](1);
            _callData[0] = abi.encodeWithSignature("add(address)", address(this));
            _dsa = IndexInterface(getIndexAddress()).buildWithCast(
                msg.sender,
                1,
                _target,
                _callData,
                address(0)
            );
            migrateAllowances(_dsa, migrateData.ctokens);
            AccountInterface(_dsa).cast.value(address(this).balance)(targets, calldatas, address(0));
        } else {
            _dsa = IndexInterface(getIndexAddress()).build(
                msg.sender,
                1,
                address(0)
            );
        }
        migrateVaults(_dsa, migrateData.vaults);
        migrateTokens(_dsa, migrateData.tokens);
    
        emit LogMigrate(_dsa, migrateData.tokens, migrateData.ctokens, migrateData.vaults);
    }
}