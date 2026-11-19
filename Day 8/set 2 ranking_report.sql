USE AirlineDB;
GO
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT dbo.Passengers(PassengerID,PassengerName,Email)
    SELECT v.id,v.n,v.e FROM (VALUES (206,'Farhan','farhan@gmail.com'),(207,'Gokul','gokul@gmail.com'),(208,'Harini','harini@gmail.com')) v(id,n,e)
    WHERE NOT EXISTS(SELECT 1 FROM dbo.Passengers p WHERE p.PassengerID=v.id);
    INSERT dbo.Seats(SeatID,FlightID,SeatNumber,SeatStatus)
    SELECT v.id,v.f,v.n,'Available' FROM (VALUES (6,101,'1D'),(7,101,'1E'),(8,102,'2C'),(9,102,'2D'),(10,102,'2E')) v(id,f,n)
    WHERE NOT EXISTS(SELECT 1 FROM dbo.Seats s WHERE s.SeatID=v.id);
    INSERT dbo.Bookings(FlightID,SeatID,PassengerID,Fare)
    SELECT v.f,v.s,v.p,v.fare FROM (VALUES
        (101,2,202,6000.00),(101,3,203,6000.00),(101,6,204,4000.00),(101,7,205,3000.00),
        (102,4,206,7000.00),(102,5,207,7000.00),(102,8,208,5000.00),(102,9,201,4000.00),(102,10,202,3000.00)
    ) v(f,s,p,fare)
    WHERE NOT EXISTS(SELECT 1 FROM dbo.Bookings b WHERE b.SeatID=v.s);
    UPDATE s SET SeatStatus='Booked' FROM dbo.Seats s WHERE EXISTS(SELECT 1 FROM dbo.Bookings b WHERE b.SeatID=s.SeatID);
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
SELECT f.FlightNumber,p.PassengerName,s.SeatNumber,b.Fare,
    RANK() OVER(PARTITION BY b.FlightID ORDER BY b.Fare DESC) AS FareRank,
    DENSE_RANK() OVER(PARTITION BY b.FlightID ORDER BY b.Fare DESC) AS DenseFareRank
FROM dbo.Bookings b
JOIN dbo.Flights f ON f.FlightID=b.FlightID
JOIN dbo.Passengers p ON p.PassengerID=b.PassengerID
JOIN dbo.Seats s ON s.SeatID=b.SeatID
ORDER BY f.FlightNumber,b.Fare DESC,p.PassengerName;
GO
WITH RankedBookings AS
(
    SELECT f.FlightNumber,b.FlightID,p.PassengerName,s.SeatNumber,b.Fare,b.BookingID,
        RANK() OVER(PARTITION BY b.FlightID ORDER BY b.Fare DESC) AS FareRank,
        DENSE_RANK() OVER(PARTITION BY b.FlightID ORDER BY b.Fare DESC) AS DenseFareRank,
        SUM(b.Fare) OVER(PARTITION BY b.FlightID ORDER BY b.Fare DESC,b.BookingID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningRevenue
    FROM dbo.Bookings b
    JOIN dbo.Flights f ON f.FlightID=b.FlightID
    JOIN dbo.Passengers p ON p.PassengerID=b.PassengerID
    JOIN dbo.Seats s ON s.SeatID=b.SeatID
)
SELECT FlightNumber,PassengerName,SeatNumber,Fare,FareRank,DenseFareRank,RunningRevenue
FROM RankedBookings
ORDER BY FlightNumber,Fare DESC,BookingID;
GO
PRINT 'RANK skips rank numbers after ties; DENSE_RANK does not. RunningRevenue uses BookingID to break fare ties deterministically.';
