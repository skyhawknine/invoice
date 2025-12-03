# Data Structs

## polygon.%contract_address%.struct.ContractInfo

Metadata and deployment information about this contract instance.

**Struct name:** `polygon.%contract_address%.struct.ContractInfo`

Fields (as Python dict keys):

- **chainId**
  - **description:** Chain ID for the target network.
  - **type:** `int` (Solidity `uint256`)
  - **possible values:** Arbitrary non-negative integer set at deployment; should match the actual chain ID.

- **compilerVersion**
  - **description:** String indicating the Solidity compiler version used.
  - **type:** `str` (Solidity `string`)
  - **possible values:** Arbitrary string provided at deployment, e.g. `"0.8.30"`.

- **contractAddress**
  - **description:** Address of this deployed contract.
  - **type:** `str` (checksummed address; Solidity `address`)
  - **possible values:** Set to the contract address at deployment and immutable thereafter.

- **deployedAt**
  - **description:** Block number at which the contract was deployed.
  - **type:** `int` (Solidity `uint256`)
  - **possible values:** Block number at deployment time.

- **deployer**
  - **description:** Address that deployed the contract.
  - **type:** `str` (checksummed address; Solidity `address`)
  - **possible values:** Address that created this instance.

- **description**
  - **description:** Human-readable description of the contract or deployment.
  - **type:** `str` (Solidity `string`)
  - **possible values:** Arbitrary string provided at deployment.

- **interfaceId**
  - **description:** Identifier string for the contract interface.
  - **type:** `str` (Solidity `string`)
  - **possible values:** Arbitrary string representing an interface or API version identifier.

- **name**
  - **description:** Human-readable name of the contract/application.
  - **type:** `str` (Solidity `string`)
  - **possible values:** Arbitrary string set at construction time.

- **networkName**
  - **description:** Human-readable name of the target network.
  - **type:** `str` (Solidity `string`)
  - **possible values:** Arbitrary string describing the network.

- **version**
  - **description:** Version string of the contract/application.
  - **type:** `str` (Solidity `string`)
  - **possible values:** Arbitrary version identifier set at deployment.

---

## polygon.%contract_address%.struct.InvoiceData

Holds all on-chain data for a single invoice.

**Struct name:** `polygon.%contract_address%.struct.InvoiceData`

Fields (as Python dict keys):

- **amount_in18decAtoms**
  - **description:** Invoice amount expressed with 18 decimals precision (atoms).
  - **type:** `int` (Solidity `uint256`)
  - **possible values:** Non-negative integer; for ERC-20 payments it is used with conversion for tokens with non-18 decimals.

- **erc20TokenAddress**
  - **description:** ERC-20 token address used for payment, or zero address for native token.
  - **type:** `str` (checksummed address; Solidity `address`)
  - **possible values:** Token contract address or `0x0000000000000000000000000000000000000000` for native token invoices.

- **expiresAt**
  - **description:** Timestamp after which the invoice is considered expired.
  - **type:** `int` (Solidity `uint256`)
  - **possible values:** If the current timestamp exceeds this value, the invoice is treated as expired while in `ISSUED` state.

- **invoiceId**
  - **description:** Unique invoice identifier as a string (expected to be 32 bytes).
  - **type:** `str` (Solidity `string`)
  - **possible values:** Must correspond to the ID used as key; expected to be exactly 32 bytes long.

- **isNativeToken**
  - **description:** Indicates whether the invoice is denominated in native token (`True`) or ERC‑20 (`False`).
  - **type:** `bool` (Solidity `bool`)
  - **possible values:** `True` if `erc20TokenAddress` is the zero address; `False` otherwise.

- **issuedAt**
  - **description:** Timestamp when the invoice was issued.
  - **type:** `int` (Solidity `uint256`)
  - **possible values:** Block timestamp at time of invoice creation.

- **issuedBy**
  - **description:** Address of the account that issued the invoice.
  - **type:** `str` (checksummed address; Solidity `address`)
  - **possible values:** Non-zero address for valid invoices.

