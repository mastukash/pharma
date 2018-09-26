pragma solidity ^0.4.24;
import "./Owned.sol";
import "./Batch.sol";
import "./Retailer.sol";
import "./DataBase.sol";

contract Distributor is Owned {
    address public DATABASE_CONTRACT;
    struct Distr
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
    
    mapping (address => Distr) distributors;
    address[] public distrAccts;

    constructor(address _DATABASE_CONTRACT) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;
    }
    function addDistributor(address _address,  string _physicalAddress, string _companyName, string _firstName, string _lastName, string _email) public
    {
        require(owner==msg.sender);
        require(distributors[_address].isValue == false);

        Distr storage distr = distributors[_address];
        distr.physicalAddress = _physicalAddress;
        distr.companyName = _companyName;
        distr.firstName = _firstName;
        distr.lastName = _lastName;
        distr.email = _email;
        distr.isValue = true;
        
        distrAccts.push(_address);
    }
      function getDistributorInfo(address _address) view public returns (string _physicalAddress, string _companyName){
        return (distributors[_address].physicalAddress, distributors[_address].companyName);
    }
    function getDistributors() view public returns(address[]) {
        return distrAccts;
    }
    function getDistributor(address _address) view public returns (string physicalAddress, string companyName, string firstName, string lastName, string email) {
        return (distributors[_address].physicalAddress, distributors[_address].companyName, distributors[_address].firstName, distributors[_address].lastName, distributors[_address].email);
    }
    function countDistributors() view public returns (uint count) {
        return distrAccts.length;
    }
    
    function getDistrubutorBatches(address _distributor) view public returns (address[] batches) 
    {
        require(distributors[_distributor].isValue == true);
        return distributors[_distributor].batches;
    }
    
    function checkAddress(address _to) public view
    {
        require(distributors[_to].isValue == true);
    }
    
    function addBatch(address _distributor , address _batchAddress) public
    {
        distributors[_distributor].batches.push(_batchAddress);
        distributors[_distributor].batchesAccs[_batchAddress]= true;
        distributors[_distributor].batchesAccs[_batchAddress]=true;
       
    }
    
     modifier saleBatchRequired(address _from,bytes32[] _items) {
         require(_items.length>0);
        require(distributors[_from].isValue == true);
        DataBase db = DataBase(DATABASE_CONTRACT);
        address _fromBatch = db.getItemBatchAddress(_items[0]);
        require(distributors[_from].batchesAccs[_fromBatch] == true);
        for(uint i=0; i< _items.length; i++){
            address currecntAddress = db.getItemBatchAddress(_items[i]);
            require(currecntAddress == _fromBatch);
        }
        _;
    }
    //провірити провірки!!!
    function saleBatchToDistributor(address _from, address _to, bytes32[] _items)saleBatchRequired(_from, _items) public returns(address addressBatch) 
    {
        checkAddress(_to);

        address newBatch = saleBatch(_to,_items, MyLibrary.ConsumerType.Distributor);
        addBatch(_to, newBatch);
        
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
    
    function saleBatch(address _to, bytes32[] _items , MyLibrary.ConsumerType _type)public  returns (address _newBatch)
    {
        address _fromBatch = getBatchByItem(_items[0]);
        Batch fromBatch = Batch(_fromBatch);
        //require(fromBatch.getSize() >= _amount);// ????????????
        
        //address[] memory tmpConcreteProducts = getProductsForSale(fromBatch.getCapacity(),fromBatch.getSize(),_amount,fromBatch.getConcreteProducts());
        
        address[] memory tmpConcreteProducts = getItemsAddresses(_items);
        
        fromBatch.setSize(fromBatch.getSize() - tmpConcreteProducts.length);

        address newBatch = new Batch(DATABASE_CONTRACT, _to, _type, fromBatch.getProduct(), _fromBatch, fromBatch.getNumberOfParty(), fromBatch.getExpirationDate(),  fromBatch.getCreationDate(), tmpConcreteProducts.length, tmpConcreteProducts);
        fromBatch.addChildBatch(newBatch);
        
         for(uint i=0; i< tmpConcreteProducts.length;i++){
            ConcreteProduct(tmpConcreteProducts[i]).setLastBatch(newBatch);
        }
        
        return newBatch;
    }
    
    function saleBatchToRetailer(address _from, address _to, bytes32[] _items)saleBatchRequired(_from, _items)  public returns(address addressBatch) 
    {
        DataBase database = DataBase(DATABASE_CONTRACT);
        Retailer retailer = Retailer(database.getRetailer());
        
        
        retailer.checkAddress(_to);

        address newBatch = saleBatch(_to , _items , MyLibrary.ConsumerType.Retailer);
        retailer.addBatch(_to, newBatch);
        
        return newBatch;
    }
    
    
}