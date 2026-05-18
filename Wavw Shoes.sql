
/* =========================================================
   1. OVERALL BUSINESS PERFORMANCE
   ========================================================= */

SELECT
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(AVG(`profit_margin_%`), 2) AS avg_profit_margin,
    SUM(quantity) AS total_quantity_sold,
    COUNT(DISTINCT customer_name) AS total_customers,
    COUNT(DISTINCT product) AS total_products
FROM Fact_Sales;


/* =========================================================
   2. MONTHLY REVENUE & PROFIT TREND
   ========================================================= */

SELECT
    DATE_FORMAT(order_date,'%Y-%m') AS month_,
    SUM(sales_amount) AS revenue,
    SUM(profit) AS profit,
    ROUND(AVG(`profit_margin_%`),2) AS avg_profit_margin
FROM Fact_Sales
GROUP BY month_
ORDER BY month_;


/* =========================================================
   3. TOP SELLING PRODUCTS
   ========================================================= */

SELECT
    product,
    category,
    SUM(quantity) AS quantity_sold,
    SUM(sales_amount) AS revenue,
    SUM(profit) AS profit
FROM Fact_Sales
GROUP BY product, category
ORDER BY revenue DESC
LIMIT 10;


/* =========================================================
   4. CATEGORY PERFORMANCE
   ========================================================= */

SELECT
    category,
    SUM(quantity) AS quantity_sold,
    SUM(cost) AS total_cost,
    SUM(sales_amount) AS total_sales,
    SUM(profit) AS total_profit
FROM Fact_Sales
GROUP BY category
ORDER BY total_sales DESC;


/* =========================================================
   5. BEST CUSTOMERS
   ========================================================= */

SELECT
    customer_name,
    city,
    state,
    COUNT(order_number) AS total_orders,
    SUM(quantity) AS quantity_purchased,
    SUM(sales_amount) AS total_spent,
    SUM(profit) AS total_profit
FROM Fact_Sales
GROUP BY customer_name, city, state
ORDER BY total_spent DESC
LIMIT 10;


/* =========================================================
   6. CITY WISE SALES ANALYSIS
   ========================================================= */

SELECT
    city,
    state,
    SUM(quantity) AS quantity_sold,
    SUM(sales_amount) AS revenue,
    SUM(profit) AS profit,
    COUNT(DISTINCT customer_name) AS customers
FROM Fact_Sales
GROUP BY city, state
ORDER BY revenue DESC;


/* =========================================================
   7. ONLINE VS OFFLINE SALES
   ========================================================= */

SELECT
    order_type,
    COUNT(order_number) AS total_orders,
    SUM(quantity) AS quantity_sold,
    SUM(sales_amount) AS revenue,
    SUM(cost) AS total_cost,
    SUM(profit) AS total_profit
FROM Fact_Sales
GROUP BY order_type;


/* =========================================================
   8. TOP PROFITABLE PRODUCTS
   ========================================================= */

SELECT
    product,
    SUM(profit) AS total_profit,
    ROUND(AVG(`profit_margin_%`),2) AS avg_profit_margin
FROM Fact_Sales
GROUP BY product
ORDER BY total_profit DESC
LIMIT 10;


/* =========================================================
   9. LOW PROFIT PRODUCTS
   ========================================================= */

SELECT
    product,
    SUM(profit) AS total_profit,
    ROUND(AVG(`profit_margin_%`),2) AS avg_profit_margin
FROM Fact_Sales
GROUP BY product
ORDER BY avg_profit_margin ASC;


/* =========================================================
   10. MONTH OVER MONTH GROWTH
   ========================================================= */

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_date,'%Y-%m') AS month_,
        SUM(sales_amount) AS revenue
    FROM Fact_Sales
    GROUP BY month_
)

SELECT
    month_,
    revenue,

    LAG(revenue) OVER(ORDER BY month_) AS previous_month_revenue,

    ROUND(
        (
            revenue - LAG(revenue) OVER(ORDER BY month_)
        )
        /
        LAG(revenue) OVER(ORDER BY month_) * 100,
        2
    ) AS mom_growth_percentage

FROM monthly_sales;


/* =========================================================
   11. RUNNING SALES TREND
   ========================================================= */

WITH monthly_sales AS
(
    SELECT
        DATE_FORMAT(order_date,'%Y-%m') AS month_,
        SUM(sales_amount) AS revenue
    FROM Fact_Sales
    GROUP BY month_
)

SELECT
    month_,
    revenue,
    SUM(revenue) OVER(ORDER BY month_) AS running_revenue
FROM monthly_sales;


/* =========================================================
   12. SALES CONTRIBUTION BY CATEGORY
   ========================================================= */

SELECT
    category,
    SUM(sales_amount) AS revenue,

    ROUND(
        (
            SUM(sales_amount)
            /
            (SELECT SUM(sales_amount) FROM Fact_Sales)
        ) * 100,
        2
    ) AS contribution_percentage

FROM Fact_Sales
GROUP BY category
ORDER BY revenue DESC;


/* =========================================================
   13. TOP 5 PRODUCTS IN EACH CATEGORY
   ========================================================= */

WITH product_rank AS
(
    SELECT
        category,
        product,
        SUM(sales_amount) AS revenue,

        RANK() OVER
        (
            PARTITION BY category
            ORDER BY SUM(sales_amount) DESC
        ) AS rnk

    FROM Fact_Sales
    GROUP BY category, product
)

SELECT *
FROM product_rank
WHERE rnk <= 5;


/* =========================================================
   14. DAILY SALES PERFORMANCE
   ========================================================= */

SELECT
    order_date,
    SUM(quantity) AS quantity_sold,
    SUM(sales_amount) AS revenue,
    SUM(profit) AS profit
FROM Fact_Sales
GROUP BY order_date
ORDER BY order_date;


/* =========================================================
   15. WEEKDAY SALES ANALYSIS
   ========================================================= */

SELECT
    DAYNAME(order_date) AS weekday_name,
    SUM(sales_amount) AS revenue,
    SUM(profit) AS profit
FROM Fact_Sales
GROUP BY weekday_name
ORDER BY revenue DESC;