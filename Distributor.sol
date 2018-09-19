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
    
    function checkAddress(address _to)
    {
        require(distributors[_to].isValue == true);
    }
    
    function addBatch(address _distributor , address _batchAddress) public
    {
        distributors[_distributor].batches.push(_batchAddress);
        distributors[_distributor].batchesAccs[_batchAddress]= true;
        bool batchAcc = distributors[_distributor].batchesAccs[_batchAddress];
        batchAcc = true;
    }
    
    function saleBatchToDistributor(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount) public returns(address addressBatch) 
    {
        saleBatchRequired(_from,  _to, _fromBatch, _amount);
        require(distributors[_to].isValue == true);

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
        distributors[_to].batches.push(newBatch);
        fromBatch.addChildBatch(newBatch);
        return newBatch;
    }
    
    function saleBatchRequired(address _from, address _to,address _fromBatch,int _amount)
    {
        require(_amount>0);
        require(distributors[_from].isValue == true);
        require(distributors[_from].batchesAccs[_fromBatch] == true);
        
    }
    
    function saleBatchToRetailer(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount) public returns(address addressBatch) 
    {
        DataBase database = DataBase(DATABASE_CONTRACT);
        Retailer retailer = Retailer(database.getRetailer());
        
        saleBatchRequired(_from, _fromBatch, _amount);
        retailer.checkAddress(_to);

        address newBatch = saleBatch(_to,_fromBatch,newNumberOfParty,newDateCreated,_amount);
        retailer.addBatch(_to, newBatch);
        
        return newBatch;
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
}