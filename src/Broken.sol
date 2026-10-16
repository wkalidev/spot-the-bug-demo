// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Broken {
    function f() public { this is not solidity }
}
