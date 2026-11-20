
USE TelecomDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_CursorLowBalanceNotification
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SubscriberID INT;
    DECLARE @Balance DECIMAL(12,2);

    DECLARE SubscriberCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT SubscriberID, Balance
    FROM dbo.D9_Subscribers
    WHERE SubscriberType = 'Prepaid'
      AND Status = 'Active'
      AND Balance < 50;

    BEGIN TRY
        BEGIN TRANSACTION;

        OPEN SubscriberCursor;

        FETCH NEXT FROM SubscriberCursor
        INTO @SubscriberID, @Balance;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO dbo.D9_Notifications
                (
                    SubscriberID,
                    NotificationMessage,
                    IsRead,
                    ProcessingMethod
                )
            VALUES
                (
                    @SubscriberID,
                    CONCAT(
                        'Low balance alert: Your balance is ',
                        @Balance,
                        '. Please recharge soon.'
                    ),
                    0,
                    'Cursor'
                );

            FETCH NEXT FROM SubscriberCursor
            INTO @SubscriberID, @Balance;
        END;

        CLOSE SubscriberCursor;
        DEALLOCATE SubscriberCursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'SubscriberCursor') >= 0
            CLOSE SubscriberCursor;

        IF CURSOR_STATUS('local', 'SubscriberCursor') >= -1
            DEALLOCATE SubscriberCursor;

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_SetBasedLowBalanceNotification
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.D9_Notifications
            (
                SubscriberID,
                NotificationMessage,
                IsRead,
                ProcessingMethod
            )
        SELECT
            SubscriberID,
            CONCAT(
                'Low balance alert: Your balance is ',
                Balance,
                '. Please recharge soon.'
            ),
            0,
            'SetBased'
        FROM dbo.D9_Subscribers
        WHERE SubscriberType = 'Prepaid'
          AND Status = 'Active'
          AND Balance < 50;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

IF OBJECT_ID('dbo.D9_PerformanceResults', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_PerformanceResults
    (
        ResultID INT IDENTITY(1,1) PRIMARY KEY,
        ProcessingMethod VARCHAR(20) NOT NULL,
        ExecutionTimeMs DECIMAL(18,3) NOT NULL,
        NotificationsInserted INT NOT NULL,
        TestedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

DELETE FROM dbo.D9_Notifications
WHERE ProcessingMethod IN ('Cursor', 'SetBased');

DELETE FROM dbo.D9_PerformanceResults;
GO

DECLARE @CursorStart DATETIME2(7);
DECLARE @CursorEnd DATETIME2(7);
DECLARE @CursorTimeMs DECIMAL(18,3);
DECLARE @CursorCount INT;

SET @CursorStart = SYSDATETIME();

EXEC dbo.usp_CursorLowBalanceNotification;

SET @CursorEnd = SYSDATETIME();

SET @CursorTimeMs =
    DATEDIFF_BIG(
        MICROSECOND,
        @CursorStart,
        @CursorEnd
    ) / 1000.0;

SELECT @CursorCount = COUNT(*)
FROM dbo.D9_Notifications
WHERE ProcessingMethod = 'Cursor';

INSERT INTO dbo.D9_PerformanceResults
    (
        ProcessingMethod,
        ExecutionTimeMs,
        NotificationsInserted
    )
VALUES
    ('Cursor', @CursorTimeMs, @CursorCount);
GO

DECLARE @SetStart DATETIME2(7);
DECLARE @SetEnd DATETIME2(7);
DECLARE @SetTimeMs DECIMAL(18,3);
DECLARE @SetCount INT;

SET @SetStart = SYSDATETIME();

EXEC dbo.usp_SetBasedLowBalanceNotification;

SET @SetEnd = SYSDATETIME();

SET @SetTimeMs =
    DATEDIFF_BIG(
        MICROSECOND,
        @SetStart,
        @SetEnd
    ) / 1000.0;

SELECT @SetCount = COUNT(*)
FROM dbo.D9_Notifications
WHERE ProcessingMethod = 'SetBased';

INSERT INTO dbo.D9_PerformanceResults
    (
        ProcessingMethod,
        ExecutionTimeMs,
        NotificationsInserted
    )
VALUES
    ('SetBased', @SetTimeMs, @SetCount);
GO

SELECT
    ProcessingMethod,
    ExecutionTimeMs,
    NotificationsInserted,
    TestedAt
FROM dbo.D9_PerformanceResults
ORDER BY ResultID;

SELECT
    ProcessingMethod,
    COUNT(*) AS TotalNotifications
FROM dbo.D9_Notifications
GROUP BY ProcessingMethod;

SELECT
    N.NotificationID,
    S.SubscriberID,
    S.SubscriberName,
    S.Balance,
    N.NotificationMessage,
    N.ProcessingMethod,
    N.IsRead
FROM dbo.D9_Notifications N
JOIN dbo.D9_Subscribers S
    ON N.SubscriberID = S.SubscriberID
ORDER BY N.ProcessingMethod, S.SubscriberID;
GO
