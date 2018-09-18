pragma solidity ^0.4.24;
import "./Owned.sol";
import "./Retailer.sol";
import "./Manufacturer.sol";
import "./Distributor.sol";

contract DataBase is Owned {

    address retailer;
    address manufacturer;
    address distributor;
    
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
}