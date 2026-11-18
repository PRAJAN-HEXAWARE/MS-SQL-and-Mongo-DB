/*
CREATE DATABASE LogisticsDB;
GO

USE LogisticsDB;
GO

-- Clean up tables if they already exist
DROP TABLE IF EXISTS DeliveryEvents;
DROP TABLE IF EXISTS Shipments;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Carriers;
DROP TABLE IF EXISTS Hubs;
GO

-- 1. Hubs
CREATE TABLE Hubs (
    HubID INT PRIMARY KEY,
    HubName VARCHAR(100),
    City VARCHAR(100)
);

-- 2. Carriers
CREATE TABLE Carriers (
    CarrierID INT PRIMARY KEY,
    CarrierName VARCHAR(100),
    ContactNumber VARCHAR(15)
);

-- 3. Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(100)
);

-- 4. Employees (Self-referencing relationship)
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Designation VARCHAR(100),
    ManagerID INT NULL,
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID)
);

-- 5. Shipments
CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    CustomerID INT,
    CarrierID INT,
    OriginHubID INT,
    DestinationHubID INT,
    EmployeeID INT,
    ShippingCost DECIMAL(10,2),
    ShipmentDate DATE,
    ExpectedDeliveryDate DATE,
    ActualDeliveryDate DATE,
    ShipmentStatus VARCHAR(30),

    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CarrierID) REFERENCES Carriers(CarrierID),
    FOREIGN KEY (OriginHubID) REFERENCES Hubs(HubID),
    FOREIGN KEY (DestinationHubID) REFERENCES Hubs(HubID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- 6. Delivery Events
CREATE TABLE DeliveryEvents (
    EventID INT PRIMARY KEY,
    ShipmentID INT,
    EventDate DATETIME,
    EventDescription VARCHAR(200),
    EventLocation VARCHAR(100),

    FOREIGN KEY (ShipmentID) REFERENCES Shipments(ShipmentID)
);
GO

-- Insert Hubs
INSERT INTO Hubs VALUES
(1, 'Chennai Central Hub', 'Chennai'),
(2, 'Coimbatore Hub', 'Coimbatore'),
(3, 'Madurai Hub', 'Madurai'),
(4, 'Salem Hub', 'Salem');

-- Insert Carriers
INSERT INTO Carriers VALUES
(1, 'BlueDart', '9876543210'),
(2, 'DTDC', '9876543211'),
(3, 'Delhivery', '9876543212'),
(4, 'India Post', '9876543213');

-- Insert Customers
INSERT INTO Customers VALUES
(1, 'Arun Kumar', 'Chennai'),
(2, 'Priya Sharma', 'Coimbatore'),
(3, 'Karthik Raj', 'Madurai'),
(4, 'Divya Nair', 'Salem'),
(5, 'Rahul Verma', 'Chennai'),
(6, 'Sneha Reddy', 'Coimbatore');

-- Insert Employees
INSERT INTO Employees VALUES
(1, 'Ramesh', 'Logistics Manager', NULL),
(2, 'Suresh', 'Operations Supervisor', 1),
(3, 'Kavitha', 'Shipment Coordinator', 1),
(4, 'Manoj', 'Delivery Executive', 2),
(5, 'Anitha', 'Delivery Executive', 2),
(6, 'Vijay', 'Shipment Coordinator', 3);

-- Insert Shipments
INSERT INTO Shipments VALUES
(101, 1, 1, 1, 2, 4, 1200, '2026-10-01', '2026-10-03', '2026-10-06', 'Delivered'),
(102, 1, 2, 1, 3, 5, 1500, '2026-10-02', '2026-10-04', '2026-10-04', 'Delivered'),
(103, 1, 3, 2, 4, 4, 900, '2026-10-03', '2026-10-05', '2026-10-09', 'Delivered'),
(104, 2, 1, 2, 1, 5, 1100, '2026-10-04', '2026-10-06', '2026-10-06', 'Delivered'),
(105, 2, 2, 2, 3, 6, 1300, '2026-10-05', '2026-10-07', '2026-10-11', 'Delivered'),
(106, 3, 3, 3, 1, 4, 1000, '2026-10-06', '2026-10-08', '2026-10-12', 'Delivered'),
(107,3, 1, 3, 2, 5, 850, '2026-10-07', '2026-10-09', '2026-10-09', 'Delivered'),
(108,4, 4, 4, 1, 6, 700, '2026-10-08', '2026-10-10', NULL, 'In Transit'),
(109,5, 2, 1, 4, 4, 1600, '2026-10-09', '2026-10-11', '2026-10-15', 'Delivered'),
(110,6, 3, 2, 4, 5, 950, '2026-10-10', '2026-10-12', '2026-10-12', 'Delivered'),
(111,1, 4, 4, 3, 6, 800, '2026-10-11', '2026-10-13', NULL, 'In Transit'),
(112,5, 1, 3, 2, 4, 1400, '2026-10-12', '2026-10-14', '2026-10-18', 'Delivered');

-- Insert Delivery Events
INSERT INTO DeliveryEvents VALUES
(1, 101, '2026-10-01 09:00', 'Shipment picked up', 'Chennai'),
(2, 101, '2026-10-02 14:00', 'Reached transit hub', 'Coimbatore'),
(3, 101, '2026-10-06 10:00', 'Shipment delivered', 'Coimbatore'),
(4, 102, '2026-10-02 11:00', 'Shipment picked up', 'Chennai'),
(5, 102, '2026-10-04 16:00', 'Shipment delivered', 'Madurai'),
(6, 103, '2026-10-03 12:00', 'Shipment picked up', 'Coimbatore'),
(7, 103, '2026-10-09 15:00', 'Shipment delivered', 'Salem'),
(8, 104, '2026-10-04 09:30', 'Shipment picked up', 'Coimbatore'),
(9, 104, '2026-10-06 13:00', 'Shipment delivered', 'Chennai'),
(10, 105, '2026-10-05 10:00', 'Shipment picked up', 'Coimbatore'),
(11, 105, '2026-10-11 14:00', 'Shipment delivered', 'Madurai'),
(12, 106, '2026-10-06 11:00', 'Shipment picked up', 'Madurai'),
(13, 106, '2026-10-12 17:00', 'Shipment delivered', 'Chennai'),
(14, 107, '2026-10-07 10:00', 'Shipment picked up', 'Madurai'),
(15, 107, '2026-10-09 12:00', 'Shipment delivered', 'Coimbatore'),
(16, 108, '2026-10-08 09:00', 'Shipment picked up', 'Salem'),
(17, 109, '2026-10-09 11:00', 'Shipment picked up', 'Chennai'),
(18, 109, '2026-10-15 16:00', 'Shipment delivered', 'Salem'),
(19, 110, '2026-10-10 10:00', 'Shipment picked up', 'Coimbatore'),
(20, 110, '2026-10-12 14:00', 'Shipment delivered', 'Salem'),
(21, 111, '2026-10-11 09:00', 'Shipment picked up', 'Salem'),
(22, 112, '2026-10-12 11:00', 'Shipment picked up', 'Madurai'),
(23, 112, '2026-10-18 15:00', 'Shipment delivered', 'Coimbatore');
GO

-- Verify the tables and records
SELECT * FROM Hubs;
SELECT * FROM Carriers;
SELECT * FROM Customers;
SELECT * FROM Employees;
SELECT * FROM Shipments;
SELECT * FROM DeliveryEvents;
GO


USE LogisticsDB;
GO

SELECT
    S.ShipmentID,
    C.CustomerName,
    CA.CarrierName,
    OH.HubName AS OriginHub,
    DH.HubName AS DestinationHub,
    S.ExpectedDeliveryDate,
    S.ActualDeliveryDate,
    DATEDIFF(DAY, S.ExpectedDeliveryDate, S.ActualDeliveryDate) AS DelayDays
FROM Shipments S
INNER JOIN Customers C ON S.CustomerID = C.CustomerID
INNER JOIN Carriers CA ON S.CarrierID = CA.CarrierID
INNER JOIN Hubs OH ON S.OriginHubID = OH.HubID
INNER JOIN Hubs DH ON S.DestinationHubID = DH.HubID
WHERE S.ActualDeliveryDate IS NOT NULL
  AND DATEDIFF(DAY, S.ExpectedDeliveryDate, S.ActualDeliveryDate) > 2;
GO

SELECT
    H.HubID,
    H.HubName,
    H.City
FROM Hubs H
LEFT JOIN Shipments S ON H.HubID = S.OriginHubID
WHERE S.ShipmentID IS NULL;
GO

SELECT
    E.EmployeeID,
    E.EmployeeName,
    E.Designation,
    M.EmployeeName AS ManagerName,
    M.Designation AS ManagerDesignation
FROM Employees E
LEFT JOIN Employees M ON E.ManagerID = M.EmployeeID;
GO

SELECT
    S.ShipmentID,
    C.CustomerName,
    CA.CarrierName,
    S.ShippingCost,
    S.ShipmentStatus,
    S.ShipmentDate
FROM Shipments S
INNER JOIN Customers C ON S.CustomerID = C.CustomerID
INNER JOIN Carriers CA ON S.CarrierID = CA.CarrierID;
GO

SELECT
    C.CustomerID,
    C.CustomerName,
    C.City,
    S.ShipmentID,
    S.ShippingCost,
    S.ShipmentStatus
FROM Customers C
LEFT JOIN Shipments S ON C.CustomerID = S.CustomerID;
GO

SELECT
    S.ShipmentID,
    CA.CarrierName,
    DE.EventDate,
    DE.EventDescription,
    DE.EventLocation
FROM Shipments S
INNER JOIN Carriers CA ON S.CarrierID = CA.CarrierID
INNER JOIN DeliveryEvents DE ON S.ShipmentID = DE.ShipmentID
ORDER BY S.ShipmentID, DE.EventDate;
GO

SELECT
    CA.CarrierID,
    CA.CarrierName,
    S.ShipmentID,
    S.ShippingCost,
    S.ShipmentStatus
FROM Carriers CA
FULL OUTER JOIN Shipments S ON CA.CarrierID = S.CarrierID;
GO

SELECT
    CA.CarrierID,
    CA.CarrierName,
    COUNT(S.ShipmentID) AS TotalShipments,
    COALESCE(SUM(S.ShippingCost), 0) AS TotalShippingCost
FROM Carriers CA
LEFT JOIN Shipments S ON CA.CarrierID = S.CarrierID
GROUP BY CA.CarrierID, CA.CarrierName;
GO

SELECT
    E.EmployeeID,
    E.EmployeeName,
    E.Designation,
    S.ShipmentID,
    S.ShipmentStatus,
    S.ShippingCost
FROM Employees E
LEFT JOIN Shipments S ON E.EmployeeID = S.EmployeeID
ORDER BY E.EmployeeID;
GO

SELECT
    S.ShipmentID,
    OH.HubName AS OriginHub,
    OH.City AS OriginCity,
    DH.HubName AS DestinationHub,
    DH.City AS DestinationCity,
    S.ShippingCost,
    S.ShipmentStatus
FROM Shipments S
INNER JOIN Hubs OH ON S.OriginHubID = OH.HubID
INNER JOIN Hubs DH ON S.DestinationHubID = DH.HubID;
GO



USE LogisticsDB;
GO

SELECT
    CustomerID,
    CustomerName,
    City
FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Shipments
);
GO

SELECT
    ShipmentID,
    CustomerID,
    ShippingCost,
    ShipmentStatus
FROM Shipments
WHERE ShippingCost > (
    SELECT AVG(ShippingCost)
    FROM Shipments
);
GO

SELECT
    CustomerID,
    CustomerName,
    City
FROM Customers C
WHERE EXISTS (
    SELECT 1
    FROM Shipments S
    WHERE S.CustomerID = C.CustomerID
);
GO

SELECT
    CustomerID,
    CustomerName,
    City
FROM Customers C
WHERE NOT EXISTS (
    SELECT 1
    FROM Shipments S
    WHERE S.CustomerID = C.CustomerID
);
GO

SELECT
    ShipmentID,
    ShippingCost,
    CarrierID
FROM Shipments
WHERE ShippingCost > ANY (
    SELECT ShippingCost
    FROM Shipments
    WHERE CarrierID = 1
);
GO

SELECT
    ShipmentID,
    ShippingCost,
    CarrierID
FROM Shipments
WHERE ShippingCost > ALL (
    SELECT ShippingCost
    FROM Shipments
    WHERE CarrierID = 1
);
GO

SELECT
    CarrierID,
    CarrierName
FROM Carriers
WHERE CarrierID IN (
    SELECT CarrierID
    FROM Shipments
    GROUP BY CarrierID
    HAVING COUNT(*) > 2
);
GO

SELECT
    HubID,
    HubName,
    City
FROM Hubs H
WHERE EXISTS (
    SELECT 1
    FROM Shipments S
    WHERE S.OriginHubID = H.HubID
       OR S.DestinationHubID = H.HubID
);
GO

SELECT
    EmployeeID,
    EmployeeName,
    Designation
FROM Employees
WHERE EmployeeID IN (
    SELECT EmployeeID
    FROM Shipments
    WHERE ShippingCost > (
        SELECT AVG(ShippingCost)
        FROM Shipments
    )
);
GO

SELECT
    ShipmentID,
    ShippingCost,
    ShipmentStatus
FROM Shipments
WHERE ShippingCost < ALL (
    SELECT ShippingCost
    FROM Shipments
    WHERE ShipmentStatus = 'Delivered'
);
GO



USE LogisticsDB;
GO

SELECT
    COUNT(*) AS TotalShipments,
    SUM(ShippingCost) AS TotalShippingCost,
    AVG(ShippingCost) AS AverageShippingCost,
    MIN(ShippingCost) AS MinimumShippingCost,
    MAX(ShippingCost) AS MaximumShippingCost
FROM Shipments;
GO

SELECT
    CA.CarrierName,
    COUNT(S.ShipmentID) AS TotalShipments,
    SUM(S.ShippingCost) AS TotalShippingCost,
    AVG(S.ShippingCost) AS AverageShippingCost
FROM Carriers CA
LEFT JOIN Shipments S ON CA.CarrierID = S.CarrierID
GROUP BY CA.CarrierName;
GO

SELECT
    ShipmentStatus,
    COUNT(*) AS TotalShipments,
    AVG(ShippingCost) AS AverageShippingCost,
    SUM(ShippingCost) AS TotalShippingCost
FROM Shipments
GROUP BY ShipmentStatus;
GO

SELECT
    OH.HubName AS OriginHub,
    COUNT(S.ShipmentID) AS TotalShipments,
    SUM(S.ShippingCost) AS TotalShippingCost
FROM Shipments S
INNER JOIN Hubs OH ON S.OriginHubID = OH.HubID
GROUP BY OH.HubName
HAVING COUNT(S.ShipmentID) > 1;
GO

SELECT
    CA.CarrierName,
    COUNT(S.ShipmentID) AS ShipmentCount
FROM Carriers CA
INNER JOIN Shipments S ON CA.CarrierID = S.CarrierID
GROUP BY CA.CarrierName
HAVING COUNT(S.ShipmentID) > 2;
GO

SELECT
    OH.City AS OriginCity,
    DH.City AS DestinationCity,
    COUNT(S.ShipmentID) AS TotalShipments,
    AVG(S.ShippingCost) AS AverageShippingCost
FROM Shipments S
INNER JOIN Hubs OH ON S.OriginHubID = OH.HubID
INNER JOIN Hubs DH ON S.DestinationHubID = DH.HubID
GROUP BY OH.City, DH.City;
GO

SELECT
    C.CustomerName,
    COUNT(S.ShipmentID) AS TotalShipments,
    SUM(S.ShippingCost) AS TotalShippingCost
FROM Customers C
INNER JOIN Shipments S ON C.CustomerID = S.CustomerID
GROUP BY C.CustomerName
HAVING SUM(S.ShippingCost) > (
    SELECT AVG(ShippingCost)
    FROM Shipments
);
GO

SELECT
    ShipmentStatus,
    COUNT(*) AS ShipmentCount
FROM Shipments
GROUP BY ShipmentStatus
ORDER BY ShipmentCount DESC;
GO



USE LogisticsDB;
GO

SELECT DISTINCT
    C.CustomerID,
    C.CustomerName,
    C.City
FROM Customers C
INNER JOIN Shipments S
    ON C.CustomerID = S.CustomerID;
GO

SELECT DISTINCT
    H.HubID,
    H.HubName,
    H.City
FROM Hubs H
INNER JOIN Shipments S
    ON H.HubID = S.OriginHubID
    OR H.HubID = S.DestinationHubID;
GO
*/

SELECT
    H.HubID,
    H.HubName,
    (
        SELECT MAX(S1.ShippingCost)
        FROM Shipments S1
        WHERE S1.OriginHubID = H.HubID
          AND S1.ShippingCost < (
              SELECT MAX(S2.ShippingCost)
              FROM Shipments S2
              WHERE S2.OriginHubID = H.HubID
          )
    ) AS SecondHighestShippingCost
FROM Hubs H
WHERE EXISTS (
    SELECT 1
    FROM Shipments S
    WHERE S.OriginHubID = H.HubID
);
GO