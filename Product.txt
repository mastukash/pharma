pragma solidity ^0.4.24;

contract Product 
{
    address DATABASE_CONTRACT;

    uint256 price;
    string name;
    string dateCreate;
    
    
    constructor(address _DATABASE_CONTRACT, uint256 _price, string _name, string _dateCreate) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;
    }
    function getDetails() view public returns(uint256 price, string name,  string dateCreate)
    {
        return (price,name,dateCreate);
    }
}
