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

The pipeline runs entirely in BigQuery:

```sql
1. Combine monthly tables into a yearly fact table:
   - `202501` to `202512` are merged into `sales_2025`
2. Calculate RFM metrics for each customer:
   - **Recency** = days since last order
   - **Frequency** = number of orders
   - **Monetary** = total order value
3. Rank customers into deciles
4. Create total RFM score
5. Assign final customer segments

## SQL Logic

### 1. Combine monthly tables
All monthly sales tables are merged into one yearly table using `UNION ALL`.

### 2. Compute RFM metrics
For each `CustomerID`, the query calculates:
- `recency`
- `frequency`
- `monetary`

### 3. Score customers
Each metric is converted into decile scores:
- `r_score`
- `f_score`
- `m_score`

### 4. Final segmentation
Customers are assigned to business-friendly groups such as:
- Champions
- Loyal VIPs
- Potential Loyalists
- Engaged
- Promising
- Requires Attention
- At Risk
- Lost/Inactive

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
