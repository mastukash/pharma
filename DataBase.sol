pragma solidity ^0.4.24;
import "./Owned.sol";
//import "./Retailer.sol";
import "./Manufacturer.sol";
//import "./Distributor.sol";
//import "./Batch.sol";
import "./Product.sol";
//import "./ConcreteProduct.sol";
library MyLibrary{ 
enum ConsumerType {Manufacturer , Distributor , Retailer }
}pragma solidity ^0.4.24;
import "./Owned.sol";
//import "./Retailer.sol";
import "./Manufacturer.sol";
//import "./Distributor.sol";
//import "./Batch.sol";
import "./Product.sol";
import "./ConcreteProduct.sol";
library MyLibrary{ 
enum ConsumerType {Manufacturer , Distributor , Retailer }
}
contract DataBase is Owned {

    address retailer;
    address manufacturer;
    address distributor;

    address[] products;
    mapping(address=>bool) productsAccts;


    address[] concreteProducts;
    mapping(bytes32=>address) concreteProductsAccts;
    
     
    
    function setDistributor(address _distributor) onlyOwner public //returns  (address distributorAddress) 
    {
        require(distributor == address(0));
        distributor = _distributor;
        //return distributor;
    }
    function getDistributor()view public returns (address distributorAddress)
    {
        return distributor;
    }
    
    function setManufacturer(address _manufacturer) onlyOwner public //returns (address manufacturerAddress)  
    {
        require(manufacturer == address(0));
        manufacturer = _manufacturer;
        //return manufacturer;
    }

    function getManufacturer() view public returns (address manufacturerAddress)
    {
        return manufacturer;
    }
    
    function setRetailer(address _retailer) onlyOwner public //returns (address retailerAddress)  
    {
        require(retailer == address(0));
        retailer = _retailer;
     //   return retailer;
    }
    function getRetailer()view public returns (address retailerAddress)
    {
        return retailer;
    }
   
    function saleFromManToDistr(address _from, address _to, address _fromBatch,string newNumberOfParty, string newDateCreated, uint  _amount)  public returns (address _batchAddress)
    {
        Manufacturer _manufacturer = Manufacturer(manufacturer);
        //address batchAddress =
        //(bool b, bytes  batchAddress) = 
        //manufacturer.call(bytes4(keccak256("saleBatchToDistributor(address, address, address, uint256, string, uint)")), _from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);  
        address batchAddress = _manufacturer.saleBatchToDistributor(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromDistrToDistr(address _from, address _to, address _fromBatch,string newNumberOfParty, string newDateCreated, uint  _amount)  public returns (address _batchAddress)
    {
        Distributor _distributor = Distributor(distributor);
        address batchAddress = _distributor.saleBatchToDistributor(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromDistrToRet(address _from, address _to, address _fromBatch,string newNumberOfParty, string newDateCreated, uint  _amount)  public returns (address _batchAddress)
    {
        Distributor _distributor = Distributor(distributor);
        address batchAddress = _distributor.saleBatchToRetailer(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromRetToRet(address _from, address _to, address _fromBatch,string newNumberOfParty, string newDateCreated, uint  _amount)  public returns (address _batchAddress)
    {
        Retailer _retailer = Retailer(retailer);    
        address batchAddress = _retailer.saleBatchToRetailer(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
  //  function saleFromRetToUser()public
   // {

//}

    function getBatchesCount(address batchAddress)private constant returns (uint)
    {
        uint count = 1;
        Batch lastBatch = Batch(batchAddress);
        while(lastBatch.getParentBatch() != address(0))
        {
          count = count +1 ;
            lastBatch = Batch(lastBatch.getParentBatch());
        }
        return count;
    }

    function getBatchHistory(address _lastBatch)private view returns (address[])
    {
         Batch lastBatch = Batch(_lastBatch);
        address[] memory adresses = new address[](getBatchesCount(_lastBatch));// = new address[tmpCount];
        uint count =0;
        adresses[count]=_lastBatch;
        while(lastBatch.getParentBatch() != address(0))
        {
            count = count+1;
            adresses[count]= lastBatch.getParentBatch();
            lastBatch = Batch(lastBatch.getParentBatch());
        }
    }
    function findHistoryProductById(bytes32 _id)public view returns (string memory name, string memory INN,  string memory form , address[] batchAddresses)
    {
        require(concreteProductsAccts[_id] != address(0));
      
        address lastBatchAddress = ConcreteProduct(concreteProductsAccts[_id]).getLastBatch();
        Batch lastBatch = Batch(lastBatchAddress);
        
        address productAddress = lastBatch.getProduct();
        Product product = Product(productAddress);
        
        address[] memory adresses = getBatchHistory(lastBatchAddress);
        
        (string memory _name, string memory _INN,  string memory _form) = product.getDetails();
        return (_name,_INN,_form, adresses);
    }
    
    function getBatchOwnerDetaild(address batchAddress)public view returns(string physicalAddress,string companyName,string firstName,string lastName,string email){
        Batch batch = Batch(batchAddress);    
        return batch.getOwnerDetails();
    }
    
    function getBatchDetails(address batchAddress)public view returns(string _numberOfParty,  string _expirationDate, string _dateCreated){
        Batch batch = Batch(batchAddress);    
        return batch.getBatchInfo();
    }
    
    //коли де небудь створюється продукт, то записувати про нього (address) інформацію в БД
    function addConcrateProduct(bytes32 _concreteProductId, address _concreteProductAddress) public
    {
        require(concreteProductsAccts[_concreteProductId] == address(0));
        concreteProducts.push(_concreteProductAddress);
        concreteProductsAccts[_concreteProductId] = _concreteProductAddress;

    }
    function createBatchaddress(address _manufacturerAcct,string _productName , string _productINN , string _productForm , string _numberOfParty, string _details,  string _dateCreated, uint  _size, bytes32[] _ids) public returns(address _addressBatch)
    {   
        Manufacturer _manufacturer = Manufacturer(manufacturer);
        Product _product = new Product(this,_productName, _productINN , _productForm);
        address batchAddress = _manufacturer.createBatch(_manufacturerAcct,  _product, _numberOfParty, _details,   _dateCreated,  _size,  _ids);
        return batchAddress;
    }
    
    
    
   
    // function createProduct
}