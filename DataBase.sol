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
}
contract DataBase is Owned {

    address retailer;
    address manufacturer;
    address distributor;

    address[] products;
    mapping(address=>bool) productsAccts;


    address[] concreteProducts;
    mapping(address=>bool) concreteProductsAccts;
    
     
    
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
   
    function saleFromManToDistr(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, uint  _amount)  public returns (address _batchAddress)
    {
        Manufacturer _manufacturer = Manufacturer(manufacturer);
        //address batchAddress =
        //(bool b, bytes  batchAddress) = 
        //manufacturer.call(bytes4(keccak256("saleBatchToDistributor(address, address, address, uint256, string, uint)")), _from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);  
        address batchAddress = _manufacturer.saleBatchToDistributor(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromDistrToDistr(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, uint  _amount)  public returns (address _batchAddress)
    {
        Distributor _distributor = Distributor(distributor);
        address batchAddress = _distributor.saleBatchToDistributor(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromDistrToRet(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, uint  _amount)  public returns (address _batchAddress)
    {
        Distributor _distributor = Distributor(distributor);
        address batchAddress = _distributor.saleBatchToRetailer(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromRetToRet(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, uint  _amount)  public returns (address _batchAddress)
    {
        Retailer _retailer = Retailer(retailer);    
        address batchAddress = _retailer.saleBatchToRetailer(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
  //  function saleFromRetToUser()public
   // {

//}
  /*  function findHistoryProductById(bytes32 _id)public
    {

    }
    */
    //коли де небудь створюється продукт, то записувати про нього (address) інформацію в БД
    function saveProductInfo(address _concreteProduct) public
    {
        require(concreteProductsAccts[_concreteProduct] == false);
        concreteProducts.push(_concreteProduct);
        concreteProductsAccts[_concreteProduct] = true;

    }
    function createBatchaddress(address _manufacturerAcct,string _productName , string _productGeneric , string _productForm , uint256 _numberOfParty, string _details,  string _dateCreated, uint  _size, bytes32[] _ids) public returns(address _addressBatch)
    {   
        Manufacturer _manufacturer = Manufacturer(manufacturer);
        Product _product = new Product(this,_productName, _productGeneric , _productForm);
        address batchAddress = _manufacturer.createBatch(_manufacturerAcct,  _product, _numberOfParty, _details,   _dateCreated,  _size,  _ids);
        return batchAddress;
    }
    
    
   
    // function createProduct
}