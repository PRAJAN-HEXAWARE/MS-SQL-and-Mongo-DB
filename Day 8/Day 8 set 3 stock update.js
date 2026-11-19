
const retailDB = db.getSiblingDB("RetailDB");

const products = retailDB.getCollection("products");

products.updateOne(
    { _id: 101 },
    {
        $setOnInsert: {
            productName: "Laptop",
            category: "Electronics",
            price: 50000,
            stock: 20
        }
    },
    { upsert: true }
);

print("Stock before reservation:");
printjson(products.findOne({ _id: 101 }));

const quantity = 2;

const result = products.updateOne(
    {
        _id: 101,
        stock: { $gte: quantity }
    },
    {
        $inc: { stock: -quantity }
    }
);

if (result.modifiedCount === 1) {
    print("Stock reserved successfully");
} else {
    print("Reservation failed: Insufficient stock");
}

print("Stock after reservation:");
printjson(products.findOne({ _id: 101 }));

const failedQuantity = 1000;

const failedResult = products.updateOne(
    {
        _id: 101,
        stock: { $gte: failedQuantity }
    },
    {
        $inc: { stock: -failedQuantity }
    }
);

if (failedResult.modifiedCount === 1) {
    print("Large stock reservation successful");
} else {
    print("Large stock reservation rejected");
    print("Insufficient stock available");
}

print("Final inventory:");
printjson(products.find().toArray());
