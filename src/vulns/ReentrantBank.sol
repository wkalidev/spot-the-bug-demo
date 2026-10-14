// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title ReentrantBank
/// @notice ETH bank where users deposit and withdraw their balance.
/// @dev INTENTIONALLY VULNERABLE — reentrancy: ETH is sent before the balance is updated.
/// Reference: The DAO hack (June 2016), ~3.6M ETH drained via recursive splitDAO() calls,
/// which led to the Ethereum / Ethereum Classic hard fork.
contract ReentrantBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");

        // BUG: interaction before effect. A contract receiver can re-enter withdraw()
        // while its balance is still non-zero.
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        balances[msg.sender] = 0;
    }
}
