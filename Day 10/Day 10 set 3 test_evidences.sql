
USE HospitalBedDB;
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
GROUP BY W.WardID, W.WardName, W.TotalBeds
ORDER BY W.WardID;
GO

INSERT INTO dbo.admissions
(
    PatientID,
    PatientName,
    WardID,
    AdmissionStatus
)
VALUES
(
    1011,
    'Karthik',
    101,
    'Admitted'
);
GO

SELECT
    AdmissionID,
    PatientID,
    PatientName,
    WardID,
    AdmissionStatus
FROM dbo.admissions
WHERE PatientID = 1011;

SELECT *
FROM dbo.admission_audit
ORDER BY AuditID;
GO

BEGIN TRY
    INSERT INTO dbo.admissions
    (
        PatientID,
        PatientName,
        WardID,
        AdmissionStatus
    )
    VALUES
        (1012, 'Lavanya', 102, 'Admitted'),
        (1013, 'Manoj', 103, 'Admitted'),
        (1014, 'Nisha', 101, 'Admitted');

    PRINT 'Multi-row admission successful';
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

SELECT
    PatientID,
    PatientName,
    WardID
FROM dbo.admissions
WHERE PatientID IN (1012, 1013, 1014);

SELECT
    COUNT(*) AS RejectedPatientsFound
FROM dbo.admissions
WHERE PatientID IN (1012, 1013, 1014);
GO

INSERT INTO dbo.admissions
(
    PatientID,
    PatientName,
    WardID,
    AdmissionStatus
)
VALUES
(
    1015,
    'Oviya',
    102,
    'Admitted'
);
GO

UPDATE dbo.admissions
SET
    AdmissionStatus = 'Discharged',
    DischargeDate = SYSDATETIME()
WHERE PatientID = 1015;
GO

DELETE FROM dbo.admissions
WHERE PatientID = 1015;
GO

SELECT
    AuditID,
    AdmissionID,
    PatientID,
    OperationType,
    OldWardID,
    NewWardID,
    OldStatus,
    NewStatus,
    ChangedBy,
    ChangedAt
FROM dbo.admission_audit
ORDER BY AuditID;
GO

SELECT
    OperationType,
    COUNT(*) AS AuditCount
FROM dbo.admission_audit
GROUP BY OperationType
ORDER BY OperationType;
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
GROUP BY W.WardID, W.WardName, W.TotalBeds
ORDER BY W.WardID;
GO
