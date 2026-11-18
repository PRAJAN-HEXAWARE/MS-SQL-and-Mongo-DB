// =====================================================
// 1. SELECT & RESET DATABASE
// =====================================================
db = db.getSiblingDB("BankLoanDB");

db.branches.drop();
db.customers.drop();
db.loans.drop();
db.repayments.drop();
db.guarantors.drop();


// =====================================================
// 2. CREATE COLLECTIONS AND INSERT SAMPLE DATA
// =====================================================

// 1. BRANCHES
db.branches.insertMany([
    { branchId: 1, branchName: "Chennai Anna Salai", city: "Chennai", managerName: "Vikram" },
    { branchId: 2, branchName: "Coimbatore Race Course", city: "Coimbatore", managerName: "Meera" },
    { branchId: 3, branchName: "Madurai KK Nagar", city: "Madurai", managerName: "Senthil" },
    { branchId: 4, branchName: "Bengaluru MG Road", city: "Bengaluru", managerName: "Anand" },
    { branchId: 5, branchName: "Salem Omalur Branch", city: "Salem", managerName: "Deepa" }
]);

// 2. CUSTOMERS
db.customers.insertMany([
    { customerId: 1, customerName: "Arun Kumar", city: "Chennai", creditScore: 760, referredByCustomerId: null },
    { customerId: 2, customerName: "Priya Sharma", city: "Coimbatore", creditScore: 720, referredByCustomerId: 1 },
    { customerId: 3, customerName: "Karthik Raj", city: "Madurai", creditScore: 650, referredByCustomerId: 1 },
    { customerId: 4, customerName: "Divya Nair", city: "Bengaluru", creditScore: 810, referredByCustomerId: 2 },
    { customerId: 5, customerName: "Rahul Verma", city: "Chennai", creditScore: 690, referredByCustomerId: null },
    { customerId: 6, customerName: "Sneha Reddy", city: "Coimbatore", creditScore: 740, referredByCustomerId: 4 },
    { customerId: 7, customerName: "Mohan Das", city: "Chennai", creditScore: 790, referredByCustomerId: 1 }
]);

// 3. LOANS
db.loans.insertMany([
    {
        loanId: 101, customerId: 1, branchId: 1, loanType: "Home Loan",
        loanAmount: 2500000, interestRate: 8.5, totalInstalments: 120,
        paidInstalments: 20, dueInstalmentsTillDate: 20,
        disbursementDate: ISODate("2025-01-15T00:00:00Z"), loanStatus: "Active"
    },
    {
        loanId: 102, customerId: 1, branchId: 2, loanType: "Car Loan",
        loanAmount: 800000, interestRate: 9.25, totalInstalments: 60,
        paidInstalments: 10, dueInstalmentsTillDate: 14,
        disbursementDate: ISODate("2025-08-10T00:00:00Z"), loanStatus: "Overdue"
    },
    {
        loanId: 103, customerId: 2, branchId: 2, loanType: "Personal Loan",
        loanAmount: 500000, interestRate: 12.0, totalInstalments: 36,
        paidInstalments: 12, dueInstalmentsTillDate: 12,
        disbursementDate: ISODate("2025-10-01T00:00:00Z"), loanStatus: "Active"
    },
    {
        loanId: 104, customerId: 2, branchId: 4, loanType: "Business Loan",
        loanAmount: 1500000, interestRate: 11.0, totalInstalments: 48,
        paidInstalments: 8, dueInstalmentsTillDate: 13,
        disbursementDate: ISODate("2025-09-05T00:00:00Z"), loanStatus: "Overdue"
    },
    {
        loanId: 105, customerId: 3, branchId: 3, loanType: "Education Loan",
        loanAmount: 600000, interestRate: 9.0, totalInstalments: 60,
        paidInstalments: 15, dueInstalmentsTillDate: 19,
        disbursementDate: ISODate("2025-03-20T00:00:00Z"), loanStatus: "Overdue"
    },
    {
        loanId: 106, customerId: 4, branchId: 4, loanType: "Home Loan",
        loanAmount: 3200000, interestRate: 8.4, totalInstalments: 180,
        paidInstalments: 24, dueInstalmentsTillDate: 24,
        disbursementDate: ISODate("2024-11-01T00:00:00Z"), loanStatus: "Active"
    },
    {
        loanId: 107, customerId: 5, branchId: 1, loanType: "Personal Loan",
        loanAmount: 400000, interestRate: 13.5, totalInstalments: 24,
        paidInstalments: 10, dueInstalmentsTillDate: 12,
        disbursementDate: ISODate("2025-11-10T00:00:00Z"), loanStatus: "Overdue"
    },
    {
        loanId: 108, customerId: 6, branchId: 3, loanType: "Gold Loan",
        loanAmount: 300000, interestRate: 9.5, totalInstalments: 12,
        paidInstalments: 12, dueInstalmentsTillDate: 12,
        disbursementDate: ISODate("2025-11-01T00:00:00Z"), loanStatus: "Closed"
    }
]);

