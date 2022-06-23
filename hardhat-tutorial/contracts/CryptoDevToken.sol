// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    // Price of one CD token is .001 ETH
    uint public constant tokenPrice = 0.001 ether;

    // 10 tokens per NFT will be given
    uint public constant tokensPerNFT = 10 * 10**18;
    uint public constant maxTotalSupply = 10000 * 10**18;

    // CryptoDevs Contract interface
    ICryptoDevs CryptoDevsNFT;

    // Keep track of which tokens have been claimed
    mapping(uint => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
     *@dev mints `amount` number of tokens
     */
    function mint(uint amount) public payable {
        // we need to receive greater than or equal to tokenPrice * amount
        uint _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Not enough ETH was sent");
        // we need to check that the amount of tokens does not exceed max supply
        uint amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Max supply exceeded"
        );
        _mint(msg.sender, amountWithDecimals);
    }

    /**
     *@dev mint tokens based on NFTs held by the message sender
     */
    function claim() public {
        address sender = msg.sender;
        uint balance = CryptoDevsNFT.balanceOf(sender);
        require(balance > 0, "No CryptoDevs NFTs found in wallet");
        uint amount = 0;
        for (uint i = 0; i < balance; i++) {
            uint tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            // if the tokenId has not been claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount = amount + 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        require(
            amount > 0,
            "All eligible tokens for this NFT have been claimed"
        );
        _mint(msg.sender, amount * tokensPerNFT);
    }

    /**
     *@dev withdraw all assets to the contract owner
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send");
    }

    receive() external payable {}

    fallback() external payable {}
}
