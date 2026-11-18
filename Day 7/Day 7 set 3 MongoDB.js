// =====================================================
// 1. SELECT & RESET DATABASE
// =====================================================
db = db.getSiblingDB("RetailReturnsDB");

db.stores.drop();
db.employees.drop();
db.customers.drop();
db.products.drop();
db.returns.drop();
db.refunds.drop();
db.returns_feedback.drop();


// =====================================================
// 2. CREATE COLLECTIONS AND INSERT SAMPLE DATA
// =====================================================

// 1. STORES
db.stores.insertMany([
    { storeId: 1, storeName: "Chennai T-Nagar Flagship", city: "Chennai", region: "South" },
    { storeId: 2, storeName: "Bengaluru Indiranagar", city: "Bengaluru", region: "South" },
    { storeId: 3, storeName: "Hyderabad Banjara Hills", city: "Hyderabad", region: "South" },
    { storeId: 4, storeName: "Mumbai Bandra West", city: "Mumbai", region: "West" },
    { storeId: 5, storeName: "Pune Koregaon Park", city: "Pune", region: "West" }
]);

// 2. EMPLOYEES
db.employees.insertMany([
    { employeeId: 1, employeeName: "Arvind Menon", role: "Regional Manager", storeId: 1, managerId: null },
    { employeeId: 2, employeeName: "Deepika Rao", role: "Store Manager", storeId: 1, managerId: 1 },
    { employeeId: 3, employeeName: "Sanjay Kulkarni", role: "Store Manager", storeId: 2, managerId: 1 },
    { employeeId: 4, employeeName: "Neha Gupta", role: "Returns Executive", storeId: 1, managerId: 2 },
    { employeeId: 5, employeeName: "Rohan Joshi", role: "Returns Executive", storeId: 2, managerId: 3 },
    { employeeId: 6, employeeName: "Pooja Deshmukh", role: "Store Manager", storeId: 4, managerId: null }
]);

// 3. CUSTOMERS
db.customers.insertMany([
    { customerId: 1, customerName: "Ananya Iyer", city: "Chennai" },
    { customerId: 2, customerName: "Vikram Rathore", city: "Bengaluru" },
    { customerId: 3, customerName: "Megha Nair", city: "Hyderabad" },
    { customerId: 4, customerName: "Siddharth Malhotra", city: "Mumbai" },
    { customerId: 5, customerName: "Kiran Kumar", city: "Pune" }
]);

// 4. PRODUCTS
db.products.insertMany([
    { productId: 101, productName: "Wireless Earbuds", category: "Electronics", unitPrice: 3000 },
    { productId: 102, productName: "Running Shoes", category: "Footwear", unitPrice: 4500 },
    { productId: 103, productName: "Cotton Kurta", category: "Apparel", unitPrice: 1500 },
    { productId: 104, productName: "Smart Watch", category: "Electronics", unitPrice: 8000 },
    { productId: 105, productName: "Leather Backpack", category: "Accessories", unitPrice: 5000 }
]);

// 5. RETURNS
db.returns.insertMany([
    { returnId: 501, orderId: 1001, productId: 101, customerId: 1, storeId: 1, quantityReturned: 4, returnDate: ISODate("2026-10-05T00:00:00Z"), returnReason: "Defective mic" },
    { returnId: 502, orderId: 1002, productId: 102, customerId: 2, storeId: 2, quantityReturned: 2, returnDate: ISODate("2026-10-08T00:00:00Z"), returnReason: "Size mismatch" },
    { returnId: 503, orderId: 1004, productId: 104, customerId: 4, storeId: 4, quantityReturned: 2, returnDate: ISODate("2026-10-11T00:00:00Z"), returnReason: "Screen flicker" },
    { returnId: 504, orderId: 1003, productId: 103, customerId: 3, storeId: 3, quantityReturned: 8, returnDate: ISODate("2026-10-12T00:00:00Z"), returnReason: "Color faded" },
    { returnId: 505, orderId: 1006, productId: 102, customerId: null, storeId: 1, quantityReturned: 1, returnDate: ISODate("2026-10-15T00:00:00Z"), returnReason: "Guest gift return" }
]);

// 6. REFUNDS
db.refunds.insertMany([
    { refundId: 901, returnId: 501, processedByEmployeeId: 4, refundAmount: 12000, refundDate: ISODate("2026-10-06T00:00:00Z"), refundMode: "Original Card" },
    { refundId: 902, returnId: 502, processedByEmployeeId: 5, refundAmount: 9000, refundDate: ISODate("2026-10-09T00:00:00Z"), refundMode: "UPI" },
    { refundId: 903, returnId: 503, processedByEmployeeId: 6, refundAmount: 16000, refundDate: ISODate("2026-10-13T00:00:00Z"), refundMode: "Bank Transfer" }
]);

