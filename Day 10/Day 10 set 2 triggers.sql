/*
IF DB_ID('BankAuditDB') IS NULL
    CREATE DATABASE BankAuditDB;
GO

USE BankAuditDB;
GO

IF OBJECT_ID('dbo.accounts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.accounts
    (
        AccountID INT PRIMARY KEY,
        CustomerName VARCHAR(100) NOT NULL,
        AccountType VARCHAR(20) NOT NULL
            CHECK (AccountType IN ('Savings', 'Current')),
        Balance DECIMAL(15,2) NOT NULL,
        AccountStatus VARCHAR(20) NOT NULL
            DEFAULT 'Active',
        LastUpdated DATETIME2 NOT NULL
            DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID('dbo.account_transaction', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.account_transaction
    (
        TransactionID INT IDENTITY(1,1) PRIMARY KEY,
        AccountID INT NOT NULL,
        TransactionType VARCHAR(20) NOT NULL
            CHECK (TransactionType IN ('Deposit', 'Withdrawal', 'Transfer')),
        Amount DECIMAL(15,2) NOT NULL
            CHECK (Amount > 0),
        TransactionDate DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        Description VARCHAR(255),
        FOREIGN KEY (AccountID)
            REFERENCES dbo.accounts(AccountID)
    );
END;
GO

IF OBJECT_ID('dbo.transaction_audit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.transaction_audit
    (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        TransactionID INT NOT NULL,
        AccountID INT NOT NULL,
        OperationType VARCHAR(10) NOT NULL,
        OldAmount DECIMAL(15,2) NULL,
        NewAmount DECIMAL(15,2) NULL,
        OldTransactionType VARCHAR(20) NULL,
        NewTransactionType VARCHAR(20) NULL,
        ChangedBy SYSNAME NOT NULL,
        ChangedAt DATETIME2 NOT NULL
            DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID('dbo.trigger_execution_log', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.trigger_execution_log
    (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        TriggerName VARCHAR(100) NOT NULL,
        NestLevel INT NOT NULL,
        ExecutionTime DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        Description VARCHAR(255)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.accounts)
BEGIN
    INSERT INTO dbo.accounts
        (AccountID, CustomerName, AccountType, Balance)
    VALUES
        (101, 'Arun', 'Savings', 15000),
        (102, 'Bala', 'Savings', 8000),
        (103, 'Charan', 'Savings', 5000),
        (104, 'Divya', 'Savings', 12000),
        (105, 'Esha', 'Savings', 500),
        (106, 'Farhan', 'Current', 20000),
        (107, 'Gokul', 'Current', 10000),
        (108, 'Harini', 'Savings', 25000),
        (109, 'Ishaan', 'Savings', 7000),
        (110, 'Janani', 'Current', 30000);
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.account_transaction)
BEGIN
    INSERT INTO dbo.account_transaction
        (AccountID, TransactionType, Amount, Description)
    VALUES
        (101, 'Deposit', 5000, 'Initial deposit'),
        (102, 'Deposit', 3000, 'Initial deposit'),
        (103, 'Withdrawal', 1000, 'ATM withdrawal'),
        (104, 'Deposit', 7000, 'Initial deposit'),
        (105, 'Deposit', 500, 'Initial deposit'),
        (106, 'Transfer', 2000, 'Fund transfer'),
        (107, 'Deposit', 4000, 'Initial deposit'),
        (108, 'Withdrawal', 2000, 'ATM withdrawal'),
        (109, 'Deposit', 2500, 'Initial deposit'),
        (110, 'Transfer', 5000, 'Fund transfer');
END;
GO

SELECT
    AccountID,
    CustomerName,
    AccountType,
    Balance,
    AccountStatus
FROM dbo.accounts
ORDER BY AccountID;

SELECT
    TransactionID,
    AccountID,
    TransactionType,
    Amount,
    Description
FROM dbo.account_transaction
ORDER BY TransactionID;

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN
(
    'accounts',
    'account_transaction',
    'transaction_audit',
    'trigger_execution_log'
)
ORDER BY TABLE_NAME;
GO
*/


USE BankAuditDB;
GO

CREATE OR ALTER TRIGGER dbo.trg_AccountTransaction_Audit
ON dbo.account_transaction
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    INSERT INTO dbo.transaction_audit
    (
        TransactionID,
        AccountID,
        OperationType,
        OldAmount,
        NewAmount,
        OldTransactionType,
        NewTransactionType,
        ChangedBy,
        ChangedAt
    )
    SELECT
        COALESCE(I.TransactionID, D.TransactionID),
        COALESCE(I.AccountID, D.AccountID),
        CASE
            WHEN D.TransactionID IS NULL THEN 'INSERT'
            WHEN I.TransactionID IS NULL THEN 'DELETE'
            ELSE 'UPDATE'
        END,
        D.Amount,
        I.Amount,
        D.TransactionType,
        I.TransactionType,
        ORIGINAL_LOGIN(),
        SYSDATETIME()
    FROM inserted I
    FULL OUTER JOIN deleted D
        ON I.TransactionID = D.TransactionID;
END;
GO

CREATE OR ALTER VIEW dbo.vw_Accounts
AS
SELECT
    AccountID,
    CustomerName,
    AccountType,
    Balance,
    AccountStatus,
    LastUpdated
FROM dbo.accounts;
GO

CREATE OR ALTER TRIGGER dbo.trg_Accounts_BalanceGuard
ON dbo.vw_Accounts
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE AccountType = 'Savings'
          AND Balance < 0
    )
    BEGIN
        THROW 50001,
              'Savings account balance cannot be negative.',
              1;
    END;

    UPDATE A
    SET
        A.CustomerName = I.CustomerName,
        A.AccountType = I.AccountType,
        A.Balance = I.Balance,
        A.AccountStatus = I.AccountStatus,
        A.LastUpdated = SYSDATETIME()
    FROM dbo.accounts A
    INNER JOIN inserted I
        ON A.AccountID = I.AccountID;
END;
GO

SELECT
    T.name AS TriggerName,
    OBJECT_NAME(T.parent_id) AS ParentObject,
    T.is_instead_of_trigger AS IsInsteadOfTrigger,
    T.is_disabled AS IsDisabled
FROM sys.triggers T
WHERE T.parent_id IN
(
    OBJECT_ID('dbo.account_transaction'),
    OBJECT_ID('dbo.vw_Accounts')
)
ORDER BY T.name;
GO