- **paidAtBlockNumber**
  - **description:** Block number at which the invoice was paid.
  - **type:** `int` (Solidity `uint256`)
  - **possible values:** `0` if not yet paid; otherwise the block number when payment succeeded.

- **paidBy**
  - **description:** Address of the payer who paid the invoice.
  - **type:** `str` (checksummed address; Solidity `address`)
  - **possible values:** Zero address if not yet paid; set to the payer address on successful payment.

- **payToAddress**
  - **description:** Recipient address that will receive payment for this invoice.
  - **type:** `str` (checksummed address; Solidity `address`)
  - **possible values:** Any address; expected to be a valid payee.

- **status**
  - **description:** Current status of the invoice.
  - **type:** `int` (enum `InvoiceStatus` as integer index)
  - **possible values:**
    - `0` – `ISSUED`
    - `1` – `PAID`
    - `2` – `CANCELLED`

---

## polygon.%contract_address%.struct.InvoiceStatus (enum)

Enumeration representing the state of an invoice. In Python it is represented as an integer value.

**Enum name:** `polygon.%contract_address%.struct.InvoiceStatus`

Variants (integer → meaning):

- `0` – `ISSUED`
- `1` – `PAID`
- `2` – `CANCELLED`

---

# Read-only / View Methods

All read-only methods return Python dictionaries. Input arguments are passed as a `dict` where keys are argument names.

## polygon.%contract_address%.method.findInvoices

Finds existing invoices by their string IDs and returns only those that exist.

**long_name:** `polygon.%contract_address%.method.findInvoices`  
**short_name:** `findInvoices`

### Input arguments

`input_arguments` is a dict with the following key:

```python
{
  "invoiceIds": <list_of_invoice_ids>
}
```

- **invoiceIds**
  - **name:** `invoiceIds`
  - **description:** Array of invoice IDs (each must be exactly 32-byte string) to look up.
  - **type:** `List[str]` (Solidity `string[]`)
  - **possible_values:** Each element must be a 32-byte length string; non-existing IDs are skipped in the result.

### Return value

The method returns a dict with the following fields:

- **foundInvoiceIds**
  - **name:** `foundInvoiceIds`
  - **description:** Array of invoice IDs that were found in storage.
  - **type:** `List[str]` (Solidity `string[]`)
  - **possible_values:** Subset of the input IDs, containing only IDs of existing invoices.

- **invoices**
  - **name:** `invoices`
  - **description:** Array of invoice data corresponding one-to-one with `foundInvoiceIds`.
  - **type:** `List[InvoiceData]` (each element is a dict matching `InvoiceData` structure)
  - **possible_values:** Each element holds the stored data for the invoice with the same index in `foundInvoiceIds`.

- **foundCount**
  - **name:** `foundCount`
  - **description:** Number of invoices found among the requested IDs.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** From `0` up to `len(invoiceIds)`.

- **queryBlockNumber**
  - **name:** `queryBlockNumber`
  - **description:** Block number at which the query was executed.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** Current block number when the function is called.

Example returned dict shape:

```python
{
  "foundInvoiceIds": ["...", "..."],
  "invoices": [
    {  # InvoiceData
      "invoiceId": "...",
      "amount_in18decAtoms": 0,
      "erc20TokenAddress": "0x...",
      "expiresAt": 0,
      "isNativeToken": True,
      "issuedAt": 0,
      "issuedBy": "0x...",
      "paidAtBlockNumber": 0,
      "paidBy": "0x...",
      "payToAddress": "0x...",
      "status": 0
    },
    # ...
  ],
  "foundCount": 2,
  "queryBlockNumber": 12345678
}
```

---

## polygon.%contract_address%.method.getContractInfo

Returns static metadata about this contract deployment.

**long_name:** `polygon.%contract_address%.method.getContractInfo`  
**short_name:** `getContractInfo`

### Input arguments

No input arguments are required. Call with an empty dict:

```python
{}
```

### Return value

The method returns a dict with a single field:

