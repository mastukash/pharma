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
    
    function saleBatchToDistributor(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, uint  _amount) public returns(address addressBatch) 
    {
         DataBase database = DataBase(DATABASE_CONTRACT);
        Retailer retailer = Retailer(database.getRetailer());
        
        saleBatchRequired(_from, _fromBatch, _amount);
        retailer.checkAddress(_to);

        address newBatch = saleBatch(_fromBatch, newNumberOfParty,newDateCreated,_amount);
        retailer.addBatch(_to, newBatch);
        
        return newBatch;
    }
    
    function saleBatchRequired(address _from,address _fromBatch,uint  _amount)public view
    {
        require(_amount>0);
        require(distributors[_from].isValue == true);
        require(distributors[_from].batchesAccs[_fromBatch] == true);
        
    }
    
    function saleBatchToRetailer(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, uint  _amount) public returns(address addressBatch) 
    {
        DataBase database = DataBase(DATABASE_CONTRACT);
        Retailer retailer = Retailer(database.getRetailer());
        
        saleBatchRequired(_from, _fromBatch, _amount);
        retailer.checkAddress(_to);

        address newBatch = saleBatch(_fromBatch, newNumberOfParty,newDateCreated,_amount);
        retailer.addBatch(_to, newBatch);
        
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
    
    function saleBatch( address _fromBatch, uint256 newNumberOfParty, string newDateCreated, uint  _amount)public returns (address _newBatch)
    {
       Batch fromBatch = Batch(_fromBatch);
        require(fromBatch.getSize() >= _amount);
       
        address[] memory tmpConcreteProducts = getProductsForSale(fromBatch.getCapacity(),fromBatch.getSize(),_amount,fromBatch.getConcreteProducts());
        
        fromBatch.setSize(fromBatch.getSize() - _amount);

        address newBatch = new Batch(DATABASE_CONTRACT, this,MyLibrary.ConsumerType.Distributor, fromBatch.getProduct(), _fromBatch, newNumberOfParty, fromBatch.getDetails(),  newDateCreated, _amount, tmpConcreteProducts);
        fromBatch.addChildBatch(newBatch);
        
        return newBatch;
    }
}