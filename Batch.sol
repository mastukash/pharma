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
    
    string numberOfParty;
    string  expirationDate;
    string dateCreated;
    uint  size; // sizeAvailable products
    uint  capacity; //maxSize products

    constructor(address _DATABASE_CONTRACT, address _owner, MyLibrary.ConsumerType _ownerType, address _product, address _parentBatch,  string _numberOfParty, string _expirationDate,  string _dateCreated, uint  _size, address[] _concreteProducts) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;
        owner = _owner;
        parentBatch = _parentBatch;
        product = _product;
        ownerType =_ownerType;
        numberOfParty = _numberOfParty;
        expirationDate = _expirationDate;
        dateCreated = _dateCreated;
        size = capacity = _size;
        
        concreteProducts = _concreteProducts;
    }
    
    
    function getOwnerDetails()public view returns (string physicalAddress,string companyName,string firstName,string lastName,string email) 
    {
        DataBase db = DataBase(DATABASE_CONTRACT);
         if(ownerType == MyLibrary.ConsumerType.Manufacturer)
        {
           return Manufacturer(db.getManufacturer()).getManufacturerDetails(owner);
        }
        else if(ownerType == MyLibrary.ConsumerType.Distributor){
            return  Distributor(db.getDistributor()).getDistributor(owner);
        }
        else if(ownerType == MyLibrary.ConsumerType.Retailer){
            return  Retailer(db.getRetailer()).getRetailer(owner);
        }
    }
    
     function getOwnerInfo()public view returns (string physicalAddress,string companyName,MyLibrary.ConsumerType _type) 
    {
        DataBase db = DataBase(DATABASE_CONTRACT);
        string memory _physicalAddress;
        string memory _companyName;
         if(ownerType == MyLibrary.ConsumerType.Manufacturer)
        {
           (_physicalAddress , _companyName) =  Manufacturer(db.getManufacturer()).getManufacturerInfo(owner);
           return (_physicalAddress,_companyName , ownerType);
        }
        else if(ownerType == MyLibrary.ConsumerType.Distributor){
              (_physicalAddress , _companyName) =    Distributor(db.getDistributor()).getDistributorInfo(owner);
               return (_physicalAddress,_companyName , ownerType);
        }
        else if(ownerType == MyLibrary.ConsumerType.Retailer){
              (_physicalAddress , _companyName) =    Retailer(db.getRetailer()).getRetailerInfo(owner);
               return (_physicalAddress,_companyName , ownerType);
        }
    }
    
    function getBatchInfo()public view returns (string _numberOfParty,  string _expirationDate, string _dateCreated){
      
        return (numberOfParty,  expirationDate, dateCreated);
        
    }
    
    function getInfo() view public returns(address _owner, address _parentBatch, address[] _childBatches, string _numberOfParty, string _expirationDate, address[] _concreteProducts)
    {
        return (owner,parentBatch,childBatches,numberOfParty,expirationDate,concreteProducts);
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
    function getOwner()public view returns(address _owner){
        return owner;
    }
    function getProduct() view public returns(address _product)
    {
        return product;
    }
    function getExpirationDate()view public returns(string _expirationDate)
    {
        return expirationDate;
    }
     function getCreationDate()view public returns(string _dateCreated)
    {
        return dateCreated;
    }
     function getNumberOfParty()view public returns(string _numberOfParty)
    {
        return numberOfParty;
    }
    function getChildBatches()view public returns(address[] _childBatches)
    {
        return childBatches;
    }
    function getCapacity()view public returns(uint  _capacity)
    {
        return capacity;
    }
    function getDataBaseAddress()public view returns(address _DATABASE_CONTRACT)
    {
        return DATABASE_CONTRACT;
    }
    function getConcreteProducts()view public returns(address[] _concreteProducts)
    {
        return concreteProducts;
    }
    function addChildBatch(address _childBatch) public 
    {
        childBatches.push(_childBatch);
    }
    //function getOwnerInfor()public view returns()
}