# 🛒 Customer RFM Analysis & Segmentation Pipeline

---

**Project Type:** Customer Intelligence | BigQuery → Power BI  
**Tools:** SQL (BigQuery), Power BI, Google Cloud Platform

---

## 📌 Specifications

### Data Scope
- Monthly sales data (Jan–Dec 2025)
- Transaction-level granularity
- Key fields: CustomerID, OrderDate, OrderValue

### Methodology
- RFM framework:
  - **Recency**: days since last purchase
  - **Frequency**: number of purchases
  - **Monetary**: total spend
- Scoring method:
  - NTILE(10) decile ranking
- Output:
  - BI-ready customer segmentation table
    
---

## 📌 Business Objective

> *"To move beyond aggregate metrics and identify *which customers* to retain, to reward, and are slipping away."*

The business sells products online. While total customer count is healthy, the company lacks visibility into **purchasing behavior patterns**. This project builds an **automated RFM (Recency, Frequency, Monetary) scoring engine** to segment customers into actionable tiers—from `Champions` to `Lost/Inactive`.

---

## 🧱 SQL Pipeline (BigQuery)

### 1. Combine monthly tables
All monthly sales tables are merged into one yearly table using `UNION ALL`.

### 2. Calculate RFM(Recency, Frequency, Monetary) and RFM ranks; Combine views with CTEs

```sql
-- Calculate RFM metrics
rfm AS (
  SELECT 
    CustomerID,
    MAX(OrderDate) AS last_order_date,
    -- Recency: days since last purchase
    DATE_DIFF(
      (SELECT analysis_date FROM current_date),
      MAX(OrderDate),
      DAY
    ) AS recency,
    -- Frequency: number of orders
    COUNT(*) AS frequency,
    -- Monetary: total spending
    SUM(OrderValue) AS monetary
  FROM `rfm-analysis-493415.sales.sales_2025`
  GROUP BY CustomerID
)
-- Add ranking
SELECT
  rfm.*,
  -- Lower recency = better
  ROW_NUMBER() OVER (ORDER BY recency ASC) AS r_rank,
  -- Higher frequency = better
  ROW_NUMBER() OVER (ORDER BY frequency DESC) AS f_rank,
  -- Higher monetary = better
  ROW_NUMBER() OVER (ORDER BY monetary DESC) AS m_rank
FROM rfm;
```

### 3. RFM scoring (deciles)

```sql
CREATE OR REPLACE VIEW `rfm-analysis-493415.sales.rfm_scores` AS
SELECT 
    *,
    NTILE(10) OVER (ORDER BY r_rank DESC) AS r_score,
    NTILE(10) OVER (ORDER BY f_rank DESC) AS f_score,
    NTILE(10) OVER (ORDER BY m_rank DESC) AS m_score
FROM `rfm-analysis-493415.sales.rfm_metrics`;
```

### 4. Total RFM score

```sql
CREATE OR REPLACE VIEW `rfm-analysis-493415.sales.rfm_total_scores` AS
SELECT 
    CustomerID,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total_score
FROM `rfm-analysis-493415.sales.rfm_scores`;
```

## Dashboard Preview

The final Power BI dashboard includes:
- a total customer count card,
- a horizontal bar chart showing customer distribution by segment,
- a detailed customer table with RFM scores,
- segment-based analysis for business decision-making.

---

## Key Business Insights

From the final segmentation table and Power BI dashboard:
- The customer base is split into distinct value groups
- A small group of customers contributes disproportionately to business value
- Mid-tier customers represent the best opportunity for growth
- At-risk and inactive customers should be targeted with retention campaigns

## ✅ Recommendations for Business

| Segment | Action |
|--------|--------|
| Champions (22) | Invite to beta / early access. Reward with exclusive discount codes. |
| Loyal VIPs (41) | Cross-sell complementary products. Monthly check-in email. |
| Potential Loyalists (41) | Create loyalty incentives. |
| At Risk (38) | Focus on retention campaigns, send "We miss you" + 15% off. Time-bound (7 days). |
| Lost/Inactive (7) | Suppress from active campaigns. Re-engage via last-known channel once. |
