pragma solidity ^0.4.0;
pragma experimental ABIEncoderV2;

contract Goods{
    struct Good{
        address sellerAddr;  // Seller's address
        string name;  // Goods name
        string realTranscatInfos;  // The informations about offline transcations to send goods to buyer
        string description;  // Goods information
        uint256 price;  // Price of goods, take EI coin as unit
        uint time;
        uint index;
    }

    uint length = 0; // All goods count
    uint[] goodIndexes;  // All updated goods indexes
    mapping(uint => Good) goodLists;  // All updated goods


    // Seller update goods
    function createNewGoods(address addr, string name, uint256 price, string realInfos, string descri) public payable returns (bool result, string mess){
        // check seller has ever create same name goods infos or not
        for(uint i=0; i<goodIndexes.length; ++i){
            Good storage temp = goodLists[goodIndexes[i]];
            if(temp.sellerAddr == addr && keccak256(temp.name) == keccak256(name)){
                return (false, "Create target good failed! You have already created another goods with the same name!");
            }
        }

        // New goods info
        uint len = goodIndexes.length;
        length += 1;
        goodIndexes.push(len+1);
        goodLists[len+1] = Good(addr, name, realInfos, descri, price, now, len+1);
        return (true, "");
    }

    // Buyer buy goods
    function acceptGoods(uint index) public payable returns (bool result, address addr, uint price){
        for(uint i=0; i<goodIndexes.length; i++){
            if(goodIndexes[i] ==  index){
                address add = goodLists[index].sellerAddr;
                uint pri = goodLists[index].price;
                delete goodIndexes[i];
                delete goodLists[index];
                return (true, add, pri);
            }
        }
        return (false, address(0), 0);
    }

    // Get all goods infos
    function getTargetGoods(uint order) public returns (address addr, string name, string real, string dest, uint256 pri, uint trueID){
        Good temp = goodLists[goodIndexes[order]];
        return (temp.sellerAddr, temp.name, temp.realTranscatInfos, temp.description, temp.price,  goodIndexes[order]);
    }

    function getLength() public constant returns (uint len){
        return length;
    }


}