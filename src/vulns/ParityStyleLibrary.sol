// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @notice Minimal hand-rolled initializer guard, OpenZeppelin-style.
abstract contract Initializable {
    bool private _initialized;

    modifier initializer() {
        require(!_initialized, "already initialized");
        _initialized = true;
        _;
    }
}

/// @title ParityStyleLibrary
/// @notice Shared wallet logic meant to be used through delegatecall by many wallet proxies.
/// @dev INTENTIONALLY VULNERABLE — unprotected initializer + selfdestruct on the implementation.
/// Reference: Parity multisig library hack (Nov 2017). The shared WalletLibrary was never
/// initialized, so anyone could call initWallet() to become its owner, then kill() it.
/// ~513k ETH in every wallet that delegated to it was frozen forever.
contract ParityStyleLibrary is Initializable {
    address public owner;

    event OwnerSet(address indexed owner);

    // BUG: anyone can call this on the implementation itself, since the constructor
    // never initializes or disables it.
    function initWallet(address _owner) external initializer {
        owner = _owner;
        emit OwnerSet(_owner);
    }

    function execute(address to, uint256 value, bytes calldata data) external returns (bytes memory) {
        require(msg.sender == owner, "not owner");
        (bool ok, bytes memory ret) = to.call{value: value}(data);
        require(ok, "call failed");
        return ret;
    }

    // BUG: once an attacker owns the implementation, this destroys the code
    // every proxy delegates to.
    function kill(address payable to) external {
        require(msg.sender == owner, "not owner");
        selfdestruct(to);
    }
}
