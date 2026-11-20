
USE RetailDB;
GO

IF OBJECT_ID('dbo.D9_OrderFollowUps', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_OrderFollowUps (
        FollowUpID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        FollowUpDate DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        FollowUpMessage VARCHAR(255) NOT NULL,
        ProcessingMethod VARCHAR(20) NOT NULL,
        CONSTRAINT FK_D9_FollowUps_Orders
            FOREIGN KEY (OrderID)
            REFERENCES dbo.D9_Orders(OrderID),
        CONSTRAINT UQ_D9_FollowUp_Method
            UNIQUE (OrderID, ProcessingMethod)
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_CursorOrderFollowUp
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @OrderID INT;

    DECLARE OrderCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT OrderID
    FROM dbo.D9_Orders
    WHERE OrderStatus = 'Pending'
      AND OrderDate < DATEADD(DAY, -3, SYSDATETIME())
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.D9_OrderFollowUps F
          WHERE F.OrderID = dbo.D9_Orders.OrderID
            AND F.ProcessingMethod = 'Cursor'
      );

    BEGIN TRY
        BEGIN TRANSACTION;

        OPEN OrderCursor;

        FETCH NEXT FROM OrderCursor INTO @OrderID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO dbo.D9_OrderFollowUps
                (OrderID, FollowUpMessage, ProcessingMethod)
            VALUES
                (
                    @OrderID,
                    'Order pending for more than 3 days',
                    'Cursor'
                );

            FETCH NEXT FROM OrderCursor INTO @OrderID;
        END;

        CLOSE OrderCursor;
        DEALLOCATE OrderCursor;

        COMMIT TRANSACTION;

        PRINT 'Cursor follow-up processing completed';
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'OrderCursor') >= 0
            CLOSE OrderCursor;

        IF CURSOR_STATUS('local', 'OrderCursor') >= -1
            DEALLOCATE OrderCursor;

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

EXEC dbo.usp_CursorOrderFollowUp;
GO

SELECT
    F.FollowUpID,
    O.OrderID,
    O.CustomerName,
    O.OrderDate,
    O.OrderStatus,
    F.FollowUpMessage,
    F.ProcessingMethod
FROM dbo.D9_OrderFollowUps F
JOIN dbo.D9_Orders O
    ON F.OrderID = O.OrderID
WHERE F.ProcessingMethod = 'Cursor'
ORDER BY F.FollowUpID;
GO

CREATE OR ALTER PROCEDURE dbo.usp_SetBasedOrderFollowUp
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.D9_OrderFollowUps
            (OrderID, FollowUpMessage, ProcessingMethod)
        SELECT
            O.OrderID,
            'Order pending for more than 3 days',
            'SetBased'
        FROM dbo.D9_Orders O
        WHERE O.OrderStatus = 'Pending'
          AND O.OrderDate < DATEADD(DAY, -3, SYSDATETIME())
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.D9_OrderFollowUps F WITH (UPDLOCK, HOLDLOCK)
              WHERE F.OrderID = O.OrderID
                AND F.ProcessingMethod = 'SetBased'
          );

        COMMIT TRANSACTION;

        PRINT 'Set-based follow-up processing completed';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

EXEC dbo.usp_SetBasedOrderFollowUp;
GO

SELECT
    F.FollowUpID,
    O.OrderID,
    O.CustomerName,
    O.OrderStatus,
    F.ProcessingMethod,
    F.FollowUpMessage,
    F.FollowUpDate
FROM dbo.D9_OrderFollowUps F
JOIN dbo.D9_Orders O
    ON F.OrderID = O.OrderID
ORDER BY F.ProcessingMethod, O.OrderID;
GO

SELECT
    ProcessingMethod,
    COUNT(*) AS TotalFollowUps
FROM dbo.D9_OrderFollowUps
GROUP BY ProcessingMethod;
GO
