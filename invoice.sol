// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract InvoiceContract {
    using SafeERC20 for IERC20;

    enum InvoiceStatus {
        ISSUED,
        PAID,
        CANCELLED
    }

    struct InvoiceData {
        string invoiceId;
        address issuedBy;
        address erc20TokenAddress;
        address payToAddress;
        uint256 amount_in18decAtoms;
        uint256 issuedAt;
        uint256 expiresAt;
        InvoiceStatus status;
        address paidBy;
        uint256 paidAtBlockNumber;
        bool isNativeToken;
    }

    struct ContractInfo {
        string name;
        string version;
        string networkName;
        address contractAddress;
        address deployer;
        string description;
        uint256 deployedAt;
        string compilerVersion;
        uint256 chainId;
        string interfaceId;
    }

    mapping(bytes32 => InvoiceData) private invoicesStorage;
    
    string[] private allInvoiceIds;
    
    uint256 private totalInvoicesCount;

    ContractInfo private contractInfo;

    event InvoiceIssued(
        string indexed invoiceId_indexed,
        string invoiceId,
        address indexed issuedBy,
        address erc20TokenAddress,
        address payToAddress,
        uint256 amount_in18decAtoms,
        uint256 issuedAt,
        uint256 expiresAt
    );

    event InvoicePaid(
        string indexed invoiceId_indexed,
        string invoiceId,
        address indexed payer,
        address indexed paidBy,
        uint256 amount_in18decAtoms
    );

    event InvoiceCancelled(
        string indexed invoiceId_indexed,
        string invoiceId,
        address indexed cancelledBy
    );

    event InvoiceExpired(
        string indexed invoiceId_indexed,
        string invoiceId
    );

    constructor(
        string memory _name,
        string memory _version,
        string memory _networkName,
        string memory _description,
        string memory _compilerVersion,
        uint256 _chainId,
        string memory _interfaceId
    ) {
        contractInfo = ContractInfo({
            name: _name,
            version: _version,
            networkName: _networkName,
            contractAddress: address(this),
            deployer: msg.sender,
            description: _description,
            deployedAt: block.number,
            compilerVersion: _compilerVersion,
            chainId: _chainId,
            interfaceId: _interfaceId
        });
    }

    function _invoiceIdToKey(string memory invoiceId) private pure returns (bytes32 key) {
        bytes memory invoiceIdBytes = bytes(invoiceId);

        require(invoiceIdBytes.length == 32, "InvalidInvoiceIdLength: Invoice ID must be exactly 32 bytes long");

        assembly {
            key := mload(add(invoiceIdBytes, 32))
        }
    }

    function _checkInvoiceExpiration(string memory invoiceId) private {
        bytes32 key = _invoiceIdToKey(invoiceId);

        InvoiceData storage invoice = invoicesStorage[key];

        require(invoice.issuedBy != address(0), "InvoiceNotFound: Invoice does not exist");

        if (invoice.status == InvoiceStatus.ISSUED && block.timestamp > invoice.expiresAt) {
            emit InvoiceExpired(invoiceId, invoiceId);
            revert("InvoiceExpiredError: Invoice has expired");
        }
    }

    function findInvoices(string[] memory invoiceIds) external view returns (string[] memory foundInvoiceIds, InvoiceData[] memory invoices, uint256 foundCount, uint256 queryBlockNumber) {
        string[] memory tempIds = new string[](invoiceIds.length);
        InvoiceData[] memory tempInvoices = new InvoiceData[](invoiceIds.length);
        foundCount = 0;

        for (uint256 i = 0; i < invoiceIds.length; i++) {
            string memory invoiceId = invoiceIds[i];

            bytes32 key = _invoiceIdToKey(invoiceId);

            InvoiceData memory invoice = invoicesStorage[key];

            if (invoice.issuedBy != address(0)) {
                tempIds[foundCount] = invoiceId;
                tempInvoices[foundCount] = invoice;
                foundCount++;
            }
        }

        foundInvoiceIds = new string[](foundCount);
        invoices = new InvoiceData[](foundCount);

        for (uint256 i = 0; i < foundCount; i++) {
            foundInvoiceIds[i] = tempIds[i];
            invoices[i] = tempInvoices[i];
        }

        queryBlockNumber = block.number;

        return (foundInvoiceIds, invoices, foundCount, queryBlockNumber);
    }

    function totalNumberOfInvoices() external view returns (uint256 count) {
        return totalInvoicesCount;
    }

    function listInvoices(uint256 batchOffset, uint256 batchSize) external view returns (
        string[] memory invoiceIds,
        InvoiceData[] memory invoices,
        uint256 actualBatchSize,
        uint256 totalCount,
        uint256 queryBlockNumber
    ) {
        totalCount = totalInvoicesCount;

        if (totalCount == 0) {
            invoiceIds = new string[](0);
            invoices = new InvoiceData[](0);
            actualBatchSize = 0;
            queryBlockNumber = block.number;
            return (invoiceIds, invoices, actualBatchSize, totalCount, queryBlockNumber);
        }

        require(batchOffset < totalCount, "BatchOffsetOutOfBounds: Batch offset exceeds total invoice count");

        uint256 endIndex = batchOffset + batchSize;
        if (endIndex > totalCount) {
            endIndex = totalCount;
        }
        actualBatchSize = endIndex - batchOffset;

        invoiceIds = new string[](actualBatchSize);
        invoices = new InvoiceData[](actualBatchSize);

        for (uint256 i = 0; i < actualBatchSize; i++) {
            uint256 index = batchOffset + i;
            string memory invoiceId = allInvoiceIds[index];

            bytes32 key = _invoiceIdToKey(invoiceId);
            InvoiceData memory invoice = invoicesStorage[key];

            invoiceIds[i] = invoiceId;
            invoices[i] = invoice;
        }

        queryBlockNumber = block.number;

        return (invoiceIds, invoices, actualBatchSize, totalCount, queryBlockNumber);
    }

    function getContractInfo() external view returns (ContractInfo memory info) {
        return contractInfo;
    }

    function issueInvoice(
        string memory invoiceId,
        address erc20TokenAddress,
        address payToAddress,
        uint256 amount_in18decAtoms,
        uint256 expiresAt
    ) external returns (bool success) {
        bytes32 key = _invoiceIdToKey(invoiceId);

        require(invoicesStorage[key].issuedBy == address(0), "InvoiceAlreadyExists: Cannot create duplicate invoice");

        bool isNative = (erc20TokenAddress == address(0));

        InvoiceData memory newInvoice = InvoiceData({
            invoiceId: invoiceId,
            issuedBy: msg.sender,
            erc20TokenAddress: erc20TokenAddress,
            payToAddress: payToAddress,
            amount_in18decAtoms: amount_in18decAtoms,
            issuedAt: block.timestamp,
            expiresAt: expiresAt,
            status: InvoiceStatus.ISSUED,
            paidBy: address(0),
            paidAtBlockNumber: 0,
            isNativeToken: isNative
        });

        invoicesStorage[key] = newInvoice;

        allInvoiceIds.push(invoiceId);

        totalInvoicesCount++;

        emit InvoiceIssued(
            invoiceId,
            invoiceId,
            msg.sender,
            erc20TokenAddress,
            payToAddress,
            amount_in18decAtoms,
            block.timestamp,
            expiresAt
        );

        return true;
    }

    function cancelInvoice(string memory invoiceId) external returns (bool success) {
        bytes32 key = _invoiceIdToKey(invoiceId);

        InvoiceData storage invoice = invoicesStorage[key];

        require(invoice.issuedBy != address(0), "InvoiceNotFound: Invoice does not exist");

        require(invoice.issuedBy == msg.sender, "UnauthorizedCancellation: Only issuer can cancel invoice");

        require(invoice.status != InvoiceStatus.PAID, "InvoiceAlreadyPaid: Invoice has already been paid");

        require(invoice.status != InvoiceStatus.CANCELLED, "InvoiceAlreadyCancelled: Invoice has already been cancelled");

        require(invoice.status == InvoiceStatus.ISSUED, "InvalidInvoiceState: Invoice must be in ISSUED state to cancel");

        _checkInvoiceExpiration(invoiceId);

        invoice.status = InvoiceStatus.CANCELLED;

        emit InvoiceCancelled(invoiceId, invoiceId, msg.sender);

        return true;
    }

    function payInvoice(string memory invoiceId) external payable returns (bool success) {
        bytes32 key = _invoiceIdToKey(invoiceId);

        InvoiceData storage invoice = invoicesStorage[key];

        require(invoice.issuedBy != address(0), "InvoiceNotFound: Invoice does not exist");

        require(invoice.status != InvoiceStatus.PAID, "InvoiceAlreadyPaid: Invoice has already been paid");

        require(invoice.status != InvoiceStatus.CANCELLED, "InvoiceAlreadyCancelled: Invoice has already been cancelled");

        require(invoice.status == InvoiceStatus.ISSUED, "InvalidInvoiceState: Invoice must be in ISSUED state to pay");

        _checkInvoiceExpiration(invoiceId);

        if (invoice.isNativeToken) {
            require(
                msg.value == invoice.amount_in18decAtoms,
                "IncorrectNativeAmount: msg.value must equal invoice amount"
            );

            invoice.status = InvoiceStatus.PAID;
            invoice.paidBy = msg.sender;
            invoice.paidAtBlockNumber = block.number;

            (bool sent, ) = payable(invoice.payToAddress).call{value: msg.value}("");
            require(sent, "NativeTransferFailed");

            emit InvoicePaid(
                invoiceId,
                invoiceId,
                msg.sender,
                msg.sender,
                invoice.amount_in18decAtoms
            );

            return true;
        } else {
            require(msg.value == 0, "DoNotSendNativeToken: msg.value must be zero for ERC20 invoice");

            IERC20 token = IERC20(invoice.erc20TokenAddress);
            IERC20Metadata tokenContract = IERC20Metadata(invoice.erc20TokenAddress);
            uint8 decimals = tokenContract.decimals();

            uint256 amount_inTokenCustomDecimals;
            if (decimals == 18) {
                amount_inTokenCustomDecimals = invoice.amount_in18decAtoms;
            } else if (decimals < 18) {
                amount_inTokenCustomDecimals = invoice.amount_in18decAtoms / (10 ** (18 - decimals));
            } else {
                amount_inTokenCustomDecimals = invoice.amount_in18decAtoms * (10 ** (decimals - 18));
            }

            uint256 allowance = token.allowance(msg.sender, address(this));
            require(allowance >= amount_inTokenCustomDecimals, "InsufficientAllowance: Payer hasn't approved enough tokens");

            invoice.status = InvoiceStatus.PAID;
            invoice.paidBy = msg.sender;
            invoice.paidAtBlockNumber = block.number;

            token.safeTransferFrom(msg.sender, invoice.payToAddress, amount_inTokenCustomDecimals);

            emit InvoicePaid(
                invoiceId,
                invoiceId,
                msg.sender,
                msg.sender,
                invoice.amount_in18decAtoms
            );

            return true;
        }
    }

    receive() external payable {
        revert("DirectNativeTransfersNotAllowed");
    }

}