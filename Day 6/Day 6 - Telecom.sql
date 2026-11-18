/*
CREATE DATABASE TelecomReportingDB;
GO

USE TelecomReportingDB;
GO

-- 1. PLANS TABLE
CREATE TABLE Plans (
    PlanID INT IDENTITY(1,1) PRIMARY KEY,
    PlanName VARCHAR(100) NOT NULL,
    MonthlyFee DECIMAL(10,2) NOT NULL,
    DataLimitGB DECIMAL(10,2) NOT NULL
);
GO

-- 2. SUBSCRIBERS TABLE
CREATE TABLE Subscribers (
    SubscriberID INT IDENTITY(1,1) PRIMARY KEY,
    SubscriberName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE,
    Circle VARCHAR(50) NOT NULL,
    PlanID INT NOT NULL,
    ActivationDate DATE NOT NULL,

    FOREIGN KEY (PlanID) REFERENCES Plans(PlanID)
);
GO

-- 3. CALL RECORDS TABLE
CREATE TABLE Call_Records (
    RecordID INT IDENTITY(1,1) PRIMARY KEY,
    SubscriberID INT NOT NULL,
    UsageDate DATE NOT NULL,
    CallMinutes DECIMAL(10,2) NULL,
    DataUsedGB DECIMAL(10,2) NULL,

    FOREIGN KEY (SubscriberID)
        REFERENCES Subscribers(SubscriberID),

    CHECK (CallMinutes IS NULL OR CallMinutes >= 0),
    CHECK (DataUsedGB IS NULL OR DataUsedGB >= 0)
);
GO

-- 4. INVOICES TABLE
CREATE TABLE Invoices (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceNumber VARCHAR(30) NOT NULL UNIQUE,
    SubscriberID INT NOT NULL,
    InvoiceDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    InvoiceAmount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL,

    FOREIGN KEY (SubscriberID)
        REFERENCES Subscribers(SubscriberID),

    CHECK (InvoiceAmount >= 0)
);
GO

-- INSERT PLANS
INSERT INTO Plans (PlanName, MonthlyFee, DataLimitGB)
VALUES
('Basic Plan', 299, 10),
('Standard Plan', 599, 20),
('Premium Plan', 999, 50);

-- INSERT SUBSCRIBERS
INSERT INTO Subscribers
(SubscriberName, PhoneNumber, Circle, PlanID, ActivationDate)
VALUES
('Arun Kumar', '9876500001', 'Chennai', 1, '2025-01-10'),
('Priya Sharma', '9876500002', 'Chennai', 2, '2025-02-15'),
('Karthik Raj', '9876500003', 'Coimbatore', 1, '2025-03-20'),
('Divya Nair', '9876500004', 'Madurai', 3, '2025-04-12'),
('Rahul Verma', '9876500005', 'Salem', 2, '2025-05-18'),
('Sneha Reddy', '9876500006', 'Chennai', 3, '2025-06-22'),
('Vijay Kumar', '9876500007', 'Coimbatore', 1, '2025-07-05'),
('Anitha Rao', '9876500008', 'Madurai', 2, '2025-08-11'),
('Suresh Babu', '9876500009', 'Salem', 3, '2025-09-16'),
('Meena Devi', '9876500010', 'Chennai', 1, '2025-10-20'),
('Ajay Kumar', '9876500011', 'Coimbatore', 2, '2025-11-25'),
('Nisha Devi', '9876500012', 'Salem', 1, '2025-12-01');

-- INSERT CALL RECORDS
INSERT INTO Call_Records
(SubscriberID, UsageDate, CallMinutes, DataUsedGB)
VALUES
(1, '2026-10-02', 180, 7),
(1, '2026-10-15', 120, 6),
(2, '2026-10-03', 250, 8),
(2, '2026-10-18', 150, 7),
(3, '2026-10-05', 200, 12),
(3, '2026-10-20', 100, 14),
(4, '2026-10-07', 350, 20),
(4, '2026-10-21', 250, 35),
(5, '2026-10-09', 160, 9),
(5, '2026-10-22', 140, 8),
(6, '2026-10-11', 400, 25),
(6, '2026-10-25', 300, 30),
(7, '2026-10-12', 100, 5),
(7, '2026-10-26', 80, 4),
(8, '2026-10-14', 220, 10),
(8, '2026-10-28', 180, 12),
(9, '2026-10-16', 500, 30),
(9, '2026-10-29', 300, 25),
(10, '2026-10-17', 130, 6),
(10, '2026-10-30', 110, 5),
(11, '2026-10-19', 270, 11),
(11, '2026-10-31', 230, 10);

-- INSERT INVOICES
INSERT INTO Invoices
(InvoiceNumber, SubscriberID, InvoiceDate, DueDate,
 InvoiceAmount, PaymentStatus)
VALUES
('INV1001', 1, '2026-10-01', '2026-10-15', 299, 'Paid'),
('INV1002', 2, '2026-10-01', '2026-10-15', 599, 'Paid'),
('INV1003', 3, '2026-10-01', '2026-10-15', 299, 'Pending'),
('INV1004', 4, '2026-10-01', '2026-10-15', 999, 'Paid'),
('INV1005', 5, '2026-10-01', '2026-10-15', 599, 'Overdue'),
('INV1006', 6, '2026-10-01', '2026-10-15', 999, 'Paid'),
('INV1007', 7, '2026-10-01', '2026-10-15', 299, 'Paid'),
('INV1008', 8, '2026-10-01', '2026-10-15', 599, 'Overdue'),
('INV1009', 9, '2026-11-01', '2026-11-10', 999, 'Pending'),
('INV1010', 10, '2026-11-01', '2026-11-10', 299, 'Paid'),
('INV1011', 11, '2026-11-01', '2026-11-10', 599, 'Paid'),
('INV1012', 12, '2026-11-01', '2026-11-10', 299, 'Pending');
GO

-- VERIFY ALL FOUR TABLES
SELECT * FROM Plans;
SELECT * FROM Subscribers;
SELECT * FROM Call_Records;
SELECT * FROM Invoices;
GO



USE TelecomReportingDB;
GO

-- 1. TOTAL CALL MINUTES PER PLAN

SELECT
    p.PlanName,
    SUM(cr.CallMinutes) AS TotalCallMinutes
FROM Plans p
JOIN Subscribers s ON p.PlanID = s.PlanID
JOIN Call_Records cr ON s.SubscriberID = cr.SubscriberID
GROUP BY p.PlanID, p.PlanName
ORDER BY TotalCallMinutes DESC;
GO


-- 2. SUBSCRIBERS EXCEEDING THEIR DATA LIMIT

SELECT
    s.SubscriberID,
    s.SubscriberName,
    p.PlanName,
    p.DataLimitGB,
    SUM(cr.DataUsedGB) AS TotalDataUsedGB
FROM Subscribers s
JOIN Plans p ON s.PlanID = p.PlanID
JOIN Call_Records cr ON s.SubscriberID = cr.SubscriberID
GROUP BY
    s.SubscriberID,
    s.SubscriberName,
    p.PlanName,
    p.DataLimitGB
HAVING SUM(cr.DataUsedGB) > p.DataLimitGB
ORDER BY TotalDataUsedGB DESC;
GO


-- 3. MONTH-WISE REVENUE

SELECT
    FORMAT(InvoiceDate, 'yyyy-MM') AS RevenueMonth,
    SUM(InvoiceAmount) AS MonthlyRevenue
FROM Invoices
GROUP BY FORMAT(InvoiceDate, 'yyyy-MM')
ORDER BY RevenueMonth;
GO


-- 4. INVOICES OVERDUE BY MORE THAN 15 DAYS

SELECT
    InvoiceNumber,
    SubscriberID,
    InvoiceAmount,
    DueDate,
    DATEDIFF(DAY, DueDate, CAST(GETDATE() AS DATE)) AS DaysOverdue
FROM Invoices
WHERE PaymentStatus <> 'Paid'
AND DueDate < DATEADD(DAY, -15, CAST(GETDATE() AS DATE))
ORDER BY DaysOverdue DESC;
GO


-- 5. SUBSCRIBERS WITH NO USAGE

SELECT
    s.SubscriberID,
    s.SubscriberName,
    s.Circle,
    s.PhoneNumber
FROM Subscribers s
LEFT JOIN Call_Records cr
ON s.SubscriberID = cr.SubscriberID
WHERE cr.RecordID IS NULL;
GO


-- 6. AVERAGE REVENUE PER USER (ARPU) BY CIRCLE

SELECT
    s.Circle,
    COUNT(s.SubscriberID) AS TotalSubscribers,
    SUM(ISNULL(i.TotalRevenue, 0)) AS TotalRevenue,
    ROUND(
        SUM(ISNULL(i.TotalRevenue, 0)) /
        NULLIF(COUNT(s.SubscriberID), 0), 2
    ) AS ARPU
FROM Subscribers s
LEFT JOIN (
    SELECT
        SubscriberID,
        SUM(InvoiceAmount) AS TotalRevenue
    FROM Invoices
    GROUP BY SubscriberID
) i ON s.SubscriberID = i.SubscriberID
GROUP BY s.Circle
ORDER BY ARPU DESC;
GO


-- 7. PLAN POPULARITY

SELECT
    p.PlanName,
    COUNT(s.SubscriberID) AS SubscriberCount
FROM Plans p
LEFT JOIN Subscribers s
ON p.PlanID = s.PlanID
GROUP BY p.PlanID, p.PlanName
ORDER BY SubscriberCount DESC;
GO


-- 8. TOP 10 DATA CONSUMERS

SELECT TOP 10
    s.SubscriberID,
    s.SubscriberName,
    s.Circle,
    SUM(cr.DataUsedGB) AS TotalDataUsedGB
FROM Subscribers s
JOIN Call_Records cr
ON s.SubscriberID = cr.SubscriberID
GROUP BY
    s.SubscriberID,
    s.SubscriberName,
    s.Circle
ORDER BY TotalDataUsedGB DESC;
GO



USE TelecomReportingDB;
GO

SELECT
    InvoiceID,
    InvoiceNumber,

    CONCAT(
        'TEL-',
        RIGHT('000000' + CAST(InvoiceID AS VARCHAR(6)), 6)
    ) AS FormattedInvoiceNumber,

    InvoiceDate,
    FORMAT(InvoiceDate, 'dd-MMM-yyyy') AS FormattedInvoiceDate,

    DueDate,

    DATEDIFF(
        DAY,
        CAST(GETDATE() AS DATE),
        DueDate
    ) AS DaysUntilDue,

    CASE
        WHEN PaymentStatus = 'Paid'
            THEN 'Paid'
        WHEN DueDate < CAST(GETDATE() AS DATE)
            THEN 'Overdue'
        WHEN DueDate = CAST(GETDATE() AS DATE)
            THEN 'Due Today'
        ELSE 'Not Yet Due'
    END AS DueDateStatus

FROM Invoices;
GO
*/


-- NULL BEHAVIOUR IN SUM AND AVG

SELECT
    s.SubscriberID,
    s.SubscriberName,

    COUNT(cr.RecordID) AS UsageRecords,

    SUM(cr.DataUsedGB) AS TotalDataUsed,

    AVG(cr.DataUsedGB) AS AverageDataUsed,

    SUM(cr.CallMinutes) AS TotalCallMinutes,

    AVG(cr.CallMinutes) AS AverageCallMinutes

FROM Subscribers s
LEFT JOIN Call_Records cr
ON s.SubscriberID = cr.SubscriberID

GROUP BY
    s.SubscriberID,
    s.SubscriberName

ORDER BY s.SubscriberID;
GO
