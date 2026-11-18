// =====================================================
// 1. SELECT & RESET DATABASE
// =====================================================
db = db.getSiblingDB("LogisticsDB");

db.hubs.drop();
db.carriers.drop();
db.customers.drop();
db.employees.drop();
db.shipments.drop();
db.delivery_events.drop();


// =====================================================
// 2. CREATE COLLECTIONS AND INSERT DATA (FROM SQL)
// =====================================================

// 1. HUBS
db.hubs.insertMany([
    { hubId: 1, hubName: "Chennai Central Hub", city: "Chennai" },
    { hubId: 2, hubName: "Coimbatore Hub", city: "Coimbatore" },
    { hubId: 3, hubName: "Madurai Hub", city: "Madurai" },
    { hubId: 4, hubName: "Salem Hub", city: "Salem" }
]);

// 2. CARRIERS
db.carriers.insertMany([
    { carrierId: 1, carrierName: "BlueDart", contactNumber: "9876543210" },
    { carrierId: 2, carrierName: "DTDC", contactNumber: "9876543211" },
    { carrierId: 3, carrierName: "Delhivery", contactNumber: "9876543212" },
    { carrierId: 4, carrierName: "India Post", contactNumber: "9876543213" }
]);

// 3. CUSTOMERS
db.customers.insertMany([
    { customerId: 1, customerName: "Arun Kumar", city: "Chennai" },
    { customerId: 2, customerName: "Priya Sharma", city: "Coimbatore" },
    { customerId: 3, customerName: "Karthik Raj", city: "Madurai" },
    { customerId: 4, customerName: "Divya Nair", city: "Salem" },
    { customerId: 5, customerName: "Rahul Verma", city: "Chennai" },
    { customerId: 6, customerName: "Sneha Reddy", city: "Coimbatore" }
]);

// 4. EMPLOYEES (Self-referencing via managerId)
db.employees.insertMany([
    { employeeId: 1, employeeName: "Ramesh", designation: "Logistics Manager", managerId: null },
    { employeeId: 2, employeeName: "Suresh", designation: "Operations Supervisor", managerId: 1 },
    { employeeId: 3, employeeName: "Kavitha", designation: "Shipment Coordinator", managerId: 1 },
    { employeeId: 4, employeeName: "Manoj", designation: "Delivery Executive", managerId: 2 },
    { employeeId: 5, employeeName: "Anitha", designation: "Delivery Executive", managerId: 2 },
    { employeeId: 6, employeeName: "Vijay", designation: "Shipment Coordinator", managerId: 3 }
]);

