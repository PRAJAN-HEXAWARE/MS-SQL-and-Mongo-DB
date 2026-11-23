/*
IF DB_ID('RetailPriceAuditDB') IS NULL
    CREATE DATABASE RetailPriceAuditDB;
GO

USE RetailPriceAuditDB;
GO

IF OBJECT_ID('dbo.product_price', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.product_price
    (
        ProductID INT PRIMARY KEY,
        ProductName VARCHAR(100) NOT NULL,
        Category VARCHAR(50) NOT NULL,
        CostPrice DECIMAL(12,2) NOT NULL,
        SellingPrice DECIMAL(12,2) NOT NULL,
        LastUpdated DATETIME2 NOT NULL
            DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID('dbo.price_audit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.price_audit
    (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        OldPrice DECIMAL(12,2) NOT NULL,
        NewPrice DECIMAL(12,2) NOT NULL,
        ChangedBy SYSNAME NOT NULL,
        ChangedAt DATETIME2 NOT NULL
            DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID('dbo.rejected_price_attempts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.rejected_price_attempts
    (
        AttemptID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        AttemptedPrice DECIMAL(12,2) NOT NULL,
        CostPrice DECIMAL(12,2) NOT NULL,
        AttemptedBy SYSNAME NOT NULL,
        AttemptedAt DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        Reason VARCHAR(255) NOT NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.product_price)
BEGIN
    INSERT INTO dbo.product_price
        (ProductID, ProductName, Category,
         CostPrice, SellingPrice)
    VALUES
        (101, 'Laptop', 'Electronics', 42000, 50000),
        (102, 'Mobile', 'Electronics', 16000, 20000),
        (103, 'Headphones', 'Electronics', 1200, 2000),
        (104, 'Shirt', 'Clothing', 600, 1000),
        (105, 'Jeans', 'Clothing', 1300, 2000),
        (106, 'Jacket', 'Clothing', 2100, 3000),
        (107, 'Keyboard', 'Electronics', 700, 1200),
        (108, 'Mouse', 'Electronics', 300, 600),
        (109, 'Shoes', 'Footwear', 1500, 2500),
        (110, 'Watch', 'Accessories', 1800, 3500);
END;
GO

SELECT *
FROM dbo.product_price
ORDER BY ProductID;

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN
(
    'product_price',
    'price_audit',
    'rejected_price_attempts'
)
ORDER BY TABLE_NAME;
GO
*/

USE RetailPriceAuditDB;
GO

CREATE OR ALTER TRIGGER dbo.trg_ProductPrice_Audit
ON dbo.product_price
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.price_audit
    (
        ProductID,
        OldPrice,
        NewPrice,
        ChangedBy,
        ChangedAt
    )
    SELECT
        I.ProductID,
        D.SellingPrice,
        I.SellingPrice,
        ORIGINAL_LOGIN(),
        SYSDATETIME()
    FROM inserted I
    INNER JOIN deleted D
        ON I.ProductID = D.ProductID
    WHERE I.SellingPrice <> D.SellingPrice;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_ProductPrice_Validation
ON dbo.product_price
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.rejected_price_attempts
    (
        ProductID,
        AttemptedPrice,
        CostPrice,
        AttemptedBy,
        AttemptedAt,
        Reason
    )
    SELECT
        I.ProductID,
        I.SellingPrice,
        I.CostPrice,
        ORIGINAL_LOGIN(),
        SYSDATETIME(),
        'Selling price cannot be below cost price'
    FROM inserted I
    WHERE I.SellingPrice < I.CostPrice;

    UPDATE P
    SET
        P.ProductName = I.ProductName,
        P.Category = I.Category,
        P.CostPrice = I.CostPrice,
        P.SellingPrice = I.SellingPrice,
        P.LastUpdated = SYSDATETIME()
    FROM dbo.product_price P
    INNER JOIN inserted I
        ON P.ProductID = I.ProductID
    WHERE I.SellingPrice >= I.CostPrice;

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE SellingPrice < CostPrice
    )
    BEGIN
        PRINT 'Invalid price updates rejected and logged';
    END;
END;
GO

SELECT
    T.name AS TriggerName,
    OBJECT_NAME(T.parent_id) AS TableName,
    T.is_disabled AS IsDisabled
FROM sys.triggers T
WHERE T.parent_id = OBJECT_ID('dbo.product_price')
ORDER BY T.name;
GO
