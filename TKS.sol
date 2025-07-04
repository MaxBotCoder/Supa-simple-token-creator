//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract MyToken {

    mapping(address => bool) Admin;

    //Price of token & token minted.
    uint public TokenPrice;
    uint public TokensMinted;
    
    //Token name & token symbol
    string public TokenName;
    string public TokenSymbol;

    modifier Privaledges() {
        require(Admin[msg.sender] == true, "Insufficent Permissions");
        _;
    }

    modifier Purchaseable(uint _Quantity) {
        require(_Quantity <= TokensMinted, "No stock left.");
        require(msg.value >= TokenPrice * _Quantity, "Not Enough Funds.");
        _;
    }

    function _MintToken(uint _Amount) public Privaledges() {
        TokensMinted += _Amount;
    }
    
    function _ChangeTokenPrice(uint _NewPrice) public Privaledges() {
        TokenPrice = _NewPrice;
    }

}

contract ConsumerInterface is MyToken {

    mapping(address => uint) public TokensOwnedByPerson;

    constructor (string memory _TokenName, string memory _TokenSymbol, uint _TokensMinted, uint _TokenPrice) {
        Admin[msg.sender] = true;
        _MintToken(_TokensMinted);
        _ChangeTokenPrice(_TokenPrice);
        TokenName = _TokenName;
        TokenSymbol = _TokenSymbol;
    }

    function ViewTokenData () public view returns (string memory _Name, string memory _Symbol, uint _TokenPrice) {
        return (TokenName, TokenSymbol ,TokenPrice);
    }

    event PurchaseEvent(address indexed _WhoPurchased, string indexed _WhatItem, uint indexed Quantity);

    function Purchase (uint _Quantity) payable public Purchaseable(_Quantity) {
        TokensMinted -= _Quantity;
        TokensOwnedByPerson[msg.sender] += _Quantity;
        emit PurchaseEvent( msg.sender, TokenName , _Quantity);
    }
    
}
