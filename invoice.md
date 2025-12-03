# Data Structs

## polygon.%contract_address%.struct.ContractInfo

```json
{
  "long_name": "polygon.%contract_address%.struct.ContractInfo",
  "short_name": "ContractInfo",
  "description": "Metadata and deployment information about this contract instance.",
  "fields": {
    "chainId": {
      "name": "chainId",
      "description": "Chain ID for the target network.",
      "type": "uint256",
      "possible_values": "Arbitrary uint256 set at deployment; should match the actual chain ID."
    },
    "compilerVersion": {
      "name": "compilerVersion",
      "description": "String indicating the Solidity compiler version used.",
      "type": "string",
      "possible_values": "Arbitrary string provided at deployment, e.g. '0.8.30'."
    },
    "contractAddress": {
      "name": "contractAddress",
      "description": "Address of this deployed contract.",
      "type": "address",
      "possible_values": "Set to address(this) at deployment and immutable thereafter."
    },
    "deployedAt": {
      "name": "deployedAt",
      "description": "Block number at which the contract was deployed.",
      "type": "uint256",
      "possible_values": "Set to block.number in the constructor."
    },
    "deployer": {
      "name": "deployer",
      "description": "Address that deployed the contract.",
      "type": "address",
      "possible_values": "Set to msg.sender in the constructor."
    },
    "description": {
      "name": "description",
      "description": "Human-readable description of the contract or deployment.",
      "type": "string",
      "possible_values": "Arbitrary string provided at deployment."
    },
    "interfaceId": {
      "name": "interfaceId",
      "description": "Identifier string for the contract interface.",
      "type": "string",
      "possible_values": "Arbitrary string representing an interface or API version identifier."
    },
    "name": {
      "name": "name",
      "description": "Human-readable name of the contract/application.",
      "type": "string",
      "possible_values": "Arbitrary string set at construction time."
    },
    "networkName": {
      "name": "networkName",
      "description": "Human-readable name of the target network.",
      "type": "string",
      "possible_values": "Arbitrary string describing the network."
    },
    "version": {
      "name": "version",
      "description": "Version string of the contract/application.",
      "type": "string",
      "possible_values": "Arbitrary version identifier set at deployment."
    }
  }
}
```

---

## polygon.%contract_address%.struct.InvoiceData

```json
{
  "long_name": "polygon.%contract_address%.struct.InvoiceData",
  "short_name": "InvoiceData",
  "description": "Holds all on-chain data for a single invoice.",
  "fields": {
    "amount_in18decAtoms": {
      "name": "amount_in18decAtoms",
      "description": "Invoice amount expressed with 18 decimals precision (atoms).",
      "type": "uint256",
      "possible_values": "Non-negative integer; used for both native and ERC-20 payments with conversion for tokens with non-18 decimals."
    },
    "erc20TokenAddress": {
      "name": "erc20TokenAddress",
      "description": "ERC-20 token address used for payment, or zero address for native token.",
      "type": "address",
      "possible_values": "Token contract address or address(0) for native token invoices."
    },
    "expiresAt": {
      "name": "expiresAt",
      "description": "Timestamp after which the invoice is considered expired.",
      "type": "uint256",
      "possible_values": "If current block.timestamp exceeds this value, invoice is treated as expired while in ISSUED state."
    },
    "invoiceId": {
      "name": "invoiceId",
      "description": "Unique invoice identifier as a string (expected to be 32 bytes).",
      "type": "string",
      "possible_values": "Must correspond to the ID used as key; expected to be exactly 32 bytes long."
    },
    "isNativeToken": {
      "name": "isNativeToken",
      "description": "Indicates whether the invoice is denominated in native token (true) or ERC-20 (false).",
      "type": "bool",
      "possible_values": "true if erc20TokenAddress is address(0); false otherwise."
    },
    "issuedAt": {
      "name": "issuedAt",
      "description": "Timestamp when the invoice was issued.",
      "type": "uint256",
      "possible_values": "Block timestamp at time of invoice creation."
    },
    "issuedBy": {
      "name": "issuedBy",
      "description": "Address of the account that issued the invoice.",
      "type": "address",
      "possible_values": "Non-zero address for valid invoices."
    },
    "paidAtBlockNumber": {
      "name": "paidAtBlockNumber",
      "description": "Block number at which the invoice was paid.",
      "type": "uint256",
      "possible_values": "0 if not yet paid; otherwise the block number when payment succeeded."
    },
    "paidBy": {
      "name": "paidBy",
      "description": "Address of the payer who paid the invoice.",
      "type": "address",
      "possible_values": "Zero address if not yet paid; set when payment succeeds."
    },
    "payToAddress": {
      "name": "payToAddress",
      "description": "Recipient address that will receive payment for this invoice.",
      "type": "address",
      "possible_values": "Any address; expected to be a valid payee."
    },
    "status": {
      "name": "status",
      "description": "Current status of the invoice.",
      "type": "InvoiceStatus",
      "possible_values": "One of: ISSUED, PAID, CANCELLED. Represented as an enum value."
    }
  }
}
```

