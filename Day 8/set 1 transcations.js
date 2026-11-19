
const bankDB = db.getSiblingDB("BankDB");
const accounts = bankDB.getCollection("accounts");

accounts.updateOne(
    { _id: 101 },
    {
        $setOnInsert: {
            name: "Arun",
            balance: 10000,
            status: "Active"
        }
    },
    { upsert: true }
);

accounts.updateOne(
    { _id: 102 },
    {
        $setOnInsert: {
            name: "Bala",
            balance: 5000,
            status: "Active"
        }
    },
    { upsert: true }
);

print("Balances before transfer:");
printjson(accounts.find().toArray());

const session = db.getMongo().startSession();

try {
    const transactionDB = session.getDatabase("BankDB");
    const transactionAccounts =
        transactionDB.getCollection("accounts");

    session.startTransaction();

    const debit = transactionAccounts.updateOne(
        {
            _id: 101,
            status: "Active",
            balance: { $gte: 2000 }
        },
        {
            $inc: { balance: -2000 }
        }
    );

    if (debit.modifiedCount !== 1) {
        throw new Error(
            "Debit failed: insufficient balance or inactive account"
        );
    }

    const credit = transactionAccounts.updateOne(
        {
            _id: 102,
            status: "Active"
        },
        {
            $inc: { balance: 2000 }
        }
    );

    if (credit.modifiedCount !== 1) {
        throw new Error(
            "Credit failed: receiver account not found or inactive"
        );
    }

    session.commitTransaction();

    print("Transaction committed successfully");

} catch (error) {
    if (session.inTransaction()) {
        session.abortTransaction();
    }

    print("Transaction failed: " + error.message);
    print("Transaction rolled back");

} finally {
    session.endSession();
}

print("Balances after transfer:");
printjson(accounts.find().toArray());
