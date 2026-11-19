
USE RetailDB;
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Orders
    WHERE OrderReference = 'SET3-HIST-001'
)
BEGIN
    INSERT INTO dbo.Orders
        (OrderReference, CustomerName, OrderDate, OrderStatus)
    VALUES
        ('SET3-HIST-001', 'Customer A', '2026-08-10', 'Confirmed'),
        ('SET3-HIST-002', 'Customer B', '2026-09-12', 'Confirmed'),
        ('SET3-HIST-003', 'Customer C', '2026-10-15', 'Confirmed');

    INSERT INTO dbo.OrderLines
        (OrderID, ProductID, Quantity, UnitPrice)
    SELECT O.OrderID, V.ProductID, V.Quantity, P.Price
    FROM (VALUES
        ('SET3-HIST-001', 101, 2),
        ('SET3-HIST-001', 102, 3),
        ('SET3-HIST-001', 103, 5),
        ('SET3-HIST-001', 104, 4),
        ('SET3-HIST-001', 105, 3),
        ('SET3-HIST-001', 106, 2),
        ('SET3-HIST-001', 107, 3),
        ('SET3-HIST-001', 108, 4),
        ('SET3-HIST-001', 109, 5),

        ('SET3-HIST-002', 101, 3),
        ('SET3-HIST-002', 102, 5),
        ('SET3-HIST-002', 103, 4),
        ('SET3-HIST-002', 104, 6),
        ('SET3-HIST-002', 105, 5),
        ('SET3-HIST-002', 106, 3),
        ('SET3-HIST-002', 107, 4),
        ('SET3-HIST-002', 108, 6),
        ('SET3-HIST-002', 109, 8),

        ('SET3-HIST-003', 101, 4),
        ('SET3-HIST-003', 102, 4),
        ('SET3-HIST-003', 103, 8),
        ('SET3-HIST-003', 104, 7),
        ('SET3-HIST-003', 105, 6),
        ('SET3-HIST-003', 106, 4),
        ('SET3-HIST-003', 107, 5),
        ('SET3-HIST-003', 108, 7),
        ('SET3-HIST-003', 109, 10)
    ) AS V(OrderReference, ProductID, Quantity)
    JOIN dbo.Orders O
        ON O.OrderReference = V.OrderReference
    JOIN dbo.Products P
        ON P.ProductID = V.ProductID;
END;
GO

PRINT 'TASK 2: PRODUCTS BELOW CATEGORY AVERAGE STOCK';

SELECT
    P.ProductID,
    P.ProductName,
    C.CategoryName,
    P.Stock,
    (
        SELECT AVG(CAST(P2.Stock AS DECIMAL(10,2)))
        FROM dbo.Products P2
        WHERE P2.CategoryID = P.CategoryID
    ) AS AverageCategoryStock
FROM dbo.Products P
JOIN dbo.Categories C
    ON P.CategoryID = C.CategoryID
WHERE P.Stock < (
    SELECT AVG(CAST(P3.Stock AS DECIMAL(10,2)))
    FROM dbo.Products P3
    WHERE P3.CategoryID = P.CategoryID
)
ORDER BY C.CategoryName, P.Stock;
GO

PRINT 'TASK 3: TOP THREE PRODUCTS BY SALES IN EACH CATEGORY';

WITH ProductSales AS
(
    SELECT
        P.ProductID,
        P.ProductName,
        C.CategoryName,
        COALESCE(
            SUM(OL.Quantity * OL.UnitPrice), 0
        ) AS TotalSales
    FROM dbo.Products P
    JOIN dbo.Categories C
        ON P.CategoryID = C.CategoryID
    LEFT JOIN dbo.OrderLines OL
        ON P.ProductID = OL.ProductID
    LEFT JOIN dbo.Orders O
        ON OL.OrderID = O.OrderID
    WHERE O.OrderStatus = 'Confirmed'
       OR O.OrderID IS NULL
    GROUP BY
        P.ProductID,
        P.ProductName,
        C.CategoryName
),
RankedProducts AS
(
    SELECT
        ProductID,
        ProductName,
        CategoryName,
        TotalSales,
        ROW_NUMBER() OVER (
            PARTITION BY CategoryName
            ORDER BY TotalSales DESC, ProductID
        ) AS SalesRank
    FROM ProductSales
)
SELECT
    CategoryName,
    ProductName,
    TotalSales,
    SalesRank
FROM RankedProducts
WHERE SalesRank <= 3
ORDER BY CategoryName, SalesRank;
GO

PRINT 'TASK 4: MONTH ON MONTH PRODUCT SALES CHANGE';

WITH MonthlySales AS
(
    SELECT
        P.ProductID,
        P.ProductName,
        DATEFROMPARTS(
            YEAR(O.OrderDate),
            MONTH(O.OrderDate),
            1
        ) AS SalesMonth,
        SUM(OL.Quantity * OL.UnitPrice) AS TotalSales
    FROM dbo.OrderLines OL
    JOIN dbo.Orders O
        ON OL.OrderID = O.OrderID
    JOIN dbo.Products P
        ON OL.ProductID = P.ProductID
    WHERE O.OrderStatus = 'Confirmed'
    GROUP BY
        P.ProductID,
        P.ProductName,
        DATEFROMPARTS(
            YEAR(O.OrderDate),
            MONTH(O.OrderDate),
            1
        )
),
SalesComparison AS
(
    SELECT
        ProductID,
        ProductName,
        SalesMonth,
        TotalSales,
        LAG(TotalSales) OVER (
            PARTITION BY ProductID
            ORDER BY SalesMonth
        ) AS PreviousMonthSales,
        LEAD(TotalSales) OVER (
            PARTITION BY ProductID
            ORDER BY SalesMonth
        ) AS NextMonthSales
    FROM MonthlySales
)
SELECT
    ProductName,
    SalesMonth,
    TotalSales,
    PreviousMonthSales,
    NextMonthSales,
    TotalSales - PreviousMonthSales
        AS MonthOnMonthChange
FROM SalesComparison
ORDER BY ProductName, SalesMonth;
GO
