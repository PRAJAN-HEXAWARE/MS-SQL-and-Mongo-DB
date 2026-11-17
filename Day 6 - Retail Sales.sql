/*
CREATE DATABASE RetailSalesReportingDB;
GO

USE RetailSalesReportingDB;
GO

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryName VARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

CREATE TABLE Order_Items (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    PaymentDate DATE NULL,
    PaymentAmount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
GO

INSERT INTO Customers (CustomerName, City)
VALUES
('Arun Kumar', 'Chennai'),
('Priya Sharma', 'Coimbatore'),
('Karthik Raj', 'Chennai'),
('Divya Nair', 'Salem'),
('Rahul Verma', 'Madurai'),
('Sneha Reddy', 'Coimbatore'),
('Vijay Kumar', 'Salem');

INSERT INTO Products (ProductName, CategoryName, UnitPrice)
VALUES
('Laptop', 'Electronics', 50000),
('Smartphone', 'Electronics', 25000),
('Headphones', 'Accessories', 2000),
('Office Chair', 'Furniture', 8000),
('Keyboard', 'Accessories', 1500),
('Monitor', 'Electronics', 12000);

INSERT INTO Orders (CustomerID, OrderDate, OrderStatus)
VALUES
(1, '2026-10-01', 'Completed'),
(1, '2026-10-05', 'Completed'),
(1, '2026-10-10', 'Completed'),
(1, '2026-10-15', 'Completed'),
(1, '2026-11-02', 'Completed'),
(2, '2026-10-03', 'Completed'),
(2, '2026-10-12', 'Completed'),
(3, '2026-10-05', 'Completed'),
(3, '2026-11-05', 'Completed'),
(4, '2026-11-07', 'Completed'),
(5, '2026-11-07', 'Completed'),
(6, '2026-11-10', 'Completed');

INSERT INTO Order_Items (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(1, 1, 1, 50000),
(1, 3, 2, 2000),
(2, 2, 1, 25000),
(2, 5, 2, 1500),
(3, 4, 1, 8000),
(3, 3, 1, 2000),
(4, 6, 2, 12000),
(5, 1, 1, 50000),
(5, 5, 2, 1500),
(6, 2, 2, 25000),
(6, 3, 1, 2000),
(7, 4, 2, 8000),
(8, 1, 1, 50000),
(8, 6, 1, 12000),
(9, 2, 1, 25000),
(10, 3, 3, 2000),
(11, 4, 1, 8000),
(12, 5, 4, 1500);

INSERT INTO Payments
(OrderID, PaymentDate, PaymentAmount, PaymentStatus)
VALUES
(1, '2026-10-01', 54000, 'Paid'),
(2, '2026-10-05', 28000, 'Paid'),
(3, '2026-10-10', 10000, 'Paid'),
(4, '2026-10-15', 24000, 'Paid'),
(6, '2026-10-03', 52000, 'Paid'),
(7, '2026-10-12', 16000, 'Paid'),
(8, '2026-10-05', 62000, 'Paid'),
(9, '2026-11-05', 25000, 'Paid'),
(10, '2026-11-07', 6000, 'Paid'),
(12, '2026-11-10', 6000, 'Paid');
GO




USE RetailSalesReportingDB;
GO

-- 1. TOP 5 PRODUCTS BY REVENUE

SELECT TOP 5
    p.ProductName,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM Products p
JOIN Order_Items oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalRevenue DESC;
GO


-- 2. MONTH-WISE SALES

SELECT
    FORMAT(o.OrderDate, 'yyyy-MM') AS SalesMonth,
    SUM(oi.Quantity * oi.UnitPrice) AS MonthlySales
FROM Orders o
JOIN Order_Items oi ON o.OrderID = oi.OrderID
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY SalesMonth;
GO


-- 3. CUSTOMERS WITH MORE THAN 3 ORDERS

SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID) AS TotalOrders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(o.OrderID) > 3;
GO


-- 4. AVERAGE BASKET VALUE PER CITY

SELECT
    c.City,
    ROUND(AVG(OrderTotals.BasketValue), 2) AS AverageBasketValue
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN (
    SELECT
        OrderID,
        SUM(Quantity * UnitPrice) AS BasketValue
    FROM Order_Items
    GROUP BY OrderID
) AS OrderTotals ON o.OrderID = OrderTotals.OrderID
GROUP BY c.City;
GO


-- 5. ORDERS WITHOUT PAYMENT (LEFT JOIN)

SELECT
    o.OrderID,
    c.CustomerName,
    o.OrderDate,
    p.PaymentStatus
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN Payments p ON o.OrderID = p.OrderID
WHERE p.PaymentID IS NULL;
GO


-- 6. CUSTOMERS WITH NO ORDERS

SELECT
    c.CustomerID,
    c.CustomerName,
    c.City
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
GO


-- 7. PRODUCT CATEGORY REVENUE SHARE

SELECT
    p.CategoryName,
    SUM(oi.Quantity * oi.UnitPrice) AS CategoryRevenue,
    ROUND(
        SUM(oi.Quantity * oi.UnitPrice) * 100.0 /
        SUM(SUM(oi.Quantity * oi.UnitPrice)) OVER (), 2
    ) AS RevenueSharePercentage
FROM Products p
JOIN Order_Items oi ON p.ProductID = oi.ProductID
GROUP BY p.CategoryName;
GO


-- 8. DAY WITH HIGHEST SALES

SELECT TOP 1
    o.OrderDate,
    SUM(oi.Quantity * oi.UnitPrice) AS DailySales
FROM Orders o
JOIN Order_Items oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderDate
ORDER BY DailySales DESC;
GO


-- CUSTOMER FRIENDLY REPORT USING FUNCTIONS

SELECT
    c.CustomerID,
    UPPER(c.CustomerName) AS CustomerName,
    CONCAT(c.CustomerName, ' - ', c.City) AS CustomerDetails,
    o.OrderDate,
    DATEDIFF(DAY, o.OrderDate, GETDATE()) AS DaysSinceOrder,
    FORMAT(o.OrderDate, 'dd-MMM-yyyy') AS FormattedOrderDate,
    ROUND(
        SUM(oi.Quantity * oi.UnitPrice), 2
    ) AS OrderAmount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Items oi ON o.OrderID = oi.OrderID
GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.City,
    o.OrderDate,
    o.OrderID;
GO



SELECT
    COUNT(*) AS TotalPaymentRecords,
    COUNT(PaymentDate) AS NonNullPaymentDates,
    AVG(PaymentAmount) AS AveragePaymentAmount
FROM Payments;

SELECT
    COUNT(*) AS TotalOrders,
    COUNT(PaymentID) AS OrdersWithPayments
FROM Orders
LEFT JOIN Payments
ON Orders.OrderID = Payments.OrderID;
GO
*/
