# MultiSig Wallet

A simple multi-signature wallet contract built in Solidity. The wallet allows a set of owners to propose transactions and requires a configurable number of confirmations before a transaction can be executed.

## Overview

This contract implements a basic M-of-N multisig pattern:

- A list of authorized owners is stored at deployment.
- Any owner can submit a transaction for execution.
- Owners confirm the transaction by calling `confirmTransaction`.
- Once the required number of confirmations is reached, the transaction is executed automatically.
- Funds can be sent with the transaction value and arbitrary calldata.

## Contract Features

- `owners`: list of wallet owners
- `required`: minimum number of confirmations required
- `transactionCount`: total number of submitted transactions
- `transactions`: mapping of transaction ID to transaction details
- `confirmations`: per-transaction confirmation tracking by owner
- `receive()`: allows the contract to accept ETH payments

## Contract Structure

The main contract is located at:

- `src/Multisig.sol`

The constructor accepts:

```solidity
constructor(address[] memory _owners, uint _confirmations)
```

It enforces:

- at least one owner
- a positive confirmation threshold
- threshold cannot exceed number of owners

## Usage

### Prerequisites

- [Foundry](https://book.getfoundry.sh/)

### Install dependencies

```bash
foundryup
```

### Compile

```bash
forge build
```

### Run tests

```bash
forge test
```

### Start a local node

```bash
anvil
```

### Deploy the contract

```bash
forge create src/Multisig.sol:MultiSig \
  --constructor-args "[0xOwner1, 0xOwner2, 0xOwner3]" 2
```

> Replace the addresses with your actual owner wallet addresses and set the confirmation threshold as needed.

## Example Flow

```solidity
address[] memory owners = new address[](3);
owners[0] = 0x1111...;
owners[1] = 0x2222...;
owners[2] = 0x3333...;

MultiSig wallet = new MultiSig(owners, 2);

wallet.submitTransaction(
    0xRecipientAddress,
    1 ether,
    hex""
);

wallet.confirmTransaction(0);
```

In this example, the wallet requires 2 confirmations. After the second owner confirms the transaction, the contract executes the call automatically.

## Notes

- `submitTransaction` calls `confirmTransaction` internally, so the submitting owner immediately counts as a confirmation.
- `executeTransaction` requires that the transaction has reached the required confirmation count.
- If the underlying call fails, the execution reverts and the transaction does not complete.

## Useful Foundry Commands

```bash
forge build
forge test
forge fmt
forge snapshot
cast --help
anvil --help
```

## License

MIT
