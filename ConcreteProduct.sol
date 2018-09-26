pragma solidity ^0.4.24;
import "./Batch.sol";
import "./DataBase.sol";
contract ConcreteProduct 
{
    address DATABASE_CONTRACT;

    address lastBatch; 
    string saleDate;
    
    bytes32 id;
    
    address sellerAddress;
    
    
    constructor(address _DATABASE_CONTRACT,address _lastBatch, bytes32 _id) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;
        lastBatch = _lastBatch;
        id = _id;
        //QR = _qr;
    }
    
    
    function saleProduct(string _saleDate)public
    {
        require(sellerAddress != address(0));
        Batch batch = Batch(lastBatch);
        address owner = batch.getOwner();
        saleDate = _saleDate;
        sellerAddress = owner;
        //DataBase db = DataBase(batch.getDataBaseAddress());
        //require(msg.sender == owner || msg.sender == db.getRetailer());
        
    }
    
    
    function setLastBatch(address _lastBatch)public{
        //require(lastBatch == address(0));
        lastBatch = _lastBatch;
    }
    
    function getInfo() view public returns(address _lastBatch,  bytes32 _id)
    {
        return (lastBatch,id);
    }
    
    function getLastBatch()public view returns(address _lastBatch){
        return lastBatch;
    }
}
