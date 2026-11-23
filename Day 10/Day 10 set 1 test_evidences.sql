
USE RetailPriceAuditDB;
GO

SELECT
    ProductID,
    ProductName,
    CostPrice,
    SellingPrice
FROM dbo.product_price
ORDER BY ProductID;
GO

UPDATE dbo.product_price
SET SellingPrice = 52000
WHERE ProductID = 101;
GO

SELECT
    ProductID,
    ProductName,
    SellingPrice
FROM dbo.product_price
WHERE ProductID = 101;

SELECT
    AuditID,
    ProductID,
    OldPrice,
    NewPrice,
    ChangedBy,
    ChangedAt
FROM dbo.price_audit
WHERE ProductID = 101
ORDER BY AuditID;
GO

UPDATE dbo.product_price
SET SellingPrice =
    CASE ProductID
        WHEN 102 THEN 22000
        WHEN 103 THEN 2500
        WHEN 104 THEN 1200
        ELSE SellingPrice
    END
WHERE ProductID IN (102, 103, 104);
GO

SELECT
    ProductID,
    ProductName,
    SellingPrice
FROM dbo.product_price
WHERE ProductID IN (102, 103, 104)
ORDER BY ProductID;

SELECT
    AuditID,
    ProductID,
    OldPrice,
    NewPrice
FROM dbo.price_audit
WHERE ProductID IN (102, 103, 104)
ORDER BY AuditID;
GO

UPDATE dbo.product_price
SET SellingPrice = 35000
WHERE ProductID = 101;
GO

SELECT
    ProductID,
    ProductName,
    CostPrice,
    SellingPrice
FROM dbo.product_price
WHERE ProductID = 101;

SELECT
    AttemptID,
    ProductID,
    AttemptedPrice,
    CostPrice,
    AttemptedBy,
    Reason
FROM dbo.rejected_price_attempts
WHERE ProductID = 101
ORDER BY AttemptID;
GO

UPDATE dbo.product_price
SET SellingPrice =
    CASE ProductID
        WHEN 105 THEN 1000
        WHEN 106 THEN 3500
        WHEN 107 THEN 500
        WHEN 108 THEN 800
        ELSE SellingPrice
    END
WHERE ProductID IN (105, 106, 107, 108);
GO

SELECT
    ProductID,
    ProductName,
    CostPrice,
    SellingPrice
FROM dbo.product_price
WHERE ProductID IN (105, 106, 107, 108)
ORDER BY ProductID;

SELECT
    AttemptID,
    ProductID,
    AttemptedPrice,
    CostPrice,
    Reason
FROM dbo.rejected_price_attempts
ORDER BY AttemptID;
GO

SELECT
    AuditID,
    ProductID,
    OldPrice,
    NewPrice,
    ChangedBy,
    ChangedAt
FROM dbo.price_audit
ORDER BY AuditID;

SELECT
    COUNT(*) AS TotalSuccessfulPriceChanges
FROM dbo.price_audit;

SELECT
    COUNT(*) AS TotalRejectedAttempts
FROM dbo.rejected_price_attempts;
GO