// 7. RETURNS FEEDBACK (Post-return customer experience & CSAT survey collection)
db.returns_feedback.insertMany([
    { feedbackId: 1, returnId: 501, customerId: 1, rating: 5, comments: "Instant replacement and refund processed smoothly.", submittedAt: ISODate("2026-10-07T10:30:00Z") },
    { feedbackId: 2, returnId: 502, customerId: 2, rating: 4, comments: "Easy drop-off at Indiranagar store.", submittedAt: ISODate("2026-10-10T14:15:00Z") },
    { feedbackId: 3, returnId: 503, customerId: 4, rating: 3, comments: "Refund took 2 days, but staff was polite.", submittedAt: ISODate("2026-10-14T09:00:00Z") },
    { feedbackId: 4, returnId: 504, customerId: 3, rating: 1, comments: "Still waiting for my refund after a week!", submittedAt: ISODate("2026-10-19T18:45:00Z") }
]);


// =====================================================
// 3. PIPELINE 1: RETURNS + FEEDBACK + REFUND STATUS
// =====================================================
// Business Question: Combine every return with its customer feedback
// and refund status to identify dissatisfied customers with pending refunds.

print("\n--- PIPELINE 1: RETURNS WITH FEEDBACK & REFUND STATUS ---");

printjson(db.returns.aggregate([
    {
        $lookup: {
            from: "returns_feedback",
            localField: "returnId",
            foreignField: "returnId",
            as: "feedback"
        }
    },
    {
        $unwind: {
            path: "$feedback",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $lookup: {
            from: "refunds",
            localField: "returnId",
            foreignField: "returnId",
            as: "refund"
        }
    },
    {
        $unwind: {
            path: "$refund",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $project: {
            _id: 0,
            returnId: 1,
            productId: 1,
            returnReason: 1,
            refundStatus: {
                $cond: [{ $ifNull: ["$refund.refundId", false] }, "Refunded", "Pending Refund"]
            },
            refundAmount: { $ifNull: ["$refund.refundAmount", 0] },
            csatRating: { $ifNull: ["$feedback.rating", "No Feedback"] },
            customerComment: { $ifNull: ["$feedback.comments", "N/A"] }
        }
    }
]).toArray());


// =====================================================
// 4. PIPELINE 2: PRODUCTS + RETURNS + AVERAGE FEEDBACK RATING
// =====================================================
// Business Question: Aggregate return quantities and average post-return
// customer satisfaction ratings per product.

print("\n--- PIPELINE 2: PRODUCT RETURN VOLUME & FEEDBACK SCORE ---");

printjson(db.products.aggregate([
    {
        $lookup: {
            from: "returns",
            let: { prodId: "$productId" },
            pipeline: [
                {
                    $match: {
                        $expr: { $eq: ["$productId", "$$prodId"] }
                    }
                },
                {
                    $lookup: {
                        from: "returns_feedback",
                        localField: "returnId",
                        foreignField: "returnId",
                        as: "fb"
                    }
                },
                {
                    $unwind: {
                        path: "$fb",
                        preserveNullAndEmptyArrays: true
                    }
                },
                {
                    $project: {
                        quantityReturned: 1,
                        rating: "$fb.rating"
                    }
                }
            ],
            as: "returnRecords"
        }
    },
    {
        $project: {
            _id: 0,
            productId: 1,
            productName: 1,
            category: 1,
            totalUnitsReturned: { $sum: "$returnRecords.quantityReturned" },
            averageReturnCsat: { $ifNull: [{ $avg: "$returnRecords.rating" }, "No Returns"] }
        }
    }
]).toArray());


// =====================================================
// 5. PIPELINE 3: STORES + RETURN FEEDBACK SENTIMENT SUMMARY
// =====================================================
// Business Question: Evaluate each store's return handling performance
// using total refunds issued and average feedback rating.

print("\n--- PIPELINE 3: STORE RETURN & FEEDBACK PERFORMANCE ---");

printjson(db.stores.aggregate([
    {
        $lookup: {
            from: "returns",
            let: { stId: "$storeId" },
            pipeline: [
                {
                    $match: {
                        $expr: { $eq: ["$storeId", "$$stId"] }
                    }
                },
                {
                    $lookup: {
                        from: "returns_feedback",
                        localField: "returnId",
                        foreignField: "returnId",
                        as: "feedbackDoc"
                    }
                },
                {
                    $unwind: {
                        path: "$feedbackDoc",
                        preserveNullAndEmptyArrays: true
                    }
                },
                {
                    $lookup: {
                        from: "refunds",
                        localField: "returnId",
                        foreignField: "returnId",
                        as: "refundDoc"
                    }
                },
                {
                    $unwind: {
                        path: "$refundDoc",
                        preserveNullAndEmptyArrays: true
                    }
                },
                {
                    $project: {
                        rating: "$feedbackDoc.rating",
                        refundAmount: { $ifNull: ["$refundDoc.refundAmount", 0] }
                    }
                }
            ],
            as: "storeReturns"
        }
    },
    {
        $project: {
            _id: 0,
            storeId: 1,
            storeName: 1,
            region: 1,
            totalReturnsHandled: { $size: "$storeReturns" },
            totalRefundValue: { $sum: "$storeReturns.refundAmount" },
            avgStoreCsat: { $ifNull: [{ $avg: "$storeReturns.rating" }, "N/A"] }
        }
    },
    {
        $sort: { totalRefundValue: -1 }
    }
]).toArray());