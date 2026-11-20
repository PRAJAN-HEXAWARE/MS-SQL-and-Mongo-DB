
const insuranceDB = db.getSiblingDB("InsuranceDB_Day9");

const complaints = insuranceDB.getCollection("complaints");

if (complaints.countDocuments({}) === 0) {
    complaints.insertMany([
        {
            complaintId: 101,
            customerId: 101,
            customerName: "Arun",
            policyId: 1001,
            complaintType: "Premium Issue",
            complaintStatus: "Open",
            priority: "High"
        },
        {
            complaintId: 102,
            customerId: 102,
            customerName: "Bala",
            policyId: 1002,
            complaintType: "Policy Renewal",
            complaintStatus: "Resolved",
            priority: "Medium"
        },
        {
            complaintId: 103,
            customerId: 103,
            customerName: "Charan",
            policyId: 1003,
            complaintType: "Claim Delay",
            complaintStatus: "Pending",
            priority: "High"
        },
        {
            complaintId: 104,
            customerId: 104,
            customerName: "Divya",
            policyId: 1004,
            complaintType: "Payment Failure",
            complaintStatus: "Open",
            priority: "Medium"
        },
        {
            complaintId: 105,
            customerId: 105,
            customerName: "Esha",
            policyId: 1005,
            complaintType: "Claim Settlement",
            complaintStatus: "Resolved",
            priority: "Low"
        },
        {
            complaintId: 106,
            customerId: 106,
            customerName: "Farhan",
            policyId: 1006,
            complaintType: "Premium Calculation",
            complaintStatus: "In Progress",
            priority: "High"
        }
    ]);
}

print("All customer complaints:");

printjson(
    complaints.find().sort({ complaintId: 1 }).toArray()
);

const viewName = "vw_unresolved_complaints";

const pipeline = [
    {
        $match: {
            complaintStatus: {
                $in: ["Open", "Pending", "In Progress"]
            }
        }
    },
    {
        $project: {
            _id: 0,
            complaintId: 1,
            customerId: 1,
            customerName: 1,
            policyId: 1,
            complaintType: 1,
            complaintStatus: 1,
            priority: 1
        }
    }
];

const existingView = insuranceDB.getCollectionInfos({
    name: viewName
});

if (existingView.length > 0) {
    if (existingView[0].type !== "view") {
        throw new Error(
            "A collection already exists with this view name"
        );
    }

    insuranceDB.runCommand({
        collMod: viewName,
        viewOn: "complaints",
        pipeline: pipeline
    });
} else {
    insuranceDB.createView(
        viewName,
        "complaints",
        pipeline
    );
}

print("MongoDB view created successfully");

print("Unresolved customer complaints:");

printjson(
    insuranceDB
        .getCollection(viewName)
        .find()
        .sort({ complaintId: 1 })
        .toArray()
);

print("Total unresolved complaints:");

print(
    insuranceDB
        .getCollection(viewName)
        .countDocuments({})
);

print("Available MongoDB views:");

printjson(
    insuranceDB.getCollectionInfos({
        type: "view"
    })
);
