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
        
        manufacturerAccts.push(_address);
    }
    function getManufacturers() view public returns(address[]_manufacturerAccts) {
        return manufacturerAccts;
    }
    function getManufacturerDetails(address _address) view public returns (string _physicalAddress, string _companyName, string _firstName, string _lastName, string _email) {
        return (manufacturers[_address].physicalAddress, manufacturers[_address].companyName, manufacturers[_address].firstName, manufacturers[_address].lastName, manufacturers[_address].email);
    }
    function countManufacturers() view public returns (uint count) {
        return manufacturerAccts.length;
    }
    
    function createBatch(address _manufacturerAcct, address _product, uint256 _numberOfParty, string _details,  string _dateCreated, int _size, bytes32[] _ids, bytes32[]_qrs) public returns(address _addressBatch) 
    {
        require(_size>1);
        //TODO чи правильно???? -> перевірка чи _product !=null
        require(_product!=address(0));
        require(manufacturers[_manufacturerAcct].isValue == true);
        
        address[] _concreteProducts;
        for(var i=0;i<_size;i++)
        {
            _concreteProducts.push(new ConcreteProduct(DATABASE_CONTRACT, this, _ids[i], _qrs[i]));
        }
        
        address batch = new Batch(DATABASE_CONTRACT, _manufacturerAcct, _product, address(0), _numberOfParty, _details,  _dateCreated, _size, _concreteProducts);
        manufacturers[_manufacturerAcct].batches.push(batch);
        bool batchAcc = manufacturers[_manufacturerAcct].batchesAccs[batch];
        batchAcc = true;
        return batch;
    }
    
    function getManufacturerBatches(address _manufacturer) view public returns (address[] batches) 
    {
        require(manufacturers[_manufacturer].isValue == true);
        return manufacturers[_manufacturer].batches;
    }
    
    function saleBatchToDistributor(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount) public returns(address addressBatch) 
    {
        DataBase database = DataBase(DATABASE_CONTRACT);
        Distributor distributor = Distributor(database.getDistributor());
        
        saleBatchToDistributorRequired(_from, _fromBatch, _amount);
        distributor.checkAddress(_to);

        address newBatch = saleBatch(_to,_fromBatch,newNumberOfParty,newDateCreated,_amount);
        distributor.addBatch(_to, newBatch);
        
        return newBatch;
    }
    
    function saleBatchToDistributorRequired(address _from,address _fromBatch,int _amount)
    {
        require(_amount>0);
        require(manufacturers[_from].isValue == true);
        require(manufacturers[_from].batchesAccs[_fromBatch] == true);
    }
    function saleBatch(address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount) returns (address _newBatch)
    {
        Batch fromBatch = Batch(_fromBatch);
        require(fromBatch.getSize() >= _amount);
        int startIdnex = fromBatch.getCapacity() - fromBatch.getSize();
        int endIndex = startIdnex+ _amount;
        address[] tmpConcreteProducts;
        address[] memory productsFromBatch = fromBatch.getConcreteProducts();
        for(int i = startIdnex;i<endIndex;i++)
        {
            tmpConcreteProducts.push(productsFromBatch[(uint256)(i)]);
        }
        
        fromBatch.setSize(fromBatch.getSize() - _amount);

        address newBatch = new Batch(DATABASE_CONTRACT, this, fromBatch.getProduct(), _fromBatch, newNumberOfParty, fromBatch.getDetails(),  newDateCreated, _amount, tmpConcreteProducts);
        fromBatch.addChildBatch(newBatch);
        
        return newBatch;
    }
    
    //TODO
    //saleBatch
    //show available batches
    //show saled batches
    //show details concrete batch
    //...
}