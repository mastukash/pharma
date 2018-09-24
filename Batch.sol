pragma solidity ^0.4.24;
import "./DataBase.sol";
import "./ConcreteProduct.sol";


contract Batch{
    address DATABASE_CONTRACT;
    address owner; //власник - це контракт який його створив
    MyLibrary.ConsumerType ownerType;
    
    address[] concreteProducts;
    address product;
    
    address parentBatch;
    address[] childBatches;
    
    uint256 numberOfParty;
    string  details;
    string dateCreated;
    uint  size; // sizeAvailable products
    uint  capacity; //maxSize products

    constructor(address _DATABASE_CONTRACT, address _owner, MyLibrary.ConsumerType _ownerType, address _product, address _parentBatch,  uint256 _numberOfParty, string _details,  string _dateCreated, uint  _size, address[] _concreteProducts) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;
        owner = _owner;
        parentBatch = _parentBatch;
        product = _product;
        ownerType =_ownerType;
        numberOfParty = _numberOfParty;
        details = _details;
        dateCreated = _dateCreated;
        size = capacity = _size;
        
        concreteProducts = _concreteProducts;
    }
    
    
    function getInfo() view public returns(address _owner, address _parentBatch, address[] _childBatches, uint256 _numberOfParty, string _details, address[] _concreteProducts)
    {
        return (owner,parentBatch,childBatches,numberOfParty,details,concreteProducts);
    }
    function getParentBatch() view public returns (address parentBatchAddress)
    {
        return parentBatch;
    }
    function setSize(uint  _size) public
    {
        size = _size;
    }
    function getSize() view public returns(uint  _size)
    {
        return size;
    }
    function getProduct() view public returns(address _product)
    {
        return product;
    }
    function getDetails()view public returns(string _details)
    {
        return details;
    }
    function getChildBatches()view public returns(address[] _childBatches)
    {
        return childBatches;
    }
    function getCapacity()view public returns(uint  _capacity)
    {
        return capacity;
    }
    function getConcreteProducts()view public returns(address[] _concreteProducts)
    {
        return concreteProducts;
    }
    function addChildBatch(address _childBatch) public 
    {
        childBatches.push(_childBatch);
    }
}