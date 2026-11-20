
USE TelecomDB;
GO

CREATE OR ALTER FUNCTION dbo.fn_ValidityDaysLeft
(
    @SubscriberID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @ValidityEndDate DATE;
    DECLARE @DaysLeft INT;

    SELECT @ValidityEndDate = ValidityEndDate
    FROM dbo.D9_Subscribers
    WHERE SubscriberID = @SubscriberID
      AND SubscriberType = 'Prepaid';

    IF @ValidityEndDate IS NULL
        RETURN NULL;

    SET @DaysLeft = DATEDIFF(
        DAY,
        CAST(GETDATE() AS DATE),
        @ValidityEndDate
    );

    RETURN CASE
        WHEN @DaysLeft < 0 THEN 0
        ELSE @DaysLeft
    END;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_LastFiveRecharges
(
    @SubscriberID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (5)
        R.RechargeID,
        R.SubscriberID,
        S.SubscriberName,
        P.PlanName,
        R.RechargeAmount,
        R.RechargeDate,
        R.BalanceAfterRecharge
    FROM dbo.D9_RechargeHistory R
    JOIN dbo.D9_Subscribers S
        ON R.SubscriberID = S.SubscriberID
    JOIN dbo.D9_Plans P
        ON R.PlanID = P.PlanID
    WHERE R.SubscriberID = @SubscriberID
      AND S.SubscriberType = 'Prepaid'
    ORDER BY R.RechargeDate DESC, R.RechargeID DESC
);
GO

CREATE OR ALTER PROCEDURE dbo.usp_Recharge
    @SubscriberID INT,
    @PlanID INT,
    @Amount DECIMAL(12,2),
    @NewBalance DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @NewBalance = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @MinimumRecharge DECIMAL(12,2);
        DECLARE @ValidityDays INT;
        DECLARE @CurrentBalance DECIMAL(12,2);
        DECLARE @CurrentValidity DATE;

        IF @Amount IS NULL OR @Amount <= 0
            THROW 50001, 'Recharge amount must be greater than zero', 1;

        SELECT
            @MinimumRecharge = MinimumRecharge,
            @ValidityDays = ValidityDays
        FROM dbo.D9_Plans
        WHERE PlanID = @PlanID
          AND IsActive = 1;

        IF @MinimumRecharge IS NULL
            THROW 50002, 'Invalid or inactive recharge plan', 1;

        IF @Amount < @MinimumRecharge
            THROW 50003, 'Recharge amount is below the plan minimum', 1;

        SELECT
            @CurrentBalance = Balance,
            @CurrentValidity = ValidityEndDate
        FROM dbo.D9_Subscribers WITH (UPDLOCK, HOLDLOCK)
        WHERE SubscriberID = @SubscriberID
          AND SubscriberType = 'Prepaid'
          AND Status = 'Active';

        IF @CurrentBalance IS NULL
            THROW 50004, 'Active prepaid subscriber not found', 1;

        UPDATE dbo.D9_Subscribers
        SET
            Balance = Balance + @Amount,
            PlanID = @PlanID,
            ValidityEndDate = DATEADD(
                DAY,
                @ValidityDays,
                CASE
                    WHEN @CurrentValidity > CAST(GETDATE() AS DATE)
                        THEN @CurrentValidity
                    ELSE CAST(GETDATE() AS DATE)
                END
            )
        WHERE SubscriberID = @SubscriberID;

        SELECT @NewBalance = Balance
        FROM dbo.D9_Subscribers
        WHERE SubscriberID = @SubscriberID;

        INSERT INTO dbo.D9_RechargeHistory
            (
                SubscriberID,
                PlanID,
                RechargeAmount,
                RechargeDate,
                BalanceAfterRecharge
            )
        VALUES
            (
                @SubscriberID,
                @PlanID,
                @Amount,
                SYSDATETIME(),
                @NewBalance
            );

        COMMIT TRANSACTION;

        PRINT 'Recharge completed successfully';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @NewBalance = NULL;

        THROW;
    END CATCH;
END;
GO

SELECT
    SubscriberID,
    SubscriberName,
    Balance,
    PlanID,
    ValidityEndDate
FROM dbo.D9_Subscribers
WHERE SubscriberID IN (101, 102, 103);
GO

SELECT
    SubscriberID,
    SubscriberName,
    dbo.fn_ValidityDaysLeft(SubscriberID) AS ValidityDaysLeft
FROM dbo.D9_Subscribers
WHERE SubscriberType = 'Prepaid'
ORDER BY SubscriberID;
GO

SELECT *
FROM dbo.fn_LastFiveRecharges(101);
GO

DECLARE @UpdatedBalance DECIMAL(12,2);

EXEC dbo.usp_Recharge
    @SubscriberID = 103,
    @PlanID = 2,
    @Amount = 199,
    @NewBalance = @UpdatedBalance OUTPUT;

SELECT @UpdatedBalance AS NewBalance;
GO

SELECT
    SubscriberID,
    SubscriberName,
    Balance,
    PlanID,
    ValidityEndDate
FROM dbo.D9_Subscribers
WHERE SubscriberID = 103;

SELECT *
FROM dbo.fn_LastFiveRecharges(103);
GO

BEGIN TRY
    DECLARE @FailedBalance DECIMAL(12,2);

    EXEC dbo.usp_Recharge
        @SubscriberID = 102,
        @PlanID = 3,
        @Amount = 100,
        @NewBalance = @FailedBalance OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Invalid recharge rejected successfully';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    DECLARE @InactivePlanBalance DECIMAL(12,2);

    EXEC dbo.usp_Recharge
        @SubscriberID = 101,
        @PlanID = 5,
        @Amount = 149,
        @NewBalance = @InactivePlanBalance OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Inactive plan rejected successfully';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

SELECT
    SubscriberID,
    SubscriberName,
    Balance,
    PlanID,
    dbo.fn_ValidityDaysLeft(SubscriberID) AS ValidityDaysLeft
FROM dbo.D9_Subscribers
WHERE SubscriberType = 'Prepaid'
ORDER BY SubscriberID;

SELECT
    RechargeID,
    SubscriberID,
    PlanID,
    RechargeAmount,
    RechargeDate,
    BalanceAfterRecharge
FROM dbo.D9_RechargeHistory
ORDER BY RechargeID;
GO
