
-- =========================
-- Combine monthly sales tables into one yearly table 
-- =========================


CREATE OR REPLACE TABLE `rfm-analysis-493415.sales.sales_2025` AS
SELECT * FROM `rfm-analysis-493415.sales.202501`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202502`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202503`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202504`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202505`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202506`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202507`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202508`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202509`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202510`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202511`
UNION ALL
SELECT * FROM `rfm-analysis-493415.sales.202512`;

-- =========================
-- Calculate RFM(Recency, Frequency, Monetary) and RFM ranks
-- Combine views with CTEs
-- =========================


CREATE OR REPLACE VIEW `rfm-analysis-493415.sales.rfm_metrics` AS
-- Step 1: Define analysis date
WITH current_date AS (
  SELECT DATE('2026-04-16') AS analysis_date  -- today's date
),
-- Step 2: Calculate RFM metrics
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
-- Step 3: Add ranking
SELECT
  rfm.*,
  -- Lower recency = better
  ROW_NUMBER() OVER (ORDER BY recency ASC) AS r_rank,
  -- Higher frequency = better
  ROW_NUMBER() OVER (ORDER BY frequency DESC) AS f_rank,
  -- Higher monetary = better
  ROW_NUMBER() OVER (ORDER BY monetary DESC) AS m_rank
FROM rfm;

-- =========================
-- RFM scoring (deciles)
-- =========================


CREATE OR REPLACE VIEW `rfm-analysis-493415.sales.rfm_scores` AS
SELECT 
    *,
    NTILE(10) OVER (ORDER BY r_rank DESC) AS r_score,
    NTILE(10) OVER (ORDER BY f_rank DESC) AS f_score,
    NTILE(10) OVER (ORDER BY m_rank DESC) AS m_score
FROM `rfm-analysis-493415.sales.rfm_metrics`;


-- =========================
-- Total RFM score
-- =========================


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


-- =========================
-- Final segmentation table (BI ready)
-- =========================


CREATE OR REPLACE TABLE `rfm-analysis-493415.sales.rfm_segment_final` AS
SELECT
    CustomerID,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_total_score,
    CASE
        WHEN rfm_total_score >= 28 THEN 'Champions'
        WHEN rfm_total_score >= 24 THEN 'Loyal VIPs'
        WHEN rfm_total_score >= 20 THEN 'Potential Loyalists'
        WHEN rfm_total_score >= 16 THEN 'Promising'
        WHEN rfm_total_score >= 12 THEN 'Engaged'
        WHEN rfm_total_score >= 8  THEN 'Requires Attention'
        WHEN rfm_total_score >= 4  THEN 'At Risk'
        ELSE 'Lost/Inactive'
    END AS rfm_segment
FROM `rfm-analysis-493415.sales.rfm_total_scores`
ORDER BY rfm_total_score DESC;
