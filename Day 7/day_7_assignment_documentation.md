# Day 7 Assignment – Joins, Subqueries, and Lookups (SQL Server 2025 & MongoDB 8.0)

**Track:** Python Track (Mavericks Segue 2026)  
**Topics Covered:** Equi & Self Joins · Subqueries (`IN`, `EXISTS`, `ANY`, `ALL`) · Nested Subqueries · MongoDB `$lookup` Pipelines  

---

## Repository Structure

```text
├── Set1_Logistics_Shipment_Analysis/
│   ├── schema_and_data.sql       # LogisticsDB schema & seed data
│   ├── advanced_reports.sql      # 10 join queries, subqueries & nested subquery
│   └── reports.js                # MongoDB $lookup pipelines for shipments, customers & carriers
│
├── Set2_Bank_Loan_Portfolio/
│   ├── schema_and_data.sql       # BankLoanDB schema & seed data
│   ├── advanced_reports.sql      # 10 join queries, correlated/uncorrelated subqueries, EXISTS/NOT EXISTS
│   └── reports.js                # MongoDB $lookup pipelines including last repayment per loan
│
├── Set3_Retail_Returns_Refunds/
│   ├── schema_and_data.sql       # RetailReturnsDB schema & seed data
│   ├── advanced_reports.sql      # 10 join queries, NOT IN NULL pitfall & NOT EXISTS fix, ANY/ALL
│   └── reports.js                # MongoDB $lookup pipelines on returns_feedback collection
│
└── README.md                     # Setup instructions & architectural notes across all 3 sets
```

---

## How to Run the Scripts

### 1. SQL Server (SSMS)
1. Open **SQL Server Management Studio (SSMS)** and connect to your local SQL Server instance.
2. Open and execute `schema_and_data.sql` for the desired set to create the database (`LogisticsDB`, `BankLoanDB`, or `RetailReturnsDB`) and populate sample records.
3. Open and execute `advanced_reports.sql` to view the output for all tasks.

### 2. MongoDB (`mongosh`)
1. Ensure your local MongoDB server (`mongod`) is running on the default port (`27017`).
2. Run the corresponding `reports.js` file from your terminal:
   ```bash
   mongosh reports.js
   ```
   Or load it from inside an active `mongosh` session:
   ```javascript
   load("reports.js")
   ```

---

## Set 1 – Logistics Shipment Analysis (`LogisticsDB`)

### Schema Overview
* **Tables/Collections:** `Hubs`, `Carriers`, `Customers`, `Employees` (self-referencing `ManagerID`), `Shipments`, `DeliveryEvents`.

### Key Deliverables & Highlights
1. **Joins (10 Business Questions):**
   * `INNER JOIN` for matching active shipments with carrier and hub names (e.g., shipments delayed $> 2$ days).
   * `LEFT JOIN` to detect hubs with zero outbound shipments and shipments without delivery events.
   * `SELF JOIN` on `Employees` (`e.ManagerID = m.EmployeeID`) to display employees alongside their supervisors.
   * `FULL OUTER JOIN` for complete reconciliation between hubs and shipments.
2. **Subqueries (`IN`, `EXISTS`, `ANY`, `ALL`):**
   * Double-negation `NOT EXISTS` to find customers who have shipped to every hub.
   * `HAVING AVG(...) > (SELECT AVG(...))` to identify carriers whose average delivery delay exceeds the fleet-wide average.
3. **Nested Subquery:**
   * Computed the **second-highest shipping cost per hub** using a correlated `MAX(ShippingCost)` strictly less than the outer hub's `MAX(ShippingCost)`.
4. **MongoDB `$lookup` & Embedding vs. Referencing Note:**
   * Built pipelines joining `shipments` with `delivery_events`, `customers` with `shipments`, and `carriers` with calculated delay statistics (`$subtract` on `ISODate` fields divided by `86400000` ms/day).
   * **When Embedding is Better than `$lookup`:** Because a shipment generates a small, bounded number of tracking scans (`DeliveryEvents`, typically 3–10 events) that are always queried together on a tracking page and never updated independently across shipments, embedding `deliveryEvents` as an array inside each `shipments` document eliminates `$lookup` overhead and guarantees single-document read performance.

