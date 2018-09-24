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
     modifier saleBatchRequired(address _from,address _fromBatch,uint  _amount) {
         require(_amount>0);
        require(manufacturers[_from].isValue == true);
        require(manufacturers[_from].batchesAccs[_fromBatch] == true);
        _;
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
    function countManufacturers() view public returns (uint count) {
        return manufacturerAccts.length;
    }
    
    function createBatch(address _manufacturerAcct, address _product, uint256 _numberOfParty, string _details,  string _dateCreated, uint  _size, bytes32[] _ids)public returns(address _addressBatch) 
    {
        require(_size>1);
        //TODO чи правильно???? -> перевірка чи _product !=null
        require(_product!=address(0));
        require(manufacturers[_manufacturerAcct].isValue == true);
        
        address[] memory _concreteProducts= new address[](_size);
        for(uint  i=0;i<_size;i++)
        {
            _concreteProducts[i] = new ConcreteProduct(DATABASE_CONTRACT, this, _ids[i]);
        }
        
        address batch = new Batch(DATABASE_CONTRACT, _manufacturerAcct,MyLibrary.ConsumerType.Manufacturer ,  _product, address(0), _numberOfParty, _details,  _dateCreated, _size, _concreteProducts);
        manufacturers[_manufacturerAcct].batches.push(batch);
        manufacturers[_manufacturerAcct].batchesAccs[batch]=true;
        return batch;
    }
    
    function getManufacturerBatches(address _manufacturer) view public returns (address[] batches) 
    {
        require(manufacturers[_manufacturer].isValue == true);
        return manufacturers[_manufacturer].batches;
    }
    
    function saleBatchToDistributor(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, uint  _amount)saleBatchRequired(_from,_fromBatch,_amount) public returns(address addressBatch) 
    {
        DataBase database = DataBase(DATABASE_CONTRACT);
        Distributor distributor = Distributor(database.getDistributor());
        
        distributor.checkAddress(_to);

        address newBatch = saleBatch(_fromBatch,newNumberOfParty,newDateCreated,_amount);
        distributor.addBatch(_to, newBatch);
        
        return newBatch;
    }
        function getProductsForSale (uint capacity , uint size , uint _amount, address[]productsFromBatch )private pure returns(address[] tmp)
    {
        uint  startIdnex = capacity - size;
        uint  endIndex = startIdnex+ _amount;
        address[] memory tmpConcreteProducts = new address[](_amount);
        // address[] memory productsFromBatch = fromBatch.getConcreteProducts();
        for(uint  i = startIdnex;i<endIndex;i++)
        {
            tmpConcreteProducts[i-startIdnex] = productsFromBatch[i];
        }
        return tmpConcreteProducts;
    }
    function saleBatch(address _fromBatch,uint256 newNumberOfParty, string newDateCreated, uint  _amount)public  returns (address _newBatch)
    {
        Batch fromBatch = Batch(_fromBatch);
        require(fromBatch.getSize() >= _amount);
        
        address[] memory tmpConcreteProducts = getProductsForSale(fromBatch.getCapacity(),fromBatch.getSize(),_amount,fromBatch.getConcreteProducts());
        
        
        fromBatch.setSize(fromBatch.getSize() - _amount);

        address newBatch = new Batch(DATABASE_CONTRACT, this,MyLibrary.ConsumerType.Distributor, fromBatch.getProduct(), _fromBatch, newNumberOfParty, fromBatch.getDetails(),  newDateCreated, _amount, tmpConcreteProducts);
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