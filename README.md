# spot-the-bug-demo

> [!WARNING]
> **This repository is INTENTIONALLY VULNERABLE.**
> The contracts on the `bugs/*` branches contain well-known, exploitable bugs on purpose.
> **Never deploy any of this code** to mainnet, a testnet, or anywhere real funds or users are involved.

## Purpose

This is a demo and test bed for **[Spot the Bug](https://github.com/wkalidev/spot-the-bug-action)**, a GitHub Action that runs static analysis on Solidity pull requests and comments with the findings.

- `main` holds a clean Foundry project with one safe contract (`src/SafeVault.sol`) and the workflow.
- `bugs/*` branches add vulnerable contracts. Opening a pull request from one of them into `main` triggers the action so you can see real findings on a real PR.

## Vulnerable contracts (`bugs/round-1`)

| Contract | Bug | Real-world reference |
| --- | --- | --- |
| `src/vulns/ParityStyleLibrary.sol` | Unprotected initializer + `selfdestruct` | Parity multisig library, 2017 |
| `src/vulns/TxOriginWallet.sol` | Authorization via `tx.origin` | Classic phishing pattern (SWC-115) |
| `src/vulns/ReentrantBank.sol` | Reentrancy (external call before state update) | The DAO, 2016 |
| `src/vulns/UncheckedToken.sol` | Unchecked ERC20 `transfer` return value | Non-reverting tokens (e.g. ZRX, BAT) |
| `src/vulns/ArbitrarySend.sol` | Anyone can send contract ETH anywhere | Unprotected withdraw functions (SWC-105) |

## Workflow

`.github/workflows/spot-the-bug.yml` runs on every pull request:

1. `actions/checkout@v4` with submodules (for `forge-std`).
2. `foundry-rs/foundry-toolchain@v1` so Slither can compile via `forge`.
3. `wkalidev/spot-the-bug-action@main` with `fail-on: high`.

## Local usage

```sh
git clone --recurse-submodules https://github.com/wkalidev/spot-the-bug-demo
cd spot-the-bug-demo
forge build
forge test
slither .
```

## License

[MIT](LICENSE)

<!-- test: README-only change, this PR will be closed -->
