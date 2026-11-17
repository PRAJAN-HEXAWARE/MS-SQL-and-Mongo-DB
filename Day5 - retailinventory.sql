
--CREATE DATABASE RetailInventoryDB;
--GO

--USE RetailInventoryDB;
--GO
--SELECT DB_NAME() AS CurrentDatabase;
/*CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);
GO
*/

--SELECT * FROM Categories;
--GO

-- =========================================
-- COMMAND 6: CREATE SUPPLIERS TABLE
-- =========================================

/*CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL UNIQUE,
    SupplierPhone VARCHAR(15) NOT NULL
);
GO

-- COMMAND 7: VERIFY SUPPLIERS TABLE

SELECT * FROM Suppliers;
GO
*/



/* CREATE TABLE Products (
    SKU VARCHAR(20) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,
    ReorderLevel INT NOT NULL DEFAULT 5,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT FK_Products_Suppliers
        FOREIGN KEY (SupplierID)
        REFERENCES Suppliers(SupplierID),

    CONSTRAINT CHK_ReorderLevel
        CHECK (ReorderLevel >= 0)
);
GO

-- COMMAND 9: VERIFY PRODUCTS TABLE

SELECT * FROM Products;
GO


-- =========================================
-- COMMAND 10: CREATE INVENTORY TABLE
-- =========================================

CREATE TABLE Inventory (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    SKU VARCHAR(20) NOT NULL,
    Warehouse VARCHAR(100) NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Inventory_Products
        FOREIGN KEY (SKU)
        REFERENCES Products(SKU)
        ON DELETE CASCADE,

    CONSTRAINT UQ_Inventory_SKU_Warehouse
        UNIQUE (SKU, Warehouse),

    CONSTRAINT CHK_Inventory_Quantity
        CHECK (Quantity >= 0)
);
GO

-- COMMAND 11: VERIFY INVENTORY TABLE

SELECT * FROM Inventory;
GO


-- =========================================
-- COMMAND 12: VERIFY ALL TABLES
-- =========================================

USE RetailInventoryDB;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO


-- =========================================
-- COMMAND 13: VERIFY FOREIGN KEYS
-- =========================================

SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable
FROM sys.foreign_keys fk;
GO


INSERT INTO Categories (CategoryName)
VALUES
('Electronics'),
('Accessories'),
('Furniture'),
('Home Appliances'),
('Clothing'),
('Footwear'),
('Groceries'),
('Sports'),
('Stationery'),
('Gaming');

INSERT INTO Suppliers (SupplierName, SupplierPhone)
VALUES
('ABC Suppliers', '9876543210'),
('XYZ Traders', '9876543211'),
('Global Distributors', '9876543212'),
('Prime Supplies', '9876543213'),
('Tech World', '9876543214'),
('Metro Wholesale', '9876543215'),
('Smart Retailers', '9876543216'),
('City Distributors', '9876543217'),
('Universal Traders', '9876543218'),
('NextGen Supplies', '9876543219');


INSERT INTO Products (SKU, ProductName, CategoryID, SupplierID, ReorderLevel)
VALUES
('P101', 'Laptop', 1, 1, 5),
('P102', 'Wireless Mouse', 2, 2, 10),
('P103', 'Office Chair', 3, 3, 8),
('P104', 'Refrigerator', 4, 4, 4),
('P105', 'T Shirt', 5, 5, 15),
('P106', 'Sports Shoes', 6, 6, 6),
('P107', 'Rice Bag', 7, 7, 20),
('P108', 'Football', 8, 8, 7),
('P109', 'Notebook', 9, 9, 12),
('P110', 'Gaming Console', 10, 10, 3);


INSERT INTO Inventory (SKU, Warehouse, Quantity)
VALUES
('P101', 'Chennai', 25),
('P102', 'Chennai', 50),
('P103', 'Bangalore', 30),
('P104', 'Chennai', 15),
('P105', 'Coimbatore', 40),
('P106', 'Bangalore', 20),
('P107', 'Chennai', 100),
('P108', 'Coimbatore', 35),
('P109', 'Bangalore', 60),
('P110', 'Chennai', 12);

SELECT * FROM Suppliers
WHERE SupplierID = 1;

UPDATE Suppliers
SET SupplierPhone = '9998887770'
WHERE SupplierID = 1;


SELECT * FROM Suppliers
WHERE SupplierID = 1;

DELETE FROM Products
WHERE SKU = 'P110';
*/
SELECT * FROM Products
WHERE SKU = 'P110';
SELECT * FROM Inventory
WHERE SKU = 'P110';