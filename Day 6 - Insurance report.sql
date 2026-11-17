/*
CREATE DATABASE InsuranceReportingDB;
GO

USE InsuranceReportingDB;
GO

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    City VARCHAR(50)
);
GO

CREATE TABLE Agents (
    AgentID INT IDENTITY(1,1) PRIMARY KEY,
    AgentName VARCHAR(100) NOT NULL,
    Branch VARCHAR(50)
);
GO

CREATE TABLE Policies (
    PolicyID INT IDENTITY(1,1) PRIMARY KEY,
    PolicyNumber VARCHAR(30) NOT NULL UNIQUE,
    CustomerID INT NOT NULL,
    AgentID INT NOT NULL,
    ProductName VARCHAR(50) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    PremiumAmount DECIMAL(12,2) NOT NULL,
    Status VARCHAR(20) NOT NULL,

    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (AgentID) REFERENCES Agents(AgentID),
    CHECK (PremiumAmount > 0),
    CHECK (EndDate > StartDate)
);
GO

CREATE TABLE Premiums (
    PremiumID INT IDENTITY(1,1) PRIMARY KEY,
    PolicyID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL,

    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID),
    CHECK (Amount > 0)
);
GO

CREATE TABLE Claims (
    ClaimID INT IDENTITY(1,1) PRIMARY KEY,
    PolicyID INT NOT NULL,
    ClaimDate DATE NOT NULL,
    ClaimAmount DECIMAL(12,2) NOT NULL,
    ClaimStatus VARCHAR(20) NOT NULL,
    SettlementDate DATE NULL,

    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID),
    CHECK (ClaimAmount >= 0)
);
GO

INSERT INTO Customers (CustomerName, DateOfBirth, City)
VALUES
('Arun Kumar', '1985-05-12', 'Chennai'),
('Priya Sharma', '1995-08-20', 'Coimbatore'),
('Karthik Raj', '1970-03-15', 'Salem'),
('Divya Nair', '2000-11-10', 'Madurai'),
('Rahul Verma', '1965-07-25', 'Chennai'),
('Sneha Reddy', '1990-02-18', 'Bangalore'),
('Vijay Kumar', '1980-09-05', 'Trichy'),
('Anitha Rao', '2005-06-30', 'Coimbatore'),
('Suresh Babu', '1975-12-12', 'Salem'),
('Meena Devi', '1998-04-22', 'Chennai');

INSERT INTO Agents (AgentName, Branch)
VALUES
('Ramesh', 'Chennai'),
('Kavitha', 'Coimbatore'),
('Sanjay', 'Salem'),
('Deepa', 'Madurai'),
('Manoj', 'Bangalore'),
('Priyanka', 'Chennai');

INSERT INTO Policies
(PolicyNumber, CustomerID, AgentID, ProductName,
 StartDate, EndDate, PremiumAmount, Status)
VALUES
('POL1001', 1, 1, 'Life Insurance', '2026-01-10', DATEADD(DAY, 10, CAST(GETDATE() AS DATE)), 25000, 'Active'),
('POL1002', 1, 2, 'Health Insurance', '2026-02-15', '2027-02-15', 18000, 'Active'),
('POL1003', 2, 1, 'Vehicle Insurance', '2026-03-01', DATEADD(DAY, 20, CAST(GETDATE() AS DATE)), 12000, 'Active'),
('POL1004', 3, 3, 'Life Insurance', '2026-04-10', '2027-04-10', 30000, 'Active'),
('POL1005', 4, 4, 'Health Insurance', '2026-05-12', '2027-05-12', 15000, 'Active'),
('POL1006', 5, 2, 'Vehicle Insurance', '2026-06-15', '2027-06-15', 10000, 'Active'),
('POL1007', 6, 5, 'Life Insurance', '2026-07-20', '2027-07-20', 28000, 'Active'),
('POL1008', 7, 3, 'Health Insurance', '2026-08-05', '2027-08-05', 16000, 'Active'),
('POL1009', 8, 4, 'Vehicle Insurance', '2026-09-10', '2027-09-10', 9000, 'Active'),
('POL1010', 9, 5, 'Life Insurance', '2026-10-01', '2027-10-01', 35000, 'Active'),
('POL1011', 10, 6, 'Health Insurance', '2026-10-15', '2027-10-15', 14000, 'Active'),
('POL1012', 2, 1, 'Life Insurance', '2026-11-01', '2027-11-01', 22000, 'Active');

INSERT INTO Premiums (PolicyID, PaymentDate, Amount, PaymentStatus)
VALUES
(1, '2026-01-10', 25000, 'Paid'),
(2, '2026-02-15', 18000, 'Paid'),
(3, '2026-03-01', 12000, 'Paid'),
(4, '2026-04-10', 30000, 'Paid'),
(5, '2026-05-12', 15000, 'Paid'),
(6, '2026-06-15', 10000, 'Paid'),
(7, '2026-07-20', 28000, 'Paid'),
(8, '2026-08-05', 16000, 'Paid'),
(9, '2026-09-10', 9000, 'Paid'),
(10, '2026-10-01', 35000, 'Paid'),
(11, '2026-10-15', 14000, 'Paid'),
(12, '2026-11-01', 22000, 'Paid'),
(1, '2026-07-10', 25000, 'Paid'),
(2, '2026-08-15', 18000, 'Paid'),
(3, '2026-09-01', 12000, 'Pending');

INSERT INTO Claims
(PolicyID, ClaimDate, ClaimAmount, ClaimStatus, SettlementDate)
VALUES
(1, '2026-03-10', 50000, 'Settled', '2026-03-20'),
(2, '2026-04-15', 10000, 'Settled', '2026-04-25'),
(3, '2026-05-01', 8000, 'Pending', NULL),
(4, '2026-06-10', 75000, 'Settled', '2026-06-25'),
(5, '2026-07-12', 12000, 'Rejected', NULL),
(7, '2026-08-20', 40000, 'Settled', '2026-09-05'),
(8, '2026-09-05', 6000, 'Pending', NULL),
(10, '2026-10-10', 25000, 'Settled', '2026-10-20');
GO



USE InsuranceReportingDB;
GO

-- 1. POLICIES EXPIRING IN THE NEXT 30 DAYS

SELECT
    PolicyNumber,
    ProductName,
    StartDate,
    EndDate,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), EndDate) AS DaysRemaining
FROM Policies
WHERE EndDate >= CAST(GETDATE() AS DATE)
AND EndDate <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
ORDER BY EndDate;
GO


-- 2. PREMIUM COLLECTED PER PRODUCT

SELECT
    p.ProductName,
    SUM(pr.Amount) AS TotalPremiumCollected
FROM Policies p
JOIN Premiums pr ON p.PolicyID = pr.PolicyID
WHERE pr.PaymentStatus = 'Paid'
GROUP BY p.ProductName
ORDER BY TotalPremiumCollected DESC;
GO


-- 3. CUSTOMERS WITH MORE THAN ONE ACTIVE POLICY

SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(p.PolicyID) AS ActivePolicyCount
FROM Customers c
JOIN Policies p ON c.CustomerID = p.CustomerID
WHERE p.Status = 'Active'
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(p.PolicyID) > 1;
GO


-- 4. CLAIM RATIO PER PRODUCT

SELECT
    ProductName,
    TotalPremium,
    TotalClaims,
    ROUND(
        TotalClaims * 100.0 / NULLIF(TotalPremium, 0), 2
    ) AS ClaimRatioPercentage
FROM
(
    SELECT
        p.ProductName,
        SUM(pr.TotalPremium) AS TotalPremium,
        SUM(cl.TotalClaims) AS TotalClaims
    FROM
    (
        SELECT DISTINCT ProductName, PolicyID
        FROM Policies
    ) p
    LEFT JOIN
    (
        SELECT PolicyID, SUM(Amount) AS TotalPremium
        FROM Premiums
        WHERE PaymentStatus = 'Paid'
        GROUP BY PolicyID
    ) pr ON p.PolicyID = pr.PolicyID
    LEFT JOIN
    (
        SELECT PolicyID, SUM(ClaimAmount) AS TotalClaims
        FROM Claims
        GROUP BY PolicyID
    ) cl ON p.PolicyID = cl.PolicyID
    GROUP BY p.ProductName
) AS ProductSummary
ORDER BY ClaimRatioPercentage DESC;
GO


-- 5. POLICIES WITHOUT CLAIMS

SELECT
    p.PolicyNumber,
    c.CustomerName,
    p.ProductName,
    p.StartDate,
    p.EndDate
FROM Policies p
JOIN Customers c ON p.CustomerID = c.CustomerID
LEFT JOIN Claims cl ON p.PolicyID = cl.PolicyID
WHERE cl.ClaimID IS NULL;
GO


-- 6. AVERAGE PREMIUM BY CUSTOMER AGE BAND

SELECT
    CASE
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 25
            THEN 'Below 25'
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) BETWEEN 25 AND 40
            THEN '25-40'
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) BETWEEN 41 AND 60
            THEN '41-60'
        ELSE 'Above 60'
    END AS AgeBand,
    ROUND(AVG(p.PremiumAmount), 2) AS AveragePremium
FROM Customers c
JOIN Policies p ON c.CustomerID = p.CustomerID
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 25
            THEN 'Below 25'
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) BETWEEN 25 AND 40
            THEN '25-40'
        WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) BETWEEN 41 AND 60
            THEN '41-60'
        ELSE 'Above 60'
    END
ORDER BY AgeBand;
GO


-- 7. MONTHLY NEW POLICIES

SELECT
    FORMAT(StartDate, 'yyyy-MM') AS PolicyMonth,
    COUNT(PolicyID) AS NewPolicies
FROM Policies
GROUP BY FORMAT(StartDate, 'yyyy-MM')
ORDER BY PolicyMonth;
GO


-- 8. TOP 5 AGENTS BY PREMIUM COLLECTED

SELECT TOP 5
    a.AgentID,
    a.AgentName,
    SUM(pr.Amount) AS TotalPremiumCollected
FROM Agents a
JOIN Policies p ON a.AgentID = p.AgentID
JOIN Premiums pr ON p.PolicyID = pr.PolicyID
WHERE pr.PaymentStatus = 'Paid'
GROUP BY a.AgentID, a.AgentName
ORDER BY TotalPremiumCollected DESC;
GO
*/

/*
SELECT
    PolicyNumber,
    CONCAT(
        LEFT(PolicyNumber, 3),
        '*****',
        RIGHT(PolicyNumber, 2)
    ) AS MaskedPolicyNumber,

    ProductName,

    DATEDIFF(DAY, StartDate, GETDATE()) AS PolicyAgeInDays,

    DATEADD(DAY, 30, EndDate) AS ExtendedExpiryDate,

    CASE
        WHEN DATEDIFF(DAY, GETDATE(), EndDate) < 0
            THEN 'Expired'
        WHEN DATEDIFF(DAY, GETDATE(), EndDate) <= 30
            THEN 'Expiring Soon'
        ELSE 'Active'
    END AS ExpiryStatus

FROM Policies;
GO
*/


-- WHERE filters individual rows before grouping

SELECT
    ProductName,
    SUM(PremiumAmount) AS TotalPremium
FROM Policies
WHERE Status = 'Active'
GROUP BY ProductName;


-- HAVING filters groups after aggregation

SELECT
    ProductName,
    COUNT(PolicyID) AS PolicyCount
FROM Policies
GROUP BY ProductName
HAVING COUNT(PolicyID) > 2;
GO
