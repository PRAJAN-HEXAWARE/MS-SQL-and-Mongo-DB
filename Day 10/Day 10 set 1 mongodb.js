
const retailDB = db.getSiblingDB("RetailPriceAuditDB");

const products = retailDB.getCollection("products");

const existingProducts = products.countDocuments({});

if (existingProducts === 0) {
    products.insertMany([
        {
            productId: 101,
            productName: "Laptop",
            costPrice: 42000,
            sellingPrice: 50000
        },
        {
            productId: 102,
            productName: "Mobile",
            costPrice: 16000,
            sellingPrice: 20000
        },
        {
            productId: 103,
            productName: "Headphones",
            costPrice: 1200,
            sellingPrice: 2000
        },
        {
            productId: 104,
            productName: "Shirt",
            costPrice: 600,
            sellingPrice: 1000
        }
    ]);
}

print("Products collection ready");

print("Starting MongoDB price change stream...");
print("Waiting for price updates...");

const changeStream = products.watch(
    [
        {
            $match: {
                operationType: "update",
                "updateDescription.updatedFields.sellingPrice": {
                    $exists: true
                }
            }
        }
    ],
    {
        fullDocument: "updateLookup"
    }
);

while (changeStream.hasNext()) {
    const change = changeStream.next();

    print("--------------------------------");

    print("Price change detected");

    print("Product ID:");
    print(change.fullDocument.productId);

    print("Product Name:");
    print(change.fullDocument.productName);

    print("New Selling Price:");
    print(
        change.updateDescription.updatedFields.sellingPrice
    );

    print("Change Time:");
    print(change.clusterTime);

    print("--------------------------------");
}
