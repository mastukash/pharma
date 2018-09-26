pragma solidity ^0.4.24;
import "./Owned.sol";
import "./DataBase.sol";
import "./Distributor.sol";
import "./Batch.sol";
import "./ConcreteProduct.sol";

contract Manufacturer is Owned {
    address public DATABASE_CONTRACT;
    struct Manufactur
    {
        string physicalAddress;
        string companyName;
        string firstName;
        string lastName;
        string email;
        bool isValue;
        
        address[] batches;
        //для швидкого пошуку партій
        mapping (address => bool) batchesAccs;
    }
    
    mapping (address => Manufactur) manufacturers;
    address[] public manufacturerAccts;

    constructor(address _DATABASE_CONTRACT) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;

    }
  
    function addManufacturer(address _address,  string _physicalAddress, string _companyName, string _firstName, string _lastName, string _email) public
    {
        require(owner==msg.sender);
        require(manufacturers[_address].isValue == false);

        
        Manufactur storage manufacturer = manufacturers[_address];
        manufacturer.physicalAddress = _physicalAddress;
        manufacturer.companyName = _companyName;
        manufacturer.firstName = _firstName;
        manufacturer.lastName = _lastName;
        manufacturer.email = _email;
        manufacturer.isValue = true;
        
        manufacturerAccts.push(_address);
    }
    function getManufacturers() view public returns(address[]_manufacturerAccts) {
        return manufacturerAccts;
    }
    function getManufacturerDetails(address _address) view public returns (string _physicalAddress, string _companyName, string _firstName, string _lastName, string _email) {
        return (manufacturers[_address].physicalAddress, manufacturers[_address].companyName, manufacturers[_address].firstName, manufacturers[_address].lastName, manufacturers[_address].email);
    }
    
    function getManufacturerInfo(address _address) view public returns (string _physicalAddress, string _companyName){
        return (manufacturers[_address].physicalAddress, manufacturers[_address].companyName);
    }
    
    function countManufacturers() view public returns (uint count) {
        return manufacturerAccts.length;
    }
    
    function createBatch(address _manufacturerAcct, address _product, string _numberOfParty, string _details,  string _dateCreated, uint  _size, bytes32[] _ids)public returns(address _addressBatch) 
    {
        require(_size>1);
        //TODO чи правильно???? -> перевірка чи _product !=null
        require(_product!=address(0));
        require(manufacturers[_manufacturerAcct].isValue == true);
        DataBase db = DataBase(DATABASE_CONTRACT);
        address[] memory _concreteProducts= new address[](_size);
        for(uint  i=0;i<_size;i++)
        {
            _concreteProducts[i] = new ConcreteProduct(DATABASE_CONTRACT, address(0), _ids[i]);
            db.addConcrateProduct(_ids[i],_concreteProducts[i]);
        }
        
        address batch = new Batch(DATABASE_CONTRACT, _manufacturerAcct,MyLibrary.ConsumerType.Manufacturer ,  _product, address(0), _numberOfParty, _details,  _dateCreated, _size, _concreteProducts);
        manufacturers[_manufacturerAcct].batches.push(batch);
        manufacturers[_manufacturerAcct].batchesAccs[batch]=true;
        for(i=0;i<_size;i++)
        {
            ConcreteProduct(_concreteProducts[i]).setLastBatch(batch);//.call("setLastBatch",batch);
        }
        return batch;
    }
    
    function getManufacturerBatches(address _manufacturer) view public returns (address[] batches) 
    {
        require(manufacturers[_manufacturer].isValue == true);
        return manufacturers[_manufacturer].batches;
    }
       modifier saleBatchRequired(address _from,bytes32[] _items) {
         require(_items.length>0);
        require(manufacturers[_from].isValue == true);
        DataBase db = DataBase(DATABASE_CONTRACT);
        address _fromBatch = db.getItemBatchAddress(_items[0]);
        require(manufacturers[_from].batchesAccs[_fromBatch] == true);
        for(uint i=0; i< _items.length; i++){
            address currecntAddress = db.getItemBatchAddress(_items[i]);
            require(currecntAddress == _fromBatch);
        }
        _;
    }
    //провірити провірки!!!
    function saleBatchToDistributor(address _from, address _to, bytes32[] _items)saleBatchRequired(_from, _items) public returns(address addressBatch) 
    {
        DataBase database = DataBase(DATABASE_CONTRACT);
        Distributor distributor = Distributor(database.getDistributor());
        
        distributor.checkAddress(_to);

        address newBatch = saleBatch(_to,_items);
        distributor.addBatch(_to, newBatch);
        
        return newBatch;
    }
         
    
    function getBatchByItem (bytes32 _itemId)private view returns (address _fromBatch)
    {
        DataBase db = DataBase(DATABASE_CONTRACT);
        return db.getItemBatchAddress(_itemId);
    }
    
    function getItemsAddresses(bytes32[] _itemsIds)private view returns(address[] addresses)
    {
        DataBase db = DataBase(DATABASE_CONTRACT);
        
        address[] memory _items = new address[](_itemsIds.length);
        for(uint i=0; i< _itemsIds.length; i++)
        {
            _items[i] = db.getItemAddress(_itemsIds[i]);
        }
        return _items;
    }
    
    function saleBatch(address _to, bytes32[] _items)public  returns (address _newBatch)
    {
        address _fromBatch = getBatchByItem(_items[0]);
        Batch fromBatch = Batch(_fromBatch);
        //require(fromBatch.getSize() >= _amount);// ????????????
        
        //address[] memory tmpConcreteProducts = getProductsForSale(fromBatch.getCapacity(),fromBatch.getSize(),_amount,fromBatch.getConcreteProducts());
        
        address[] memory tmpConcreteProducts = getItemsAddresses(_items);
        
        fromBatch.setSize(fromBatch.getSize() - tmpConcreteProducts.length);

        address newBatch = new Batch(DATABASE_CONTRACT, _to, MyLibrary.ConsumerType.Distributor, fromBatch.getProduct(), _fromBatch, fromBatch.getNumberOfParty(), fromBatch.getExpirationDate(),  fromBatch.getCreationDate(), tmpConcreteProducts.length, tmpConcreteProducts);
        fromBatch.addChildBatch(newBatch);
        
        for(uint i=0; i< tmpConcreteProducts.length;i++){
            ConcreteProduct(tmpConcreteProducts[i]).setLastBatch(newBatch);
        }
        
        return newBatch;
    }
    
    //TODO
    //saleBatch
    //show available batches
    //show saled batches
    //show details concrete batch
    //...
}