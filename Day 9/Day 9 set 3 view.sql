
IF DB_ID('TelecomDB') IS NULL
    CREATE DATABASE TelecomDB;
GO

USE TelecomDB;
GO

IF OBJECT_ID('dbo.D9_Subscribers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Subscribers
    (
        SubscriberID INT PRIMARY KEY,
        SubscriberName VARCHAR(100) NOT NULL,
        MobileNumber VARCHAR(15) NOT NULL UNIQUE,
        SubscriberType VARCHAR(20) NOT NULL
            CHECK (SubscriberType IN ('Prepaid', 'Postpaid')),
        Balance DECIMAL(12,2) NOT NULL DEFAULT 0
            CHECK (Balance >= 0),
        PlanID INT NULL,
        ValidityEndDate DATE NULL,
        Status VARCHAR(20) NOT NULL DEFAULT 'Active'
    );
END;
GO

IF OBJECT_ID('dbo.D9_Plans', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Plans
    (
        PlanID INT PRIMARY KEY,
        PlanName VARCHAR(100) NOT NULL,
        MinimumRecharge DECIMAL(12,2) NOT NULL,
        ValidityDays INT NOT NULL,
        IsActive BIT NOT NULL DEFAULT 1
    );
END;
GO

IF OBJECT_ID('dbo.D9_RechargeHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_RechargeHistory
    (
        RechargeID INT IDENTITY(1,1) PRIMARY KEY,
        SubscriberID INT NOT NULL,
        PlanID INT NOT NULL,
        RechargeAmount DECIMAL(12,2) NOT NULL,
        RechargeDate DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        BalanceAfterRecharge DECIMAL(12,2) NOT NULL,
        FOREIGN KEY (SubscriberID)
            REFERENCES dbo.D9_Subscribers(SubscriberID),
        FOREIGN KEY (PlanID)
            REFERENCES dbo.D9_Plans(PlanID)
    );
END;
GO

IF OBJECT_ID('dbo.D9_Notifications', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.D9_Notifications
    (
        NotificationID INT IDENTITY(1,1) PRIMARY KEY,
        SubscriberID INT NOT NULL,
        NotificationMessage VARCHAR(255) NOT NULL,
        NotificationDate DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        IsRead BIT NOT NULL DEFAULT 0,
        ProcessingMethod VARCHAR(20) NOT NULL,
        FOREIGN KEY (SubscriberID)
            REFERENCES dbo.D9_Subscribers(SubscriberID)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.D9_Plans)
BEGIN
    INSERT INTO dbo.D9_Plans
        (PlanID, PlanName, MinimumRecharge, ValidityDays, IsActive)
    VALUES
        (1, 'Basic Plan', 99, 14, 1),
        (2, 'Standard Plan', 199, 28, 1),
        (3, 'Premium Plan', 399, 56, 1),
        (4, 'Annual Plan', 1999, 365, 1),
        (5, 'Discontinued Plan', 149, 28, 0);
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.D9_Subscribers)
BEGIN
    INSERT INTO dbo.D9_Subscribers
        (SubscriberID, SubscriberName, MobileNumber,
         SubscriberType, Balance, PlanID,
         ValidityEndDate, Status)
    VALUES
        (101, 'Arun', '9000000001',
         'Prepaid', 25, 1,
         DATEADD(DAY, 10, CAST(GETDATE() AS DATE)), 'Active'),

        (102, 'Bala', '9000000002',
         'Prepaid', 40, 2,
         DATEADD(DAY, 20, CAST(GETDATE() AS DATE)), 'Active'),

        (103, 'Charan', '9000000003',
         'Prepaid', 120, 3,
         DATEADD(DAY, 45, CAST(GETDATE() AS DATE)), 'Active'),

        (104, 'Divya', '9000000004',
         'Prepaid', 15, 1,
         DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), 'Active'),

        (105, 'Esha', '9000000005',
         'Prepaid', 75, 2,
         DATEADD(DAY, 25, CAST(GETDATE() AS DATE)), 'Active'),

        (106, 'Farhan', '9000000006',
         'Prepaid', 10, 1,
         DATEADD(DAY, 7, CAST(GETDATE() AS DATE)), 'Active'),

        (107, 'Gokul', '9000000007',
         'Postpaid', 0, NULL,
         NULL, 'Active'),

        (108, 'Harini', '9000000008',
         'Postpaid', 0, NULL,
         NULL, 'Active');
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.D9_RechargeHistory)
BEGIN
    INSERT INTO dbo.D9_RechargeHistory
        (SubscriberID, PlanID, RechargeAmount,
         RechargeDate, BalanceAfterRecharge)
    VALUES
        (101, 1, 99,
         DATEADD(DAY, -15, SYSDATETIME()), 99),

        (101, 2, 199,
         DATEADD(DAY, -5, SYSDATETIME()), 224),

        (102, 2, 199,
         DATEADD(DAY, -10, SYSDATETIME()), 199),

        (103, 3, 399,
         DATEADD(DAY, -20, SYSDATETIME()), 399),

        (104, 1, 99,
         DATEADD(DAY, -12, SYSDATETIME()), 99),

        (105, 2, 199,
         DATEADD(DAY, -8, SYSDATETIME()), 199),

        (106, 1, 99,
         DATEADD(DAY, -18, SYSDATETIME()), 99);
END;
GO

CREATE OR ALTER VIEW dbo.vw_prepaid_subscribers
AS
SELECT
    SubscriberID,
    SubscriberName,
    MobileNumber,
    Balance,
    PlanID,
    ValidityEndDate,
    Status
FROM dbo.D9_Subscribers
WHERE SubscriberType = 'Prepaid'
WITH CHECK OPTION;
GO

CREATE OR ALTER VIEW dbo.vw_recharge_summary
AS
SELECT
    S.SubscriberID,
    S.SubscriberName,
    COUNT(R.RechargeID) AS TotalRecharges,
    ISNULL(SUM(R.RechargeAmount), 0) AS TotalRechargeAmount,
    MAX(R.RechargeDate) AS LastRechargeDate
FROM dbo.D9_Subscribers S
LEFT JOIN dbo.D9_RechargeHistory R
    ON S.SubscriberID = R.SubscriberID
WHERE S.SubscriberType = 'Prepaid'
GROUP BY
    S.SubscriberID,
    S.SubscriberName;
GO

SELECT *
FROM dbo.vw_prepaid_subscribers
ORDER BY SubscriberID;

SELECT *
FROM dbo.vw_recharge_summary
ORDER BY SubscriberID;

SELECT
    SubscriberID,
    SubscriberName,
    Balance
FROM dbo.vw_prepaid_subscribers
WHERE Balance < 50
ORDER BY Balance;

SELECT
    SubscriberID,
    SubscriberName,
    SubscriberType
FROM dbo.D9_Subscribers
WHERE SubscriberType = 'Postpaid';
GO