// 5. SHIPMENTS
db.shipments.insertMany([
    {
        shipmentId: 101, customerId: 1, carrierId: 1, originHubId: 1, destinationHubId: 2, employeeId: 4,
        shippingCost: 1200,
        shipmentDate: ISODate("2026-10-01T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-03T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-06T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 102, customerId: 1, carrierId: 2, originHubId: 1, destinationHubId: 3, employeeId: 5,
        shippingCost: 1500,
        shipmentDate: ISODate("2026-10-02T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-04T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-04T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 103, customerId: 1, carrierId: 3, originHubId: 2, destinationHubId: 4, employeeId: 4,
        shippingCost: 900,
        shipmentDate: ISODate("2026-10-03T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-05T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-09T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 104, customerId: 2, carrierId: 1, originHubId: 2, destinationHubId: 1, employeeId: 5,
        shippingCost: 1100,
        shipmentDate: ISODate("2026-10-04T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-06T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-06T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 105, customerId: 2, carrierId: 2, originHubId: 2, destinationHubId: 3, employeeId: 6,
        shippingCost: 1300,
        shipmentDate: ISODate("2026-10-05T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-07T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-11T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 106, customerId: 3, carrierId: 3, originHubId: 3, destinationHubId: 1, employeeId: 4,
        shippingCost: 1000,
        shipmentDate: ISODate("2026-10-06T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-08T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-12T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 107, customerId: 3, carrierId: 1, originHubId: 3, destinationHubId: 2, employeeId: 5,
        shippingCost: 850,
        shipmentDate: ISODate("2026-10-07T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-09T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-09T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 108, customerId: 4, carrierId: 4, originHubId: 4, destinationHubId: 1, employeeId: 6,
        shippingCost: 700,
        shipmentDate: ISODate("2026-10-08T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-10T00:00:00Z"),
        actualDeliveryDate: null,
        shipmentStatus: "In Transit"
    },
    {
        shipmentId: 109, customerId: 5, carrierId: 2, originHubId: 1, destinationHubId: 4, employeeId: 4,
        shippingCost: 1600,
        shipmentDate: ISODate("2026-10-09T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-11T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-15T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 110, customerId: 6, carrierId: 3, originHubId: 2, destinationHubId: 4, employeeId: 5,
        shippingCost: 950,
        shipmentDate: ISODate("2026-10-10T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-12T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-12T00:00:00Z"),
        shipmentStatus: "Delivered"
    },
    {
        shipmentId: 111, customerId: 1, carrierId: 4, originHubId: 4, destinationHubId: 3, employeeId: 6,
        shippingCost: 800,
        shipmentDate: ISODate("2026-10-11T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-13T00:00:00Z"),
        actualDeliveryDate: null,
        shipmentStatus: "In Transit"
    },
    {
        shipmentId: 112, customerId: 5, carrierId: 1, originHubId: 3, destinationHubId: 2, employeeId: 4,
        shippingCost: 1400,
        shipmentDate: ISODate("2026-10-12T00:00:00Z"),
        expectedDeliveryDate: ISODate("2026-10-14T00:00:00Z"),
        actualDeliveryDate: ISODate("2026-10-18T00:00:00Z"),
        shipmentStatus: "Delivered"
    }
]);

// 6. DELIVERY EVENTS
db.delivery_events.insertMany([
    { eventId: 1, shipmentId: 101, eventDate: ISODate("2026-10-01T09:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Chennai" },
    { eventId: 2, shipmentId: 101, eventDate: ISODate("2026-10-02T14:00:00Z"), eventDescription: "Reached transit hub", eventLocation: "Coimbatore" },
    { eventId: 3, shipmentId: 101, eventDate: ISODate("2026-10-06T10:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Coimbatore" },
    { eventId: 4, shipmentId: 102, eventDate: ISODate("2026-10-02T11:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Chennai" },
    { eventId: 5, shipmentId: 102, eventDate: ISODate("2026-10-04T16:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Madurai" },
    { eventId: 6, shipmentId: 103, eventDate: ISODate("2026-10-03T12:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Coimbatore" },
    { eventId: 7, shipmentId: 103, eventDate: ISODate("2026-10-09T15:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Salem" },
    { eventId: 8, shipmentId: 104, eventDate: ISODate("2026-10-04T09:30:00Z"), eventDescription: "Shipment picked up", eventLocation: "Coimbatore" },
    { eventId: 9, shipmentId: 104, eventDate: ISODate("2026-10-06T13:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Chennai" },
    { eventId: 10, shipmentId: 105, eventDate: ISODate("2026-10-05T10:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Coimbatore" },
    { eventId: 11, shipmentId: 105, eventDate: ISODate("2026-10-11T14:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Madurai" },
    { eventId: 12, shipmentId: 106, eventDate: ISODate("2026-10-06T11:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Madurai" },
    { eventId: 13, shipmentId: 106, eventDate: ISODate("2026-10-12T17:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Chennai" },
    { eventId: 14, shipmentId: 107, eventDate: ISODate("2026-10-07T10:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Madurai" },
    { eventId: 15, shipmentId: 107, eventDate: ISODate("2026-10-09T12:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Coimbatore" },
    { eventId: 16, shipmentId: 108, eventDate: ISODate("2026-10-08T09:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Salem" },
    { eventId: 17, shipmentId: 109, eventDate: ISODate("2026-10-09T11:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Chennai" },
    { eventId: 18, shipmentId: 109, eventDate: ISODate("2026-10-15T16:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Salem" },
    { eventId: 19, shipmentId: 110, eventDate: ISODate("2026-10-10T10:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Coimbatore" },
    { eventId: 20, shipmentId: 110, eventDate: ISODate("2026-10-12T14:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Salem" },
    { eventId: 21, shipmentId: 111, eventDate: ISODate("2026-10-11T09:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Salem" },
    { eventId: 22, shipmentId: 112, eventDate: ISODate("2026-10-12T11:00:00Z"), eventDescription: "Shipment picked up", eventLocation: "Madurai" },
    { eventId: 23, shipmentId: 112, eventDate: ISODate("2026-10-18T15:00:00Z"), eventDescription: "Shipment delivered", eventLocation: "Coimbatore" }
]);


// =====================================================
// 3. VERIFY INSERTED DATA
// =====================================================

print("\n--- HUBS ---");
printjson(db.hubs.find().toArray());

print("\n--- CARRIERS ---");
printjson(db.carriers.find().toArray());

print("\n--- CUSTOMERS ---");
printjson(db.customers.find().toArray());

print("\n--- EMPLOYEES ---");
printjson(db.employees.find().toArray());

print("\n--- SHIPMENTS ---");
printjson(db.shipments.find().toArray());

print("\n--- DELIVERY EVENTS ---");
printjson(db.delivery_events.find().toArray());


// =====================================================
// 4. AGGREGATION 1: SHIPMENTS + DELIVERY EVENTS
// =====================================================
// Business Question: Display every shipment along with its delivery events.

print("\n--- SHIPMENTS WITH DELIVERY EVENTS ---");

printjson(db.shipments.aggregate([
    {
        $lookup: {
            from: "delivery_events",
            localField: "shipmentId",
            foreignField: "shipmentId",
            as: "deliveryEvents"
        }
    },
    {
        $project: {
            _id: 0,
            shipmentId: 1,
            customerId: 1,
            carrierId: 1,
            employeeId: 1,
            shippingCost: 1,
            shipmentStatus: 1,
            deliveryEvents: 1
        }
    }
]).toArray());


// =====================================================
// 5. AGGREGATION 2: CUSTOMERS + SHIPMENTS
// =====================================================
// Business Question: Display each customer with all their shipments.

print("\n--- CUSTOMERS WITH SHIPMENTS ---");

printjson(db.customers.aggregate([
    {
        $lookup: {
            from: "shipments",
            localField: "customerId",
            foreignField: "customerId",
            as: "customerShipments"
        }
    },
    {
        $project: {
            _id: 0,
            customerId: 1,
            customerName: 1,
            city: 1,
            customerShipments: 1
        }
    }
]).toArray());


// =====================================================
// 6. AGGREGATION 3: CARRIERS + DELIVERY DELAY STATISTICS
// =====================================================
// Business Question: Calculate each carrier's total delivered shipments,
// average delay, and number of shipments delayed by more than 2 days.

print("\n--- CARRIER DELIVERY DELAY STATISTICS ---");

printjson(db.carriers.aggregate([
    {
        $lookup: {
            from: "shipments",
            let: { currentCarrierId: "$carrierId" },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $and: [
                                { $eq: ["$carrierId", "$$currentCarrierId"] },
                                { $ne: ["$actualDeliveryDate", null] }
                            ]
                        }
                    }
                },
                {
                    $addFields: {
                        delayDays: {
                            $divide: [
                                { $subtract: ["$actualDeliveryDate", "$expectedDeliveryDate"] },
                                86400000 // Convert milliseconds to days
                            ]
                        }
                    }
                },
                {
                    $group: {
                        _id: null,
                        totalDeliveredShipments: { $sum: 1 },
                        averageDelayDays: { $avg: "$delayDays" },
                        delayedShipments: {
                            $sum: {
                                $cond: [{ $gt: ["$delayDays", 2] }, 1, 0]
                            }
                        }
                    }
                }
            ],
            as: "delayStatistics"
        }
    },
    {
        $unwind: {
            path: "$delayStatistics",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $project: {
            _id: 0,
            carrierId: 1,
            carrierName: 1,
            contactNumber: 1,
            totalDeliveredShipments: { $ifNull: ["$delayStatistics.totalDeliveredShipments", 0] },
            averageDelayDays: { $ifNull: ["$delayStatistics.averageDelayDays", 0] },
            delayedShipments: { $ifNull: ["$delayStatistics.delayedShipments", 0] }
        }
    }
]).toArray());


// =====================================================
// 7. BONUS AGGREGATION (SPECIFIC TO YOUR SQL SCHEMA)
// =====================================================
// Business Question: Show employee hierarchy (Employee + Manager)
// and total shipments handled per employee.

print("\n--- EMPLOYEES WITH MANAGER & SHIPMENT COUNT ---");

printjson(db.employees.aggregate([
    {
        $lookup: {
            from: "employees",
            localField: "managerId",
            foreignField: "employeeId",
            as: "managerInfo"
        }
    },
    {
        $unwind: {
            path: "$managerInfo",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $lookup: {
            from: "shipments",
            localField: "employeeId",
            foreignField: "employeeId",
            as: "handledShipments"
        }
    },
    {
        $project: {
            _id: 0,
            employeeId: 1,
            employeeName: 1,
            designation: 1,
            managerName: { $ifNull: ["$managerInfo.employeeName", "None (Top Level)"] },
            totalShipmentsHandled: { $size: "$handledShipments" }
        }
    }
]).toArray());
