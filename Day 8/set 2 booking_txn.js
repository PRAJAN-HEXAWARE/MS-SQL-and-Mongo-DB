
const airlineDB = db.getSiblingDB("AirlineDB");

const seats = airlineDB.getCollection("seats");
const bookings = airlineDB.getCollection("bookings");

seats.updateOne(
    { _id: 1 },
    {
        $setOnInsert: {
            flightId: 101,
            flightNumber: "AI202",
            seatNumber: "1A",
            status: "Available"
        }
    },
    { upsert: true }
);

print("Seat status before booking:");
printjson(seats.findOne({ _id: 1 }));

const session = db.getMongo().startSession();

try {
    const transactionDB = session.getDatabase("AirlineDB");

    const transactionSeats =
        transactionDB.getCollection("seats");

    const transactionBookings =
        transactionDB.getCollection("bookings");

    session.startTransaction();

    const seatUpdate = transactionSeats.updateOne(
        {
            _id: 1,
            flightId: 101,
            status: "Available"
        },
        {
            $set: {
                status: "Booked"
            }
        }
    );

    if (seatUpdate.modifiedCount !== 1) {
        throw new Error(
            "Seat is already booked or unavailable"
        );
    }

    transactionBookings.insertOne({
        flightId: 101,
        seatId: 1,
        seatNumber: "1A",
        passengerId: 201,
        passengerName: "Arun",
        fare: 5000,
        bookingDate: new Date()
    });

    session.commitTransaction();

    print("Seat booked successfully");
    print("Transaction committed successfully");

} catch (error) {
    if (session.inTransaction()) {
        session.abortTransaction();
    }

    print("Booking failed: " + error.message);
    print("Transaction rolled back");

} finally {
    session.endSession();
}

print("Seat status after booking:");
printjson(seats.findOne({ _id: 1 }));

print("Booking details:");
printjson(bookings.find({ seatId: 1 }).toArray());
