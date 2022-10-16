pragma solidity 0.5.12;


contract DSPauseAbstract {
    function delay() public view returns (uint256);
    function plot(address, bytes32, bytes memory, uint256) public;
    function exec(address, bytes32, bytes memory, uint256) public returns (bytes memory);
}


contract PotAbstract {
    function drip() external returns (uint256);
}


contract JugAbstract {
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function drip(bytes32) external returns (uint256);
}


contract VatAbstract {
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
}

contract SaiMomLike {
    function setCap(uint256) external;
    function setFee(uint256) external;
}

contract SpellAction {
    
    
    string  constant public description = "04/03/2020 MakerDAO Executive Spell";

    
    
    
    
    
    
    address constant public MCD_VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address constant public MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant public MCD_POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;

    
    
    
    
    
    
    uint256 constant public TWELVE_PCT_RATE = 1000000003593629043335673582;

    uint256 constant public RAD = 10**45;
    uint256 constant public MILLION = 10**6;

    function execute() external {

        
        PotAbstract(MCD_POT).drip();
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");
        JugAbstract(MCD_JUG).drip("USDC-A");

        

        
        
        
        
        
        
        
        
        uint256 USDC_FEE = TWELVE_PCT_RATE;
        JugAbstract(MCD_JUG).file("USDC-A", "duty", USDC_FEE);

        
        
        
        
        
        
        
        
        uint256 SAI_LINE = 0;
        VatAbstract(MCD_VAT).file("SAI", "line", SAI_LINE);

        
        
        
        
        
        
        
        
        
        
        uint256 GLOBAL_AMOUNT = 113 * MILLION;
        VatAbstract(MCD_VAT).file("Line", GLOBAL_AMOUNT * RAD);
    }
}

contract DssSpell {

    DSPauseAbstract  public pause =
        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    uint256          public expiration;
    bool             public done;

    uint256 constant internal MILLION = 10**6;

    address constant public SAIMOM = 0xF2C5369cFFb8Ea6284452b0326e326DbFdCb867C;
    uint256 constant SCD_EIGHT_PCT_FEE = 1000000002440418608258400030;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);

        
        

        
        
        
        
        
        
        SaiMomLike(SAIMOM).setFee(SCD_EIGHT_PCT_FEE);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}