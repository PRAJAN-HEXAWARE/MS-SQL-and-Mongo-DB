
const telecomDB = db.getSiblingDB("TelecomDB_Day9");

const notifications = telecomDB.getCollection("notification_log");

if (notifications.countDocuments({}) === 0) {
    notifications.insertMany([
        {
            notificationId: 1,
            subscriberId: 101,
            subscriberName: "Arun",
            message: "Low balance alert",
            isRead: false
        },
        {
            notificationId: 2,
            subscriberId: 101,
            subscriberName: "Arun",
            message: "Recharge reminder",
            isRead: false
        },
        {
            notificationId: 3,
            subscriberId: 101,
            subscriberName: "Arun",
            message: "Plan validity reminder",
            isRead: true
        },
        {
            notificationId: 4,
            subscriberId: 102,
            subscriberName: "Bala",
            message: "Low balance alert",
            isRead: false
        },
        {
            notificationId: 5,
            subscriberId: 104,
            subscriberName: "Divya",
            message: "Low balance alert",
            isRead: false
        },
        {
            notificationId: 6,
            subscriberId: 104,
            subscriberName: "Divya",
            message: "Recharge reminder",
            isRead: false
        },
        {
            notificationId: 7,
            subscriberId: 106,
            subscriberName: "Farhan",
            message: "Low balance alert",
            isRead: false
        },
        {
            notificationId: 8,
            subscriberId: 103,
            subscriberName: "Charan",
            message: "Recharge successful",
            isRead: true
        }
    ]);
}

print("All notifications:");

printjson(
    notifications.find().sort({ notificationId: 1 }).toArray()
);

const viewName = "vw_unread_notification_counts";

const pipeline = [
    {
        $match: {
            isRead: false
        }
    },
    {
        $group: {
            _id: {
                subscriberId: "$subscriberId",
                subscriberName: "$subscriberName"
            },
            UnreadCount: {
                $sum: 1
            }
        }
    },
    {
        $project: {
            _id: 0,
            SubscriberID: "$_id.subscriberId",
            SubscriberName: "$_id.subscriberName",
            UnreadCount: 1
        }
    }
];

const existingView = telecomDB.getCollectionInfos({
    name: viewName
});

if (existingView.length > 0) {
    if (existingView[0].type !== "view") {
        throw new Error(
            "A collection already exists with the view name"
        );
    }

    const result = telecomDB.runCommand({
        collMod: viewName,
        viewOn: "notification_log",
        pipeline: pipeline
    });

    if (result.ok !== 1) {
        throw new Error("Failed to update MongoDB view");
    }
} else {
    telecomDB.createView(
        viewName,
        "notification_log",
        pipeline
    );
}

print("MongoDB view created successfully");

print("Unread notification counts per subscriber:");

printjson(
    telecomDB
        .getCollection(viewName)
        .find()
        .sort({ SubscriberID: 1 })
        .toArray()
);

print("Total unread notifications:");

const unreadSummary = telecomDB
    .getCollection(viewName)
    .aggregate([
        {
            $group: {
                _id: null,
                TotalUnread: {
                    $sum: "$UnreadCount"
                }
            }
        }
    ])
    .toArray();

printjson(unreadSummary);

print("Available MongoDB views:");

printjson(
    telecomDB.getCollectionInfos({
        type: "view"
    })
);
