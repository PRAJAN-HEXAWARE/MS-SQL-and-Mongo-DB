
IF DB_ID('RetailDB') IS NULL
    CREATE DATABASE RetailDB;
GO

USE RetailDB;
GO

IF OBJECT_ID('dbo.Categories', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categories (
        CategoryID INT PRIMARY KEY,
        CategoryName VARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.Products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products (
        ProductID INT PRIMARY KEY,
        ProductName VARCHAR(100) NOT NULL,
        CategoryID INT NOT NULL,
        Price DECIMAL(10,2) NOT NULL,
        Stock INT NOT NULL CHECK (Stock >= 0),
        FOREIGN KEY (CategoryID)
            REFERENCES dbo.Categories(CategoryID)
    );
END;
GO

IF OBJECT_ID('dbo.Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        OrderReference VARCHAR(50) NOT NULL UNIQUE,
        CustomerName VARCHAR(100) NOT NULL,
        OrderDate DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        OrderStatus VARCHAR(20) NOT NULL
            DEFAULT 'Confirmed'
    );
END;
GO

IF OBJECT_ID('dbo.OrderLines', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderLines (
        OrderLineID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL CHECK (Quantity > 0),
        UnitPrice DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (OrderID)
            REFERENCES dbo.Orders(OrderID),
        FOREIGN KEY (ProductID)
            REFERENCES dbo.Products(ProductID)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Categories)
BEGIN
    INSERT INTO dbo.Categories VALUES
    (1, 'Electronics'),
    (2, 'Clothing'),
    (3, 'Accessories');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Products)
BEGIN
    INSERT INTO dbo.Products VALUES
    (101, 'Laptop', 1, 50000, 20),
    (102, 'Mobile', 1, 20000, 40),
    (103, 'Headphones', 1, 2000, 15),
    (104, 'Shirt', 2, 1000, 50),
    (105, 'Jeans', 2, 2000, 30),
    (106, 'Jacket', 2, 3000, 10),
    (107, 'Watch', 3, 5000, 25),
    (108, 'Bag', 3, 1500, 35),
    (109, 'Wallet', 3, 500, 12);
END;
GO

SELECT * FROM dbo.Products;

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @OrderID INT;
    DECLARE @ProductID INT = 101;
    DECLARE @Quantity INT = 2;
    DECLARE @Price DECIMAL(10,2);

    IF EXISTS (
        SELECT 1
        FROM dbo.Orders
        WHERE OrderReference = 'SET3-SUCCESS-001'
    )
        THROW 50001, 'Demo order already exists', 1;

    UPDATE dbo.Products
    SET Stock = Stock - @Quantity
    WHERE ProductID = @ProductID
      AND Stock >= @Quantity;

    IF @@ROWCOUNT <> 1
        THROW 50002, 'Insufficient stock', 1;

    SELECT @Price = Price
    FROM dbo.Products
    WHERE ProductID = @ProductID;

    INSERT INTO dbo.Orders
        (OrderReference, CustomerName, OrderStatus)
    VALUES
        ('SET3-SUCCESS-001', 'Arun', 'Confirmed');

    SET @OrderID = SCOPE_IDENTITY();

    INSERT INTO dbo.OrderLines
        (OrderID, ProductID, Quantity, UnitPrice)
    VALUES
        (@OrderID, @ProductID, @Quantity, @Price);

    COMMIT TRANSACTION;

    PRINT 'Order placed successfully';
    PRINT 'Stock reserved successfully';

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();
END CATCH;
GO

SELECT ProductID, ProductName, Stock
FROM dbo.Products
WHERE ProductID = 101;

SELECT * FROM dbo.Orders;

SELECT * FROM dbo.OrderLines;

SELECT ProductID, ProductName, Stock
FROM dbo.Products
WHERE ProductID = 101;

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @FailedOrderID INT;
    DECLARE @FailedProductID INT = 101;
    DECLARE @FailedQuantity INT = 1000;
    DECLARE @FailedPrice DECIMAL(10,2);

    INSERT INTO dbo.Orders
        (OrderReference, CustomerName, OrderStatus)
    VALUES
        ('SET3-FAIL-001', 'Bala', 'Pending');

    SET @FailedOrderID = SCOPE_IDENTITY();

    UPDATE dbo.Products
    SET Stock = Stock - @FailedQuantity
    WHERE ProductID = @FailedProductID
      AND Stock >= @FailedQuantity;

    IF @@ROWCOUNT <> 1
        THROW 50003, 'Insufficient stock: Order cancelled', 1;

    SELECT @FailedPrice = Price
    FROM dbo.Products
    WHERE ProductID = @FailedProductID;

    INSERT INTO dbo.OrderLines
        (OrderID, ProductID, Quantity, UnitPrice)
    VALUES
        (@FailedOrderID, @FailedProductID,
         @FailedQuantity, @FailedPrice);

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Transaction rolled back';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

SELECT ProductID, ProductName, Stock
FROM dbo.Products
WHERE ProductID = 101;

SELECT OrderID, OrderReference, CustomerName
FROM dbo.Orders
WHERE OrderReference IN (
    'SET3-SUCCESS-001',
    'SET3-FAIL-001'
);

SELECT
    O.OrderReference,
    P.ProductName,
    OL.Quantity,
    OL.UnitPrice,
    OL.Quantity * OL.UnitPrice AS TotalAmount
FROM dbo.Orders O
JOIN dbo.OrderLines OL
    ON O.OrderID = OL.OrderID
JOIN dbo.Products P
    ON OL.ProductID = P.ProductID;
