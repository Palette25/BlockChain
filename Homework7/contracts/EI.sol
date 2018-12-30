pragma solidity ^0.4.0;

contract EI{
	struct EI_Good {
		address sellerAddr;
		address buyerAddr;
		string goodsName;
		string sellerName;
		string buyerName;
		uint256 price;
		uint timestamp;
	}

	uint pendingLength = 0;  // Pending list length
	mapping(uint => EI_Good) pendingList;  // All pending goods list, waiting to be confirmed

	uint confirmedLength = 0;  // Confirmed goods list length
	mapping(uint => EI_Good) confirmedList;  // All confirmed goods list, 


	// Get user pending transactions length
	function getPendingLength(address addr) public constant returns (uint len) {
		uint result = 0; 
		for(uint i=0; i<pendingLength; i++){
			if(pendingList[i].sellerAddr == addr || pendingList[i].buyerAddr == addr){
				result += 1;
			}
		}
		return result;
	}

	// Get user confirmed transactions length
	function getConfirmedLength(address addr) public constant returns (uint len) {
		uint result = 0; 
		for(uint i=0; i<confirmedLength; i++){
			if(confirmedList[i].sellerAddr == addr || confirmedList[i].buyerAddr == addr){
				result += 1;
			}
		}
		return result;
	}

	// Get user's target pending transaction, promise providing legal index
	function getPendingTrans(address addr, uint index) public constant returns (address addr1, address addr2, string gname, string name1, string name2, uint256 price, uint time) {
		uint currIndex = 0;
		for(uint i=0; i<pendingLength; i++){
            if(pendingList[i].sellerAddr == addr || pendingList[i].buyerAddr == addr){
                if(currIndex == index){
                    return (pendingList[i].sellerAddr, pendingList[i].buyerAddr, pendingList[i].goodsName, pendingList[i].sellerName, pendingList[i].buyerName, pendingList[i].price, pendingList[i].timestamp);
                }else {
                    currIndex += 1;
                }
            }
		}
		return (address(0), address(0), "", "", "", 0, 0);
	}
	
	// Get user's target confiremd transaction, promise providing legal index
	function getConfirmedTrans(address addr, uint index) public constant returns (address addr1, address addr2, string gname, string name1, string name2, uint256 price, uint time) {
		uint currIndex = 0;
		for(uint i=0; i<confirmedLength; i++){
            if(confirmedList[i].sellerAddr == addr || confirmedList[i].buyerAddr == addr){
                if(currIndex == index){
                    return (confirmedList[i].sellerAddr, confirmedList[i].buyerAddr, confirmedList[i].goodsName, confirmedList[i].sellerName, confirmedList[i].buyerName, confirmedList[i].price, confirmedList[i].timestamp);
                }else {
                    currIndex += 1;
                }
            }
		}
		return (address(0), address(0), "", "", "", 0, 0);
	}
	
	// Add pending EI goods
	function addPendingTrans(address addr1, address addr2, string gname, string name1, string name2, uint256 price) public payable returns (bool result) {
	    pendingList[pendingLength] = EI_Good(addr1, addr2, gname, name1, name2, price, now);
	    pendingLength += 1;
	    return true;
	}
	
	// Confirm pending EI goods (Only buyer can confirm the transaction)
	function confirmPendingTrans(address sellerAddr, address buyerAddr, string gname) public payable returns (bool result) {
	    uint index = 1000000000;
	    for(uint i=0; i<pendingLength; i++){
	        if(pendingList[i].sellerAddr == sellerAddr && pendingList[i].buyerAddr == buyerAddr && keccak256(pendingList[i].goodsName) == keccak256(gname)){
	            index = i;
	            break;
	        }
	    }
	    if(index != 1000000000){
	        // Adding confirmed transaction
	        confirmedList[confirmedLength] = EI_Good(
	            pendingList[index].sellerAddr, pendingList[index].buyerAddr, pendingList[index].goodsName,
	            pendingList[index].sellerName, pendingList[index].buyerName, pendingList[index].price, now
	        );
	        confirmedLength += 1;
	        // Disable pending list target element
	        pendingList[index] = EI_Good(address(0), address(0), "", "", "", 0, 0);
	        return true;
	    }else {
	        return false;
	    }
	}

}