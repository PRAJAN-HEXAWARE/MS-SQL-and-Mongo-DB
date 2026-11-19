/*
IF DB_ID('BankDB') IS NULL
    CREATE DATABASE BankDB;
GO

USE BankDB;
GO


IF OBJECT_ID('dbo.BankAccounts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BankAccounts (
        AccountID INT PRIMARY KEY,
        AccountHolder VARCHAR(100),
        Balance DECIMAL(12,2) NOT NULL
            CHECK (Balance >= 0),
        Status VARCHAR(20) NOT NULL
            CHECK (Status IN ('Active', 'Inactive'))
    );
END;
GO


IF OBJECT_ID('dbo.BankTransactions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BankTransactions (
        TransactionID INT IDENTITY(1,1) PRIMARY KEY,
        AccountID INT NOT NULL,
        TransactionType VARCHAR(20) NOT NULL,
        Amount DECIMAL(12,2) NOT NULL,
        BalanceAfter DECIMAL(12,2) NOT NULL,
        TransactionDate DATETIME2 DEFAULT SYSDATETIME(),
        FOREIGN KEY (AccountID)
            REFERENCES dbo.BankAccounts(AccountID)
    );
END;
GO

-- STEP 4: Insert sample accounts if they do not exist

INSERT INTO dbo.BankAccounts
    (AccountID, AccountHolder, Balance, Status)
SELECT 101, 'Arun', 10000.00, 'Active'
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.BankAccounts WHERE AccountID = 101
);

INSERT INTO dbo.BankAccounts
    (AccountID, AccountHolder, Balance, Status)
SELECT 102, 'Bala', 5000.00, 'Active'
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.BankAccounts WHERE AccountID = 102
);

INSERT INTO dbo.BankAccounts
    (AccountID, AccountHolder, Balance, Status)
SELECT 103, 'Charan', 2000.00, 'Inactive'
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.BankAccounts WHERE AccountID = 103
);
GO

SELECT * FROM dbo.BankAccounts;

SELECT * FROM dbo.BankTransactions;



USE BankDB;
GO

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @FromAccount INT = 101;
    DECLARE @ToAccount INT = 102;
    DECLARE @Amount DECIMAL(12,2) = 2000.00;

    IF @Amount <= 0
        THROW 50001, 'Invalid transfer amount', 1;

    IF @FromAccount = @ToAccount
        THROW 50002, 'Cannot transfer to same account', 1;

    DECLARE @ActiveAccounts INT;

    SELECT @ActiveAccounts = COUNT(*)
    FROM dbo.BankAccounts WITH (UPDLOCK, HOLDLOCK)
    WHERE AccountID IN (@FromAccount, @ToAccount)
      AND Status = 'Active';

    IF @ActiveAccounts <> 2
        THROW 50003, 'Account not found or inactive', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.BankAccounts
        WHERE AccountID = @FromAccount
          AND Balance >= @Amount
    )
        THROW 50004, 'Insufficient balance', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - @Amount
    WHERE AccountID = @FromAccount;

    INSERT INTO dbo.BankTransactions
        (AccountID, TransactionType, Amount, BalanceAfter)
    SELECT AccountID, 'Debit', @Amount, Balance
    FROM dbo.BankAccounts
    WHERE AccountID = @FromAccount;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + @Amount
    WHERE AccountID = @ToAccount;

    INSERT INTO dbo.BankTransactions
        (AccountID, TransactionType, Amount, BalanceAfter)
    SELECT AccountID, 'Credit', @Amount, Balance
    FROM dbo.BankAccounts
    WHERE AccountID = @ToAccount;

    COMMIT TRANSACTION;

    PRINT 'Transfer completed successfully';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Transfer failed';
    THROW;
END CATCH;

SELECT * FROM dbo.BankAccounts;

SELECT * FROM dbo.BankTransactions;



USE BankDB;
GO

SET XACT_ABORT ON;

SELECT AccountID, AccountHolder, Balance
FROM dbo.BankAccounts
WHERE AccountID IN (101, 102);

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - 1000
    WHERE AccountID = 101;

    PRINT 'Amount debited successfully';

    SELECT AccountID, AccountHolder, Balance
    FROM dbo.BankAccounts
    WHERE AccountID IN (101, 102);

    THROW 50005, 'Deliberate failure after debit', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + 1000
    WHERE AccountID = 102;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Transaction rolled back successfully';
    PRINT ERROR_MESSAGE();
END CATCH;

SELECT AccountID, AccountHolder, Balance
FROM dbo.BankAccounts
WHERE AccountID IN (101, 102);

SELECT *
FROM dbo.BankTransactions;



USE BankDB;
GO

SET XACT_ABORT OFF;

SELECT AccountID, AccountHolder, Balance
FROM dbo.BankAccounts
WHERE AccountID IN (101, 102);

BEGIN TRY
    BEGIN TRANSACTION;

    IF (
        SELECT COUNT(*)
        FROM dbo.BankAccounts WITH (UPDLOCK, HOLDLOCK)
        WHERE AccountID IN (101, 102)
          AND Status = 'Active'
    ) <> 2
        THROW 50010, 'Account not found or inactive', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.BankAccounts
        WHERE AccountID = 101
          AND Balance >= 1000
    )
        THROW 50011, 'Insufficient balance', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - 1000
    WHERE AccountID = 101;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + 1000
    WHERE AccountID = 102;

    INSERT INTO dbo.BankTransactions
        (AccountID, TransactionType, Amount, BalanceAfter)
    SELECT AccountID, 'Debit', 1000, Balance
    FROM dbo.BankAccounts
    WHERE AccountID = 101;

    INSERT INTO dbo.BankTransactions
        (AccountID, TransactionType, Amount, BalanceAfter)
    SELECT AccountID, 'Credit', 1000, Balance
    FROM dbo.BankAccounts
    WHERE AccountID = 102;

    PRINT 'Fund transfer completed';

    SAVE TRANSACTION BeforeFee;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - 50
    WHERE AccountID = 101
      AND Balance >= 50;

    IF @@ROWCOUNT <> 1
        THROW 50012, 'Insufficient balance for fee', 1;

    PRINT 'Processing fee deducted';

    SELECT AccountID, AccountHolder, Balance
    FROM dbo.BankAccounts
    WHERE AccountID IN (101, 102);

    ROLLBACK TRANSACTION BeforeFee;

    PRINT 'Fee deduction rolled back';

    COMMIT TRANSACTION;

    PRINT 'Fund transfer committed successfully';

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();
    THROW;
END CATCH;

SET XACT_ABORT ON;

SELECT AccountID, AccountHolder, Balance
FROM dbo.BankAccounts
WHERE AccountID IN (101, 102);

SELECT *
FROM dbo.BankTransactions
ORDER BY TransactionID;
*/


