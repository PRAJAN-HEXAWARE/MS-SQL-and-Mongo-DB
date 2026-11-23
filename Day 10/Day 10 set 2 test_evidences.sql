/*
USE BankAuditDB;
GO

SELECT
    AccountID,
    CustomerName,
    AccountType,
    Balance
FROM dbo.accounts
ORDER BY AccountID;
GO

INSERT INTO dbo.account_transaction
(
    AccountID,
    TransactionType,
    Amount,
    Description
)
VALUES
(101, 'Deposit', 2500, 'Audit insert test'),
(102, 'Withdrawal', 1000, 'Audit insert test');
GO

SELECT *
FROM dbo.transaction_audit
ORDER BY AuditID;
GO

UPDATE dbo.account_transaction
SET Amount = Amount + 500
WHERE Description = 'Audit insert test';
GO

SELECT *
FROM dbo.transaction_audit
ORDER BY AuditID;
GO

DELETE FROM dbo.account_transaction
WHERE Description = 'Audit insert test';
GO

SELECT *
FROM dbo.transaction_audit
ORDER BY AuditID;
GO

UPDATE dbo.vw_Accounts
SET Balance = Balance + 1000
WHERE AccountID IN (101, 102, 103, 104, 105);
GO

SELECT
    AccountID,
    CustomerName,
    AccountType,
    Balance
FROM dbo.accounts
WHERE AccountID IN (101, 102, 103, 104, 105)
ORDER BY AccountID;
GO

BEGIN TRY
    UPDATE dbo.vw_Accounts
    SET Balance = Balance - 2000
    WHERE AccountID IN (101, 102, 103, 104, 105);

    PRINT 'Batch update completed';
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

SELECT
    AccountID,
    CustomerName,
    AccountType,
    Balance
FROM dbo.accounts
WHERE AccountID IN (101, 102, 103, 104, 105)
ORDER BY AccountID;
GO

SELECT
    OperationType,
    COUNT(*) AS AuditCount
FROM dbo.transaction_audit
GROUP BY OperationType
ORDER BY OperationType;
GO



USE BankAuditDB;
GO

CREATE OR ALTER TRIGGER dbo.trg_TransactionAudit_NestedLog
ON dbo.transaction_audit
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 2
        RETURN;

    INSERT INTO dbo.trigger_execution_log
    (
        TriggerName,
        NestLevel,
        Description
    )
    SELECT
        'trg_TransactionAudit_NestedLog',
        TRIGGER_NESTLEVEL(),
        CONCAT(
            'Audit record created for transaction ',
            I.TransactionID
        )
    FROM inserted I;
END;
GO

SELECT
    name AS TriggerName,
    OBJECT_NAME(parent_id) AS TableName,
    is_disabled AS IsDisabled
FROM sys.triggers
WHERE parent_id IN
(
    OBJECT_ID('dbo.account_transaction'),
    OBJECT_ID('dbo.transaction_audit')
)
ORDER BY name;
GO
*/


USE BankAuditDB;
GO

INSERT INTO dbo.account_transaction
(
    AccountID,
    TransactionType,
    Amount,
    Description
)
VALUES
(
    101,
    'Deposit',
    1500,
    'Nested trigger test'
);
GO

SELECT
    AuditID,
    TransactionID,
    AccountID,
    OperationType,
    NewAmount
FROM dbo.transaction_audit
ORDER BY AuditID DESC;
GO

SELECT
    LogID,
    TriggerName,
    NestLevel,
    Description,
    ExecutionTime
FROM dbo.trigger_execution_log
ORDER BY LogID DESC;
GO