// 4. REPAYMENTS (Includes multiple repayments per loan to test "last repayment" logic)
db.repayments.insertMany([
    { repaymentId: 1, loanId: 101, paymentDate: ISODate("2026-10-25T00:00:00Z"), amountPaid: 28000, paymentMode: "NEFT" },
    { repaymentId: 2, loanId: 101, paymentDate: ISODate("2026-11-10T00:00:00Z"), amountPaid: 28000, paymentMode: "NEFT" },
    { repaymentId: 3, loanId: 102, paymentDate: ISODate("2026-07-15T00:00:00Z"), amountPaid: 16500, paymentMode: "UPI" },
    { repaymentId: 4, loanId: 103, paymentDate: ISODate("2026-10-05T00:00:00Z"), amountPaid: 16600, paymentMode: "Auto-Debit" },
    { repaymentId: 5, loanId: 103, paymentDate: ISODate("2026-11-05T00:00:00Z"), amountPaid: 16600, paymentMode: "Auto-Debit" },
    { repaymentId: 6, loanId: 104, paymentDate: ISODate("2026-06-10T00:00:00Z"), amountPaid: 38500, paymentMode: "RTGS" },
    { repaymentId: 7, loanId: 105, paymentDate: ISODate("2026-07-20T00:00:00Z"), amountPaid: 12400, paymentMode: "UPI" },
    { repaymentId: 8, loanId: 106, paymentDate: ISODate("2026-10-12T00:00:00Z"), amountPaid: 31200, paymentMode: "Auto-Debit" },
    { repaymentId: 9, loanId: 106, paymentDate: ISODate("2026-11-12T00:00:00Z"), amountPaid: 31200, paymentMode: "Auto-Debit" },
    { repaymentId: 10, loanId: 107, paymentDate: ISODate("2026-09-01T00:00:00Z"), amountPaid: 19100, paymentMode: "NEFT" },
    { repaymentId: 11, loanId: 108, paymentDate: ISODate("2026-08-15T00:00:00Z"), amountPaid: 26500, paymentMode: "Cash" }
]);

// 5. GUARANTORS
db.guarantors.insertMany([
    { guarantorRecordId: 1, loanId: 102, guarantorCustomerId: 2, relationship: "Colleague" },
    { guarantorRecordId: 2, loanId: 104, guarantorCustomerId: 1, relationship: "Business Partner" },
    { guarantorRecordId: 3, loanId: 105, guarantorCustomerId: 4, relationship: "Cousin" },
    { guarantorRecordId: 4, loanId: 107, guarantorCustomerId: 7, relationship: "Friend" }
]);


// =====================================================
// 3. PIPELINE 1: LOANS + CUSTOMER & BRANCH DETAILS
// =====================================================
// Business Question: Display every loan enriched with its borrower's
// profile and sanctioning branch details.

