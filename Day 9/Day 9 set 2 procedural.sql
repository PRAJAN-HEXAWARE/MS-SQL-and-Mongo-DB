
USE InsuranceDB;
GO

CREATE OR ALTER FUNCTION dbo.fn_PremiumWithNoClaimDiscount
(
    @BasePremium DECIMAL(12,2),
    @NoClaimYears INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @DiscountRate DECIMAL(5,2);
    DECLARE @FinalPremium DECIMAL(12,2);

    SET @DiscountRate =
        CASE
            WHEN @NoClaimYears >= 5 THEN 20.00
            WHEN @NoClaimYears >= 3 THEN 15.00
            WHEN @NoClaimYears >= 2 THEN 10.00
            WHEN @NoClaimYears = 1 THEN 5.00
            ELSE 0.00
        END;

    SET @FinalPremium =
        @BasePremium * (1 - @DiscountRate / 100.0);

    RETURN @FinalPremium;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_AgentRenewalQuotes
(
    @AgentID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        P.PolicyID,
        C.CustomerName,
        A.AgentName,
        P.PolicyType,
        P.Premium AS CurrentPremium,
        P.NoClaimYears,
        dbo.fn_PremiumWithNoClaimDiscount(
            P.Premium,
            P.NoClaimYears
        ) AS RenewalQuote,
        P.RenewalDate
    FROM dbo.D9_Policies P
    JOIN dbo.D9_Customers C
        ON P.CustomerID = C.CustomerID
    JOIN dbo.D9_Agents A
        ON P.AgentID = A.AgentID
    WHERE P.AgentID = @AgentID
      AND P.PolicyStatus = 'Active'
      AND P.RenewalDate >= CAST(GETDATE() AS DATE)
      AND P.RenewalDate <= DATEADD(
          DAY, 30, CAST(GETDATE() AS DATE)
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.D9_Claims CL
          WHERE CL.PolicyID = P.PolicyID
            AND CL.ClaimStatus = 'Pending'
      )
);
GO

CREATE OR ALTER PROCEDURE dbo.usp_RenewPolicy
    @PolicyID INT,
    @NewPremium DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @NewPremium = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldPremium DECIMAL(12,2);
        DECLARE @NoClaimYears INT;
        DECLARE @PolicyStatus VARCHAR(20);

        SELECT
            @OldPremium = Premium,
            @NoClaimYears = NoClaimYears,
            @PolicyStatus = PolicyStatus
        FROM dbo.D9_Policies WITH (UPDLOCK, HOLDLOCK)
        WHERE PolicyID = @PolicyID;

        IF @OldPremium IS NULL
            THROW 50001, 'Policy does not exist', 1;

        IF @PolicyStatus <> 'Active'
            THROW 50002, 'Policy is not active', 1;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.D9_Claims
            WHERE PolicyID = @PolicyID
              AND ClaimStatus = 'Pending'
        )
            THROW 50003, 'Policy has a pending claim', 1;

        SET @NewPremium =
            dbo.fn_PremiumWithNoClaimDiscount(
                @OldPremium,
                @NoClaimYears
            );

        UPDATE dbo.D9_Policies
        SET
            Premium = @NewPremium,
            RenewalDate = DATEADD(
                YEAR, 1, RenewalDate
            ),
            NoClaimYears = NoClaimYears + 1
        WHERE PolicyID = @PolicyID;

        INSERT INTO dbo.D9_RenewalAudit
            (PolicyID, OldPremium, NewPremium)
        VALUES
            (@PolicyID, @OldPremium, @NewPremium);

        COMMIT TRANSACTION;

        PRINT 'Policy renewed successfully';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @NewPremium = NULL;

        THROW;
    END CATCH;
END;
GO

SELECT
    PolicyID,
    Premium,
    RenewalDate,
    NoClaimYears,
    PolicyStatus
FROM dbo.D9_Policies
WHERE PolicyID IN (1001, 1003);
GO

SELECT
    dbo.fn_PremiumWithNoClaimDiscount(
        12000, 2
    ) AS PremiumAfterDiscount;
GO

SELECT *
FROM dbo.fn_AgentRenewalQuotes(1);
GO

DECLARE @RenewedPremium DECIMAL(12,2);

EXEC dbo.usp_RenewPolicy
    @PolicyID = 1001,
    @NewPremium = @RenewedPremium OUTPUT;

SELECT @RenewedPremium AS RenewedPremium;
GO

BEGIN TRY
    DECLARE @RejectedPremium DECIMAL(12,2);

    EXEC dbo.usp_RenewPolicy
        @PolicyID = 1003,
        @NewPremium = @RejectedPremium OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Renewal rejected successfully';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

SELECT
    PolicyID,
    Premium,
    RenewalDate,
    NoClaimYears,
    PolicyStatus
FROM dbo.D9_Policies
WHERE PolicyID IN (1001, 1003);

SELECT
    AuditID,
    PolicyID,
    OldPremium,
    NewPremium,
    RenewalDate
FROM dbo.D9_RenewalAudit
ORDER BY AuditID;
GO
