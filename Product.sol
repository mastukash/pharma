pragma solidity ^0.4.24;

contract Product 
{
    address DATABASE_CONTRACT;

    string name;
    string generic;
    string form;
    
    constructor(address _DATABASE_CONTRACT, string _name, string _generic,  string _form) public
    {
        DATABASE_CONTRACT = _DATABASE_CONTRACT;
        name = _name;
        generic = _generic;
        form = _form;
    }
    function getDetails() view public returns(string _name, string _generic,  string _form)
    {
        return (name,generic,form);
    }
}
