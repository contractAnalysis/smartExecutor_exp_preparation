pragma solidity ^0.4.26;
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
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface OrFeedInterface {
  function getExchangeRate ( string fromSymbol, string toSymbol, string venue, uint256 amount ) external view returns ( uint256 );
  function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 );
  function getTokenAddress ( string symbol ) external view returns ( address );
  function getSynthBytes32 ( string symbol ) external view returns ( bytes32 );
  function getForexAddress ( string symbol ) external view returns ( address );
}

interface StockETFPrice{
    function getLastPrice (string symbol) constant returns (uint256);
    function getTimeUpdated (string symbol) constant returns (uint256);
}

interface Kyber {
    function getOutputAmount(ERC20 from, ERC20 to, uint256 amount) external view returns(uint256);

    function getInputAmount(ERC20 from, ERC20 to, uint256 amount) external view returns(uint256);
}


library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b > 0); 
        uint256 c = a / b;
        assert(a == b * c + a % b); 
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}






contract PremiumFeedPrices{
    
    mapping (address=>address) uniswapAddresses;
    mapping (string=>address) tokenAddress;
    
    
     constructor() public  {
         
         
        
         
         uniswapAddresses[0x6b175474e89094c44da98b954eedeac495271d0f] =  0x2a1530c4c41db0b0b2bb646cb5eb1a67b7158667;
         
         
         uniswapAddresses[0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359] = 0x09cabec1ead1c0ba254b09efb3ee13841712be14;
         
         
         uniswapAddresses[0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48] = 0x97dec872013f6b5fb443861090ad931542878126;
         
         
         
         uniswapAddresses[0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2] = 0x2c4bd064b998838076fa341a83d007fc2fa50957;
         
         
         uniswapAddresses[0x0d8775f648430679a709e98d2b0cb6250d2887ef] = 0x2e642b8d59b45a1d8c5aef716a84ff44ea665914;
         
         
         uniswapAddresses[0x514910771af9ca656af840dff83e8264ecf986ca] = 0xf173214c720f58e03e194085b1db28b50acdeead;
         
         
         uniswapAddresses[0xe41d2489571d322189246dafa5ebde1f4699f498] = 0xae76c84c9262cdb9abc0c2c8888e62db8e22a0bf;
     
          
         uniswapAddresses[0x2260fac5e5542a773aa44fbcfedf7c193bc2c599] = 0x4d2f5cfba55ae412221182d8475bc85799a5644b;
         
          
         uniswapAddresses[0xdd974d5c2e2928dea5f71b9825b8b646686bd200] =0x49c4f9bc14884f6210f28342ced592a633801a8b;
         
         
         
         
         
         
         
        
         tokenAddress['DAI'] = 0x6b175474e89094c44da98b954eedeac495271d0f;
         tokenAddress['SAI'] = 0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359;
        tokenAddress['USDC'] = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;
        tokenAddress['MKR'] = 0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2;
        tokenAddress['LINK'] = 0x514910771af9ca656af840dff83e8264ecf986ca;
        tokenAddress['BAT'] = 0x0d8775f648430679a709e98d2b0cb6250d2887ef;
        tokenAddress['WBTC'] = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599;
        tokenAddress['BTC'] = 0x2260fac5e5542a773aa44fbcfedf7c193bc2c599;
        tokenAddress['OMG'] = 0xd26114cd6EE289AccF82350c8d8487fedB8A0C07;
        tokenAddress['ZRX'] = 0xe41d2489571d322189246dafa5ebde1f4699f498;
        tokenAddress['TUSD'] = 0x0000000000085d4780B73119b644AE5ecd22b376;
        tokenAddress['ETH'] = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        tokenAddress['WETH'] = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2;
         tokenAddress['KNC'] = 0xdd974d5c2e2928dea5f71b9825b8b646686bd200;
        
     }
     
     function getExchangeRate(string fromSymbol, string toSymbol, string venue, uint256 amount, address requestAddress) public constant returns(uint256){
         
         address toA1 = tokenAddress[fromSymbol];
         address toA2 = tokenAddress[toSymbol];
         
         
         
         string memory theSide = determineSide(venue);
         string memory theExchange = determineExchange(venue);
         
         uint256 price = 0;
         string memory queryVenue = venue;
         string memory queryToSymbol = toSymbol;
         string memory queryFromSymbol = fromSymbol;
         
         if(equal(queryVenue,"PROVIDER1") && equal(queryToSymbol,"USD")){
             StockETFPrice stockProvider = StockETFPrice(0x7556fccfb056ada7aa10c6ed88b5def40d66c591);
             price = stockProvider.getLastPrice(queryFromSymbol);
         }
         
         else if(equal(theExchange,"UNISWAP")){
            price= uniswapPrice(toA1, toA2, theSide, amount);
         }
         
         else if(equal(theExchange,"KYBER")){
            price= kyberPrice(toA1, toA2, theSide, amount);
         }
         else{
             price=0;
         }
         
         
         return price;
     }
    
    function uniswapPrice(address token1, address token2, string  side, uint256 amount) public constant returns (uint256){
    
            address fromExchange = getUniswapContract(token1);
            address toExchange = getUniswapContract(token2);
            UniswapExchangeInterface usi1 = UniswapExchangeInterface(fromExchange);
            UniswapExchangeInterface usi2 = UniswapExchangeInterface(toExchange);    
        
            uint256  ethPrice1;
            uint256 ethPrice2;
            uint256 resultingTokens;
            uint256 ethBack;
            
        if(equal(side,"BUY")){
            
        
            if(token2 == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE){
                resultingTokens = usi1.getTokenToEthOutputPrice(amount);
                return resultingTokens;
            }
            if(token1 == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE){
                resultingTokens = usi2.getTokenToEthOutputPrice(amount);
                return resultingTokens;
            }
            
            
            ethBack = usi2.getTokenToEthOutputPrice(amount);
            resultingTokens = usi1.getEthToTokenOutputPrice(ethBack);
            
            
            
            

            
            
            return resultingTokens;
        }
        
        else{
            
             if(token2 == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE){
                resultingTokens = usi1.getEthToTokenOutputPrice(amount);
                return resultingTokens;
            }
            if(token1 == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE){
                resultingTokens = usi2.getEthToTokenInputPrice(amount);
                return resultingTokens;
            }
            
              ethBack = usi2.getTokenToEthOutputPrice(amount);
            resultingTokens = usi1.getTokenToEthInputPrice(ethBack);
            
            
            return resultingTokens;
        }
    
    }
    
    
    
     function kyberPrice(address token1, address token2, string  side, uint256 amount) public constant returns (uint256){
         
         Kyber kyber = Kyber(0xFd9304Db24009694c680885e6aa0166C639727D6);
         uint256 price;
           if(equal(side,"BUY")){
            price = kyber.getInputAmount(ERC20(token2), ERC20(token1), amount);
           }
           else{
                price = kyber.getOutputAmount(ERC20(token1), ERC20(token2), amount);
                 
                
           }
         
         return price;
     }
    
    
    
    function getUniswapContract(address tokenAddress) public constant returns (address){
        return uniswapAddresses[tokenAddress];
    }
    
    function determineSide(string sideString) public constant returns (string){
            
        if(contains("SELL", sideString ) == false){
            return "BUY";
        }
        
        else{
            return "SELL";
        }
    }
    
    
    
    function determineExchange(string exString) constant returns (string){
            
        if(contains("UNISWA", exString ) == true){
            return "UNISWAP";
        }
        
        else if(contains("KYBE", exString ) == true){
            return "KYBER";
        }
        else{
            return "NONE";
        }
    }
    
    
    function contains (string memory what, string memory where)  constant returns(bool){
    bytes memory whatBytes = bytes (what);
    bytes memory whereBytes = bytes (where);

    bool found = false;
    for (uint i = 0; i < whereBytes.length - whatBytes.length; i++) {
        bool flag = true;
        for (uint j = 0; j < whatBytes.length; j++)
            if (whereBytes [i + j] != whatBytes [j]) {
                flag = false;
                break;
            }
        if (flag) {
            found = true;
            break;
        }
    }
  
    return found;
    
}


   function compare(string _a, string _b) returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }
    
    function equal(string _a, string _b) returns (bool) {
        return compare(_a, _b) == 0;
    }
    
    function indexOf(string _haystack, string _needle) returns (int)
    {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
            return -1;
        else if(h.length > (2**128 -1)) 
            return -1;                                  
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0]) 
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) 
                    {
                        subindex++;
                    }   
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }   
    }
    

    
}