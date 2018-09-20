pragma solidity ^0.4.24;
import "./Owned.sol";
import "./Retailer.sol";
import "./Manufacturer.sol";
import "./Distributor.sol";
import "./Batch.sol";
import "./Product.sol";
import "./ConcreteProduct.sol";

contract DataBase is Owned {

    address retailer;
    address manufacturer;
    address distributor;

    address[] concreteProducts;
    mapping(address=>bool) concreteProductsAccts;
    
    function createDistributor() onlyOwner public returns  (address distributorAddress) 
    {
        require(distributor == address(0));
        distributor = new Distributor(this);
        return distributor;
    }
    function getDistributor()view public returns (address distributorAddress)
    {
        return distributor;
    }
    
    function createManufacturer() onlyOwner public returns (address manufacturerAddress)  
    {
        require(manufacturer == address(0));
        manufacturer = new Manufacturer(this);
        return manufacturer;
    }
    function getManufacturer() view public returns (address manufacturerAddress)
    {
        return manufacturer;
    }
    
    function createRetailer() onlyOwner public returns (address retailerAddress)  
    {
        require(retailer == address(0));
        retailer = new Retailer(this);
        return retailer;
    }
    function getRetailer()view public returns (address retailerAddress)
    {
        return retailer;
    }
   
    function saleFromManToDistr(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount)view  public returns (address _batchAddress)
    {
        Manufacturer _manufacturer = Manufacturer(manufacturer);
        address batchAddress = _manufacturer.saleBatchToDistributor(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromDistrToDistr(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount)view  public returns (address _batchAddress)
    {
        Distributor _distributor = Distributor(distributor);
        address batchAddress = _distributor.saleBatchToDistributor(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromDistrToRet(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount)view  public returns (address _batchAddress)
    {
        Distributor _distributor = Distributor(distributor);
        address batchAddress = _distributor.saleBatchToRetailer(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromRetToRet(address _from, address _to, address _fromBatch,uint256 newNumberOfParty, string newDateCreated, int _amount)view  public returns (address _batchAddress)
    {
        Retailer _retailer = Retailer(retailer);    
        address batchAddress = _retailer.saleBatchToRetailer(_from, _to, _fromBatch,newNumberOfParty, newDateCreated, _amount);
        return batchAddress;
    }
    function saleFromRetToUser()public
    {

    }
    function findHistoryProductById(bytes32 _id)public
    {

    }
    function findHistoryProductByQR(bytes32 _QR)public
    {
        
    }
    //коли де небудь створюється продукт, то записувати про нього (address) інформацію в БД
    function saveProductInfo(address _concreteProduct) public
    {
        require(concreteProductsAccts[_concreteProduct] == false);
        concreteProducts.push(_concreteProduct);
        concreteProductsAccts[_concreteProduct] = true;

    }
    // function createProduct
}