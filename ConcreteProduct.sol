pragma solidity ^0.4.24;

contract ConcreteProduct 
{
    address DATABASE_CONTRACT;

    address lastBatch; 
    address saleAddress;
    
    bytes32 id;
    bytes32 QR;
    
    constructor(address _DATABASE_CONTRACT,address _lastBatch, bytes32 _id, bytes32 _qr) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;
        lastBatch = _lastBatch;
        id = _id;
        QR = _qr;
    }
    function getInfo() view public returns(address _lastBatch,  bytes32 _id, bytes32 _QR)
    {
        return (lastBatch,id,QR);
    }
}
