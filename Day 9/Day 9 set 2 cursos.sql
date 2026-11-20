
USE InsuranceDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_SetBasedPolicyLapse
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ChangedPolicies TABLE
    (
        PolicyID INT,
        OldStatus VARCHAR(20),
        NewStatus VARCHAR(20)
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE P
        SET P.PolicyStatus = 'Lapsed'
        OUTPUT
            inserted.PolicyID,
            deleted.PolicyStatus,
            inserted.PolicyStatus
        INTO @ChangedPolicies
            (PolicyID, OldStatus, NewStatus)
        FROM dbo.D9_Policies P
        WHERE P.PolicyStatus = 'Active'
          AND EXISTS
          (
              SELECT 1
              FROM dbo.D9_PremiumPayments PP
              WHERE PP.PolicyID = P.PolicyID
                AND PP.DueDate < CAST(GETDATE() AS DATE)
                AND PP.PaymentStatus = 'Overdue'
                AND PP.PaymentDate IS NULL
          );

        INSERT INTO dbo.D9_PolicyLapseLog
            (PolicyID, OldStatus, NewStatus, ProcessingMethod)
        SELECT
            PolicyID,
            OldStatus,
            NewStatus,
            'SetBased'
        FROM @ChangedPolicies;

        COMMIT TRANSACTION;

        PRINT 'Set-based policy lapse completed';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

UPDATE dbo.D9_Policies
SET PolicyStatus = 'Active'
WHERE PolicyID IN (1004, 1005)
  AND PolicyStatus = 'Lapsed';
GO

EXEC dbo.usp_SetBasedPolicyLapse;
GO

SELECT
    PolicyID,
    PolicyStatus
FROM dbo.D9_Policies
WHERE PolicyID IN (1004, 1005);

SELECT
    ProcessingMethod,
    COUNT(*) AS TotalPoliciesProcessed
FROM dbo.D9_PolicyLapseLog
GROUP BY ProcessingMethod;
GO
