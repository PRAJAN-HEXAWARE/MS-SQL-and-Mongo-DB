IF DB_ID('AirlineDB') IS NULL
    CREATE DATABASE AirlineDB;
GO
USE AirlineDB;
GO
IF OBJECT_ID('dbo.Flights','U') IS NULL
    CREATE TABLE dbo.Flights (FlightID INT PRIMARY KEY, FlightNumber VARCHAR(20) NOT NULL, SourceCity VARCHAR(50) NOT NULL, DestinationCity VARCHAR(50) NOT NULL, DepartureDate DATE NOT NULL);
IF OBJECT_ID('dbo.Passengers','U') IS NULL
    CREATE TABLE dbo.Passengers (PassengerID INT PRIMARY KEY, PassengerName VARCHAR(100) NOT NULL, Email VARCHAR(100));
IF OBJECT_ID('dbo.Seats','U') IS NULL
    CREATE TABLE dbo.Seats (SeatID INT PRIMARY KEY, FlightID INT NOT NULL REFERENCES dbo.Flights(FlightID), SeatNumber VARCHAR(10) NOT NULL, SeatStatus VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK (SeatStatus IN ('Available','Booked')), CONSTRAINT UQ_Flight_Seat UNIQUE(FlightID,SeatNumber));
IF OBJECT_ID('dbo.Bookings','U') IS NULL
    CREATE TABLE dbo.Bookings (BookingID INT IDENTITY(1,1) PRIMARY KEY, FlightID INT NOT NULL REFERENCES dbo.Flights(FlightID), SeatID INT NOT NULL REFERENCES dbo.Seats(SeatID), PassengerID INT NOT NULL REFERENCES dbo.Passengers(PassengerID), Fare DECIMAL(10,2) NOT NULL CHECK(Fare>0), BookingDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(), CONSTRAINT UQ_Booked_Seat UNIQUE(SeatID));
GO
IF NOT EXISTS(SELECT 1 FROM dbo.Flights WHERE FlightID=101)
    INSERT dbo.Flights VALUES (101,'AI202','Chennai','Delhi','2026-12-10');
IF NOT EXISTS(SELECT 1 FROM dbo.Flights WHERE FlightID=102)
    INSERT dbo.Flights VALUES (102,'6E305','Chennai','Mumbai','2026-12-11');
INSERT dbo.Passengers(PassengerID,PassengerName,Email)
SELECT v.id,v.n,v.e FROM (VALUES (201,'Arun','arun@gmail.com'),(202,'Bala','bala@gmail.com'),(203,'Charan','charan@gmail.com'),(204,'Divya','divya@gmail.com'),(205,'Esha','esha@gmail.com')) v(id,n,e)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Passengers p WHERE p.PassengerID=v.id);
INSERT dbo.Seats(SeatID,FlightID,SeatNumber,SeatStatus)
SELECT v.id,v.f,v.n,'Available' FROM (VALUES (1,101,'1A'),(2,101,'1B'),(3,101,'1C'),(4,102,'2A'),(5,102,'2B'),(11,101,'3A'),(12,101,'3B')) v(id,f,n)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Seats s WHERE s.SeatID=v.id);
GO
CREATE OR ALTER PROCEDURE dbo.BookSeat
    @FlightID INT, @SeatID INT, @PassengerID INT, @Fare DECIMAL(10,2), @Isolation VARCHAR(20)='READ COMMITTED', @HoldSeconds VARCHAR(8)='00:00:00'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Isolation = 'SERIALIZABLE'
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    ELSE IF @Isolation = 'READ COMMITTED'
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    ELSE
        THROW 51000,'Unsupported isolation level',1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Fare <= 0 THROW 51001,'Fare must be positive',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.Passengers WHERE PassengerID=@PassengerID)
            THROW 51002,'Passenger does not exist',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.Seats WITH (UPDLOCK,HOLDLOCK) WHERE SeatID=@SeatID AND FlightID=@FlightID AND SeatStatus='Available')
            THROW 51003,'Seat unavailable or already booked',1;
        IF @HoldSeconds <> '00:00:00'
            WAITFOR DELAY @HoldSeconds;
        INSERT dbo.Bookings(FlightID,SeatID,PassengerID,Fare)
        VALUES(@FlightID,@SeatID,@PassengerID,@Fare);
        UPDATE dbo.Seats SET SeatStatus='Booked'
        WHERE SeatID=@SeatID AND FlightID=@FlightID AND SeatStatus='Available';
        IF @@ROWCOUNT<>1 THROW 51004,'Seat status update failed',1;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Outcome,@PassengerID AS PassengerID,@SeatID AS SeatID,@Isolation AS IsolationLevel;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
        SELECT 'FAILED' AS Outcome,@PassengerID AS PassengerID,@SeatID AS SeatID,@Isolation AS IsolationLevel,ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END;
GO
EXEC dbo.BookSeat @FlightID=101,@SeatID=1,@PassengerID=201,@Fare=5000;
SELECT s.SeatID,s.SeatNumber,s.SeatStatus,b.BookingID,p.PassengerName,b.Fare
FROM dbo.Seats s LEFT JOIN dbo.Bookings b ON b.SeatID=s.SeatID
LEFT JOIN dbo.Passengers p ON p.PassengerID=b.PassengerID WHERE s.SeatID=1;
GO
PRINT 'TASK 2: Two SSMS connections are required. Use seats 11 and 12, which are reserved for this demonstration.';
PRINT 'READ COMMITTED: In Session A execute: EXEC dbo.BookSeat 101,11,202,6000,''READ COMMITTED'',''00:00:15'';';
PRINT 'Immediately in Session B execute: EXEC dbo.BookSeat 101,11,203,6000,''READ COMMITTED'';';
PRINT 'Session B waits for Session A and then fails with seat unavailable. Run Session A first.';
PRINT 'SERIALIZABLE: In Session A execute: EXEC dbo.BookSeat 101,12,204,6500,''SERIALIZABLE'',''00:00:15'';';
PRINT 'Immediately in Session B execute: EXEC dbo.BookSeat 101,12,205,6500,''SERIALIZABLE'';';
PRINT 'Session B waits and then fails with seat unavailable. Both tests prevent double booking because of locks and UNIQUE(SeatID).';
PRINT 'Run the following SELECT after both sessions finish to capture evidence.';
SELECT s.SeatID,s.SeatNumber,s.SeatStatus,b.BookingID,b.PassengerID
FROM dbo.Seats s LEFT JOIN dbo.Bookings b ON b.SeatID=s.SeatID
WHERE s.SeatID IN(11,12) ORDER BY s.SeatID;
GO
