-- MongoDB Shell 1 :


const hospitalDB = db.getSiblingDB("HospitalBedDB");

const wardAlerts = hospitalDB.getCollection("ward_alerts");

print("====================================");
print("HOSPITAL WARD ALERT MONITOR");
print("====================================");

print("Monitoring CRITICAL ward alerts...");
print("Press Ctrl+C to stop.");

const changeStream = wardAlerts.watch([
    {
        $match: {
            operationType: "insert",
            "fullDocument.severity": "CRITICAL"
        }
    }
]);

while (changeStream.hasNext()) {
    const change = changeStream.next();
    const alert = change.fullDocument;

    print("\n====================================");
    print("CRITICAL WARD ALERT DETECTED");
    print("====================================");

    print("Alert ID: " + alert.alertId);
    print("Ward ID: " + alert.wardId);
    print("Ward Name: " + alert.wardName);
    print("Alert Type: " + alert.alertType);
    print("Severity: " + alert.severity);
    print("Description: " + alert.description);
    print("Detected At: " + alert.detectedAt);

    print("====================================");
}

-- MongoDB shell 2 :


use HospitalBedDB

db.ward_alerts.insertMany([
    {
        alertId: 1001,
        wardId: 101,
        wardName: "General Ward A",
        alertType: "Ward Full",
        severity: "CRITICAL",
        description: "All 5 beds are occupied",
        detectedAt: new Date()
    },
    {
        alertId: 1002,
        wardId: 103,
        wardName: "ICU Ward",
        alertType: "Capacity Warning",
        severity: "HIGH",
        description: "Only one ICU bed available",
        detectedAt: new Date()
    },
    {
        alertId: 1003,
        wardId: 104,
        wardName: "Emergency Ward",
        alertType: "Emergency Capacity",
        severity: "CRITICAL",
        description: "Emergency ward requires immediate attention",
        detectedAt: new Date()
    }
]);

