pragma solidity ^0.4.24;
import "./Owned.sol";
import "./DataBase.sol";

contract Retailer is Owned {
    address public DATABASE_CONTRACT;
    struct Retail
    {
        string physicalAddress;
        string companyName;
        string firstName;
        string lastName;
        string email;
        bool isValue;
        
        address[] batches;
        mapping (address => bool) batchesAccs;
    }
    
    mapping (address => Retail) retailers;
    address[] public retailerAccts;

    constructor(address _DATABASE_CONTRACT) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;

    }
    function addRetailer(address _address,  string _physicalAddress, string _companyName, string _firstName, string _lastName, string _email) public
    {
        require(owner==msg.sender);
        require(retailers[_address].isValue == false);

        Retail storage retailer = retailers[_address];
        retailer.physicalAddress = _physicalAddress;
        retailer.companyName = _companyName;
        retailer.firstName = _firstName;
        retailer.lastName = _lastName;
        retailer.email = _email;
        retailer.isValue = true;
        
        retailerAccts.push(_address);
    }
    function getRetailers() view public returns(address[]) {
        return retailerAccts;
    }
    function getRetailer(address _address) view public returns (string physicalAddress, string companyName, string firstName, string lastName, string email) {
        return (retailers[_address].physicalAddress, retailers[_address].companyName, retailers[_address].firstName, retailers[_address].lastName, retailers[_address].email);
    }
    function countRetailers() view public returns (uint count) {
        return retailerAccts.length;
    }
    
    
    function getRetailerBatches(address _retailer) view public returns (address[] batches) 
    {
        require(retailers[_retailer].isValue == true);
        return retailers[_retailer].batches;
    }
    
    function checkAddress(address _to)
    {
        require(retailers[_to].isValue == true);
    }
    
    function addBatch(address _retailer , address _batchAddress) public
    {
        retailers[_retailer].batches.push(_batchAddress);
        retailers[_retailer].batchesAccs[_batchAddress]= true;
        bool batchAcc = retailers[_retailer].batchesAccs[_batchAddress];
        batchAcc = true;
    }
}