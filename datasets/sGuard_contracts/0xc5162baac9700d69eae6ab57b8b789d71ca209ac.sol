pragma solidity >=0.4.26;

contract UniswapExchangeInterface {
    
    function tokenAddress() external view returns (address token);
    
    function factoryAddress() external view returns (address factory);
    
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    
    function setup(address token_addr) external;
}

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


interface KyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes hint) external payable returns(uint);

}


contract Trader{

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint  constant internal MAX_QTY   = (10**28); 
    KyberNetworkProxyInterface public proxy = KyberNetworkProxyInterface(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    address saiAddress = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359; 
    address daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address uniswapSai = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
    address uniswapDai = 0x2a1530C4C41db0B0b2bB646CB5Eb1A67b7158667;
    bytes  PERM_HINT = "PERM";
    address owner;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    constructor() public{
     owner = msg.sender;
    }

    function getUniswapToken(address uniswapContract) internal view returns (ERC20) {
        if (uniswapContract == uniswapSai) {
          return ERC20(saiAddress);
        }else if (uniswapContract == uniswapDai){
          return ERC20(daiAddress);
        }else{
            revert();
        }
    }
    
    function getUniswapContractAddress(address tokenAddress) internal view returns (address){
        if (tokenAddress == saiAddress) {
          return uniswapSai;
        }else if (tokenAddress == daiAddress){
          return uniswapDai;
        }else{
            revert();
        }
    }
    
   function swapEtherToToken1 (ERC20 token, uint ethAmt) internal returns (uint) {

     
     

     
     

       uint destAmount = proxy.tradeWithHint.value(ethAmt)(ETH_TOKEN_ADDRESS, ethAmt, token, this, MAX_QTY, 0, 0x0000000000000000000000000000000000000000, PERM_HINT);

       return destAmount;

    }

    function swapTokenToEther1 (ERC20 token, uint tokenQty) internal returns (uint) {

       
        

        
        

        
        

       

        
       token.approve(address(proxy), tokenQty);

       uint destAmount = proxy.tradeWithHint(token, tokenQty, ETH_TOKEN_ADDRESS, this, MAX_QTY, 0, 0x0000000000000000000000000000000000000004, PERM_HINT);

       return destAmount;
      
      
      
    }

      
     function kyberToUniSwapArb(address fromAddress, address uniSwapContract, uint theAmount) public payable onlyOwner returns (bool){

        address theAddress = uniSwapContract;
        UniswapExchangeInterface usi = UniswapExchangeInterface(theAddress);

        ERC20 address1 = ERC20(fromAddress);

        uint ethBack = swapTokenToEther1(address1 , theAmount);

        usi.ethToTokenSwapInput.value(ethBack)(1, block.timestamp);

        return true;
    }

     function u2kArb(address uniSwapContract, address tokenAddress, uint amountBN) public payable onlyOwner returns (bool){ 
        uint theAmount = amountBN * 1000000000;
        address theAddress = uniSwapContract;
        
        UniswapExchangeInterface usi = UniswapExchangeInterface(theAddress);
        ERC20 token = getUniswapToken(theAddress);
        token.approve(usi, theAmount);    
        
        uint ethBack = usi.tokenToEthSwapInput(theAmount, 1, block.timestamp);
        
        ERC20 address1 = ERC20(tokenAddress); 
        swapEtherToToken1 (address1, ethBack);

        return true;
    }
   
     function any2Arb(address fromAddress, address toAddress, int8 fromExch, int8 toExch, uint amountBN) public payable onlyOwner returns (bool){ 
        uint theAmount = amountBN * 1000000000;
        ERC20 token1 = ERC20(fromAddress);
        ERC20 token2 = ERC20(toAddress);
        uint ethBack = 0;
        
        if (fromExch == 2) {
             ethBack = swapTokenToEther1(token1 , theAmount);
        }else{
              UniswapExchangeInterface usi = UniswapExchangeInterface(getUniswapContractAddress(fromAddress));
              token1.approve(usi, theAmount); 
              ethBack = usi.tokenToEthSwapInput(theAmount, 1, block.timestamp);
        }
        
        if (ethBack > 1000){
            if (toExch == 2){
                swapEtherToToken1 (token2, ethBack);
            }else{
                UniswapExchangeInterface usi2 = UniswapExchangeInterface(getUniswapContractAddress(toAddress));
                usi2.ethToTokenSwapInput.value(ethBack)(1, block.timestamp);
            }
        }

        return true;
    }

    function () external payable  {

    }

    function withdrawETHAndTokens() public onlyOwner{
         
         msg.sender.transfer(address(this).balance);

         ERC20 daiToken = ERC20(daiAddress);
         uint256 currentDaiBalance = daiToken.balanceOf(this);
         daiToken.transfer(msg.sender, currentDaiBalance);

         ERC20 saiToken = ERC20(saiAddress);
         uint256 currentSaiBalance = saiToken.balanceOf(this);
         saiToken.transfer(msg.sender, currentSaiBalance);

    }

    function getTokenBalance (address tokenAddress) public view returns (uint256){
        ERC20 token = ERC20(tokenAddress);
        uint256 currentBalance = token.balanceOf(this);
        return currentBalance;
    }
    
     function getKyberExpectedRate(ERC20 token, uint256 amount) public view returns (uint256){
         uint minRate;
        (, minRate) = proxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, amount);
        return minRate;
        
    }


}