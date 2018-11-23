pragma solidity ^0.4.0;

import "./Users.sol";
import "./Goods.sol";

contract EI{
    /*
    * EI accept transaction structure
    */
    struct EI_Transact{
        address sellerAddr;
        address buyerAddr;
        uint256 transactPrice;
        uint time;
        bool dealed;
    }

    /* 
    * EI exhange's private varibales
    */
    Users userStorage = new Users();  // Basic user infos storage
    Goods goodStorage = new Goods();  // Basic goods infos storage (Only process logical goods new and delete)
    EI_Transact[] Transactions;  // Store all pending transactions(undealed) and accepted transactions(dealed)


    /*
    * EI exchange's public methods
    */

    // 1. Basic user signin, signup methods
    function registerUser(address addr, string username, string password) public returns (bool result, string errMess){
        return userStorage.createNewUser(addr, username, password);
    }

    function siginUser(address addr, string username, string password) public returns (bool result, string errMess){
        return userStorage.loginUser(addr, username, password);
    }
    
    // 2. User exchanges balance methods
    function transcation(address srcAddress, address dstAddress, uint coinNum) private returns (bool result, string errMess){
        uint srcBalance = userStorage.getBalanceByAddr(srcAddress);
        // check source user balance enough ot not
        if(srcBalance < coinNum){
            return (false, "Buyer does not have enough EI coins!");
        }
        if(userStorage.decreaseBalance(srcAddress, coinNum) && userStorage.increaseBalance(dstAddress, coinNum)){
            return (true, "");
        }else {
            return (false, "Error occurs when changing user balances!");
        }
    }
    
    // 3. User update goods infos, or accept goods infos
    function updateGoodsInfo(string goodName, uint goodPrice, string realInfos, string description) public returns (bool result, string errMess){
        // First step: check sender address valid
        if(!userStorage.checkUserAddressExist(msg.sender)){
            return (false, "Unregisted address, invalid updation of goods!");
        }
        // Sceond step: put new goods
        return goodStorage.createNewGoods(msg.sender, goodName, goodPrice, realInfos, description);
    }

    function acceptTargetGood(uint goodID) public returns (bool result, string errMess){
        // First step: check sender address valid
        if(!userStorage.checkUserAddressExist(msg.sender)){
            return (false, "Unregisted address, invalid updation of goods!");
        }
        // Second step: do transaction
        bool res;
        address dstAddr;
        uint price;
        (res, dstAddr, price) = goodStorage.acceptGoods(goodID);
        if(!res){
            return (res, "Buy goods failed!");
        }
        // Fourth step: append EI_Transact
        return transcation(msg.sender, dstAddr, price);
    }
    
}