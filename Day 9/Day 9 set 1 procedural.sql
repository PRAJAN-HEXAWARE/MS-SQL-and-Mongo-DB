
USE RetailDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_PlaceOrder
    @CustomerID INT,
    @CustomerName VARCHAR(100),
    @ProductID INT,
    @Quantity INT,
    @OrderNumber INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @OrderNumber = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @CustomerID IS NULL
           OR @CustomerName IS NULL
           OR LTRIM(RTRIM(@CustomerName)) = ''
            THROW 50001, 'Invalid customer details', 1;

        IF @Quantity IS NULL OR @Quantity <= 0
            THROW 50002, 'Quantity must be greater than zero', 1;

        DECLARE @Price DECIMAL(10,2);

        UPDATE dbo.D9_Products
        SET Stock = Stock - @Quantity
        WHERE ProductID = @ProductID
          AND Stock >= @Quantity;

        IF @@ROWCOUNT <> 1
            THROW 50003, 'Product unavailable or insufficient stock', 1;

        SELECT @Price = SellingPrice
        FROM dbo.D9_Products
        WHERE ProductID = @ProductID;

        INSERT INTO dbo.D9_Orders
            (CustomerID, CustomerName, OrderDate, OrderStatus)
        VALUES
            (@CustomerID, @CustomerName, SYSDATETIME(), 'Pending');

        SET @OrderNumber = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.D9_OrderLines
            (OrderID, ProductID, Quantity, UnitPrice)
        VALUES
            (@OrderNumber, @ProductID, @Quantity, @Price);

        COMMIT TRANSACTION;

        PRINT 'Order placed successfully';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @OrderNumber = NULL;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_OrderTotalWithTax
(
    @OrderID INT,
    @TaxRate DECIMAL(5,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT @Total =
        CAST(
            SUM(
                CAST(Quantity AS DECIMAL(18,2))
                * UnitPrice
            ) * (1 + @TaxRate / 100.0)
            AS DECIMAL(18,2)
        )
    FROM dbo.D9_OrderLines
    WHERE OrderID = @OrderID;

    RETURN ISNULL(@Total, 0);
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_CustomerOrders
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        O.OrderID,
        O.CustomerID,
        O.CustomerName,
        O.OrderDate,
        O.OrderStatus,
        SUM(OL.Quantity) AS TotalQuantity,
        SUM(OL.Quantity * OL.UnitPrice) AS Subtotal
    FROM dbo.D9_Orders O
    JOIN dbo.D9_OrderLines OL
        ON O.OrderID = OL.OrderID
    WHERE O.CustomerID = @CustomerID
    GROUP BY
        O.OrderID,
        O.CustomerID,
        O.CustomerName,
        O.OrderDate,
        O.OrderStatus
);
GO

DECLARE @NewOrderNumber INT;

EXEC dbo.usp_PlaceOrder
    @CustomerID = 205,
    @CustomerName = 'Esha',
    @ProductID = 101,
    @Quantity = 2,
    @OrderNumber = @NewOrderNumber OUTPUT;

SELECT @NewOrderNumber AS GeneratedOrderNumber;

SELECT
    OrderID,
    CustomerName,
    OrderStatus
FROM dbo.D9_Orders
WHERE OrderID = @NewOrderNumber;

SELECT
    ProductID,
    ProductName,
    Stock
FROM dbo.D9_Products
WHERE ProductID = 101;

SELECT
    @NewOrderNumber AS OrderID,
    dbo.fn_OrderTotalWithTax(
        @NewOrderNumber, 18.00
    ) AS TotalWith18PercentTax;

SELECT *
FROM dbo.fn_CustomerOrders(205);
GO

BEGIN TRY
    DECLARE @FailedOrderNumber INT;

    EXEC dbo.usp_PlaceOrder
        @CustomerID = 206,
        @CustomerName = 'Farhan',
        @ProductID = 103,
        @Quantity = 1000,
        @OrderNumber = @FailedOrderNumber OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Insufficient stock test rejected successfully';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

SELECT
    ProductID,
    ProductName,
    Stock
FROM dbo.D9_Products
WHERE ProductID IN (101, 103);

SELECT
    O.OrderID,
    O.CustomerName,
    P.ProductName,
    OL.Quantity,
    OL.UnitPrice,
    OL.Quantity * OL.UnitPrice AS Subtotal
FROM dbo.D9_Orders O
JOIN dbo.D9_OrderLines OL
    ON O.OrderID = OL.OrderID
JOIN dbo.D9_Products P
    ON OL.ProductID = P.ProductID
ORDER BY O.OrderID;
