/*
IF DB_ID('HospitalBedDB') IS NULL
    CREATE DATABASE HospitalBedDB;
GO

USE HospitalBedDB;
GO

IF OBJECT_ID('dbo.wards', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.wards
    (
        WardID INT PRIMARY KEY,
        WardName VARCHAR(100) NOT NULL,
        WardType VARCHAR(50) NOT NULL,
        TotalBeds INT NOT NULL
            CHECK (TotalBeds > 0),
        WardStatus VARCHAR(20) NOT NULL
            DEFAULT 'Active'
    );
END;
GO

IF OBJECT_ID('dbo.admissions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.admissions
    (
        AdmissionID INT IDENTITY(1,1) PRIMARY KEY,
        PatientID INT NOT NULL,
        PatientName VARCHAR(100) NOT NULL,
        WardID INT NOT NULL,
        AdmissionDate DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
        DischargeDate DATETIME2 NULL,
        AdmissionStatus VARCHAR(20) NOT NULL
            DEFAULT 'Admitted',
        CONSTRAINT FK_Admissions_Wards
            FOREIGN KEY (WardID)
            REFERENCES dbo.wards(WardID),
        CONSTRAINT CK_AdmissionStatus
            CHECK (AdmissionStatus IN
                ('Admitted', 'Discharged'))
    );
END;
GO

IF OBJECT_ID('dbo.admission_audit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.admission_audit
    (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        AdmissionID INT NOT NULL,
        PatientID INT NOT NULL,
        OperationType VARCHAR(10) NOT NULL,
        OldWardID INT NULL,
        NewWardID INT NULL,
        OldStatus VARCHAR(20) NULL,
        NewStatus VARCHAR(20) NULL,
        ChangedBy SYSNAME NOT NULL,
        ChangedAt DATETIME2 NOT NULL
            DEFAULT SYSDATETIME()
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.wards)
BEGIN
    INSERT INTO dbo.wards
    (
        WardID,
        WardName,
        WardType,
        TotalBeds
    )
    VALUES
        (101, 'General Ward A', 'General', 5),
        (102, 'General Ward B', 'General', 8),
        (103, 'ICU Ward', 'ICU', 3),
        (104, 'Emergency Ward', 'Emergency', 6),
        (105, 'Pediatric Ward', 'Pediatric', 5);
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.admissions)
BEGIN
    INSERT INTO dbo.admissions
    (
        PatientID,
        PatientName,
        WardID,
        AdmissionStatus
    )
    VALUES
        (1001, 'Arun', 101, 'Admitted'),
        (1002, 'Bala', 101, 'Admitted'),
        (1003, 'Charan', 101, 'Admitted'),
        (1004, 'Divya', 101, 'Admitted'),
        (1005, 'Esha', 102, 'Admitted'),
        (1006, 'Farhan', 102, 'Admitted'),
        (1007, 'Gokul', 103, 'Admitted'),
        (1008, 'Harini', 103, 'Admitted'),
        (1009, 'Ishaan', 104, 'Admitted'),
        (1010, 'Janani', 105, 'Admitted');
END;
GO

SELECT
    WardID,
    WardName,
    WardType,
    TotalBeds
FROM dbo.wards
ORDER BY WardID;
GO

SELECT
    AdmissionID,
    PatientID,
    PatientName,
    WardID,
    AdmissionStatus
FROM dbo.admissions
ORDER BY AdmissionID;
GO

SELECT
    W.WardID,
    W.WardName,
    W.TotalBeds,
    COUNT(A.AdmissionID) AS OccupiedBeds,
    W.TotalBeds - COUNT(A.AdmissionID) AS AvailableBeds
FROM dbo.wards W
LEFT JOIN dbo.admissions A
    ON W.WardID = A.WardID
    AND A.AdmissionStatus = 'Admitted'
GROUP BY
    W.WardID,
    W.WardName,
    W.TotalBeds
ORDER BY W.WardID;
GO
*/


USE HospitalBedDB;
GO

CREATE OR ALTER TRIGGER dbo.trg_WardCapacity_Check
ON dbo.admissions
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.wards W WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN
        (
            SELECT DISTINCT WardID
            FROM inserted
            WHERE AdmissionStatus = 'Admitted'
        ) I
            ON W.WardID = I.WardID
        CROSS APPLY
        (
            SELECT COUNT(*) AS OccupiedBeds
            FROM dbo.admissions A
            WHERE A.WardID = W.WardID
              AND A.AdmissionStatus = 'Admitted'
        ) C
        WHERE C.OccupiedBeds > W.TotalBeds
    )
    BEGIN
        THROW 50002,
              'Admission rejected: Ward bed capacity exceeded.',
              1;
    END;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_Admission_Audit
ON dbo.admissions
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.admission_audit
    (
        AdmissionID,
        PatientID,
        OperationType,
        OldWardID,
        NewWardID,
        OldStatus,
        NewStatus,
        ChangedBy,
        ChangedAt
    )
    SELECT
        COALESCE(I.AdmissionID, D.AdmissionID),
        COALESCE(I.PatientID, D.PatientID),
        CASE
            WHEN D.AdmissionID IS NULL THEN 'INSERT'
            WHEN I.AdmissionID IS NULL THEN 'DELETE'
            ELSE 'UPDATE'
        END,
        D.WardID,
        I.WardID,
        D.AdmissionStatus,
        I.AdmissionStatus,
        ORIGINAL_LOGIN(),
        SYSDATETIME()
    FROM inserted I
    FULL OUTER JOIN deleted D
        ON I.AdmissionID = D.AdmissionID;
END;
GO

SELECT
    T.name AS TriggerName,
    OBJECT_NAME(T.parent_id) AS TableName,
    T.is_disabled AS IsDisabled
FROM sys.triggers T
WHERE T.parent_id = OBJECT_ID('dbo.admissions')
ORDER BY T.name;
GO