---

## polygon.%contract_address%.struct.InvoiceStatus (enum)

```json
{
  "long_name": "polygon.%contract_address%.struct.InvoiceStatus",
  "short_name": "InvoiceStatus",
  "description": "Enumeration representing the state of an invoice.",
  "variants": [
    "ISSUED",
    "PAID",
    "CANCELLED"
  ]
}
```

---

# Read-only / View Methods

All methods in this section do not modify state. They accept a single `dict` of named arguments matching the described input schema and return a `dict` with named fields as described.

Methods are listed in alphabetical order by `function_long_name`.

## polygon.%contract_address%.method.findInvoices

```json
{
  "long_name": "polygon.%contract_address%.method.findInvoices",
  "short_name": "findInvoices",
  "description": "Finds existing invoices by their string IDs and returns only those that exist.",
  "input_arguments": {
    "invoiceIds": {
      "name": "invoiceIds",
      "description": "Array of invoice IDs (each must be exactly 32-byte string) to lookup.",
      "type": "string[]",
      "possible_values": "Each element must be a 32-byte length string; non-existing IDs are skipped in the result."
    }
  },
  "returns": [
    {
      "name": "foundInvoiceIds",
      "description": "Array of invoice IDs that were found in storage.",
      "type": "string[]",
      "possible_values": "Subset of the input IDs, containing only IDs of existing invoices."
    },
    {
      "name": "invoices",
      "description": "Array of invoice data corresponding one-to-one with foundInvoiceIds.",
      "type": "InvoiceData[]",
      "possible_values": "Each element holds the stored data for the invoice with the same index in foundInvoiceIds. Each entry is an InvoiceData struct converted to a Python dict."
    },
    {
      "name": "foundCount",
      "description": "Number of invoices found among the requested IDs.",
      "type": "uint256",
      "possible_values": "From 0 up to len(invoiceIds)."
    },
    {
      "name": "queryBlockNumber",
      "description": "Block number at which the query was executed.",
      "type": "uint256",
      "possible_values": "Current block number at call time."
    }
  ]
}
```

**Input structure (Python):**

```python
{
  "invoiceIds": [
    "<32-byte-id-1>",
    "<32-byte-id-2>",
    # ...
  ]
}
```

**Output structure (Python):**

```python
{
  "foundInvoiceIds": ["<existing-id-1>", "<existing-id-2>", ...],
  "invoices": [
    {
      "invoiceId": "<existing-id-1>",
      "amount_in18decAtoms": 0,
      "erc20TokenAddress": "0x...",
      "expiresAt": 0,
      "isNativeToken": True,
      "issuedAt": 0,
      "issuedBy": "0x...",
      "paidAtBlockNumber": 0,
      "paidBy": "0x...",
      "payToAddress": "0x...",
      "status": 0  # enum index: 0=ISSUED, 1=PAID, 2=CANCELLED
    },
    # one entry per foundInvoiceIds element
  ],
  "foundCount": 0,
  "queryBlockNumber": 0
}
```

---

## polygon.%contract_address%.method.getContractInfo

```json
{
  "long_name": "polygon.%contract_address%.method.getContractInfo",
  "short_name": "getContractInfo",
  "description": "Returns static metadata about this contract deployment.",
  "input_arguments": {},
  "returns": [
    {
      "name": "info",
      "description": "Struct containing descriptive and deployment information about the contract.",
      "type": "ContractInfo",
      "possible_values": "Contains name, version, network name, contract address, deployer address, description, deployed block number, compiler version, chain ID, and interface ID. Represented as a dict following the ContractInfo struct schema."
    }
  ]
}
```