---

## Set 2 – Bank Loan Portfolio (`BankLoanDB`)

### Schema Overview
* **Tables/Collections:** `Branches`, `Customers` (self-referencing `ReferredByCustomerID`), `Loans`, `Repayments`, `Guarantors`.

### Key Deliverables & Highlights
1. **Join-Selection Note:**
   * **`INNER JOIN`:** Chosen when filtering matched records across core entities—such as loans overdue by $> 3$ instalments (`DueInstalmentsTillDate - PaidInstalments > 3`) and customers holding loans across multiple branches (`COUNT(DISTINCT BranchID) > 1`).
   * **`SELF JOIN`:** Used on `Customers` to map customer referral hierarchies (`ReferredByCustomerID`) and on `Guarantors` joined back to `Loans` to identify guarantors who are also active borrowers (`Arun Kumar`, `Priya Sharma`, `Divya Nair`).
   * **`LEFT JOIN`:** Used with `WHERE LoanID IS NULL` to isolate branches with zero sanctioned loans (`Salem Omalur Branch`) and customers who only act as guarantors (`Mohan Das`).
   * **`FULL OUTER JOIN`:** Used to audit all branches and all loans simultaneously without dropping unmatched branches.
2. **Correlated vs. Uncorrelated Subqueries:**
   * Compared customer loan exposure against their branch's average loan size using both a correlated subquery (`WHERE l2.BranchID = l.BranchID`) and an uncorrelated derived-table join.
3. **`EXISTS` & `NOT EXISTS`:**
   * Isolated customers who hold a loan (`EXISTS`) but have made no repayment within the last 60 days (`NOT EXISTS` with `DATEADD(DAY, -60, GETDATE())`).
4. **Nested Subquery:**
   * Found branches whose maximum loan exceeds the bank-wide average of branch maximums (`Chennai Anna Salai` and `Bengaluru MG Road`).
5. **MongoDB `$lookup` Pipelines:**
   * Implemented three pipelines, including a correlated `$lookup` sub-pipeline with `$sort: { paymentDate: -1 }` and `$limit: 1` to fetch only the **most recent repayment** for every loan.

---

## Set 3 – Retail Returns and Refunds (`RetailReturnsDB`)

### Schema Overview
* **Tables/Collections:** `Stores`, `Employees` (self-referencing `ManagerID`), `Customers`, `Products`, `Orders`, `OrderItems`, `Returns`, `Refunds`, and `returns_feedback` (MongoDB).

### Key Deliverables & Highlights
1. **Joins & Subquery Choices:**
   * Calculated product return rates ($> 10\%$), identified customers with pending refunds (`Megha Nair`), ranked stores by refund value, and mapped employee-manager reporting chains via `SELF JOIN`.
   * Used `> ALL (...)` and `> ANY (...)` to benchmark each store's total refunds against peer stores within the same region (`South` vs. `West`).
2. **The `NOT IN` `NULL` Pitfall & `NOT EXISTS` Fix:**
   * `Returns` includes an anonymous guest return (`ReturnID 505`) where `CustomerID IS NULL`.
   * Running `WHERE CustomerID NOT IN (SELECT CustomerID FROM Returns)` evaluates `CustomerID <> NULL` as `UNKNOWN` under SQL's three-valued logic, returning **0 rows**.
   * Rewriting the filter with `NOT EXISTS` safely checks row presence and accurately returns `Kiran Kumar` (`CustomerID 5`).
3. **MongoDB `$lookup` on `returns_feedback` vs. SQL Server Joins:**
   * Created three pipelines combining `returns`, `returns_feedback`, `refunds`, `products`, and `stores` to compute post-return CSAT ratings alongside refund status.
   * `$lookup` + `$unwind: { preserveNullAndEmptyArrays: true }` mirrors SQL's `LEFT OUTER JOIN`, whereas standard `$unwind` mirrors an `INNER JOIN`. For `1:1` post-return feedback and refunds, embedding both subdocuments inside `returns` simplifies queries and avoids multi-collection joins.