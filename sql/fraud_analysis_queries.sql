-- Q1: Overall Fraud Summary KPIs
SELECT
    COUNT(*) AS Total_Transactions,
    SUM(Class) AS Total_Fraud,
    ROUND(SUM(Class)*100.0/COUNT(*), 4) AS Fraud_Rate_Pct,
    ROUND(AVG(CASE WHEN Class=1 THEN Amount END), 2) AS Avg_Fraud_Amount,
    ROUND(AVG(CASE WHEN Class=0 THEN Amount END), 2) AS Avg_Legit_Amount,
    ROUND(SUM(CASE WHEN Class=1 THEN Amount ELSE 0 END), 2) AS Total_Fraud_Amount
FROM transactions;

-- Q2: Fraud Rate by Amount Bucket
SELECT
    Amount_bucket,
    COUNT(*) AS Total_Txns,
    SUM(Class) AS Fraud_Count,
    ROUND(SUM(Class)*100.0/COUNT(*), 3) AS Fraud_Rate_Pct
FROM transactions
GROUP BY Amount_bucket
ORDER BY Fraud_Rate_Pct DESC;

-- Q3: Fraud by Time of Day (Night vs Day)
SELECT
    TimeOfDay,
    COUNT(*) AS Transactions,
    SUM(Class) AS Fraud_Count,
    ROUND(SUM(Class)*100.0/COUNT(*), 3) AS Fraud_Rate_Pct
FROM transactions
GROUP BY TimeOfDay
ORDER BY Fraud_Rate_Pct DESC;

-- Q4: Fraud Rate by Hour (all 24 hours)
SELECT
    CAST(Hour AS INTEGER) AS Hour_of_Day,
    COUNT(*) AS Transactions,
    SUM(Class) AS Fraud,
    ROUND(SUM(Class)*100.0/COUNT(*),4) AS Fraud_Rate_Pct
FROM transactions
GROUP BY Hour_of_Day
ORDER BY Hour_of_Day;

-- Q5: High-Value Fraudulent Transactions (Top 20 by Amount)
SELECT
    ROUND(Amount,2) AS Amount,
    ROUND(Hour,1) AS Hour,
    TimeOfDay,
    Amount_bucket,
    V1, V2, V3, V4
FROM transactions
WHERE Class = 1
ORDER BY Amount DESC
LIMIT 20;

-- Q6: Transaction Volume Trend Over Time (hourly)
SELECT
    CAST(Hour AS INTEGER) AS Hour_of_Day,
    COUNT(*) AS Total_Transactions,
    SUM(Class) AS Fraud_Count,
    ROUND(SUM(Amount),2) AS Total_Volume
FROM transactions
GROUP BY Hour_of_Day;

-- Q7: Rapid Velocity Detection (potential card testing)
-- Transactions under $2 are classic "card testing" pattern
SELECT
    CASE WHEN Amount < 2 THEN 'Micro (<$2)'
         WHEN Amount < 10 THEN 'Small ($2-10)'
         ELSE 'Normal'
    END AS Amount_Type,
    COUNT(*) AS Count,
    SUM(Class) AS Fraud_Count,
    ROUND(SUM(Class)*100.0/COUNT(*),2) AS Fraud_Rate
FROM transactions
GROUP BY Amount_Type
ORDER BY Fraud_Rate DESC;

-- Q8: Fraud Concentration in Night Hours (11pm-5am)
SELECT
    CASE WHEN Hour >= 23 OR Hour < 5 THEN 'Late Night Risk Window'
         ELSE 'Normal Hours'
    END AS Time_Window,
    COUNT(*) AS Transactions,
    SUM(Class) AS Fraud,
    ROUND(SUM(Class)*100.0/COUNT(*),3) AS Fraud_Rate_Pct
FROM transactions
GROUP BY Time_Window;

-- Q9: Total Financial Exposure by Hour
SELECT
    CAST(Hour AS INTEGER) AS Hour_of_Day,
    ROUND(SUM(CASE WHEN Class=1 THEN Amount ELSE 0 END),2) AS Fraud_Amount_Lost
FROM transactions
GROUP BY Hour_of_Day
ORDER BY Fraud_Amount_Lost DESC
LIMIT 10;

-- Q10: Cumulative Fraud Detection (for ROC-style SQL analysis)
SELECT
    Amount_bucket,
    COUNT(*) AS Transactions,
    SUM(Class) AS Fraud,
    SUM(SUM(Class)) OVER (ORDER BY SUM(Class) DESC) AS Cumulative_Fraud
FROM transactions
GROUP BY Amount_bucket;