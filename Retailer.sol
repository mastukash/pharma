pragma solidity ^0.4.24;
import "./Owned.sol";
import "./Batch.sol";
import "./DataBase.sol";

contract Retailer is Owned {
    address public DATABASE_CONTRACT;
    struct Retail
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
    
    mapping (address => Retail) retailers;
    address[] public retailerAccts;

    constructor(address _DATABASE_CONTRACT) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;

    }
    function addRetailer(address _address,  string _physicalAddress, string _companyName, string _firstName, string _lastName, string _email) public
    {
        require(owner==msg.sender);
        require(retailers[_address].isValue == false);

        Retail storage retailer = retailers[_address];
        retailer.physicalAddress = _physicalAddress;
        retailer.companyName = _companyName;
        retailer.firstName = _firstName;
        retailer.lastName = _lastName;
        retailer.email = _email;
        retailer.isValue = true;
        
        retailerAccts.push(_address);
    }
    function getRetailers() view public returns(address[]) {
        return retailerAccts;
    }
    function getRetailer(address _address) view public returns (string physicalAddress, string companyName, string firstName, string lastName, string email) {
        return (retailers[_address].physicalAddress, retailers[_address].companyName, retailers[_address].firstName, retailers[_address].lastName, retailers[_address].email);
    }
    function countRetailers() view public returns (uint count) {
        return retailerAccts.length;
    }
    
    
    function getRetailerBatches(address _retailer) view public returns (address[] batches) 
    {
        require(retailers[_retailer].isValue == true);
        return retailers[_retailer].batches;
    }
    
    function checkAddress(address _to)
    {
        require(retailers[_to].isValue == true);
    }
    
    function addBatch(address _retailer , address _batchAddress) public
    {
        retailers[_retailer].batches.push(_batchAddress);
        retailers[_retailer].batchesAccs[_batchAddress]= true;
        bool batchAcc = retailers[_retailer].batchesAccs[_batchAddress];
        batchAcc = true;
    }

    function saleBatchToRetaler(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount) public returns(address addressBatch) 
    {
        saleBatchRequired(_from,  _to, _fromBatch, _amount);
        require(retailers[_to].isValue == true);

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
        retailers[_to].batches.push(newBatch);
        fromBatch.addChildBatch(newBatch);
        return newBatch;
    }
    function saleBatchRequired(address _from, address _to,address _fromBatch,int _amount)
    {
        require(_amount>0);
        require(retailers[_from].isValue == true);
        require(retailers[_from].batchesAccs[_fromBatch] == true);
    }

    // чи шукати продукти по ід? чи продавати тільки 1 товар,
    // чи зразу продавати з партії пару продуктів???
    // якось записувати деталі продужу користувачу
    function saleProductToUser(address _from, address _concreteProduct, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount) public 
    {

    }
}