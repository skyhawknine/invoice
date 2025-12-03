# InvoiceContract

A Solidity smart contract for issuing, managing, and paying on-chain invoices using either the network’s native token (e.g., MATIC) or arbitrary ERC‑20 tokens. The contract standardizes invoice storage and payment flows, making invoice data easily queryable both on-chain and via off-chain tools.

---

## Live Deployment

- **Network:** Polygon Mainnet  
- **Contract Address:** `0xD58D286197395C57Ee8dA820212Dda1194294313`  
  - Explorer: [View on Polygonscan](https://polygonscan.com/address/0xD58D286197395C57Ee8dA820212Dda1194294313)

### Web Dashboard

- **URL:** https://bnl-invoice.red-triplane.com/
- **Description:**
  - Interactive interface to view all invoices stored by the contract
  - Search and filter invoices by ID, status, and other fields
  - Real-time invoice status and payment history
  - Displays contract information and deployment metadata
  - Supports network-specific views (e.g., Polygon Mainnet)

The dashboard is the recommended entry point for non-technical users to browse invoices and inspect contract state without interacting directly with the blockchain.

---

## Features

- **On-chain invoice registry**
  - Each invoice is stored as a dedicated `InvoiceData` struct.
  - Uniquely identified by a 32‑byte string invoice ID.

- **Supports native token and ERC‑20 payments**
  - Native token (e.g., MATIC) invoices via `msg.value`.
  - ERC‑20 invoices using `SafeERC20.safeTransferFrom` and `allowance` checks.

- **Precise amount handling**
  - Amounts stored in a unified 18‑decimals format (`amount_in18decAtoms`).
  - Automatic conversion for ERC‑20 tokens with non‑18 decimals.

- **Invoice lifecycle management**
  - Status enum: `ISSUED`, `PAID`, `CANCELLED`.
  - Invoices can be cancelled (by issuer only) while in `ISSUED` state and not expired.
  - Payments automatically transition invoices to `PAID` with block number tracking.

- **Expiration logic**
  - Each invoice has an `expiresAt` timestamp.
  - Attempts to pay or cancel an expired `ISSUED` invoice revert with a specific error.
  - An `InvoiceExpired` event is emitted when expiration is detected.

- **Indexed, paginated access**
  - Global invoice index for enumeration and pagination.
  - Batch listing and filtered lookup by IDs.

- **Deployment metadata**
  - `ContractInfo` struct provides:
    - Name, version, description
    - Network name and chain ID
    - Contract address and deployer address
    - Deployed block number and compiler version
    - Interface ID string

- **Safety and correctness**
  - Uses OpenZeppelin `SafeERC20` utilities.
  - Rejects direct native token transfers to the contract (must go through `payInvoice`).
  - Clear, descriptive revert messages for common failure conditions.

---

## Contract Overview

`InvoiceContract` is designed as a lightweight, auditable backend for invoice-based payment flows. It focuses on:

- **Transparent, immutable invoice records**: Once issued, invoice details (amount, payee, payment token, timestamps) are permanently stored on-chain.
- **Simple payment flow**: Payers need only the invoice ID to pay in either native or ERC‑20 tokens.
- **Off-chain integration**: The contract is easy to integrate into backend services, front-end dashboards, and analytics tools thanks to well-structured data and read methods.

### Main Use Cases

- Merchant or SaaS billing where each invoice is a unique, trackable, on-chain object
- B2B payments with auditable records of issuance and payment
- Automated reconciliation systems where external services track invoice states and payments
- Dashboards or accounting tools that enumerate and analyze invoices over time

---

## Technical Details

### Contract Structure

- **Contract Name:** `InvoiceContract`
- **Solidity Version:** `0.8.30` (fixed pragma `0.8.30`)
- **Dependencies:**
  - `@openzeppelin/contracts/token/ERC20/IERC20.sol`
  - `@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol`
  - `@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol`

#### Core Storage

- `mapping(bytes32 => InvoiceData) private invoicesStorage;`
  - Maps an internal key derived from `invoiceId` (a 32‑byte string) to `InvoiceData`.

- `string[] private allInvoiceIds;`
  - Sequential list of all invoice IDs ever issued, used for enumeration.

- `uint256 private totalInvoicesCount;`
  - Monotonic counter of all invoices, used by `totalNumberOfInvoices()`.

- `ContractInfo private contractInfo;`
  - Immutable deployment metadata set in the constructor.

### Data Structures

#### `enum InvoiceStatus`

Represents the lifecycle state of an invoice:

- `ISSUED` (0): Invoice has been created and is payable.
- `PAID` (1): Invoice has been successfully paid.
- `CANCELLED` (2): Invoice has been cancelled by the issuer.

#### `struct InvoiceData`

Holds all information about a single invoice:

- `string invoiceId` — Unique identifier (string expected to be exactly 32 bytes).
- `address issuedBy` — Address that issued the invoice.
- `address erc20TokenAddress` — ERC‑20 token used for payment, or `address(0)` for native token.
- `address payToAddress` — Recipient of the funds.
- `uint256 amount_in18decAtoms` — Amount in 18‑decimal atoms (unified representation).
- `uint256 issuedAt` — Timestamp at issuance.
- `uint256 expiresAt` — Expiration timestamp.
- `InvoiceStatus status` — Current status (ISSUED / PAID / CANCELLED).
- `address paidBy` — Payer address when paid.
- `uint256 paidAtBlockNumber` — Block number when payment occurred.
- `bool isNativeToken` — `true` if invoice is denominated in native token, else `false` for ERC‑20.

#### `struct ContractInfo`

Provides contract and deployment metadata:

- `string name` — Human-readable application/contract name.
- `string version` — Version string for this deployment.
- `string networkName` — Human-readable network name.
- `address contractAddress` — Deployed contract address (`address(this)`).
- `address deployer` — Address that deployed the contract.
- `string description` — Human-readable contract/deployment description.
- `uint256 deployedAt` — Block number at deployment.
- `string compilerVersion` — Solidity compiler version, e.g., `"0.8.30"`.
- `uint256 chainId` — Chain ID for the target network.
- `string interfaceId` — Interface or API version identifier.

### Internal Helpers

#### `_invoiceIdToKey(string invoiceId) -> bytes32`

- Converts the string `invoiceId` into a `bytes32` key for storage.
- **Requires** `bytes(invoiceId).length == 32` (exactly 32 bytes).
- Reverts with: `"InvalidInvoiceIdLength: Invoice ID must be exactly 32 bytes long"` if the length check fails.

#### `_checkInvoiceExpiration(string invoiceId)`

- Loads the invoice and verifies it exists.
- If `status == ISSUED` and `block.timestamp > expiresAt`:
  - Emits `InvoiceExpired(invoiceId)`
  - Reverts with: `"InvoiceExpiredError: Invoice has expired"`

### Events

- `event InvoiceIssued(string indexed invoiceId, address indexed issuedBy, address erc20TokenAddress, address payToAddress, uint256 amount_in18decAtoms, uint256 issuedAt, uint256 expiresAt);`
- `event InvoicePaid(string indexed invoiceId, address indexed payer, address indexed paidBy, uint256 amount_in18decAtoms);`
- `event InvoiceCancelled(string indexed invoiceId, address indexed cancelledBy);`
- `event InvoiceExpired(string indexed invoiceId);`

These events are intended for off-chain indexing and analytics tools as well as the dashboard.

---

## Public Interface

This section summarizes the main public methods. The detailed JSON-style documentation in the original `invoice.md` is compatible with Python APIs and off-chain tooling.

### View / Read-Only Methods

#### `getContractInfo() -> ContractInfo`

Returns the `ContractInfo` struct with deployment metadata.

**Solidity example:**

```solidity
ContractInfo memory info = invoiceContract.getContractInfo();
```

#### `totalNumberOfInvoices() -> uint256`

Returns the total number of invoices that have ever been issued.

```solidity
uint256 count = invoiceContract.totalNumberOfInvoices();
```

#### `listInvoices(uint256 batchOffset, uint256 batchSize)`

Returns a paginated batch of invoices:

- `invoiceIds` — array of invoice ID strings
- `invoices` — array of `InvoiceData` structs
- `actualBatchSize` — number of records actually returned
- `totalCount` — same as `totalNumberOfInvoices()`
- `queryBlockNumber` — block number of the query

Usage (Solidity / off-chain ABI call):

```solidity
(string[] memory ids,
 InvoiceData[] memory data,
 uint256 batchSizeEffective,
 uint256 total,
 uint256 blockNo
) = invoiceContract.listInvoices(0, 50);
```

**Constraints:**
- If `totalCount > 0`, `batchOffset` must be `< totalCount` or the call reverts with:
  - `"BatchOffsetOutOfBounds: Batch offset exceeds total invoice count"`

#### `findInvoices(string[] invoiceIds)`

Bulk-lookup by invoice IDs. Returns only existing invoices:

- `foundInvoiceIds` — subset of input IDs that exist
- `invoices` — corresponding `InvoiceData` entries
- `foundCount` — number of found invoices
- `queryBlockNumber` — block number of the query

```solidity
string[] memory ids = new string[](2);
ids[0] = someInvoiceId1;
ids[1] = someInvoiceId2;

(string[] memory foundIds,
 InvoiceData[] memory foundInvoices,
 uint256 foundCount,
 uint256 blockNo
) = invoiceContract.findInvoices(ids);
```

### State-Changing Methods

#### `issueInvoice(string invoiceId, address erc20TokenAddress, address payToAddress, uint256 amount_in18decAtoms, uint256 expiresAt) -> bool`

Issues a new invoice.

**Requirements and behavior:**
- `invoiceId` must be a string with exactly 32 bytes.
- No existing invoice with the same `invoiceId` may exist, otherwise reverts with:
  - `"InvoiceAlreadyExists: Cannot create duplicate invoice"`.
- `erc20TokenAddress == address(0)` indicates a native token invoice (`isNativeToken = true`).
- Otherwise an ERC‑20 token is used (`isNativeToken = false`).
- `expiresAt` can be any timestamp; if in the past, invoice will immediately behave as expired for payment/cancellation.
- On success:
  - Stores `InvoiceData` in `invoicesStorage`.
  - Appends `invoiceId` to `allInvoiceIds`.
  - Increments `totalInvoicesCount`.
  - Emits `InvoiceIssued` event.

**Solidity example:**

```solidity
bool ok = invoiceContract.issueInvoice(
    myInvoiceId,
    address(0), // native token
    0x1234...ABCD, // payee
    1 ether,       // amount in 18 decimals
    block.timestamp + 7 days
);
```

#### `cancelInvoice(string invoiceId) -> bool`

Cancels an existing, non-expired invoice.

**Rules:**
- Invoice must exist, otherwise:
  - `"InvoiceNotFound: Invoice does not exist"`.
- Caller must be the original issuer (`invoice.issuedBy`), otherwise:
  - `"UnauthorizedCancellation: Only issuer can cancel invoice"`.
- Invoice must be in `ISSUED` state:
  - Not `PAID`: `"InvoiceAlreadyPaid: Invoice has already been paid"`.
  - Not `CANCELLED`: `"InvoiceAlreadyCancelled: Invoice has already been cancelled"`.
  - Status must equal `ISSUED`: `"InvalidInvoiceState: Invoice must be in ISSUED state to cancel"`.
- Invoice must not be expired (`_checkInvoiceExpiration` is called): if expired, `InvoiceExpired` event is emitted and the call reverts.
- On success:
  - `status` is set to `CANCELLED`.
  - `InvoiceCancelled` event is emitted.

```solidity
bool ok = invoiceContract.cancelInvoice(myInvoiceId);
```

#### `payInvoice(string invoiceId) payable -> bool`

Pays an existing, non-expired invoice in either native or ERC‑20 token.

**Common rules:**
- Invoice must exist:
  - `"InvoiceNotFound: Invoice does not exist"` if not.
- Must not be already paid or cancelled:
  - `"InvoiceAlreadyPaid: Invoice has already been paid"`.
  - `"InvoiceAlreadyCancelled: Invoice has already been cancelled"`.
- Must be in `ISSUED` state:
  - `"InvalidInvoiceState: Invoice must be in ISSUED state to pay"`.
- Must not be expired: `_checkInvoiceExpiration` is called.
- On success:
  - `status` is set to `PAID`.
  - `paidBy` is set to `msg.sender`.
  - `paidAtBlockNumber` is set to `block.number`.
  - `InvoicePaid` event is emitted.

**Native token payment** (`invoice.isNativeToken == true`):
- `erc20TokenAddress` is `address(0)`.
- `msg.value` must equal `amount_in18decAtoms`:
  - Reverts with `"IncorrectNativeAmount: msg.value must equal invoice amount"` if not.
- Funds are forwarded to `invoice.payToAddress` via `call{value: msg.value}`.
- If transfer fails, reverts with `"NativeTransferFailed"`.

**Example (native token):**

```solidity
bool ok = invoiceContract.payInvoice{ value: 1 ether }(myInvoiceId);
```

**ERC‑20 payment** (`invoice.isNativeToken == false`):
- `erc20TokenAddress` must be a valid ERC‑20 token contract.
- `msg.value` must be `0`:
  - Reverts with `"DoNotSendNativeToken: msg.value must be zero for ERC20 invoice"`.
- The contract reads token decimals via `IERC20Metadata.decimals()`.
- Conversion from stored 18‑decimals to token decimals:
  - If `decimals == 18`: use `amount_in18decAtoms` as-is.
  - If `decimals < 18`: `amount / 10 ** (18 - decimals)` (integer division, possible truncation).
  - If `decimals > 18`: `amount * 10 ** (decimals - 18)`.
- The payer must have approved the contract for at least this computed amount:
  - Uses `token.allowance(msg.sender, address(this))`.
  - Reverts with `"InsufficientAllowance: Payer hasn't approved enough tokens"` if allowance is too low.
- Tokens are transferred using `token.safeTransferFrom(msg.sender, invoice.payToAddress, amount_inTokenCustomDecimals);`.

**Example (ERC‑20 token, off-chain pseudo-code):**

```solidity
IERC20 usdc = IERC20(USDC_ADDRESS);
uint256 amount = ...; // 18-decimal invoice amount determined off-chain

// Step 1: Approve the contract
usdc.approve(address(invoiceContract), amountToPayInUsdc);

// Step 2: Pay the invoice (no ETH value)
bool ok = invoiceContract.payInvoice(myInvoiceId);
```

### Fallback / Receive

#### `receive() external payable`

- Always reverts with `"DirectNativeTransfersNotAllowed"`.
- Ensures that native token can only be sent as part of an explicit `payInvoice` call for a native invoice.

---

## Usage

This section illustrates common interaction patterns for both developers and non-technical users.

### For Non-Technical Users

- Use the **dashboard** at https://bnl-invoice.red-triplane.com/ to:
  - Search for invoices by ID.
  - View invoice details (issuer, payee, amount, status, token type, timestamps).
  - Track payments and statuses in real time.

Payment UX will typically be abstracted behind a dApp or wallet integration that calls `payInvoice` for you.

### For Developers (Solidity / EVM)

#### Issuing an Invoice

```solidity
function createInvoice(InvoiceContract invoiceContract, string memory invoiceId) external {
    bool success = invoiceContract.issueInvoice(
        invoiceId,
        address(0),     // native token (MATIC on Polygon)
        msg.sender,     // pay to the caller
        5 ether,        // amount_in18decAtoms
        block.timestamp + 3 days
    );
    require(success, "Invoice issuance failed");
}
```

#### Paying a Native Token Invoice

```solidity
function payNativeInvoice(InvoiceContract invoiceContract, string memory invoiceId) external payable {
    // msg.value must match amount_in18decAtoms for this invoice
    bool success = invoiceContract.payInvoice{ value: msg.value }(invoiceId);
    require(success, "Invoice payment failed");
}
```

#### Paying an ERC‑20 Invoice (e.g., from a contract)

```solidity
function payErc20Invoice(InvoiceContract invoiceContract, IERC20 token, string memory invoiceId, uint256 amountToApprove) external {
    // Payer (msg.sender) must first approve from their EOA; or
    // this contract must hold tokens and call approve+pay itself
    token.approve(address(invoiceContract), amountToApprove);

    bool success = invoiceContract.payInvoice(invoiceId);
    require(success, "Invoice payment failed");
}
```

#### Listing Invoices (Pagination)

```solidity
function listFirstBatch(InvoiceContract invoiceContract) external view returns (string[] memory ids) {
    (ids, , , , ) = invoiceContract.listInvoices(0, 50);
}
```

### Off-Chain / Python-style Usage

The `invoice.md` documentation is tailored for a Python-style API:

- All calls take a single `dict` of named parameters.
- Complex structs (`ContractInfo`, `InvoiceData`) are returned as nested dictionaries.
- Enums (like `InvoiceStatus`) are returned as integers: `0 = ISSUED`, `1 = PAID`, `2 = CANCELLED`.

**Example (pseudo-Python):**

```python
# Get contract info
info = contract.getContractInfo({})["info"]

# List first 50 invoices
result = contract.listInvoices({"batchOffset": 0, "batchSize": 50})
ids = result["invoiceIds"]

# Find specific invoices
lookup = contract.findInvoices({"invoiceIds": ["<32-byte-id-1>", "<32-byte-id-2>"]})
found = lookup["invoices"]

# Issue an invoice (transaction)
contract.issueInvoice({
    "invoiceId": "<32-byte-id>",
    "erc20TokenAddress": "0x0000000000000000000000000000000000000000",  # native token
    "payToAddress": "0x...",
    "amount_in18decAtoms": 10**18,
    "expiresAt": 1710000000,
})

# Pay an invoice (native token)
contract.payInvoice({"invoiceId": "<32-byte-id>"}, value=10**18)
```

---

## Important Notes & Caveats

- **Invoice ID format:**
  - `invoiceId` is a string but must be exactly 32 bytes (`bytes(invoiceId).length == 32`).
  - Incorrect length will cause a revert on any method that converts the ID.

- **Immediate expiration:**
  - If `expiresAt` is set to a past timestamp, the invoice will be considered expired for payment and cancellation, and those actions will revert.
  - Still, the invoice data and events remain on-chain for record-keeping.

- **Token decimals handling:**
  - Stored amount is in 18 decimals. When paying an ERC‑20:
    - The contract converts to token decimals using integer division or multiplication.
    - If `decimals < 18`, division may truncate sub-atom remainders.
  - Integrators must be aware of potential rounding/truncation when deriving amounts.

- **Native token security:**
  - Direct transfers to the contract (without calling `payInvoice`) are rejected by the `receive()` function.
  - Always call `payInvoice` when sending native tokens for an invoice.

- **Access control:**
  - Only the issuer can cancel an invoice.
  - Any address can pay an `ISSUED` invoice (subject to token and expiration conditions).

- **Upgradability:**
  - The provided contract is a plain Solidity contract, not an upgradeable proxy.
  - Deployment metadata is fixed at construction time.

---

## License

This project is licensed under the **MIT License**.

SPDX-License-Identifier: MIT
