
-- Problem 1: How many users do we have in each country? Show top 10 countries. -- 
SELECT 
    country,
    COUNT(*) as user_count
FROM users
GROUP BY country
ORDER BY user_count DESC
LIMIT 10;

-- Problem 2: What's the total monthly revenue for each subscription plan type? --
SELECT 
    plan_type,
    COUNT(*) as subscription_count,
    SUM(monthly_revenue) as total_monthly_revenue,
    AVG(monthly_revenue) as avg_monthly_revenue
FROM subscriptions 
WHERE status = 'active'
GROUP BY plan_type
ORDER BY total_monthly_revenue DESC;

-- Problem 3: Which products are included in the most subscriptions? --
SELECT 
    p.product_name,
    p.product_category,
    COUNT(si.item_id) as subscription_count,
    SUM(si.quantity) as total_licenses
FROM products p
JOIN subscription_items si ON p.product_id = si.product_id
GROUP BY p.product_id, p.product_name, p.product_category
ORDER BY subscription_count DESC
LIMIT 15;

-- Problem 4: What's our payment success rate by payment method? --
SELECT 
    payment_method,
    COUNT(*) as total_payments,
    SUM(CASE WHEN payment_status = 'Success' THEN 1 ELSE 0 END) as successful_payments,
    ROUND(
        (SUM(CASE WHEN payment_status = 'Success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2
    ) as success_rate_percent
FROM payments
GROUP BY payment_method
ORDER BY success_rate_percent DESC;

-- Problem 5: What's the average session duration and activity count by activity type? --
SELECT 
    activity_type,
    COUNT(*) as total_activities,
    AVG(session_duration) as avg_session_minutes,
    AVG(features_used) as avg_features_used,
    AVG(api_calls) as avg_api_calls
FROM user_activities
GROUP BY activity_type
ORDER BY total_activities DESC;

-- Problem 6: Calculate the lifetime value for each customer based on all their payments --
WITH customer_clv AS (
    SELECT 
        u.user_id,
        u.first_name,
        u.last_name,
        u.company_name,
        u.country,
        COUNT(DISTINCT s.subscription_id) as total_subscriptions,
        SUM(p.amount) as lifetime_value,
        MIN(s.start_date) as first_subscription_date,
        MAX(p.payment_date) as last_payment_date
    FROM users u
    JOIN subscriptions s ON u.user_id = s.user_id
    JOIN payments p ON s.subscription_id = p.subscription_id
    WHERE p.payment_status = 'Success'
    GROUP BY u.user_id, u.first_name, u.last_name, u.company_name, u.country
)
SELECT 
    user_id,
    first_name,
    last_name,
    company_name,
    country,
    total_subscriptions,
    lifetime_value,
    first_subscription_date,
    last_payment_date,
    DATEDIFF(last_payment_date, first_subscription_date) as customer_age_days
FROM customer_clv
ORDER BY lifetime_value DESC
LIMIT 20;

-- Problem 7: Show monthly subscription growth trends over the past 2 years --
SELECT 
    DATE_FORMAT(start_date, '%Y-%m') as month_year,
    COUNT(*) as new_subscriptions,
    SUM(COUNT(*)) OVER (ORDER BY DATE_FORMAT(start_date, '%Y-%m')) as cumulative_subscriptions,
    LAG(COUNT(*), 1) OVER (ORDER BY DATE_FORMAT(start_date, '%Y-%m')) as prev_month_subs,
    CASE 
        WHEN LAG(COUNT(*), 1) OVER (ORDER BY DATE_FORMAT(start_date, '%Y-%m')) IS NOT NULL
        THEN ROUND(
            ((COUNT(*) - LAG(COUNT(*), 1) OVER (ORDER BY DATE_FORMAT(start_date, '%Y-%m'))) * 100.0 
            / LAG(COUNT(*), 1) OVER (ORDER BY DATE_FORMAT(start_date, '%Y-%m'))), 2
        )
        ELSE NULL 
    END as growth_rate_percent
FROM subscriptions
WHERE start_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
GROUP BY DATE_FORMAT(start_date, '%Y-%m')
ORDER BY month_year;

-- Problem 8: Segment customers based on Recency, Frequency, and Monetary value --
WITH rfm_metrics AS (
    SELECT 
        u.user_id,
        u.first_name,
        u.last_name,
        u.company_name,
        -- Recency: Days since last payment
        DATEDIFF(CURDATE(), MAX(p.payment_date)) as recency_days,
        -- Frequency: Number of payments
        COUNT(p.payment_id) as frequency,
        -- Monetary: Total payment amount
        SUM(p.amount) as monetary_value
    FROM users u
    JOIN subscriptions s ON u.user_id = s.user_id
    JOIN payments p ON s.subscription_id = p.subscription_id
    WHERE p.payment_status = 'Success'
        AND p.payment_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
    GROUP BY u.user_id, u.first_name, u.last_name, u.company_name
),
rfm_scores AS (
    SELECT 
        *,
        -- RFM Scoring (1-5 scale)
        CASE 
            WHEN recency_days <= 30 THEN 5
            WHEN recency_days <= 90 THEN 4
            WHEN recency_days <= 180 THEN 3
            WHEN recency_days <= 365 THEN 2
            ELSE 1
        END as recency_score,
        
        CASE 
            WHEN frequency >= 20 THEN 5
            WHEN frequency >= 15 THEN 4
            WHEN frequency >= 10 THEN 3
            WHEN frequency >= 5 THEN 2
            ELSE 1
        END as frequency_score,
        
        CASE 
            WHEN monetary_value >= 2000 THEN 5
            WHEN monetary_value >= 1000 THEN 4
            WHEN monetary_value >= 500 THEN 3
            WHEN monetary_value >= 100 THEN 2
            ELSE 1
        END as monetary_score
    FROM rfm_metrics
)
SELECT 
    user_id,
    first_name,
    last_name,
    company_name,
    recency_days,
    frequency,
    monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    CONCAT(recency_score, frequency_score, monetary_score) as rfm_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
        WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 3 THEN 'Cannot Lose Them'
        WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2 THEN 'Lost Customers'
        ELSE 'Others'
    END as customer_segment
FROM rfm_scores
ORDER BY monetary_value DESC, frequency DESC, recency_days ASC
LIMIT 100;

-- Problem 9: Prepare feature dataset for churn prediction modeling --
WITH user_features AS (
    SELECT 
        u.user_id,
        u.industry,
        u.country,
        -- Subscription features
        s.plan_type,
        s.monthly_revenue,
        s.discount_percent,
        DATEDIFF(CURDATE(), s.start_date) as subscription_age_days,
        
        -- Payment features
        COUNT(p.payment_id) as total_payments,
        SUM(CASE WHEN p.payment_status = 'Success' THEN 1 ELSE 0 END) as successful_payments,
        SUM(CASE WHEN p.payment_status = 'Failed' THEN 1 ELSE 0 END) as failed_payments,
        AVG(p.amount) as avg_payment_amount,
        DATEDIFF(CURDATE(), MAX(p.payment_date)) as days_since_last_payment,
        
        -- Activity features
        COUNT(ua.activity_id) as total_activities,
        COUNT(DISTINCT DATE(ua.activity_date)) as active_days,
        AVG(ua.session_duration) as avg_session_duration,
        SUM(ua.features_used) as total_features_used,
        SUM(ua.api_calls) as total_api_calls,
        MAX(ua.activity_date) as last_activity_date,
        
        -- Product diversity
        COUNT(DISTINCT si.product_id) as unique_products,
        
        -- Current status for labeling
        s.status as current_status,
        CASE WHEN s.status IN ('cancelled', 'expired') THEN 1 ELSE 0 END as is_churned
        
    FROM users u
    JOIN subscriptions s ON u.user_id = s.user_id
    LEFT JOIN payments p ON s.subscription_id = p.subscription_id 
                          AND p.payment_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    LEFT JOIN user_activities ua ON u.user_id = ua.user_id 
                                  AND ua.activity_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    LEFT JOIN subscription_items si ON s.subscription_id = si.subscription_id
    WHERE s.start_date <= DATE_SUB(CURDATE(), INTERVAL 3 MONTH) -- At least 3 months old
    GROUP BY u.user_id, u.industry, u.country, s.plan_type, s.monthly_revenue, 
             s.discount_percent, s.start_date, s.status
)
SELECT 
    user_id,
    industry,
    country,
    plan_type,
    monthly_revenue,
    subscription_age_days,
    CASE WHEN total_payments > 0 THEN successful_payments / total_payments ELSE 0 END as payment_success_rate,
    days_since_last_payment,
    CASE WHEN subscription_age_days > 0 THEN total_activities / subscription_age_days ELSE 0 END as activity_frequency,
    unique_products,
    CASE WHEN failed_payments >= 3 THEN 1 ELSE 0 END as high_payment_failures,
    CASE WHEN days_since_last_payment > 45 THEN 1 ELSE 0 END as payment_delay_risk,
    CASE WHEN last_activity_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END as low_activity_risk,
    is_churned as target_variable
FROM user_features
ORDER BY user_id
LIMIT 1000;  

-- Problem 10: Analyze revenue components for forecasting models --
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(p.payment_date, '%Y-%m') as month_year,
        YEAR(p.payment_date) as year,
        MONTH(p.payment_date) as month,
        SUM(p.amount) as monthly_revenue,
        COUNT(DISTINCT p.subscription_id) as active_subscriptions,
        AVG(p.amount) as avg_payment_amount
    FROM payments p
    WHERE p.payment_status = 'Success'
        AND p.payment_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
    GROUP BY DATE_FORMAT(p.payment_date, '%Y-%m'), YEAR(p.payment_date), MONTH(p.payment_date)
    ORDER BY month_year
),
revenue_trends AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY month_year) as time_period,
        LAG(monthly_revenue, 1) OVER (ORDER BY month_year) as prev_month_revenue,
        LAG(monthly_revenue, 12) OVER (ORDER BY month_year) as same_month_prev_year,
        AVG(monthly_revenue) OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_3m_avg,
        AVG(monthly_revenue) OVER (ORDER BY month_year ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as rolling_12m_avg
    FROM monthly_revenue
),
seasonal_patterns AS (
    SELECT 
        month,
        AVG(monthly_revenue) as avg_monthly_revenue,
        STDDEV(monthly_revenue) as revenue_volatility,
        COUNT(*) as data_points
    FROM revenue_trends
    GROUP BY month
)
SELECT 
    rt.month_year,
    rt.monthly_revenue,
    rt.prev_month_revenue,
    rt.same_month_prev_year,
    rt.rolling_3m_avg,
    rt.rolling_12m_avg,
    sp.avg_monthly_revenue as seasonal_baseline,
    sp.revenue_volatility,
    
    -- Growth calculations
    CASE 
        WHEN rt.prev_month_revenue > 0 THEN 
            ROUND(((rt.monthly_revenue - rt.prev_month_revenue) * 100.0 / rt.prev_month_revenue), 2)
        ELSE NULL 
    END as mom_growth_percent,
    
    CASE 
        WHEN rt.same_month_prev_year > 0 THEN 
            ROUND(((rt.monthly_revenue - rt.same_month_prev_year) * 100.0 / rt.same_month_prev_year), 2)
        ELSE NULL 
    END as yoy_growth_percent,
    
    -- Trend indicators
    CASE 
        WHEN rt.monthly_revenue > rt.rolling_3m_avg * 1.05 THEN 'Above Trend'
        WHEN rt.monthly_revenue < rt.rolling_3m_avg * 0.95 THEN 'Below Trend'  
        ELSE 'On Trend'
    END as trend_status,
    
    -- Seasonality indicators
    CASE 
        WHEN rt.monthly_revenue > sp.avg_monthly_revenue + sp.revenue_volatility THEN 'High Season'
        WHEN rt.monthly_revenue < sp.avg_monthly_revenue - sp.revenue_volatility THEN 'Low Season'
        ELSE 'Normal Season'  
    END as seasonality_status
    