**Input structure (Python):**

```python
{}
```

**Output structure (Python):**

```python
{
  "info": {
    "name": "...",
    "version": "...",
    "networkName": "...",
    "contractAddress": "0x...",
    "deployer": "0x...",
    "description": "...",
    "deployedAt": 0,
    "compilerVersion": "0.8.30",
    "chainId": 137,
    "interfaceId": "..."
  }
}
```

---

## polygon.%contract_address%.method.listInvoices

```json
{
  "long_name": "polygon.%contract_address%.method.listInvoices",
  "short_name": "listInvoices",
  "description": "Returns a paginated batch of invoices and their IDs starting from a given offset.",
  "input_arguments": {
    "batchOffset": {
      "name": "batchOffset",
      "description": "Index in the global invoice list from which to start the batch.",
      "type": "uint256",
      "possible_values": "Must be less than totalNumberOfInvoices() if total count is greater than 0."
    },
    "batchSize": {
      "name": "batchSize",
      "description": "Requested maximum number of invoices to return.",
      "type": "uint256",
      "possible_values": "If batchOffset + batchSize exceeds total count, the batch is truncated to the remaining items."
    }
  },
  "returns": [
    {
      "name": "invoiceIds",
      "description": "Array of invoice IDs in the returned batch.",
      "type": "string[]",
      "possible_values": "Sequential subset of all invoice IDs from batchOffset with length actualBatchSize."
    },
    {
      "name": "invoices",
      "description": "Array of invoice data corresponding to invoiceIds.",
      "type": "InvoiceData[]",
      "possible_values": "Each element is the stored data for the invoice with the same index in invoiceIds. Each entry is an InvoiceData struct converted to a Python dict."
    },
    {
      "name": "actualBatchSize",
      "description": "Number of invoices actually returned in this batch.",
      "type": "uint256",
      "possible_values": "0 if there are no invoices; otherwise between 1 and batchSize, constrained by remaining items."
    },
    {
      "name": "totalCount",
      "description": "Total number of invoices stored at query time.",
      "type": "uint256",
      "possible_values": "Same value as returned by totalNumberOfInvoices()."
    },
    {
      "name": "queryBlockNumber",
      "description": "Block number at which the query was executed.",
      "type": "uint256",
      "possible_values": "Current block number when the method is called."
    }
  ]
}
```

**Input structure (Python):**

```python
{
  "batchOffset": 0,
  "batchSize": 50
}
```

**Output structure (Python):**

```python
{
  "invoiceIds": ["<id-1>", "<id-2>", ...],
  "invoices": [
    {
      "invoiceId": "<id-1>",
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
    # one entry per invoiceIds element
  ],
  "actualBatchSize": 0,
  "totalCount": 0,
  "queryBlockNumber": 0
}
```

---

## polygon.%contract_address%.method.totalNumberOfInvoices

```json
{
  "long_name": "polygon.%contract_address%.method.totalNumberOfInvoices",
  "short_name": "totalNumberOfInvoices",
  "description": "Returns the total number of invoices ever issued.",
  "input_arguments": {},
  "returns": [
    {
      "name": "count",
      "description": "Total number of invoices stored.",
      "type": "uint256",
      "possible_values": "Non-decreasing integer; increments by one on each successful invoice issuance."
    }
  ]
}
```

**Input structure (Python):**

```python
{}
```

**Output structure (Python):**

```python
{
  "count": 0
}
```

---

# Execute Methods

Methods in this section perform actions or modify data. They accept a single `dict` of named arguments matching the described input schema. Unless otherwise specified, they do not return any value (i.e. the result is implementation-specific and may be an empty dict in Python).

Methods are listed in alphabetical order by `function_long_name`.

## polygon.%contract_address%.method.cancelInvoice

