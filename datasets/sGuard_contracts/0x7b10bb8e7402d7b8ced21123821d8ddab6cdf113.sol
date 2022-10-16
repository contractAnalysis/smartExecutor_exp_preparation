pragma solidity ^0.5.12;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract OtcLike {
    struct OfferInfo {
        uint              pay_amt;
        address           pay_gem;
        uint              buy_amt;
        address           buy_gem;
        address           owner;
        uint64            timestamp;
    }
    mapping (uint => OfferInfo) public offers;
    function getBestOffer(address, address) public view returns (uint);
    function getWorseOffer(uint) public view returns (uint);
}

contract MakerOtcSupportMethods is DSMath {
    function getOffers(address otc, address payToken, address buyToken) public view returns (uint[100] memory ids,
                                                                                             uint[100] memory payAmts,
                                                                                             uint[100] memory buyAmts,
                                                                                             address[100] memory owners,
                                                                                             uint[100] memory timestamps) {
        (ids, payAmts, buyAmts, owners, timestamps) = getOffers(otc, OtcLike(otc).getBestOffer(payToken, buyToken));
    }

    function getOffers(address otc, uint offerId_) public view returns (uint[100] memory ids, uint[100] memory payAmts,
                                                                        uint[100] memory buyAmts, address[100] memory owners,
                                                                        uint[100] memory timestamps) {
        uint offerId = offerId_;
        uint i = 0;
        do {
            (payAmts[i],, buyAmts[i],, owners[i], timestamps[i]) = OtcLike(otc).offers(offerId);
            if(owners[i] == address(0)) break;
            ids[i] = offerId;
            offerId = OtcLike(otc).getWorseOffer(offerId);
        } while (++i < 100);
    }

    function getOffersAmountToSellAll(address otc, address payToken,
                                      uint payAmt, address buyToken) public view returns (uint ordersToTake, bool takesPartialOrder) {

        uint offerId = OtcLike(otc).getBestOffer(buyToken, payToken);               
        ordersToTake = 0;
        uint payAmt2 = payAmt;
        uint orderBuyAmt = 0;
        (,,orderBuyAmt,,,) = OtcLike(otc).offers(offerId);
        while (payAmt2 > orderBuyAmt) {
            ordersToTake ++;                                                        
            payAmt2 = sub(payAmt2, orderBuyAmt);                                    
            if (payAmt2 > 0) {                                                      
                offerId = OtcLike(otc).getWorseOffer(offerId);                      
                require(offerId != 0, "");                                          // Fails if there are not enough offers to complete
                (,,orderBuyAmt,,,) = OtcLike(otc).offers(offerId);
            }
        }
        ordersToTake = payAmt2 == orderBuyAmt ? ordersToTake + 1 : ordersToTake;    // If the remaining amount is equal than the latest order, then it will also be taken completely
        takesPartialOrder = payAmt2 < orderBuyAmt;                                  // If the remaining amount is lower than the latest order, then it will take a partial order
    }

    function getOffersAmountToBuyAll(address otc, address buyToken,
                                     uint buyAmt, address payToken) public view returns (uint ordersToTake, bool takesPartialOrder) {

        uint offerId = OtcLike(otc).getBestOffer(buyToken, payToken);               // Get best offer for the token pair
        ordersToTake = 0;
        uint buyAmt2 = buyAmt;
        uint orderPayAmt = 0;
        (orderPayAmt,,,,,) = OtcLike(otc).offers(offerId);
        while (buyAmt2 > orderPayAmt) {
            ordersToTake ++;                                                        // New order taken
            buyAmt2 = sub(buyAmt2, orderPayAmt);                                    // Decrease amount to buy
            if (buyAmt2 > 0) {                                                      // If we still need more offers
                offerId = OtcLike(otc).getWorseOffer(offerId);                      // We look for the next best offer
                require(offerId != 0, "");                                          
                (orderPayAmt,,,,,) = OtcLike(otc).offers(offerId);
            }
        }
        ordersToTake = buyAmt2 == orderPayAmt ? ordersToTake + 1 : ordersToTake;    
        takesPartialOrder = buyAmt2 < orderPayAmt;                                  
    }
}