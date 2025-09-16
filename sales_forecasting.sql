/*-- ✅ Always create the view in the current database and schema
CREATE OR REPLACE VIEW public.vw_sales_analysis AS
SELECT 
    f.order_id,
    f.sales,
    f.profit,
    f.discount,
    f.quantity,
    f.order_date,
    f.ship_date,
    c.customer_id,
    c.customer_name,
    c.segment       AS customer_segment,
    p.product_id,
    p.category      AS product_category,
    d.date          AS calendar_date,
    d.year          AS order_year,
    d.month         AS order_month,
    d.quarter       AS order_quarter
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_date d    ON f.order_date = d.date;
*/

--SELECT * FROM public.vw_sales_analysis LIMIT 10;

/*SELECT 
    EXTRACT(YEAR FROM f.order_date) AS order_year,
    SUM(f.sales) AS yearly_sales,
    LAG(SUM(f.sales)) OVER (ORDER BY EXTRACT(YEAR FROM f.order_date)) AS prev_year_sales,
    ROUND(
        (SUM(f.sales) - LAG(SUM(f.sales)) OVER (ORDER BY EXTRACT(YEAR FROM f.order_date))) 
        / NULLIF(LAG(SUM(f.sales)) OVER (ORDER BY EXTRACT(YEAR FROM f.order_date)), 0) * 100, 2
    ) AS yoy_growth_percent
FROM fact_sales f
GROUP BY order_year
ORDER BY order_year;
*/

/*SELECT 
    p.category,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100, 2) AS profit_margin_pct
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY profit_margin_pct DESC;
*/

WITH ranked_customers AS (
    SELECT 
        EXTRACT(YEAR FROM f.order_date) AS order_year,
        c.customer_id,
        c.customer_name,
        SUM(f.sales) AS total_sales,
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM f.order_date) ORDER BY SUM(f.sales) DESC) AS sales_rank
    FROM fact_sales f
    JOIN dim_customer c ON f.customer_id = c.customer_id
    GROUP BY order_year, c.customer_id, c.customer_name
)
SELECT *
FROM ranked_customers
WHERE sales_rank <= 5
ORDER BY order_year, sales_rank;