FROM revenue_trends rt
JOIN seasonal_patterns sp ON rt.month = sp.month
ORDER BY rt.month_year DESC
LIMIT 20;


-- Problem 11: List the top 10 customers based on total payments received --
SELECT u.user_id, u.first_name, u.last_name, SUM(p.amount) AS lifetime_spend
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
JOIN payments p ON s.subscription_id = p.subscription_id
WHERE p.payment_status = 'Success'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY lifetime_spend DESC
LIMIT 10;


-- Problem 12: Show user subscription count and percentage increase month-over-month for the last year --
SELECT ym, subs,
       ROUND((subs - LAG(subs,1) OVER (ORDER BY ym)) / LAG(subs,1) OVER (ORDER BY ym) * 100, 2) AS pct_growth
FROM (
   SELECT DATE_FORMAT(start_date, '%Y-%m') AS ym, COUNT(*) AS subs
   FROM subscriptions
   WHERE start_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
   GROUP BY ym
   ORDER BY ym
) t;


-- Problem 13: Which two products are most commonly purchased together in the same subscription? --
SELECT p1.product_name AS product1, p2.product_name AS product2, COUNT(*) AS together_count
FROM subscription_items si1
JOIN subscription_items si2 ON si1.subscription_id = si2.subscription_id AND si1.product_id < si2.product_id
JOIN products p1 ON si1.product_id = p1.product_id
JOIN products p2 ON si2.product_id = p2.product_id
GROUP BY product1, product2
ORDER BY together_count DESC
LIMIT 5;


