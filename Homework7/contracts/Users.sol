pragma solidity ^0.4.0;

contract Users{
    // User schema
    struct User{
        address userAddress;
        string username;
        string password;
        uint timestamp;
        uint index;
        uint balance;
    }

    // User address 
    struct UserAddress{
        address userAddress;
        uint index;
    }

    address[] public userAddresses; // All the users' addresses
    string[] private userNames;  // All the users' names
    mapping(address => User) private userList; // User list mapping with its address
    mapping(string => UserAddress) private userAddrs; // User address mapping with its username


    // User address existion check
    function checkUserAddressExist(address addr) public constant returns (bool isExist){
        if(userAddresses.length == 0) return false;
        uint targetUserIndex = userList[addr].index;
        // Check target user's index pointing address equal to input or not
        return (userAddresses[targetUserIndex] == addr);
    }

    // User name duplication check
    function checkUserNameDuplicate(string name) private constant returns (bool isDuplicate){
        if(userNames.length == 0) return false;
        uint targetUserIndex = userAddrs[name].index;
        // Check target user's index pointing username equal to input or not
        return (keccak256(userNames[targetUserIndex]) == keccak256(name));
    }

    // Create a new user
    function createNewUser(address addr, string name, string password) public returns (bool result, string errMess){
        // Check address and username duplication
        if(checkUserAddressExist(addr)){
            return (false, "The user address has already registered an account!");
        }else if(checkUserNameDuplicate(name)){
            return (false, "The username has already been used, please pick another one!");
        }
        // Remember to store new user into userList, also create entity in userAddrs
        userAddresses.push(addr);
        userNames.push(name);

        userList[addr] = User(addr, name, password, now, userAddresses.length - 1, 100);
        userAddrs[name] = UserAddress(addr, userNames.length - 1);
        return (true, "");
    }

    // Check user's address, username and password
    function loginUser(address addr, string name, string password) public returns (bool result, string errMess){
        if(!checkUserAddressExist(addr)){
            return (false, "User address not exist!");
        }
        require(checkUserAddressExist(addr));
        User storage targetUser = userList[addr];
        if(keccak256(targetUser.username) != keccak256(name)){
            return (false, "Valid address with wrong username!");
        }else if(keccak256(targetUser.password) != keccak256(password)){
            return (false, "Valid address and username, but wrong password!");
        }
        return (true, "");
    }

    // Get target user's info
    function getUserInfo(address addr) public constant returns (bool result, string username, uint userTime, uint userIndex){
        if(!checkUserAddressExist(addr)){
            return (false, "", 0, 0);
        }
        return (
            true,
            userList[addr].username,
            userList[addr].timestamp,
            userList[addr].index
        );
    }

    // Get target user's address by username
    function getAddrByName(string name) public constant returns (address addr){
        return userAddrs[name].userAddress;
    }

    // Check user balance
    function getBalanceByAddr(address addr) public constant returns (uint balance){
        return userList[addr].balance;
    }

    // Increase user balance
    function increaseBalance(address targetAddr, uint count) public payable returns (bool result){
        if(userList[targetAddr].balance + count <= count){
            return false;
        }
        userList[targetAddr].balance += count;
        return true;
    }

    // Decrease user balance
    function decreaseBalance(address targetAddr, uint count) public payable returns (bool result){
        if(userList[targetAddr].balance < count){
            return false;
        }
        userList[targetAddr].balance -= count;
        return true;
    }

}