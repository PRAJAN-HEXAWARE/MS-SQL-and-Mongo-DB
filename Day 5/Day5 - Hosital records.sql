
/*CREATE DATABASE HospitalRecordsDB;
GO

USE HospitalRecordsDB;
GO

CREATE TABLE Department (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE Patient (
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    PatientName VARCHAR(100) NOT NULL,
    Address VARCHAR(250) NOT NULL
);
GO

CREATE TABLE Doctor (
    DoctorID INT IDENTITY(1,1) PRIMARY KEY,
    DoctorName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,

    CONSTRAINT FK_Doctor_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES Department(DepartmentID)
);
GO

CREATE TABLE Visit (
    VisitID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    VisitDate DATE NOT NULL,
    Diagnosis VARCHAR(200) NOT NULL,
    Prescription VARCHAR(250),
    Notes VARCHAR(500),

    CONSTRAINT FK_Visit_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID),

    CONSTRAINT FK_Visit_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor(DoctorID),

    CONSTRAINT CHK_VisitDate
        CHECK (VisitDate <= CAST(GETDATE() AS DATE))
);
GO

CREATE TABLE Billing (
    BillingID INT IDENTITY(1,1) PRIMARY KEY,
    VisitID INT NOT NULL UNIQUE,
    BillAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    Status VARCHAR(20) NOT NULL DEFAULT 'Open',

    CONSTRAINT FK_Billing_Visit
        FOREIGN KEY (VisitID)
        REFERENCES Visit(VisitID),

    CONSTRAINT CHK_BillAmount
        CHECK (BillAmount >= 0),

    CONSTRAINT CHK_BillingStatus
        CHECK (Status IN ('Open', 'Paid', 'Pending'))
);
GO


USE HospitalRecordsDB;
GO

INSERT INTO Department (DepartmentName)
VALUES
('Cardiology'),
('Neurology'),
('Orthopedics'),
('Dermatology'),
('Pediatrics'),
('ENT'),
('Oncology'),
('General Medicine'),
('Urology'),
('Gynecology');

INSERT INTO Patient (PatientName, Address)
VALUES
('Arun Kumar', 'Chennai'),
('Priya Sharma', 'Salem'),
('Karthik Raj', 'Coimbatore'),
('Divya Nair', 'Madurai'),
('Rahul Verma', 'Chennai'),
('Sneha Reddy', 'Salem'),
('Vijay Kumar', 'Trichy'),
('Anitha Rao', 'Bangalore'),
('Suresh Babu', 'Erode'),
('Meena Devi', 'Namakkal');

INSERT INTO Doctor (DoctorName, DepartmentID)
VALUES
('Dr. Ravi', 1),
('Dr. Priya', 2),
('Dr. Kumar', 3),
('Dr. Meena', 4),
('Dr. Suresh', 5),
('Dr. Anitha', 6),
('Dr. Raj', 7),
('Dr. Deepa', 8),
('Dr. Manoj', 9),
('Dr. Kavitha', 10);

INSERT INTO Visit
(PatientID, DoctorID, VisitDate, Diagnosis, Prescription, Notes)
VALUES
(1, 1, '2026-10-01', 'Heart Checkup', 'Medicine A', 'Regular checkup'),
(2, 2, '2026-10-05', 'Migraine', 'Medicine B', 'Headache'),
(3, 3, '2026-10-08', 'Knee Pain', 'Medicine C', 'Joint pain'),
(4, 4, '2026-10-10', 'Skin Allergy', 'Medicine D', 'Rash'),
(5, 5, '2026-10-12', 'Fever', 'Medicine E', 'Mild fever'),
(6, 6, '2026-10-15', 'Ear Infection', 'Medicine F', 'Ear pain'),
(7, 7, '2026-10-18', 'Cancer Screening', 'Medicine G', 'Screening'),
(8, 8, '2026-10-20', 'Cold', 'Medicine H', 'Common cold'),
(9, 9, '2026-10-22', 'Kidney Stone', 'Medicine I', 'Abdominal pain'),
(10, 10, '2026-10-25', 'Routine Checkup', 'Medicine J', 'General examination');

INSERT INTO Billing (VisitID, BillAmount)
VALUES
(1, 1500),
(2, 1200),
(3, 2000),
(4, 800),
(5, 500),
(6, 900),
(7, 5000),
(8, 600),
(9, 3000),
(10, 1000);
GO


-- Add insurance_id column
ALTER TABLE Patient
ADD insurance_id VARCHAR(30) NULL;
GO

-- Rename Billing table
EXEC sp_rename 'Billing', 'PatientBilling';
GO

-- Drop the bill amount constraint
ALTER TABLE PatientBilling
DROP CONSTRAINT CHK_BillAmount;
GO

-- Verify the changes
SELECT * FROM Patient;

SELECT * FROM PatientBilling;
GO



-- Insert a new patient
INSERT INTO Patient (PatientName, Address, insurance_id)
VALUES ('Ajay Kumar', 'Trichy', 'INS1001');

-- Insert a new visit
INSERT INTO Visit
(PatientID, DoctorID, VisitDate, Diagnosis, Prescription, Notes)
VALUES
(11, 1, '2026-10-28', 'Chest Pain', 'Medicine K', 'Follow-up');

-- Insert billing
INSERT INTO PatientBilling (VisitID, BillAmount, Status)
VALUES (11, 1800, 'Open');

-- Update patient address
UPDATE Patient
SET Address = 'Namakkal'
WHERE PatientID = 11;

-- Update billing status
UPDATE PatientBilling
SET Status = 'Paid'
WHERE VisitID = 11;

-- Retrieve patients visited in October 2026
SELECT p.PatientID, p.PatientName, v.VisitDate, v.Diagnosis
FROM Patient p
INNER JOIN Visit v ON p.PatientID = v.PatientID
WHERE v.VisitDate >= '2026-10-01'
AND v.VisitDate < '2026-11-01';

-- Retrieve doctors in the Cardiology department
SELECT d.DoctorName, dep.DepartmentName
FROM Doctor d
INNER JOIN Department dep
ON d.DepartmentID = dep.DepartmentID
WHERE dep.DepartmentName LIKE '%Cardio%';

-- Delete the newly inserted visit
DELETE FROM PatientBilling WHERE VisitID = 11;
DELETE FROM Visit WHERE VisitID = 11;
DELETE FROM Patient WHERE PatientID = 11;

GO

*/