```json
{
  "long_name": "polygon.%contract_address%.method.cancelInvoice",
  "short_name": "cancelInvoice",
  "description": "Cancels an existing, non-expired, ISSUED invoice. Only the issuer can cancel.",
  "input_arguments": {
    "invoiceId": {
      "name": "invoiceId",
      "description": "ID of the invoice to cancel (must be exactly 32-byte string of an existing invoice).",
      "type": "string",
      "possible_values": "Must refer to an existing invoice in ISSUED state that has not expired, not paid, and not already cancelled."
    }
  },
  "returns": []
}
```

**Input structure (Python):**

```python
{
  "invoiceId": "<32-byte-id>"
}
```

**Output structure (Python):**

```python
{}
```

---

## polygon.%contract_address%.method.issueInvoice

```json
{
  "long_name": "polygon.%contract_address%.method.issueInvoice",
  "short_name": "issueInvoice",
  "description": "Issues a new invoice with the given parameters and stores it.",
  "input_arguments": {
    "amount_in18decAtoms": {
      "name": "amount_in18decAtoms",
      "description": "Invoice amount expressed with 18-decimal precision (\"atoms\").",
      "type": "uint256",
      "possible_values": "Non-negative integer; for ERC-20 payments it will be converted to token decimals."
    },
    "erc20TokenAddress": {
      "name": "erc20TokenAddress",
      "description": "ERC-20 token address for payment; zero address indicates native token payment.",
      "type": "address",
      "possible_values": "Either an ERC-20 token contract address or address(0) for native token."
    },
    "expiresAt": {
      "name": "expiresAt",
      "description": "Unix timestamp after which the invoice is considered expired.",
      "type": "uint256",
      "possible_values": "Any uint256 timestamp; if in the past, the invoice will effectively be immediately expired for payment/cancellation."
    },
    "invoiceId": {
      "name": "invoiceId",
      "description": "Unique invoice ID as a string that must be exactly 32 bytes long.",
      "type": "string",
      "possible_values": "Must be 32 bytes; must not already exist in storage."
    },
    "payToAddress": {
      "name": "payToAddress",
      "description": "Address that will receive the payment when the invoice is paid.",
      "type": "address",
      "possible_values": "Any non-zero address is recommended; zero address is not explicitly forbidden."
    }
  },
  "returns": []
}
```

**Input structure (Python):**

```python
{
  "amount_in18decAtoms": 1000000000000000000,
  "erc20TokenAddress": "0x0000000000000000000000000000000000000000",  # native token example
  "expiresAt": 1710000000,
  "invoiceId": "<32-byte-id>",
  "payToAddress": "0x..."
}
```

**Output structure (Python):**

```python
{}
```

---

## polygon.%contract_address%.method.payInvoice

```json
{
  "long_name": "polygon.%contract_address%.method.payInvoice",
  "short_name": "payInvoice",
  "description": "Pays an existing, non-expired, ISSUED invoice using either native token or ERC-20, depending on the invoice configuration.",
  "input_arguments": {
    "invoiceId": {
      "name": "invoiceId",
      "description": "ID of the invoice to pay (must be exactly 32-byte string of an existing invoice).",
      "type": "string",
      "possible_values": "Must refer to an existing invoice in ISSUED state that has not expired, not paid, and not cancelled."
    }
  },
  "returns": []
}
```

**Input structure (Python):**

```python
{
  "invoiceId": "<32-byte-id>"
}
```

**Output structure (Python):**

```python
{}
```

---

## polygon.%contract_address%.method.receive

```json
{
  "long_name": "polygon.%contract_address%.method.receive",
  "short_name": "receive",
  "description": "Fallback receive-like method that rejects direct native token transfers.",
  "input_arguments": {},
  "returns": []
}
```

**Input structure (Python):**

```python
{}
```

**Output structure (Python):**

```python
{}
```

---

# Usage Notes (Python API)

- All method calls use **named arguments** passed as a single `dict`. Argument names must match the `name` field in the method documentation.
- Complex return types such as `ContractInfo` and `InvoiceData` are returned as nested Python dictionaries following the schemas in the **Data Structs** section.
- Arrays are always returned as Python lists; enum values such as `InvoiceStatus` are returned as integers (0 = `ISSUED`, 1 = `PAID`, 2 = `CANCELLED`).

This allows you to treat all documented methods as regular Python functions that accept and return standard Python data structures.
