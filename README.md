# Invoice.sol: On-Chain Invoicing Smart Contract

## Overview

**Invoice.sol** is a robust, multi-network Solidity smart contract for managing, issuing, paying, and tracking invoices entirely on-chain. This enables secure, automated invoice workflows for businesses, DAOs, and individual users, supporting both native and ERC-20 token payments on any EVM-compatible blockchain.

This repository provides the complete contract source code, deployment information, and supporting documentation for integrating InvoiceContract into your dApp or workflow.

---

## Live Deployment

### Polygon Mainnet
- **Contract Address:** [`0xD58D286197395C57Ee8dA820212Dda1194294313`](https://polygonscan.com/address/0xD58D286197395C57Ee8dA820212Dda1194294313)
- **Network:** Polygon Mainnet

### Dashboard
- **Web Dashboard:** [https://bnl-invoice.red-triplane.com/](https://bnl-invoice.red-triplane.com/)

The dashboard provides an interactive interface for users to:
- View, filter, and search all invoices on-chain
- Track real-time invoice status, payments, and history
- Instantly access contract details and network-specific data
- Manage invoices across supported EVM networks with a unified UI

---

## Features

- **On-chain Invoice Management:** Issue, cancel, and query invoices directly via blockchain.
- **Native & ERC-20 Payments:** Supports network native tokens (ETH on Mainnet, POL on Polygon, etc.) and any ERC-20 token.
- **Multi-Network Support:** Deployable to any EVM-compatible chain; tested on Polygon Mainnet.
- **Rich Metadata:** Every invoice contains all required data, including issuer, payee, amount (18 decimals), currency, and expiry.
- **Transparent Status Tracking:** Real-time updates on invoice state—ISSUED, PAID, or CANCELLED—fully auditable on-chain.
- **Batch & Paginated Queries:** Efficient methods for listing and retrieving large sets of invoices.
- **Dashboard Integration:** User-friendly interface for non-technical users and back-office operations.
- **Strong Security:** Permission checks and strict validation to prevent unauthorized actions and ensure data integrity.

---

## Contract Overview

**InvoiceContract** acts as an on-chain invoice book. Each invoice is tied to a unique 32-byte identifier and stores payer/payee info, amount, token/currency type, expiry, and payment status. Invoices can be:
- **Issued** by any user or smart contract
- **Paid** in native or ERC-20 tokens, with proper amount/account checks
- **Cancelled** by the issuer before payment or expiry

**Main Use Cases:**
- Automating B2B or DAO payments and settlements
- On-chain accounting and audit for services or goods
- Payment gateways for SaaS or subscription models

---

## Technical Details

### Contract Structure
- **Structs:**
  - `ContractInfo`: Metadata about deployment, version, and environment
  - `InvoiceData`: All details for each invoice (see below)
- **Enum:**
  - `InvoiceStatus`: {ISSUED, PAID, CANCELLED}
- **Mappings:**
  - `invoicesStorage`: Maps 32-byte UUID to stored `InvoiceData`

### Data Structures

#### InvoiceData
| Field               | Type      | Description                                                                                   |
|---------------------|-----------|-----------------------------------------------------------------------------------------------|
| invoiceId           | string    | Unique 32-byte ID of the invoice                                                              |
| issuedBy            | address   | Address that issued the invoice                                                               |
| erc20TokenAddress   | address   | Token for payment (zero address for native token)                                             |
| payToAddress        | address   | Address to receive payment                                                                    |
| amount_in18decAtoms | uint256   | Amount, always 18 decimal atoms (normalized to token decimals if needed)                      |
| issuedAt            | uint256   | Timestamp when invoice was issued                                                             |
| expiresAt           | uint256   | Timestamp when invoice expires                                                                |
| status              | enum      | ISSUED (0), PAID (1), CANCELLED (2)                                                           |
| paidBy              | address   | Payer (populated on payment)                                                                  |
| paidAtBlockNumber   | uint256   | Block number at time of payment                                                               |
| isNativeToken       | bool      | True if native token (ERC-20 address is zero)                                                 |

#### ContractInfo
| Field            | Type    | Description                                    |
|------------------|---------|------------------------------------------------|
| name             | string  | Deployed contract/app name                      |
| version          | string  | Application version                             |
| networkName      | string  | Target network name                             |
| contractAddress  | address | This contract's address                         |
| deployer         | address | Deployer's address                              |
| description      | string  | Deployment description                          |
| deployedAt       | uint256 | Block number at which deployed                  |
| compilerVersion  | string  | Solidity version used                           |
| chainId          | uint256 | EVM chain ID                                    |
| interfaceId      | string  | Arbitrary interface/API version identifier       |

### Key Functions and Events

- `issueInvoice(...)`: Issues a new invoice with all required data; emits `InvoiceIssued` event.
- `payInvoice(invoiceId)`: Pay an invoice—validates status, expiry, payer's funds/allowance; emits `InvoicePaid` event.
- `cancelInvoice(invoiceId)`: Issuer may cancel an open, non-paid invoice; emits `InvoiceCancelled`.
- `findInvoices(invoiceIds[])`: Retrieve multiple invoices by ID.
- `listInvoices(batchOffset, batchSize)`: Paginated listing for batch/query processing.
- `totalNumberOfInvoices()`: Returns total count for UI/accounting.
- `getContractInfo()`: Returns deployment metadata.

**Events:**
- `InvoiceIssued`
- `InvoicePaid`
- `InvoiceCancelled`
- `InvoiceExpired`

---

## Usage

### Accessing the Contract

#### On-Chain (Web3/Ethers/Hardhat)

```solidity
// Example using ethers.js
const contract = new ethers.Contract(
  '0xD58D286197395C57Ee8dA820212Dda1194294313',
  InvoiceContractABI,
  providerOrSigner
);
```

#### Python/Web3.py Example
```python
contract = web3.eth.contract(address='0xD58D286197395C57Ee8dA820212Dda1194294313', abi=InvoiceContract_ABI)
```

### Issuing an Invoice

```python
invoice_id = b'myuniqueinvoiceidxxxxxxxxxx......'  # must be exactly 32 bytes (string/hex)
tx = contract.functions.issueInvoice(
    invoice_id,
    Web3.toChecksumAddress('0x0000000000000000000000000000000000000000'),  # Native POL
    Web3.toChecksumAddress('0xRecipientAddress...'),
    int(1 * (10**18)),  # 1 POL or 1 ERC20 in 18 decimals
    expiresAtTimestamp
).transact({'from': myaddress})
```

### Paying an Invoice (Native or ERC-20)
- For native token (POL): send `msg.value` equal to `amount_in18decAtoms`.
- For ERC-20 tokens: approve the contract before calling `payInvoice`.

```python
# Pay native token
contract.functions.payInvoice(invoice_id).transact({
    'from': user,
    'value': invoice_amount
})

# Pay via ERC-20
erc20_token.functions.approve(contract_address, invoice_amount).transact({'from': payer})
contract.functions.payInvoice(invoice_id).transact({'from': payer})
```

### Querying Invoices
```python
# Get all invoices (paginated)
batch = contract.functions.listInvoices(0, 50).call()
# Get one or more by ID
invoice = contract.functions.findInvoices([invoice_id]).call()
```

### Canceling an Invoice
Issuer only:
```python
contract.functions.cancelInvoice(invoice_id).transact({'from': issuer})
```

---

## Important Notes
- **Invoice IDs MUST be exactly 32 bytes** (hex string or utf-8 string of 32 characters).
- For ERC-20 invoices, allowance and decimals conversion are handled internally.
- Only the issuer can cancel an invoice before it's paid/expired.
- Expired invoices cannot be paid or cancelled.
- Direct native token (POL) transfers to the contract are rejected for security.

---

## License

This project and smart contract are licensed under the [MIT License](./LICENSE).
