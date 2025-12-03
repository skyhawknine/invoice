# Invoice.sol: On-Chain Invoicing Smart Contract

## Overview

**Invoice.sol** is a robust, multi-network Solidity smart contract for managing, issuing, paying, and tracking invoices entirely on-chain. This enables secure, automated invoice workflows for businesses, DAOs, and individual users, supporting both native and ERC-20 token payments on any EVM-compatible blockchain.

---

## Live Deployment

This contract supports multiple EVM networks. Here are current live deployments:

### Polygon Mainnet
- **Contract Address:** [`0x63e47242e1e1272E801783bf37fd525B4A597fFD`](https://polygonscan.com/address/0x63e47242e1e1272E801783bf37fd525B4A597fFD)
- **Network:** Polygon Mainnet

### Dashboard
- **Web Dashboard:** [https://bnl-invoice.red-triplane.com/](https://bnl-invoice.red-triplane.com/)
- **Features:**
  - Interactive invoice browsing and search
  - Filter by invoice ID, status, dates, or parties
  - Real-time status updates
  - Payment tracking and full history
  - Network-specific views for all supported blockchains
  - Visual contract and transaction info

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

**InvoiceContract** is a general-purpose, auditable invoice system designed for:
- _Business-to-business (B2B) settlements_
- _Service marketplaces_
- _Automated payment collection_
- _Web3 accounting tools_
- _Payment integrations for dApps and DAOs_

**Lifecycle:**
1. **Issue:** Authorized address issues a new invoice with a unique 32-byte ID, payable amount, token address (ERC-20 or native), payee, and expiry date.
2. **Payment:** Any user may pay an `ISSUED` invoice before expiry, transferring the required asset (POL or ERC-20) to the payee directly.
3. **Cancel:** Issuer can cancel their own `ISSUED` invoices before they are paid or expired.
4. **Tracking:** The status (`ISSUED`, `PAID`, `CANCELLED`) is maintained on-chain, with events emitted at each update.
5. **Query:** Users and dApps can query invoice status, details, and full paginated listings at any time.

---

## Technical Details

### Contract Structure

- **Enums:**
  - `InvoiceStatus`: `ISSUED` (0), `PAID` (1), `CANCELLED` (2).
- **Structs:**
  - `InvoiceData`: all invoice parameters and metadata.
  - `ContractInfo`: deployment metadata (name, version, network, chain ID, etc.).
- **Mappings and Storage:**
  - Invoices are stored in a mapping keyed by 32-byte ID; IDs are stored in a global array for pagination.
- **Events:**
  - Emitted for issue, payment, cancellation, and expiry.
  
### Key Data Structures

#### `InvoiceData` fields
- `invoiceId`: string (32 bytes)
- `issuedBy`: invoice creator address
- `erc20TokenAddress`: ERC-20 token address or zero for native token
- `payToAddress`: payment recipient
- `amount_in18decAtoms`: invoice amount (always 18 decimals; adjusted for tokens at payment)
- `issuedAt`: UNIX timestamp when issued
- `expiresAt`: UNIX timestamp for expiry
- `status`: enum (`ISSUED`, `PAID`, `CANCELLED`)
- `paidBy`: payer address (if paid)
- `paidAtBlockNumber`: block when paid
- `isNativeToken`: true for native POL payments

#### `ContractInfo` fields
- `name`, `version`, `networkName`, `description`
- `contractAddress`, `deployer`, `deployedAt`, `chainId`, `compilerVersion`, `interfaceId`

### Important Functions

#### Read Methods
- `findInvoices(invoiceIds)`: Batch lookup by one or more invoice IDs.
- `listInvoices(batchOffset, batchSize)`: Paginated query of all invoices.
- `totalNumberOfInvoices()`: Current invoice count.
- `getContractInfo()`: Returns all deployment metadata.

#### Write Methods
- `issueInvoice(...)`: Create an invoice (must use unique 32-byte string ID).
- `cancelInvoice(invoiceId)`: Issuer cancels an existing, non-expired, non-paid invoice.
- `payInvoice(invoiceId)`: Pays a single invoice using ERC-20 or native POL (auto-detects/token conversions).

---

## Usage

### Issuing a New Invoice

```solidity
// Example call from a dApp (pseudo-code)
contract.issueInvoice(
  invoiceId,             // 32-byte string, must be unique
  erc20TokenAddress,     // ERC-20 token contract or '0x000...' for native POL
  payToAddress,          // recipient address
  amount_in18decAtoms,   // amount in 18-decimal precision
  expiresAt              // UNIX timestamp when expires
)
```

- Invoice IDs **must be exactly 32 bytes** in length and unique.
- The issuer will be the transaction sender.
- For native POL, set `erc20TokenAddress = 0x0000000000000000000000000000000000000000`.

### Paying an Invoice

1. **Check invoice details**: (`findInvoices` or `listInvoices`). Verify status is `ISSUED` and not expired.
2. **For ERC-20 payment:**
   - Approve this contract to spend the required amount (`approve(contractAddress, amount)` on the token contract).
   - Call `payInvoice(invoiceId)` from the paying account. Do **not** send native tokens.
3. **For native POL payment:**
   - Call `payInvoice(invoiceId)`, supplying the required POL amount as `msg.value`.

### Cancelling an Invoice

- Only the original issuer can cancel a non-paid, non-expired `ISSUED` invoice:
  ```solidity
  contract.cancelInvoice(invoiceId);
  ```

### Querying Invoices

- **List all invoices (paginated):**
  ```solidity
  contract.listInvoices(batchOffset, batchSize);
  ```
- **Read contract metadata:**
  ```solidity
  contract.getContractInfo();
  ```

### Example (Web3.js)

Issue invoice (POL):
```js
await contract.methods.issueInvoice(
  invoiceId,
  '0x0000000000000000000000000000000000000000',
  payToAddress,
  web3.utils.toWei('100', 'ether'), // 100 POL, 18 decimals
  Math.floor(Date.now() / 1000) + 7*24*60*60 // expires in a week
).send({from: issuerAddr});
```

Pay invoice (ERC-20):
```js
// First, approve token transfer:
await erc20Token.methods.approve(contractAddress, amount).send({from: payerAddr});
// Then, pay:
await contract.methods.payInvoice(invoiceId).send({from: payerAddr});
```

Pay invoice (POL):
```js
await contract.methods.payInvoice(invoiceId).send({
  from: payerAddr,
  value: web3.utils.toWei('100', 'ether') // Amount must match invoice
});
```

---

## Important Notes

- **Invoice ID Format:** Must be a 32-byte string. IDs of any other size will be rejected.
- **Token Decimals:** Amounts must be provided in 18 decimals; contract converts for underlying ERC-20 tokens if decimals ≠ 18.
- **Native Token:** For Polygon, the native token is now called POL (not MATIC). Use the zero address for POL invoices.
- **Invoice Expiry:** Expired invoices cannot be paid or cancelled. Both payment and cancellation check current block timestamp vs. `expiresAt`.
- **No Direct Transfers:** The contract's `receive()` function will always revert. All payments must go through `payInvoice`.
- **Revoking Invoices:** Once an invoice is `PAID` or `CANCELLED`, it is immutable and cannot be reset.
- **Event Logging:** All actions are logged for blockchain indexing and off-chain monitoring.
- **Multi-Network Support:** The contract is designed for deployment on any EVM-compatible chain. Network-specific details are included in each deployment's `getContractInfo()` data.

---

## License

This project and smart contract are licensed under the [MIT License](./LICENSE).
