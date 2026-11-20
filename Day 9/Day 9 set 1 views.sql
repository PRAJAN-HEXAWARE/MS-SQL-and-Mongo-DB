
USE RetailDB;
GO

IF OBJECT_ID('dbo.D9_Products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Products (
        ProductID INT PRIMARY KEY,
        ProductName VARCHAR(100) NOT NULL,
        Category VARCHAR(50) NOT NULL,
        SellingPrice DECIMAL(10,2) NOT NULL,
        CostPrice DECIMAL(10,2) NOT NULL,
        SupplierName VARCHAR(100) NOT NULL,
        Stock INT NOT NULL CHECK (Stock >= 0)
    );
END;
GO

IF OBJECT_ID('dbo.D9_Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Orders (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL,
        CustomerName VARCHAR(100) NOT NULL,
        OrderDate DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        OrderStatus VARCHAR(20) NOT NULL
            DEFAULT 'Pending'
    );
END;
GO

IF OBJECT_ID('dbo.D9_OrderLines', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_OrderLines (
        OrderLineID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL CHECK (Quantity > 0),
        UnitPrice DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (OrderID)
            REFERENCES dbo.D9_Orders(OrderID),
        FOREIGN KEY (ProductID)
            REFERENCES dbo.D9_Products(ProductID)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.D9_Products
)
BEGIN
    INSERT INTO dbo.D9_Products
    VALUES
    (101, 'Laptop', 'Electronics', 50000, 42000, 'Dell Supplier', 20),
    (102, 'Mobile', 'Electronics', 20000, 16000, 'Samsung Supplier', 8),
    (103, 'Headphones', 'Electronics', 2000, 1200, 'Sony Supplier', 5),
    (104, 'Shirt', 'Clothing', 1000, 600, 'Fashion Supplier', 50),
    (105, 'Jeans', 'Clothing', 2000, 1300, 'Denim Supplier', 7),
    (106, 'Jacket', 'Clothing', 3000, 2100, 'Winter Supplier', 15);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.D9_Orders
)
BEGIN
    INSERT INTO dbo.D9_Orders
        (CustomerID, CustomerName, OrderDate, OrderStatus)
    VALUES
    (201, 'Arun', DATEADD(DAY, -6, SYSDATETIME()), 'Pending'),
    (202, 'Bala', DATEADD(DAY, -5, SYSDATETIME()), 'Pending'),
    (203, 'Charan', DATEADD(DAY, -2, SYSDATETIME()), 'Pending'),
    (204, 'Divya', DATEADD(DAY, -8, SYSDATETIME()), 'Completed');

    INSERT INTO dbo.D9_OrderLines
        (OrderID, ProductID, Quantity, UnitPrice)
    SELECT
        O.OrderID,
        V.ProductID,
        V.Quantity,
        P.SellingPrice
    FROM (VALUES
        (201, 101, 1),
        (202, 102, 2),
        (203, 104, 3),
        (204, 105, 2)
    ) AS V(CustomerID, ProductID, Quantity)
    JOIN dbo.D9_Orders O
        ON O.CustomerID = V.CustomerID
    JOIN dbo.D9_Products P
        ON P.ProductID = V.ProductID;
END;
GO

CREATE OR ALTER VIEW dbo.vw_order_summary
AS
SELECT
    O.OrderID,
    O.CustomerID,
    O.CustomerName,
    O.OrderDate,
    O.OrderStatus,
    SUM(OL.Quantity) AS TotalQuantity,
    SUM(OL.Quantity * OL.UnitPrice) AS OrderTotal
FROM dbo.D9_Orders O
JOIN dbo.D9_OrderLines OL
    ON O.OrderID = OL.OrderID
GROUP BY
    O.OrderID,
    O.CustomerID,
    O.CustomerName,
    O.OrderDate,
    O.OrderStatus;
GO

CREATE OR ALTER VIEW dbo.vw_low_stock
AS
SELECT
    ProductID,
    ProductName,
    Category,
    SellingPrice,
    Stock
FROM dbo.D9_Products
WHERE Stock < 10;
GO

CREATE OR ALTER VIEW dbo.vw_active_products
AS
SELECT
    ProductID,
    ProductName,
    Category,
    SellingPrice,
    Stock
FROM dbo.D9_Products
WHERE Stock >= 10
WITH CHECK OPTION;
GO

SELECT * FROM dbo.vw_order_summary;

SELECT * FROM dbo.vw_low_stock;

SELECT * FROM dbo.vw_active_products;
GO

BEGIN TRY
    UPDATE dbo.vw_active_products
    SET Stock = 5
    WHERE ProductID = 101;

    PRINT 'Update successful';
END TRY
BEGIN CATCH
    PRINT 'Update rejected by WITH CHECK OPTION';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

SELECT ProductID, ProductName, Stock
FROM dbo.D9_Products
WHERE ProductID = 101;
