# 🚀 Gadget Sales Data Pipeline (CDC Architecture)

## 📌 Project Overview

This project demonstrates a real-time **Change Data Capture (CDC)** pipeline on AWS for streaming gadget sales data and performing analytics using SQL.

The pipeline captures changes from Amazon DynamoDB, streams them through Amazon EventBridge and Amazon Kinesis Data Streams, processes them using AWS Lambda, stores them in Amazon S3, catalogs metadata with AWS Glue, and enables analytics using Amazon Athena.

---

# 🏗 Architecture Overview

## 🔄 End-to-End Data Flow

1. **Python (Mock Data Generator)**  
   Generates real-time gadget sales order data.

2. **Amazon DynamoDB**  
   Stores `OrdersFactT` table and captures data changes using DynamoDB Streams.

3. **Amazon EventBridge (Pipe)**  
   Routes DynamoDB Stream events to Kinesis Data Stream.

4. **Amazon Kinesis Data Streams**  
   Handles real-time streaming ingestion.

5. **Amazon Kinesis Data Firehose**  
   Buffers and delivers streaming data to S3.

6. **AWS Lambda (Transformation Layer)**  
   Cleans and transforms streaming records before storage.

7. **Amazon S3**  
   Stores processed sales data in JSON/Parquet format.

8. **AWS Glue Crawler**  
   Automatically detects schema from S3.

9. **AWS Glue Data Catalog**  
   Creates metadata tables for querying.

10. **Amazon Athena**  
    Performs SQL-based sales analytics.

---

# 🛠 Tech Stack

- Python  
- Amazon DynamoDB  
- Amazon EventBridge  
- Amazon Kinesis Data Streams  
- Amazon Kinesis Data Firehose  
- AWS Lambda  
- Amazon S3  
- AWS Glue  
- Amazon Athena  

---

# 🗃️ Source Table (DynamoDB)

**Table Name:** `OrdersFactT`  

| Attribute Name | Data Type |
|---------------|-----------|
| orderid (PK)  | String    |
| product_name  | String    |
| quantity      | Number    |
| price         | Number    |

**Purpose:**  
Stores gadget sales order records and enables change tracking using DynamoDB Streams.

---

# 🔄 Step-by-Step Pipeline Setup

## 1️⃣ Create DynamoDB Table

- Table name: `OrdersFactT`
- Partition Key: `orderid`
- Enable **DynamoDB Streams**
- Stream view type: `NEW_AND_OLD_IMAGES`

---

## 2️⃣ Create Kinesis Data Stream

- Stream name: `kinesis-for-sales-data`
- Capacity mode: On-demand
- Retention period: 1 day

---

## 3️⃣ Configure EventBridge Pipe

- Source: DynamoDB Stream (`OrdersFactT`)
- Target: Kinesis Data Stream (`kinesis-for-sales-data`)
- Pipe name: `sales-ingestion-DynamoDB-to-kinesis`
- Status: Running

---

## 4️⃣ Monitor Kinesis Stream

- Open Kinesis → Data Viewer
- Select shard
- Choose timestamp
- Click **Get records**
- Confirm JSON order events are visible

---

## 5️⃣ Configure Firehose Delivery Stream

- Source: Kinesis Data Stream
- Destination: Amazon S3
- Format: JSON / Parquet (optional)
- Buffer interval: 60–300 seconds
- Compression: GZIP (optional)

---

## 6️⃣ Create AWS Lambda Transformation (Optional but Recommended)

- Trigger: Kinesis Firehose
- Perform:
  - Remove unwanted attributes
  - Convert data types
  - Add derived fields (e.g., total_amount = quantity × price)

---

## 7️⃣ Create AWS Glue Crawler

- Data source: S3 bucket (Firehose output path)
- Output database: `sales_database`
- Table name: `kinesis_firehose_destination_g1`
- Run crawler to create schema

---

## 8️⃣ Query Data Using Athena

Example Query:

```sql
SELECT product_name,
       SUM(quantity) AS total_units,
       SUM(quantity * price) AS total_sales
FROM kinesis_firehose_destination_g1
GROUP BY product_name
ORDER BY total_sales DESC;

