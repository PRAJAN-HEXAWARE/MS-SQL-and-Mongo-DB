
const retailDB = db.getSiblingDB("RetailDB_Day9");

const orders = retailDB.getCollection("orders");

if (orders.countDocuments({}) === 0) {
    orders.insertMany([
        {
            orderId: 101,
            customerName: "Arun",
            orderStatus: "Pending",
            orderAmount: 50000
        },
        {
            orderId: 102,
            customerName: "Bala",
            orderStatus: "Pending",
            orderAmount: 40000
        },
        {
            orderId: 103,
            customerName: "Charan",
            orderStatus: "Completed",
            orderAmount: 3000
        },
        {
            orderId: 104,
            customerName: "Divya",
            orderStatus: "Completed",
            orderAmount: 4000
        },
        {
            orderId: 105,
            customerName: "Esha",
            orderStatus: "Cancelled",
            orderAmount: 2000
        },
        {
            orderId: 106,
            customerName: "Farhan",
            orderStatus: "Pending",
            orderAmount: 6000
        }
    ]);
}

print("Orders collection:");
printjson(orders.find().toArray());

const viewName = "vw_order_status_counts";

const existingView = retailDB.getCollectionInfos({
    name: viewName
});

if (existingView.length > 0) {
    if (existingView[0].type !== "view") {
        throw new Error(
            "A collection already exists with the view name"
        );
    }

    retailDB.runCommand({
        collMod: viewName,
        viewOn: "orders",
        pipeline: [
            {
                $group: {
                    _id: "$orderStatus",
                    TotalOrders: { $sum: 1 }
                }
            },
            {
                $project: {
                    _id: 0,
                    OrderStatus: "$_id",
                    TotalOrders: 1
                }
            }
        ]
    });
} else {
    retailDB.createView(
        viewName,
        "orders",
        [
            {
                $group: {
                    _id: "$orderStatus",
                    TotalOrders: { $sum: 1 }
                }
            },
            {
                $project: {
                    _id: 0,
                    OrderStatus: "$_id",
                    TotalOrders: 1
                }
            }
        ]
    );
}

print("MongoDB view created successfully");

print("Order status summary:");

printjson(
    retailDB
        .getCollection(viewName)
        .find()
        .sort({ OrderStatus: 1 })
        .toArray()
);

print("Available views:");

printjson(
    retailDB.getCollectionInfos({
        type: "view"
    })
);
