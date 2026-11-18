/*
CREATE DATABASE RetailReturnsDB;
GO

USE RetailReturnsDB;
GO

-- Clean up existing tables
DROP TABLE IF EXISTS Refunds;
DROP TABLE IF EXISTS Returns;
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Stores;
GO

-- 1. Stores
CREATE TABLE Stores (
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(100),
    City VARCHAR(100),
    Region VARCHAR(50)
);

-- 2. Employees (Self-referencing ManagerID)
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Role VARCHAR(50),
    StoreID INT,
    ManagerID INT NULL,
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID),
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID)
);

-- 3. Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(100)
);

-- 4. Products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    UnitPrice DECIMAL(10,2)
);

-- 5. Orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    StoreID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID)
);

-- 6. OrderItems (Total units sold per product/order)
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    QuantitySold INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 7. Returns (Note: CustomerID allows NULL to demonstrate the NOT IN pitfall)
CREATE TABLE Returns (
    ReturnID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    CustomerID INT NULL,
    StoreID INT,
    QuantityReturned INT,
    ReturnDate DATE,
    ReturnReason VARCHAR(100),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID)
);

-- 8. Refunds
CREATE TABLE Refunds (
    RefundID INT PRIMARY KEY,
    ReturnID INT,
    ProcessedByEmployeeID INT,
    RefundAmount DECIMAL(10,2),
    RefundDate DATE,
    RefundMode VARCHAR(30),
    FOREIGN KEY (ReturnID) REFERENCES Returns(ReturnID),
    FOREIGN KEY (ProcessedByEmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- Insert Stores (2 Regions: South & West)
INSERT INTO Stores VALUES
(1, 'Chennai T-Nagar Flagship', 'Chennai', 'South'),
(2, 'Bengaluru Indiranagar', 'Bengaluru', 'South'),
(3, 'Hyderabad Banjara Hills', 'Hyderabad', 'South'),
(4, 'Mumbai Bandra West', 'Mumbai', 'West'),
(5, 'Pune Koregaon Park', 'Pune', 'West');

-- Insert Employees
INSERT INTO Employees VALUES
(1, 'Arvind Menon', 'Regional Manager', 1, NULL),
(2, 'Deepika Rao', 'Store Manager', 1, 1),
(3, 'Sanjay Kulkarni', 'Store Manager', 2, 1),
(4, 'Neha Gupta', 'Returns Executive', 1, 2),
(5, 'Rohan Joshi', 'Returns Executive', 2, 3),
(6, 'Pooja Deshmukh', 'Store Manager', 4, NULL);

-- Insert Customers
INSERT INTO Customers VALUES
(1, 'Ananya Iyer', 'Chennai'),
(2, 'Vikram Rathore', 'Bengaluru'),
(3, 'Megha Nair', 'Hyderabad'),
(4, 'Siddharth Malhotra', 'Mumbai'),
(5, 'Kiran Kumar', 'Pune');

-- Insert Products
INSERT INTO Products VALUES
(101, 'Wireless Earbuds', 'Electronics', 3000.00),
(102, 'Running Shoes', 'Footwear', 4500.00),
(103, 'Cotton Kurta', 'Apparel', 1500.00),
(104, 'Smart Watch', 'Electronics', 8000.00),
(105, 'Leather Backpack', 'Accessories', 5000.00);

-- Insert Orders
INSERT INTO Orders VALUES
(1001, 1, 1, '2026-10-01'),
(1002, 2, 2, '2026-10-03'),
(1003, 3, 3, '2026-10-05'),
(1004, 4, 4, '2026-10-07'),
(1005, 5, 5, '2026-10-09'),
(1006, 1, 1, '2026-10-12');

-- Insert OrderItems
-- Product 101: 20 sold, 4 returned = 20% return rate (>10%)
-- Product 102: 30 sold, 2 returned = 6.67% return rate (<=10%)
-- Product 103: 50 sold, 8 returned = 16% return rate (>10%)
-- Product 104: 10 sold, 2 returned = 20% return rate (>10%)
-- Product 105: 25 sold, 0 returned = 0% return rate
INSERT INTO OrderItems VALUES
(1, 1001, 101, 20),
(2, 1002, 102, 30),
(3, 1003, 103, 50),
(4, 1004, 104, 10),
(5, 1005, 105, 25),
(6, 1006, 102, 10);

-- Insert Returns
-- Return 504 has NO Refund (Customer 3: Megha Nair)
-- Return 505 is an anonymous/guest return with CustomerID = NULL (triggers the NOT IN pitfall)
INSERT INTO Returns VALUES
(501, 1001, 101, 1, 1, 4, '2026-10-05', 'Defective mic'),
(502, 1002, 102, 2, 2, 2, '2026-10-08', 'Size mismatch'),
(503, 1004, 104, 4, 4, 2, '2026-10-11', 'Screen flicker'),
(504, 1003, 103, 3, 3, 8, '2026-10-12', 'Color faded'),
(505, 1006, 102, NULL, 1, 1, '2026-10-15', 'Guest gift return');

-- Insert Refunds (Return 504 and 505 have no refunds)
INSERT INTO Refunds VALUES
(901, 501, 4, 12000.00, '2026-10-06', 'Original Card'),
(902, 502, 5, 9000.00, '2026-10-09', 'UPI'),
(903, 503, 6, 16000.00, '2026-10-13', 'Bank Transfer');
GO



-- Q1. Products with a return rate above 10 percent (LEFT JOIN + Aggregation)
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(oi.QuantitySold) AS TotalSold,
    ISNULL(SUM(ret.QuantityReturned), 0) AS TotalReturned,
    CAST(ISNULL(SUM(ret.QuantityReturned), 0) * 100.0 / SUM(oi.QuantitySold) AS DECIMAL(5,2)) AS ReturnRatePct
FROM Products p
INNER JOIN OrderItems oi ON p.ProductID = oi.ProductID
LEFT JOIN (
    SELECT ProductID, SUM(QuantityReturned) AS QuantityReturned
    FROM Returns
    GROUP BY ProductID
) ret ON p.ProductID = ret.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category
HAVING (ISNULL(SUM(ret.QuantityReturned), 0) * 100.0 / SUM(oi.QuantitySold)) > 10.0;

-- Q2. Customers who initiated a return but have received no refund yet (INNER JOIN + LEFT JOIN)
SELECT 
    c.CustomerID,
    c.CustomerName,
    r.ReturnID,
    p.ProductName,
    r.ReturnDate,
    r.ReturnReason
FROM Returns r
INNER JOIN Customers c ON r.CustomerID = c.CustomerID
INNER JOIN Products p ON r.ProductID = p.ProductID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
WHERE rf.RefundID IS NULL;

-- Q3. Stores ranked by highest total refund value (LEFT JOIN + GROUP BY)
SELECT 
    s.StoreID,
    s.StoreName,
    s.Region,
    ISNULL(SUM(rf.RefundAmount), 0) AS TotalRefundValue
FROM Stores s
LEFT JOIN Returns r ON s.StoreID = r.StoreID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreID, s.StoreName, s.Region
ORDER BY TotalRefundValue DESC;

-- Q4. Employees and their reporting managers (SELF JOIN on Employees)
SELECT 
    e.EmployeeID,
    e.EmployeeName AS Employee,
    e.Role,
    s.StoreName,
    ISNULL(m.EmployeeName, 'Top-Level Head') AS ManagerName
FROM Employees e
INNER JOIN Stores s ON e.StoreID = s.StoreID
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID;

-- Q5. Products that have never been returned (LEFT JOIN)
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    p.UnitPrice
FROM Products p
LEFT JOIN Returns r ON p.ProductID = r.ProductID
WHERE r.ReturnID IS NULL;

-- Q6. Complete audit of all returns, showing refund amount and the employee who processed it (LEFT JOIN)
SELECT 
    r.ReturnID,
    p.ProductName,
    ISNULL(c.CustomerName, 'Guest Return') AS CustomerName,
    r.ReturnDate,
    rf.RefundID,
    ISNULL(rf.RefundAmount, 0) AS RefundAmount,
    ISNULL(e.EmployeeName, 'Pending Processing') AS ProcessedBy
FROM Returns r
INNER JOIN Products p ON r.ProductID = p.ProductID
LEFT JOIN Customers c ON r.CustomerID = c.CustomerID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
LEFT JOIN Employees e ON rf.ProcessedByEmployeeID = e.EmployeeID;

-- Q7. Stores with zero refunds issued (LEFT JOIN)
SELECT 
    s.StoreID,
    s.StoreName,
    s.City,
    s.Region
FROM Stores s
LEFT JOIN Returns r ON s.StoreID = r.StoreID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreID, s.StoreName, s.City, s.Region
HAVING COUNT(rf.RefundID) = 0;

-- Q8. Average turnaround time (in days) from ReturnDate to RefundDate per store (INNER JOIN)
SELECT 
    s.StoreName,
    COUNT(rf.RefundID) AS RefundsProcessed,
    AVG(DATEDIFF(DAY, r.ReturnDate, rf.RefundDate)) AS AvgTurnaroundDays
FROM Stores s
INNER JOIN Returns r ON s.StoreID = r.StoreID
INNER JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreName;

-- Q9. Full reconciliation of all customers and all returns, including unmatched guest returns (FULL OUTER JOIN)
SELECT 
    c.CustomerID,
    c.CustomerName,
    r.ReturnID,
    r.ReturnDate,
    r.ReturnReason
FROM Customers c
FULL OUTER JOIN Returns r ON c.CustomerID = r.CustomerID;

-- Q10. Pairs of stores operating within the same region (SELF JOIN on Stores)
SELECT 
    s1.Region,
    s1.StoreName AS StoreA,
    s2.StoreName AS StoreB
FROM Stores s1
INNER JOIN Stores s2 
    ON s1.Region = s2.Region 
    AND s1.StoreID < s2.StoreID;

    
-- Q1. Products with a return rate above 10 percent (LEFT JOIN + Aggregation)
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(oi.QuantitySold) AS TotalSold,
    ISNULL(SUM(ret.QuantityReturned), 0) AS TotalReturned,
    CAST(ISNULL(SUM(ret.QuantityReturned), 0) * 100.0 / SUM(oi.QuantitySold) AS DECIMAL(5,2)) AS ReturnRatePct
FROM Products p
INNER JOIN OrderItems oi ON p.ProductID = oi.ProductID
LEFT JOIN (
    SELECT ProductID, SUM(QuantityReturned) AS QuantityReturned
    FROM Returns
    GROUP BY ProductID
) ret ON p.ProductID = ret.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category
HAVING (ISNULL(SUM(ret.QuantityReturned), 0) * 100.0 / SUM(oi.QuantitySold)) > 10.0;

-- Q2. Customers who initiated a return but have received no refund yet (INNER JOIN + LEFT JOIN)
SELECT 
    c.CustomerID,
    c.CustomerName,
    r.ReturnID,
    p.ProductName,
    r.ReturnDate,
    r.ReturnReason
FROM Returns r
INNER JOIN Customers c ON r.CustomerID = c.CustomerID
INNER JOIN Products p ON r.ProductID = p.ProductID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
WHERE rf.RefundID IS NULL;

-- Q3. Stores ranked by highest total refund value (LEFT JOIN + GROUP BY)
SELECT 
    s.StoreID,
    s.StoreName,
    s.Region,
    ISNULL(SUM(rf.RefundAmount), 0) AS TotalRefundValue
FROM Stores s
LEFT JOIN Returns r ON s.StoreID = r.StoreID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreID, s.StoreName, s.Region
ORDER BY TotalRefundValue DESC;

-- Q4. Employees and their reporting managers (SELF JOIN on Employees)
SELECT 
    e.EmployeeID,
    e.EmployeeName AS Employee,
    e.Role,
    s.StoreName,
    ISNULL(m.EmployeeName, 'Top-Level Head') AS ManagerName
FROM Employees e
INNER JOIN Stores s ON e.StoreID = s.StoreID
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID;

-- Q5. Products that have never been returned (LEFT JOIN)
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    p.UnitPrice
FROM Products p
LEFT JOIN Returns r ON p.ProductID = r.ProductID
WHERE r.ReturnID IS NULL;

-- Q6. Complete audit of all returns, showing refund amount and the employee who processed it (LEFT JOIN)
SELECT 
    r.ReturnID,
    p.ProductName,
    ISNULL(c.CustomerName, 'Guest Return') AS CustomerName,
    r.ReturnDate,
    rf.RefundID,
    ISNULL(rf.RefundAmount, 0) AS RefundAmount,
    ISNULL(e.EmployeeName, 'Pending Processing') AS ProcessedBy
FROM Returns r
INNER JOIN Products p ON r.ProductID = p.ProductID
LEFT JOIN Customers c ON r.CustomerID = c.CustomerID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
LEFT JOIN Employees e ON rf.ProcessedByEmployeeID = e.EmployeeID;

-- Q7. Stores with zero refunds issued (LEFT JOIN)
SELECT 
    s.StoreID,
    s.StoreName,
    s.City,
    s.Region
FROM Stores s
LEFT JOIN Returns r ON s.StoreID = r.StoreID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreID, s.StoreName, s.City, s.Region
HAVING COUNT(rf.RefundID) = 0;

-- Q8. Average turnaround time (in days) from ReturnDate to RefundDate per store (INNER JOIN)
SELECT 
    s.StoreName,
    COUNT(rf.RefundID) AS RefundsProcessed,
    AVG(DATEDIFF(DAY, r.ReturnDate, rf.RefundDate)) AS AvgTurnaroundDays
FROM Stores s
INNER JOIN Returns r ON s.StoreID = r.StoreID
INNER JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreName;

-- Q9. Full reconciliation of all customers and all returns, including unmatched guest returns (FULL OUTER JOIN)
SELECT 
    c.CustomerID,
    c.CustomerName,
    r.ReturnID,
    r.ReturnDate,
    r.ReturnReason
FROM Customers c
FULL OUTER JOIN Returns r ON c.CustomerID = r.CustomerID;

-- Q10. Pairs of stores operating within the same region (SELF JOIN on Stores)
SELECT 
    s1.Region,
    s1.StoreName AS StoreA,
    s2.StoreName AS StoreB
FROM Stores s1
INNER JOIN Stores s2 
    ON s1.Region = s2.Region 
    AND s1.StoreID < s2.StoreID;

    

-- 2A. Using IN: Find customers who have made at least one return
SELECT CustomerID, CustomerName, City
FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID 
    FROM Returns 
    WHERE CustomerID IS NOT NULL
);

-- 2B. THE NULL PITFALL WITH NOT IN:
-- Goal: Find customers who have NEVER returned a product (Expected: Kiran Kumar, ID 5).
-- Because Returns contains a row where CustomerID IS NULL (ReturnID 505),
-- SQL evaluates: CustomerID <> 1 AND CustomerID <> 2 AND ... AND CustomerID <> NULL -> UNKNOWN.
-- RESULT: Returns 0 rows!
SELECT CustomerID, CustomerName, City
FROM Customers
WHERE CustomerID NOT IN (
    SELECT CustomerID FROM Returns
);

-- 2C. FIXING THE PITFALL WITH NOT EXISTS:
-- NOT EXISTS checks row presence using three-valued logic safely without failing on NULLs.
-- RESULT: Accurately returns Kiran Kumar (CustomerID 5).
SELECT c.CustomerID, c.CustomerName, c.City
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM Returns r 
    WHERE r.CustomerID = c.CustomerID
);



-- 3A. Using ALL: Find stores whose total refund amount is strictly greater than ALL other stores in their region
SELECT 
    s.StoreID,
    s.StoreName,
    s.Region,
    ISNULL(SUM(rf.RefundAmount), 0) AS StoreTotalRefund
FROM Stores s
LEFT JOIN Returns r ON s.StoreID = r.StoreID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreID, s.StoreName, s.Region
HAVING ISNULL(SUM(rf.RefundAmount), 0) > ALL (
    SELECT ISNULL(SUM(rf2.RefundAmount), 0)
    FROM Stores s2
    LEFT JOIN Returns r2 ON s2.StoreID = r2.StoreID
    LEFT JOIN Refunds rf2 ON r2.ReturnID = rf2.ReturnID
    WHERE s2.Region = s.Region
      AND s2.StoreID <> s.StoreID
    GROUP BY s2.StoreID
);

-- 3B. Using ANY: Find stores whose total refund amount is greater than AT LEAST ONE other store in their region
SELECT 
    s.StoreID,
    s.StoreName,
    s.Region,
    ISNULL(SUM(rf.RefundAmount), 0) AS StoreTotalRefund
FROM Stores s
LEFT JOIN Returns r ON s.StoreID = r.StoreID
LEFT JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreID, s.StoreName, s.Region
HAVING ISNULL(SUM(rf.RefundAmount), 0) > ANY (
    SELECT ISNULL(SUM(rf2.RefundAmount), 0)
    FROM Stores s2
    LEFT JOIN Returns r2 ON s2.StoreID = r2.StoreID
    LEFT JOIN Refunds rf2 ON r2.ReturnID = rf2.ReturnID
    WHERE s2.Region = s.Region
      AND s2.StoreID <> s.StoreID
    GROUP BY s2.StoreID
);


-- 4A. Nested Subquery 1: Find customers who returned products from categories whose overall return volume exceeds the average category return volume
SELECT DISTINCT c.CustomerID, c.CustomerName
FROM Customers c
INNER JOIN Returns r ON c.CustomerID = r.CustomerID
WHERE r.ProductID IN (
    -- Middle subquery: Products belonging to high-return categories
    SELECT p.ProductID
    FROM Products p
    WHERE p.Category IN (
        SELECT p2.Category
        FROM Products p2
        INNER JOIN Returns r2 ON p2.ProductID = r2.ProductID
        GROUP BY p2.Category
        HAVING SUM(r2.QuantityReturned) > (
            -- Innermost subquery: Average returned quantity across all categories
            SELECT AVG(CatTotalReturns)
            FROM (
                SELECT SUM(r3.QuantityReturned) AS CatTotalReturns
                FROM Products p3
                INNER JOIN Returns r3 ON p3.ProductID = r3.ProductID
                GROUP BY p3.Category
            ) AS CategoryTotals
        )
    )
);

-- 4B. Nested Subquery 2: Find the store(s) that issued the second-highest total refund value across the company
SELECT 
    s.StoreID,
    s.StoreName,
    s.Region,
    SUM(rf.RefundAmount) AS TotalRefundValue
FROM Stores s
INNER JOIN Returns r ON s.StoreID = r.StoreID
INNER JOIN Refunds rf ON r.ReturnID = rf.ReturnID
GROUP BY s.StoreID, s.StoreName, s.Region
HAVING SUM(rf.RefundAmount) = (
    -- Middle subquery: Highest refund value strictly below the overall maximum
    SELECT MAX(StoreRefund)
    FROM (
        SELECT SUM(rf2.RefundAmount) AS StoreRefund
        FROM Returns r2
        INNER JOIN Refunds rf2 ON r2.ReturnID = rf2.ReturnID
        GROUP BY r2.StoreID
    ) AS StoreTotals
    WHERE StoreRefund < (
        -- Innermost subquery: Overall maximum store refund value
        SELECT MAX(StoreRefundInner)
        FROM (
            SELECT SUM(rf3.RefundAmount) AS StoreRefundInner
            FROM Returns r3
            INNER JOIN Refunds rf3 ON r3.ReturnID = rf3.ReturnID
            GROUP BY r3.StoreID
        ) AS StoreTotalsInner
    )
);

*/