- **info**
  - **name:** `info`
  - **description:** Struct containing descriptive and deployment information about the contract.
  - **type:** `ContractInfo` (dict matching the `ContractInfo` structure)
  - **possible_values:** Contains name, version, network name, contract address, deployer address, description, deployed block number, compiler version, chain ID, and interface ID.

Example returned dict shape:

```python
{
  "info": {
    "name": "...",
    "version": "...",
    "networkName": "...",
    "contractAddress": "0x...",
    "deployer": "0x...",
    "description": "...",
    "deployedAt": 12345678,
    "compilerVersion": "0.8.30",
    "chainId": 137,
    "interfaceId": "..."
  }
}
```

---

## polygon.%contract_address%.method.listInvoices

Returns a paginated batch of invoices and their IDs starting from a given offset.

**long_name:** `polygon.%contract_address%.method.listInvoices`  
**short_name:** `listInvoices`

### Input arguments

`input_arguments` is a dict with the following keys:

```python
{
  "batchOffset": <offset>,
  "batchSize": <size>
}
```

- **batchOffset**
  - **name:** `batchOffset`
  - **description:** Index in the global invoice list from which to start the batch.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** Must be less than `totalNumberOfInvoices()` if total count is greater than 0.

- **batchSize**
  - **name:** `batchSize`
  - **description:** Requested maximum number of invoices to return.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** If `batchOffset + batchSize` exceeds total count, the batch is truncated to the remaining items.

### Return value

The method returns a dict with the following fields:

- **invoiceIds**
  - **name:** `invoiceIds`
  - **description:** Array of invoice IDs in the returned batch.
  - **type:** `List[str]` (Solidity `string[]`)
  - **possible_values:** Sequential subset of all invoice IDs from `batchOffset` with length `actualBatchSize`.

- **invoices**
  - **name:** `invoices`
  - **description:** Array of invoice data corresponding to `invoiceIds`.
  - **type:** `List[InvoiceData]` (each element is a dict matching `InvoiceData` structure)
  - **possible_values:** Each element is the stored data for the invoice with the same index in `invoiceIds`.

- **actualBatchSize**
  - **name:** `actualBatchSize`
  - **description:** Number of invoices actually returned in this batch.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** `0` if there are no invoices; otherwise between `1` and `batchSize`, constrained by remaining items.

- **totalCount**
  - **name:** `totalCount`
  - **description:** Total number of invoices stored at query time.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** Same as `totalNumberOfInvoices()`.

- **queryBlockNumber**
  - **name:** `queryBlockNumber`
  - **description:** Block number at which the query was executed.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** Current block number when the function is called.

Example returned dict shape:

```python
{
  "invoiceIds": ["...", "..."],
  "invoices": [
    {  # InvoiceData
      "invoiceId": "...",
      "amount_in18decAtoms": 0,
      "erc20TokenAddress": "0x...",
      "expiresAt": 0,
      "isNativeToken": True,
      "issuedAt": 0,
      "issuedBy": "0x...",
      "paidAtBlockNumber": 0,
      "paidBy": "0x...",
      "payToAddress": "0x...",
      "status": 0
    },
    # ...
  ],
  "actualBatchSize": 2,
  "totalCount": 10,
  "queryBlockNumber": 12345678
}
```

---

## polygon.%contract_address%.method.totalNumberOfInvoices

Returns the total number of invoices ever issued.

**long_name:** `polygon.%contract_address%.method.totalNumberOfInvoices`  
**short_name:** `totalNumberOfInvoices`

### Input arguments

No input arguments are required. Call with an empty dict:

```python
{}
```

### Return value

The method returns a dict with the following field:

- **count**
  - **name:** `count`
  - **description:** Total number of invoices stored.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** Non-decreasing integer; increments by one on each successful invoice issuance.

Example returned dict shape:

```python
{
  "count": 42
}
```

---

# Execute Methods

Execute methods perform actions or modify stored data. Input arguments are passed as a `dict` where keys are argument names. Unless otherwise noted, these methods do not return a value; in Python you typically only check that the call completed successfully.

