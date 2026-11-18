/*
CREATE DATABASE BankLoanDB;
GO

USE BankLoanDB;
GO

-- Clean up existing tables if re-running
DROP TABLE IF EXISTS Guarantors;
DROP TABLE IF EXISTS Repayments;
DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Branches;
GO

-- 1. Branches
CREATE TABLE Branches (
    BranchID INT PRIMARY KEY,
    BranchName VARCHAR(100),
    City VARCHAR(100),
    ManagerName VARCHAR(100)
);

-- 2. Customers (Includes self-referencing ReferredByCustomerID for self-join scenarios)
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(100),
    CreditScore INT,
    ReferredByCustomerID INT NULL,
    FOREIGN KEY (ReferredByCustomerID) REFERENCES Customers(CustomerID)
);

-- 3. Loans
CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT,
    BranchID INT,
    LoanType VARCHAR(50),
    LoanAmount DECIMAL(12,2),
    InterestRate DECIMAL(5,2),
    TotalInstalments INT,
    PaidInstalments INT,
    DueInstalmentsTillDate INT, -- Instalments that should have been paid by today
    DisbursementDate DATE,
    LoanStatus VARCHAR(30),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

-- 4. Repayments
CREATE TABLE Repayments (
    RepaymentID INT PRIMARY KEY,
    LoanID INT,
    PaymentDate DATE,
    AmountPaid DECIMAL(12,2),
    PaymentMode VARCHAR(30),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

-- 5. Guarantors (Links a Loan to a Customer acting as Guarantor)
CREATE TABLE Guarantors (
    GuarantorRecordID INT PRIMARY KEY,
    LoanID INT,
    GuarantorCustomerID INT,
    Relationship VARCHAR(50),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID),
    FOREIGN KEY (GuarantorCustomerID) REFERENCES Customers(CustomerID)
);
GO

-- Insert Branches (Branch 5 intentionally has NO loans)
INSERT INTO Branches VALUES
(1, 'Chennai Anna Salai', 'Chennai', 'Vikram'),
(2, 'Coimbatore Race Course', 'Coimbatore', 'Meera'),
(3, 'Madurai KK Nagar', 'Madurai', 'Senthil'),
(4, 'Bengaluru MG Road', 'Bengaluru', 'Anand'),
(5, 'Salem Omalur Branch', 'Salem', 'Deepa');

-- Insert Customers (Customer 7 intentionally has NO loans; acts as a pure guarantor)
INSERT INTO Customers VALUES
(1, 'Arun Kumar', 'Chennai', 760, NULL),
(2, 'Priya Sharma', 'Coimbatore', 720, 1),
(3, 'Karthik Raj', 'Madurai', 650, 1),
(4, 'Divya Nair', 'Bengaluru', 810, 2),
(5, 'Rahul Verma', 'Chennai', 690, NULL),
(6, 'Sneha Reddy', 'Coimbatore', 740, 4),
(7, 'Mohan Das', 'Chennai', 790, 1);

-- Insert Loans
-- Note: Overdue Instalments = DueInstalmentsTillDate - PaidInstalments
INSERT INTO Loans VALUES
(101, 1, 1, 'Home Loan', 2500000.00, 8.50, 120, 20, 20, '2025-01-15', 'Active'),      -- 0 overdue
(102, 1, 2, 'Car Loan', 800000.00, 9.25, 60, 10, 14, '2025-08-10', 'Overdue'),       -- 4 overdue (>3)
(103, 2, 2, 'Personal Loan', 500000.00, 12.00, 36, 12, 12, '2025-10-01', 'Active'),  -- 0 overdue
(104, 2, 4, 'Business Loan', 1500000.00, 11.00, 48, 8, 13, '2025-09-05', 'Overdue'), -- 5 overdue (>3)
(105, 3, 3, 'Education Loan', 600000.00, 9.00, 60, 15, 19, '2025-03-20', 'Overdue'), -- 4 overdue (>3)
(106, 4, 4, 'Home Loan', 3200000.00, 8.40, 180, 24, 24, '2024-11-01', 'Active'),     -- 0 overdue
(107, 5, 1, 'Personal Loan', 400000.00, 13.50, 24, 10, 12, '2025-11-10', 'Overdue'), -- 2 overdue (<=3)
(108, 6, 3, 'Gold Loan', 300000.00, 9.50, 12, 12, 12, '2025-11-01', 'Closed');       -- 0 overdue

-- Insert Repayments (Relative to current date: 2026-11-18)
-- Customers 1, 2, 4 have recent repayments (< 60 days). Customers 3, 5, 6 have NO repayments in the last 60 days.
INSERT INTO Repayments VALUES
(1, 101, '2026-10-25', 28000.00, 'NEFT'),
(2, 101, '2026-11-10', 28000.00, 'NEFT'),
(3, 102, '2026-07-15', 16500.00, 'UPI'),
(4, 103, '2026-11-05', 16600.00, 'Auto-Debit'),
(5, 104, '2026-06-10', 38500.00, 'RTGS'),
(6, 105, '2026-07-20', 12400.00, 'UPI'),
(7, 106, '2026-11-12', 31200.00, 'Auto-Debit'),
(8, 107, '2026-09-01', 19100.00, 'NEFT'),
(9, 108, '2026-08-15', 26500.00, 'Cash');

-- Insert Guarantors
-- Customers 1, 2, 4 are guarantors AND also have their own loans. Customer 7 is a guarantor with NO loan.
INSERT INTO Guarantors VALUES
(1, 102, 2, 'Colleague'),     -- Priya Sharma (Customer 2) guarantees Arun's Loan 102 (Priya is also a borrower)
(2, 104, 1, 'Business Partner'), -- Arun Kumar (Customer 1) guarantees Priya's Loan 104 (Arun is also a borrower)
(3, 105, 4, 'Cousin'),        -- Divya Nair (Customer 4) guarantees Karthik's Loan 105 (Divya is also a borrower)
(4, 107, 7, 'Friend');        -- Mohan Das (Customer 7) guarantees Rahul's Loan 107 (Mohan is NOT a borrower)
GO


-- Q1. Loans overdue by more than three instalments with customer & branch names (INNER JOIN)
SELECT 
    l.LoanID,
    c.CustomerName,
    b.BranchName,
    l.LoanType,
    (l.DueInstalmentsTillDate - l.PaidInstalments) AS OverdueInstalments
FROM Loans l
INNER JOIN Customers c ON l.CustomerID = c.CustomerID
INNER JOIN Branches b ON l.BranchID = b.BranchID
WHERE (l.DueInstalmentsTillDate - l.PaidInstalments) > 3;

-- Q2. Customers with loans in more than one branch (INNER JOIN + GROUP BY/HAVING)
SELECT 
    c.CustomerID,
    c.CustomerName,
    COUNT(DISTINCT l.BranchID) AS BranchCount,
    SUM(l.LoanAmount) AS TotalExposure
FROM Customers c
INNER JOIN Loans l ON c.CustomerID = l.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(DISTINCT l.BranchID) > 1;

-- Q3. Guarantors who are also borrowers (SELF JOIN on Loans via Guarantors)
SELECT DISTINCT
    c.CustomerID AS GuarantorID,
    c.CustomerName AS GuarantorName,
    g.LoanID AS GuaranteedLoanID,
    bLoan.LoanID AS OwnLoanID,
    bLoan.LoanType AS OwnLoanType,
    bLoan.LoanAmount AS OwnLoanAmount
FROM Guarantors g
INNER JOIN Customers c ON g.GuarantorCustomerID = c.CustomerID
INNER JOIN Loans bLoan ON g.GuarantorCustomerID = bLoan.CustomerID;

-- Q4. Branches with no loans sanctioned (LEFT JOIN)
SELECT 
    b.BranchID,
    b.BranchName,
    b.City,
    b.ManagerName
FROM Branches b
LEFT JOIN Loans l ON b.BranchID = l.BranchID
WHERE l.LoanID IS NULL;

-- Q5. Customers who have never taken a loan (LEFT JOIN)
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.City,
    c.CreditScore
FROM Customers c
LEFT JOIN Loans l ON c.CustomerID = l.CustomerID
WHERE l.LoanID IS NULL;

-- Q6. Customer referral hierarchy: Customers and who referred them (SELF JOIN on Customers)
SELECT 
    c.CustomerID,
    c.CustomerName AS Customer,
    ISNULL(ref.CustomerName, 'Direct Walk-in') AS ReferredBy
FROM Customers c
LEFT JOIN Customers ref ON c.ReferredByCustomerID = ref.CustomerID;

-- Q7. All loans along with their guarantor details, including loans without a guarantor (LEFT JOIN)
SELECT 
    l.LoanID,
    borrower.CustomerName AS BorrowerName,
    l.LoanType,
    l.LoanAmount,
    ISNULL(guarantor.CustomerName, 'No Guarantor') AS GuarantorName,
    g.Relationship
FROM Loans l
INNER JOIN Customers borrower ON l.CustomerID = borrower.CustomerID
LEFT JOIN Guarantors g ON l.LoanID = g.LoanID
LEFT JOIN Customers guarantor ON g.GuarantorCustomerID = guarantor.CustomerID;

-- Q8. Total loan amount and total repaid amount per loan (LEFT JOIN + Aggregation)
SELECT 
    l.LoanID,
    c.CustomerName,
    l.LoanAmount,
    ISNULL(SUM(r.AmountPaid), 0) AS TotalRepaid,
    (l.LoanAmount - ISNULL(SUM(r.AmountPaid), 0)) AS RemainingPrincipal
FROM Loans l
INNER JOIN Customers c ON l.CustomerID = c.CustomerID
LEFT JOIN Repayments r ON l.LoanID = r.LoanID
GROUP BY l.LoanID, c.CustomerName, l.LoanAmount;

-- Q9. Complete audit view of all branches and all loans, including unmatched branches (FULL OUTER JOIN)
SELECT 
    b.BranchID,
    b.BranchName,
    l.LoanID,
    l.LoanType,
    l.LoanAmount
FROM Branches b
FULL OUTER JOIN Loans l ON b.BranchID = l.BranchID;

-- Q10. Customers sharing the same city who both hold active/overdue loans (SELF JOIN on Customers)
SELECT 
    c1.CustomerName AS Customer1,
    c2.CustomerName AS Customer2,
    c1.City
FROM Customers c1
INNER JOIN Customers c2 
    ON c1.City = c2.City 
    AND c1.CustomerID < c2.CustomerID
INNER JOIN Loans l1 ON c1.CustomerID = l1.CustomerID
INNER JOIN Loans l2 ON c2.CustomerID = l2.CustomerID
GROUP BY c1.CustomerName, c2.CustomerName, c1.City;



-- 2A. CORRELATED SUBQUERY:
-- Finds customers whose total loan exposure in a branch exceeds that specific branch's average loan amount.
SELECT 
    c.CustomerID,
    c.CustomerName,
    b.BranchName,
    SUM(l.LoanAmount) AS CustomerBranchExposure
FROM Loans l
INNER JOIN Customers c ON l.CustomerID = c.CustomerID
INNER JOIN Branches b ON l.BranchID = b.BranchID
GROUP BY c.CustomerID, c.CustomerName, l.BranchID, b.BranchName
HAVING SUM(l.LoanAmount) > (
    SELECT AVG(l2.LoanAmount)
    FROM Loans l2
    WHERE l2.BranchID = l.BranchID
);

-- 2B. UNCORRELATED SUBQUERY (using derived table):
-- Pre-computes branch averages independently and joins against customer exposure.
SELECT 
    custExp.CustomerID,
    c.CustomerName,
    b.BranchName,
    custExp.CustomerBranchExposure,
    branchAvg.AvgBranchLoan
FROM (
    SELECT CustomerID, BranchID, SUM(LoanAmount) AS CustomerBranchExposure
    FROM Loans
    GROUP BY CustomerID, BranchID
) custExp
INNER JOIN (
    SELECT BranchID, AVG(LoanAmount) AS AvgBranchLoan
    FROM Loans
    GROUP BY BranchID
) branchAvg ON custExp.BranchID = branchAvg.BranchID
INNER JOIN Customers c ON custExp.CustomerID = c.CustomerID
INNER JOIN Branches b ON custExp.BranchID = b.BranchID
WHERE custExp.CustomerBranchExposure > branchAvg.AvgBranchLoan;



SELECT 
    c.CustomerID,
    c.CustomerName,
    c.City
FROM Customers c
WHERE EXISTS (
    -- Customer must have at least one loan
    SELECT 1
    FROM Loans l
    WHERE l.CustomerID = c.CustomerID
)
AND NOT EXISTS (
    -- Customer must NOT have any repayment within the last 60 days
    SELECT 1
    FROM Loans l
    INNER JOIN Repayments r ON l.LoanID = r.LoanID
    WHERE l.CustomerID = c.CustomerID
      AND r.PaymentDate >= DATEADD(DAY, -60, GETDATE())
);



SELECT 
    b.BranchID,
    b.BranchName,
    b.City,
    MAX(l.LoanAmount) AS HighestBranchLoan
FROM Branches b
INNER JOIN Loans l ON b.BranchID = l.BranchID
GROUP BY b.BranchID, b.BranchName, b.City
HAVING MAX(l.LoanAmount) > (
    -- Outer subquery: bank-wide average of each branch's maximum loan
    SELECT AVG(BranchMaxLoan)
    FROM (
        -- Inner nested subquery: maximum loan amount per branch
        SELECT MAX(LoanAmount) AS BranchMaxLoan
        FROM Loans
        GROUP BY BranchID
    ) AS BranchMaximums
);

*/