-- Problem 14: How many customers have churned each month in the last 12 months? --
SELECT DATE_FORMAT(end_date, '%Y-%m') AS month, COUNT(DISTINCT user_id) AS churned_users
FROM subscriptions
WHERE status IN ('cancelled', 'expired') AND end_date IS NOT NULL
AND end_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY month
ORDER BY month;


-- Problem 15: What is the total revenue attributed to each product from all subscriptions? --
SELECT pr.product_name, SUM(si.unit_price * si.quantity) AS total_revenue
FROM subscription_items si
JOIN products pr ON si.product_id = pr.product_id
GROUP BY pr.product_id, pr.product_name
ORDER BY total_revenue DESC;


-- Problem 16: Find users (top 10) with the highest average features used per activity --
SELECT u.user_id, u.first_name, u.last_name, AVG(ua.features_used) AS avg_features
FROM users u
JOIN user_activities ua ON u.user_id = ua.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY avg_features DESC
LIMIT 10;


-- Problem 17: What is the retention rate for each plan type after 6 months? --
SELECT plan_type,
       COUNT(*) AS started, 
       SUM(CASE WHEN end_date IS NULL OR DATEDIFF(end_date, start_date) >= 180 THEN 1 ELSE 0 END) AS retained_after_6m,
       ROUND(SUM(CASE WHEN end_date IS NULL OR DATEDIFF(end_date, start_date) >= 180 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS retention_pct
FROM subscriptions
WHERE start_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY plan_type;


-- Problem 18: Identify products with highest month-to-month revenue variance --
SELECT pr.product_name,
       ROUND(STDDEV(monthly_rev),2) AS revenue_volatility
FROM (
   SELECT si.product_id, DATE_FORMAT(si.added_date, '%Y-%m') AS ym,
          SUM(si.unit_price * si.quantity) AS monthly_rev
   FROM subscription_items si
   GROUP BY si.product_id, ym
) m
JOIN products pr ON m.product_id = pr.product_id
GROUP BY pr.product_name
ORDER BY revenue_volatility DESC
LIMIT 5;


-- Problem 19: On average, how long does it take users to make their first payment after subscription? --
SELECT ROUND(AVG(days_to_payment)) AS avg_days_to_payment
FROM (
    SELECT 
        u.user_id,
        DATEDIFF(MIN(p.payment_date), MIN(s.start_date)) AS days_to_payment
    FROM users u
    JOIN subscriptions s ON u.user_id = s.user_id
    JOIN payments p ON s.subscription_id = p.subscription_id
    WHERE p.payment_status = 'Success'
    AND p.payment_date >= s.start_date
    GROUP BY u.user_id
    HAVING days_to_payment >= 0
) t;


-- Problem 20: What percent of total payment revenue comes from 'Enterprise' plan subscriptions? --
SELECT ROUND(
   SUM(CASE WHEN s.plan_type='Enterprise' THEN p.amount ELSE 0 END) / SUM(p.amount) * 100, 2
) AS enterprise_revenue_pct
FROM payments p
JOIN subscriptions s ON p.subscription_id = s.subscription_id
WHERE p.payment_status = 'Success';