## polygon.%contract_address%.method.cancelInvoice

Cancels an existing, non-expired, `ISSUED` invoice. Only the issuer can cancel.

**long_name:** `polygon.%contract_address%.method.cancelInvoice`  
**short_name:** `cancelInvoice`

### Input arguments

`input_arguments` is a dict with the following key:

```python
{
  "invoiceId": <invoice_id>
}
```

- **invoiceId**
  - **name:** `invoiceId`
  - **description:** ID of the invoice to cancel (must be exactly 32-byte string of an existing invoice).
  - **type:** `str` (Solidity `string`)
  - **possible_values:** Must refer to an existing invoice in `ISSUED` state that has not expired, not paid, and not already cancelled.

### Return value

No structured return data is defined for this method. The Python call is used for its side effects; success indicates that the invoice has been processed for cancellation.

---

## polygon.%contract_address%.method.issueInvoice

Issues a new invoice with the given parameters and stores it.

**long_name:** `polygon.%contract_address%.method.issueInvoice`  
**short_name:** `issueInvoice`

### Input arguments

`input_arguments` is a dict with the following keys:

```python
{
  "amount_in18decAtoms": <amount>,
  "erc20TokenAddress": <token_address>,
  "expiresAt": <timestamp>,
  "invoiceId": <invoice_id>,
  "payToAddress": <recipient_address>
}
```

- **amount_in18decAtoms**
  - **name:** `amount_in18decAtoms`
  - **description:** Invoice amount expressed with 18-decimal precision ("atoms").
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** Non-negative integer; for ERC‑20 payments it will be converted according to the token decimals.

- **erc20TokenAddress**
  - **name:** `erc20TokenAddress`
  - **description:** ERC‑20 token address for payment; zero address indicates native token payment.
  - **type:** `str` (checksummed address; Solidity `address`)
  - **possible_values:** Either an ERC‑20 token contract address or the zero address for native token.

- **expiresAt**
  - **name:** `expiresAt`
  - **description:** Unix timestamp after which the invoice is considered expired.
  - **type:** `int` (Solidity `uint256`)
  - **possible_values:** Any non-negative timestamp; if in the past, the invoice will effectively be immediately expired for payment/cancellation.

- **invoiceId**
  - **name:** `invoiceId`
  - **description:** Unique invoice ID as a string that must be exactly 32 bytes long.
  - **type:** `str` (Solidity `string`)
  - **possible_values:** Must be 32 bytes; must not already exist.

- **payToAddress**
  - **name:** `payToAddress`
  - **description:** Address that will receive the payment when the invoice is paid.
  - **type:** `str` (checksummed address; Solidity `address`)
  - **possible_values:** Any non-zero address is recommended; zero address is not explicitly forbidden.

### Return value

No structured return data is defined for this method. The Python call is used for its side effects; success indicates that the invoice has been created.

---

## polygon.%contract_address%.method.payInvoice

Pays an existing, non-expired, `ISSUED` invoice using either native token or ERC‑20, depending on the invoice configuration.

**long_name:** `polygon.%contract_address%.method.payInvoice`  
**short_name:** `payInvoice`

### Input arguments

`input_arguments` is a dict with the following key:

```python
{
  "invoiceId": <invoice_id>
}
```

- **invoiceId**
  - **name:** `invoiceId`
  - **description:** ID of the invoice to pay (must be exactly 32-byte string of an existing invoice).
  - **type:** `str` (Solidity `string`)
  - **possible_values:** Must refer to an existing invoice in `ISSUED` state that has not expired, not paid, and not cancelled.

### Return value

No structured return data is defined for this method. The Python call is used for its side effects; success indicates that payment has been processed.

---

## polygon.%contract_address%.method.receive

Fallback receive function that rejects direct native token transfers.

**long_name:** `polygon.%contract_address%.method.receive`  
**short_name:** `receive`

### Input arguments

No input arguments are expected. Call with an empty dict:

```python
{}
```

### Return value

No structured return data is defined. This method is not intended to be used directly in typical Python integrations.