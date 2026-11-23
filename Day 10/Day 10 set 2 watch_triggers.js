--Mongo shell 1:

const bankDB = db.getSiblingDB("BankAuditDB");

const fraudAlerts = bankDB.getCollection("fraud_alerts");

print("==================================");
print("BANK FRAUD ALERT MONITOR");
print("==================================");

print("Monitoring new fraud alerts...");
print("Press Ctrl+C to stop.");

const changeStream = fraudAlerts.watch([
    {
        $match: {
            operationType: "insert"
        }
    }
]);

while (changeStream.hasNext()) {
    const change = changeStream.next();

    const alert = change.fullDocument;

    print("\n==================================");
    print("NEW FRAUD ALERT DETECTED");
    print("==================================");

    print("Alert ID: " + alert.alertId);
    print("Account ID: " + alert.accountId);
    print("Transaction Amount: " + alert.amount);
    print("Alert Type: " + alert.alertType);
    print("Severity: " + alert.severity);
    print("Description: " + alert.description);
    print("Detected At: " + alert.detectedAt);

    print("==================================");
}

-- Mongo shell 2 :


use BankAuditDB

db.fraud_alerts.insertMany([
    {
        alertId: 1001,
        accountId: 101,
        amount: 75000,
        alertType: "Large Transaction",
        severity: "HIGH",
        description: "Unusually large withdrawal detected",
        detectedAt: new Date()
    },
    {
        alertId: 1002,
        accountId: 105,
        amount: 45000,
        alertType: "Suspicious Activity",
        severity: "CRITICAL",
        description: "Multiple suspicious transactions detected",
        detectedAt: new Date()
    },
    {
        alertId: 1003,
        accountId: 108,
        amount: 30000,
        alertType: "Unusual Transfer",
        severity: "MEDIUM",
        description: "Transfer from an unfamiliar location",
        detectedAt: new Date()
    }
]);
