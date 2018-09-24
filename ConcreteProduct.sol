pragma solidity ^0.4.24;

contract ConcreteProduct 
{
    address DATABASE_CONTRACT;

    address lastBatch; 
    address saleAddress;
    
    bytes32 id;
    
    constructor(address _DATABASE_CONTRACT,address _lastBatch, bytes32 _id) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;
        lastBatch = _lastBatch;
        id = _id;
        //QR = _qr;
    }
    function getInfo() view public returns(address _lastBatch,  bytes32 _id)
    {
        return (lastBatch,id);
    }
}
