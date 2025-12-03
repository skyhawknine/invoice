# Invoice Smart Contract (Polygon)

A secure, robust on-chain solution for issuing, managing, and paying invoices in both native and ERC-20 tokens.

## Overview
This smart contract enables businesses, DAOs, and developers to seamlessly issue and process invoices directly on-chain. It acts as a decentralized invoice book, supporting both native (MATIC) and ERC-20 token payments, with on-chain tracking, event logs, and integration-ready API methods.

---

## Live Deployment

- **Network:** Polygon Mainnet
- **Contract Address:** [`0xD58D286197395C57Ee8dA820212Dda1194294313`](https://polygonscan.com/address/0xD58D286197395C57Ee8dA820212Dda1194294313)
- **Block Explorer:** [View on PolygonScan](https://polygonscan.com/address/0xD58D286197395C57Ee8dA820212Dda1194294313)

### Dashboard
- **Live Dashboard:** [https://bnl-invoice.red-triplane.com/](https://bnl-invoice.red-triplane.com/)
  
  The dashboard provides:
  - Real-time invoice search, filtering, and listing by ID, status, and more
  - Payment tracking and on-chain status updates
  - Easy access to contract information and deployment details
  - User-friendly interface with network-aware views
  - Public overview of all issued, paid, or cancelled invoices

---

## Features
- **Issue Invoices:** Issue new invoices for native or ERC-20 token payments
- **On-chain Status:** Track invoice status (ISSUED, PAID, CANCELLED, or expired)
- **Flexible Payments:** Accept payments in MATIC or any ERC-20 token
- **Batch Listing and Search:** Efficient batch retrieval and searching by invoice IDs
- **Robust Events:** Emits events for all key actions (issue, pay, cancel, expire)
- **Expiration Handling:** Automatically prevents payment/cancellation of expired invoices
- **Permissioned Cancellation:** Only the issuer can cancel an invoice
- **Secure Payments:** Leverages OpenZeppelin's SafeERC20 for token transfers and prevents accidental native transfers
- **Full Metadata:** Stores comprehensive deployment and configuration metadata

---

## Contract Overview
This smart contract implements a decentralized, auditable invoicing system. Invoices are recorded immutably on-chain, including:
- The issuer, payee, token type, amount, and expiration
- Payment details, including payer and payment block
- Strict enforcement of invoice statuses: only eligible invoices can be paid/cancelled
- Robust querying interfaces for integration with off-chain apps, bots, or dashboards

**Main Use Cases:**
- Businesses or freelancers issuing invoices to clients
- DAOs tracking grant, bounty, or reimbursement payments
- Developers and dApps integrating on-chain payment requests

---

## Technical Details

### Contract Structure

- **Main Contract:** `InvoiceContract`
- **Key Data Structures:**
  - `ContractInfo`: Metadata about this deployment (name, version, network, etc.)
  - `InvoiceData`: On-chain record per invoice (issuer, payee, token, status, etc.)
  - `InvoiceStatus` (enum): `ISSUED` (0), `PAID` (1), `CANCELLED` (2)
- **Core Events:** `InvoiceIssued`, `InvoicePaid`, `InvoiceCancelled`, `InvoiceExpired`
- **Security:**
  - Only issuer can cancel
  - Expired invoices cannot be paid or cancelled
  - Utilizes SafeERC20 for all ERC-20 operations
  - Reverts on direct native token transfers to the contract

### Key Functions

- `issueInvoice(...)`: Issues a new invoice with relevant parameters
- `payInvoice(invoiceId)`: Pays a specified invoice if payable (in MATIC/ERC-20)
- `cancelInvoice(invoiceId)`: Cancellation (by issuer, only if eligible)
- `findInvoices(invoiceIds)`: Batch lookup of invoices by ID
- `listInvoices(batchOffset, batchSize)`: Paginated on-chain listing
- `getContractInfo()`: Returns network, deployer, and contract metadata
- `totalNumberOfInvoices()`: Count of invoices ever issued

#### InvoiceData Structure (per invoice)
```solidity
struct InvoiceData {
  string invoiceId;           // Unique 32-byte ID
  address issuedBy;           // Issuer address
  address erc20TokenAddress;  // Token used (address(0) for native)
  address payToAddress;       // Payment recipient
  uint256 amount_in18decAtoms;// Amount (18 decimals precision)
  uint256 issuedAt;           // Timestamp
  uint256 expiresAt;          // Expiry timestamp
  InvoiceStatus status;       // 0=ISSUED, 1=PAID, 2=CANCELLED
  address paidBy;             // Who paid
  uint256 paidAtBlockNumber;  // Payment block
  bool isNativeToken;         // True for MATIC, false for ERC-20
}
```

#### InvoiceStatus Enum
```solidity
enum InvoiceStatus {
  ISSUED,     // 0
  PAID,       // 1
  CANCELLED   // 2
}
```

---

## Usage Instructions

### Issuing an Invoice
To issue an invoice:
```python
# Example using web3.py or similar integration
contract.functions.issueInvoice(
    invoiceId,                 # Unique 32-byte string (recommended: hex)
    erc20TokenAddress,         # Address of ERC-20 token or 0x0 for native/MATIC
    payToAddress,              # Address to receive payment
    amount_in18decAtoms,       # Amount (in 1e18 for MATIC or equivalent)
    expiresAt                  # Invoice expiry as unix timestamp
).transact({'from': issuer_address})
```

### Paying an Invoice

For a native MATIC payment:
```python
contract.functions.payInvoice(invoiceId).transact({
    'from': payer_address,
    'value': amount_in18decAtoms # Send the correct MATIC amount
})
```

For ERC-20 token payments:
```python
# Approve first!
token.functions.approve(
    contract_address,
    token_amount_in_token_decimals
).transact({'from': payer_address})

# Then pay:
contract.functions.payInvoice(invoiceId).transact({'from': payer_address})
```

### List Invoices
Batch retrieval (useful for pagination):
```python
contract.functions.listInvoices(batchOffset, batchSize).call()
```

### Find Invoices By IDs
```python
contract.functions.findInvoices([id1, id2, ...]).call()
```

### Get Contract Info
```python
contract.functions.getContractInfo().call()
```

---

## Important Notes
- **Invoice IDs must be exactly 32 bytes** (for compatibility with contract mapping keys).
- **Expiration is enforced:** Expired invoices cannot be paid/cancelled; expired events are emitted if applicable.
- **Issuer controls cancellation:** Only the creator may cancel, if unpaid/uncancelled/unexpired.
- **Decimal Handling:** All amounts are stored in 1e18/"18 decimals" format for standardization; conversion is auto-handled for ERC-20 tokens with different decimals.
- **Direct Deposit Prohibited:** Sending native tokens directly to the contract will revert.
- **Security:** All ERC-20 transfers utilize SafeERC20 to prevent stuck tokens and failed transfers.

---

## License

This project is licensed under the [MIT License](LICENSE). All code and documentation herein are open for public use and modification, provided original rights and attributions are preserved.

---

For more information, or to interact with the contract directly, visit the [live dashboard](https://bnl-invoice.red-triplane.com/) or inspect the deployment on [PolygonScan](https://polygonscan.com/address/0xD58D286197395C57Ee8dA820212Dda1194294313).
