
IF DB_ID('InsuranceDB') IS NULL
    CREATE DATABASE InsuranceDB;
GO

USE InsuranceDB;
GO

IF OBJECT_ID('dbo.D9_Agents', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Agents (
        AgentID INT PRIMARY KEY,
        AgentName VARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('dbo.D9_Customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Customers (
        CustomerID INT PRIMARY KEY,
        CustomerName VARCHAR(100) NOT NULL,
        Email VARCHAR(100),
        Phone VARCHAR(20),
        AadhaarNumber VARCHAR(20),
        BankAccountNumber VARCHAR(30)
    );
END;
GO

IF OBJECT_ID('dbo.D9_Policies', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Policies (
        PolicyID INT PRIMARY KEY,
        CustomerID INT NOT NULL,
        AgentID INT NOT NULL,
        PolicyType VARCHAR(50) NOT NULL,
        Premium DECIMAL(12,2) NOT NULL,
        RenewalDate DATE NOT NULL,
        PolicyStatus VARCHAR(20) NOT NULL,
        NoClaimYears INT NOT NULL DEFAULT 0,
        FOREIGN KEY (CustomerID)
            REFERENCES dbo.D9_Customers(CustomerID),
        FOREIGN KEY (AgentID)
            REFERENCES dbo.D9_Agents(AgentID)
    );
END;
GO

IF OBJECT_ID('dbo.D9_Claims', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Claims (
        ClaimID INT IDENTITY(1,1) PRIMARY KEY,
        PolicyID INT NOT NULL,
        ClaimStatus VARCHAR(20) NOT NULL,
        ClaimAmount DECIMAL(12,2) NOT NULL,
        FOREIGN KEY (PolicyID)
            REFERENCES dbo.D9_Policies(PolicyID)
    );
END;
GO

IF OBJECT_ID('dbo.D9_PremiumPayments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_PremiumPayments (
        PaymentID INT IDENTITY(1,1) PRIMARY KEY,
        PolicyID INT NOT NULL,
        Amount DECIMAL(12,2) NOT NULL,
        DueDate DATE NOT NULL,
        PaymentDate DATE NULL,
        PaymentStatus VARCHAR(20) NOT NULL,
        FOREIGN KEY (PolicyID)
            REFERENCES dbo.D9_Policies(PolicyID)
    );
END;
GO

IF OBJECT_ID('dbo.D9_RenewalAudit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_RenewalAudit (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        PolicyID INT NOT NULL,
        OldPremium DECIMAL(12,2) NOT NULL,
        NewPremium DECIMAL(12,2) NOT NULL,
        RenewalDate DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        FOREIGN KEY (PolicyID)
            REFERENCES dbo.D9_Policies(PolicyID)
    );
END;
GO

IF OBJECT_ID('dbo.D9_PolicyLapseLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_PolicyLapseLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        PolicyID INT NOT NULL,
        OldStatus VARCHAR(20) NOT NULL,
        NewStatus VARCHAR(20) NOT NULL,
        ProcessingMethod VARCHAR(20) NOT NULL,
        ChangedAt DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        FOREIGN KEY (PolicyID)
            REFERENCES dbo.D9_Policies(PolicyID)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.D9_Agents)
BEGIN
    INSERT INTO dbo.D9_Agents VALUES
    (1, 'Rajesh'),
    (2, 'Priya'),
    (3, 'Kumar');
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.D9_Customers)
BEGIN
    INSERT INTO dbo.D9_Customers VALUES
    (101, 'Arun', 'arun@gmail.com', '9000000001',
     'XXXX1111', 'BANK1001'),
    (102, 'Bala', 'bala@gmail.com', '9000000002',
     'XXXX2222', 'BANK1002'),
    (103, 'Charan', 'charan@gmail.com', '9000000003',
     'XXXX3333', 'BANK1003'),
    (104, 'Divya', 'divya@gmail.com', '9000000004',
     'XXXX4444', 'BANK1004'),
    (105, 'Esha', 'esha@gmail.com', '9000000005',
     'XXXX5555', 'BANK1005'),
    (106, 'Farhan', 'farhan@gmail.com', '9000000006',
     'XXXX6666', 'BANK1006');
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.D9_Policies)
BEGIN
    INSERT INTO dbo.D9_Policies
        (PolicyID, CustomerID, AgentID, PolicyType,
         Premium, RenewalDate, PolicyStatus, NoClaimYears)
    VALUES
    (1001, 101, 1, 'Health', 12000,
     DATEADD(DAY, 10, CAST(GETDATE() AS DATE)),
     'Active', 2),

    (1002, 102, 1, 'Vehicle', 8000,
     DATEADD(DAY, 20, CAST(GETDATE() AS DATE)),
     'Active', 3),

    (1003, 103, 2, 'Life', 15000,
     DATEADD(DAY, 5, CAST(GETDATE() AS DATE)),
     'Active', 1),

    (1004, 104, 2, 'Health', 10000,
     DATEADD(DAY, -15, CAST(GETDATE() AS DATE)),
     'Active', 0),

    (1005, 105, 3, 'Vehicle', 6000,
     DATEADD(DAY, -30, CAST(GETDATE() AS DATE)),
     'Active', 2),

    (1006, 106, 3, 'Life', 20000,
     DATEADD(DAY, 60, CAST(GETDATE() AS DATE)),
     'Active', 4);
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.D9_Claims)
BEGIN
    INSERT INTO dbo.D9_Claims
        (PolicyID, ClaimStatus, ClaimAmount)
    VALUES
    (1003, 'Pending', 5000),
    (1005, 'Approved', 2000);
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.D9_PremiumPayments)
BEGIN
    INSERT INTO dbo.D9_PremiumPayments
        (PolicyID, Amount, DueDate, PaymentDate, PaymentStatus)
    VALUES
    (1001, 12000,
     DATEADD(DAY, 10, CAST(GETDATE() AS DATE)),
     NULL, 'Pending'),

    (1002, 8000,
     DATEADD(DAY, 20, CAST(GETDATE() AS DATE)),
     NULL, 'Pending'),

    (1003, 15000,
     DATEADD(DAY, 5, CAST(GETDATE() AS DATE)),
     NULL, 'Pending'),

    (1004, 10000,
     DATEADD(DAY, -15, CAST(GETDATE() AS DATE)),
     NULL, 'Overdue'),

    (1005, 6000,
     DATEADD(DAY, -30, CAST(GETDATE() AS DATE)),
     NULL, 'Overdue'),

    (1006, 20000,
     DATEADD(DAY, 60, CAST(GETDATE() AS DATE)),
     NULL, 'Pending');
END;
GO

CREATE OR ALTER VIEW dbo.vw_policy_due
AS
SELECT
    P.PolicyID,
    C.CustomerID,
    C.CustomerName,
    C.Email,
    C.Phone,
    A.AgentName,
    P.PolicyType,
    P.Premium,
    P.RenewalDate,
    P.PolicyStatus,
    DATEDIFF(
        DAY,
        CAST(GETDATE() AS DATE),
        P.RenewalDate
    ) AS DaysUntilRenewal
FROM dbo.D9_Policies P
JOIN dbo.D9_Customers C
    ON P.CustomerID = C.CustomerID
JOIN dbo.D9_Agents A
    ON P.AgentID = A.AgentID
WHERE P.PolicyStatus = 'Active'
  AND P.RenewalDate >= CAST(GETDATE() AS DATE)
  AND P.RenewalDate <= DATEADD(
      DAY, 30, CAST(GETDATE() AS DATE)
  );
GO

SELECT *
FROM dbo.vw_policy_due
ORDER BY RenewalDate;

SELECT
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'vw_policy_due'
ORDER BY ORDINAL_POSITION;
GO
