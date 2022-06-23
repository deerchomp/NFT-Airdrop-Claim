// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface ICryptoDevs {
    /**
     *@dev Returns a token ID owned by 'owner' at a given 'index'
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.abi
     */
    function tokenOfOwnerByIndex(address owner, uint index)
        external
        view
        returns (uint tokenId);

    /**
     *@dev returns the number of tokens in owner's account
     */
    function balanceOf(address owner) external view returns (uint balance);
}
