pragma solidity ^0.4.24;
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
   
    function saleFromManToDistr(address _from, address _to, bytes32[] _items)  public returns (address _batchAddress)
    {
        Manufacturer _manufacturer = Manufacturer(manufacturer);
        address batchAddress = _manufacturer.saleBatchToDistributor(_from, _to, _items);
        return batchAddress;
    }
    function saleFromDistrToDistr(address _from, address _to, bytes32[] _items)  public returns (address _batchAddress)
    {
        Distributor _distributor = Distributor(distributor);
        address batchAddress = _distributor.saleBatchToDistributor(_from, _to, _items);
        return batchAddress;
    }
    function saleFromDistrToRet(address _from, address _to, bytes32[] _items)  public returns (address _batchAddress)
    {
        Distributor _distributor = Distributor(distributor);
        address batchAddress = _distributor.saleBatchToRetailer(_from, _to, _items);
        return batchAddress;
    }
    
  //  function saleFromRetToUser()public
   // {

//}

    function getItemBatchAddress(bytes32 _itemId)public view returns (address _lastBatch)
    {
        address _itemAddress = concreteProductsAccts[_itemId];
        require (_itemAddress != address(0));
        ConcreteProduct _item = ConcreteProduct(_itemAddress);
        
        return _item.getLastBatch();
    }
    
    function getItemAddress(bytes32 _itemId)public view returns (address _itemAddress)
    {
        require (concreteProductsAccts[_itemId] != address(0));
        return concreteProductsAccts[_itemId];
    }

    function getBatchesCount(address batchAddress)public constant returns (uint)
    {
        Batch lastBatch = Batch(batchAddress);
        uint count =0;
        while(batchAddress != address(0))
        {
            batchAddress = lastBatch.getParentBatch();
            lastBatch = Batch(batchAddress);
            count = count+1;
        }
        return count;
    }

    function getBatchHistory(address _lastBatch)public view returns (address[])
    {
        Batch lastBatch = Batch(_lastBatch);
        uint  batchesCount = getBatchesCount(_lastBatch);
        address[] memory adresses = new address[](batchesCount);// = new address[tmpCount];
        uint count =0;
        while(_lastBatch != address(0))
        {
            adresses[count]=  _lastBatch;
            _lastBatch = lastBatch.getParentBatch();
            lastBatch = Batch(_lastBatch);
            count = count+1;
        }
        return adresses;
    }
    function findHistoryProductById(bytes32 _id)public view returns (string memory name, string memory INN,  string memory form , address[] batchAddresses)
    {
        require(concreteProductsAccts[_id] != address(0));
      
        address lastBatchAddress = ConcreteProduct(concreteProductsAccts[_id]).getLastBatch();
        Batch lastBatch = Batch(lastBatchAddress);
        
        address productAddress = lastBatch.getProduct();
        Product product = Product(productAddress);
        
        address[] memory adresses = getBatchHistory(lastBatchAddress);
        
        (string memory _name, string memory _INN,  string memory _form) = product.getInfo();
        return (_name,_INN,_form, adresses);
    }
    
    function getBatchOwnerDetails(address batchAddress)public view returns(string physicalAddress,string companyName,MyLibrary.ConsumerType _type){
        Batch batch = Batch(batchAddress);    
        return batch.getOwnerInfo();
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
    function createBatchaddress(address _manufacturerAcct,string _productName , string _productINN , string _productForm , string _numberOfParty, string _expirationDate,  string _dateCreated, uint  _size, bytes32[] _ids) public returns(address _addressBatch)
    {   
        Manufacturer _manufacturer = Manufacturer(manufacturer);
        Product _product = new Product(this,_productName, _productINN , _productForm);
        address batchAddress = _manufacturer.createBatch(_manufacturerAcct,  _product, _numberOfParty, _expirationDate,   _dateCreated,  _size,  _ids);
        return batchAddress;
    }
   
    // function createProduct
}