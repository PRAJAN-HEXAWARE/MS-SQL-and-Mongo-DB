USE BankDB;
GO

WITH MonthlyStatement AS
(
    SELECT
        TransactionID,
        AccountID,
        TransactionType,
        Amount,
        BalanceAfter,
        TransactionDate,

        ROW_NUMBER() OVER (
            PARTITION BY AccountID
            ORDER BY TransactionDate, TransactionID
        ) AS RowNum,

        LAG(BalanceAfter) OVER (
            PARTITION BY AccountID
            ORDER BY TransactionDate, TransactionID
        ) AS PreviousBalance

    FROM dbo.BankTransactions

    WHERE TransactionDate >=
        DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)

    AND TransactionDate <
        DATEADD(
            MONTH,
            1,
            DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
        )
)

SELECT
    AccountID,
    RowNum,
    TransactionID,
    TransactionType,
    Amount,
    PreviousBalance,
    BalanceAfter,
    TransactionDate
FROM MonthlyStatement
ORDER BY AccountID, RowNum;