print("\n--- PIPELINE 1: LOANS WITH CUSTOMER & BRANCH DETAILS ---");

printjson(db.loans.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "customerId",
            foreignField: "customerId",
            as: "customerDetails"
        }
    },
    {
        $unwind: "$customerDetails"
    },
    {
        $lookup: {
            from: "branches",
            localField: "branchId",
            foreignField: "branchId",
            as: "branchDetails"
        }
    },
    {
        $unwind: "$branchDetails"
    },
    {
        $project: {
            _id: 0,
            loanId: 1,
            loanType: 1,
            loanAmount: 1,
            loanStatus: 1,
            customerName: "$customerDetails.customerName",
            customerCity: "$customerDetails.city",
            creditScore: "$customerDetails.creditScore",
            branchName: "$branchDetails.branchName"
        }
    }
]).toArray());


// =====================================================
// 4. PIPELINE 2: CUSTOMERS + LOANS + REPAYMENT SUMMARY
// =====================================================
// Business Question: Display each customer with all their loans
// and total amount repaid across their portfolio.

print("\n--- PIPELINE 2: CUSTOMERS WITH LOANS & TOTAL REPAID ---");

printjson(db.customers.aggregate([
    {
        $lookup: {
            from: "loans",
            let: { custId: "$customerId" },
            pipeline: [
                {
                    $match: {
                        $expr: { $eq: ["$customerId", "$$custId"] }
                    }
                },
                {
                    $lookup: {
                        from: "repayments",
                        localField: "loanId",
                        foreignField: "loanId",
                        as: "repaymentHistory"
                    }
                },
                {
                    $addFields: {
                        totalRepaidForLoan: { $sum: "$repaymentHistory.amountPaid" }
                    }
                },
                {
                    $project: {
                        _id: 0,
                        loanId: 1,
                        loanType: 1,
                        loanAmount: 1,
                        loanStatus: 1,
                        totalRepaidForLoan: 1
                    }
                }
            ],
            as: "loans"
        }
    },
    {
        $project: {
            _id: 0,
            customerId: 1,
            customerName: 1,
            city: 1,
            totalExposure: { $sum: "$loans.loanAmount" },
            totalRepaidPortfolio: { $sum: "$loans.totalRepaidForLoan" },
            loans: 1
        }
    }
]).toArray());


// =====================================================
// 5. PIPELINE 3: LOANS + LAST REPAYMENT PER LOAN
// =====================================================
// Business Question: Return every loan along with its customer name
// and only the most recent (last) repayment record.

print("\n--- PIPELINE 3: LOANS WITH LAST REPAYMENT ---");

printjson(db.loans.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "customerId",
            foreignField: "customerId",
            as: "customer"
        }
    },
    {
        $unwind: "$customer"
    },
    {
        $lookup: {
            from: "repayments",
            let: { currentLoanId: "$loanId" },
            pipeline: [
                {
                    $match: {
                        $expr: { $eq: ["$loanId", "$$currentLoanId"] }
                    }
                },
                {
                    // Sort descending by paymentDate (and repaymentId as tie-breaker)
                    $sort: { paymentDate: -1, repaymentId: -1 }
                },
                {
                    // Keep only the single latest repayment
                    $limit: 1
                },
                {
                    $project: {
                        _id: 0,
                        repaymentId: 1,
                        paymentDate: 1,
                        amountPaid: 1,
                        paymentMode: 1
                    }
                }
            ],
            as: "lastRepayment"
        }
    },
    {
        $unwind: {
            path: "$lastRepayment",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $project: {
            _id: 0,
            loanId: 1,
            customerName: "$customer.customerName",
            loanType: 1,
            loanAmount: 1,
            loanStatus: 1,
            lastRepayment: { $ifNull: ["$lastRepayment", "No Repayments Recorded"] }
        }
    }
]).toArray());