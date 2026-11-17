/*
CREATE DATABASE BankBranchDB;
GO

USE BankBranchDB;
GO

CREATE TABLE Branches (
    BranchID INT IDENTITY(1,1) PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL,
    BranchCode VARCHAR(20) NOT NULL UNIQUE
);
GO

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Address VARCHAR(250) NOT NULL
);
GO

CREATE TABLE RelationshipManagers (
    ManagerID INT IDENTITY(1,1) PRIMARY KEY,
    ManagerName VARCHAR(100) NOT NULL,
    BranchID INT NOT NULL,

    CONSTRAINT FK_Manager_Branch
        FOREIGN KEY (BranchID)
        REFERENCES Branches(BranchID)
);
GO

CREATE TABLE Accounts (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    AccountNumber VARCHAR(20) NOT NULL UNIQUE,
    AccountType VARCHAR(30) NOT NULL,
    ManagerID INT NOT NULL,
    Balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    OpenedDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),

    CONSTRAINT FK_Accounts_Manager
        FOREIGN KEY (ManagerID)
        REFERENCES RelationshipManagers(ManagerID),

    CONSTRAINT CHK_AccountType
        CHECK (AccountType IN ('Savings', 'Current', 'Fixed Deposit')),

    CONSTRAINT CHK_SavingsBalance
        CHECK (AccountType <> 'Savings' OR Balance >= 0)
);
GO

CREATE TABLE AccountCustomers (
    AccountID INT NOT NULL,
    CustomerID INT NOT NULL,

    CONSTRAINT PK_AccountCustomers
        PRIMARY KEY (AccountID, CustomerID),

    CONSTRAINT FK_AC_Account
        FOREIGN KEY (AccountID)
        REFERENCES Accounts(AccountID)
        ON DELETE CASCADE,

    CONSTRAINT FK_AC_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);
GO


USE BankBranchDB;
GO

INSERT INTO Branches (BranchName, BranchCode)
VALUES
('Chennai Main', 'BR001'),
('Coimbatore', 'BR002'),
('Salem', 'BR003');

INSERT INTO Customers (CustomerName, Address)
VALUES
('Arun Kumar', 'Chennai'),
('Priya Sharma', 'Coimbatore'),
('Karthik Raj', 'Salem'),
('Divya Nair', 'Chennai'),
('Rahul Verma', 'Madurai'),
('Sneha Reddy', 'Bangalore'),
('Vijay Kumar', 'Salem'),
('Anitha Rao', 'Coimbatore'),
('Suresh Babu', 'Chennai'),
('Meena Devi', 'Madurai');

INSERT INTO RelationshipManagers (ManagerName, BranchID)
VALUES
('Ramesh', 1),
('Kavitha', 1),
('Sanjay', 2),
('Deepa', 2),
('Manoj', 3);

INSERT INTO Accounts
(AccountNumber, AccountType, ManagerID, Balance, OpenedDate)
VALUES
('ACC1001', 'Savings', 1, 75000, '2026-07-05'),
('ACC1002', 'Current', 2, 150000, '2026-07-12'),
('ACC1003', 'Savings', 3, 45000, '2026-07-20'),
('ACC1004', 'Fixed Deposit', 4, 200000, '2026-08-02'),
('ACC1005', 'Savings', 5, 90000, '2026-08-15'),
('ACC1006', 'Current', 1, 250000, '2026-08-22'),
('ACC1007', 'Savings', 2, 30000, '2026-09-03'),
('ACC1008', 'Fixed Deposit', 3, 175000, '2026-09-10'),
('ACC1009', 'Savings', 4, 55000, '2026-05-15'),
('ACC1010', 'Current', 5, 125000, '2026-04-20');

INSERT INTO AccountCustomers (AccountID, CustomerID)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);
GO


CREATE TABLE DropTest (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO DropTest (Name)
VALUES ('Arun'), ('Priya');

BEGIN TRANSACTION;
DROP TABLE DropTest;
ROLLBACK TRANSACTION;

SELECT * FROM DropTest;

INSERT INTO DropTest (Name)
VALUES ('Karthik');

SELECT * FROM DropTest;
GO


CREATE TABLE TruncateTest (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO TruncateTest (Name)
VALUES ('Arun'), ('Priya');

BEGIN TRANSACTION;
TRUNCATE TABLE TruncateTest;

SELECT * FROM TruncateTest;

ROLLBACK TRANSACTION;

SELECT * FROM TruncateTest;

TRUNCATE TABLE TruncateTest;

INSERT INTO TruncateTest (Name)
VALUES ('Karthik');

SELECT * FROM TruncateTest;
GO


CREATE TABLE DeleteTest (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO DeleteTest (Name)
VALUES ('Arun'), ('Priya');

BEGIN TRANSACTION;
DELETE FROM DeleteTest;

SELECT * FROM DeleteTest;

ROLLBACK TRANSACTION;

SELECT * FROM DeleteTest;

DELETE FROM DeleteTest;

INSERT INTO DeleteTest (Name)
VALUES ('Karthik');

SELECT * FROM DeleteTest;
GO
*/


USE BankBranchDB;
GO

-- INSERT a new customer and account
INSERT INTO Customers (CustomerName, Address)
VALUES ('Ajay Kumar', 'Trichy');

INSERT INTO Accounts
(AccountNumber, AccountType, ManagerID, Balance, OpenedDate)
VALUES
('ACC1011', 'Savings', 1, 65000, '2026-09-15');

INSERT INTO AccountCustomers (AccountID, CustomerID)
VALUES (11, 11);


-- UPDATE account balance
UPDATE Accounts
SET Balance = 80000
WHERE AccountNumber = 'ACC1001';


-- DELETE account
DELETE FROM Accounts
WHERE AccountNumber = 'ACC1011';


-- Retrieve using AND
SELECT *
FROM Accounts
WHERE OpenedDate BETWEEN '2026-07-01' AND '2026-09-30'
AND Balance > 50000;


-- Retrieve using OR
SELECT *
FROM Accounts
WHERE AccountType = 'Savings'
OR AccountType = 'Current';


-- Retrieve using IN
SELECT *
FROM Accounts
WHERE AccountType IN ('Savings', 'Fixed Deposit');


-- Retrieve using BETWEEN
SELECT *
FROM Accounts
WHERE Balance BETWEEN 50000 AND 150000;


-- Final account details
SELECT * FROM Accounts;
GO
