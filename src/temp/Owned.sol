// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// Temporary contract for testing; transferOwnership lacks a zero-address check.
contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "not owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
