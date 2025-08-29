CREATE DATABASE techflow_analytics;
USE techflow_analytics;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    company_name VARCHAR(200),
    industry VARCHAR(100),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_country (country),
    INDEX idx_industry (industry),
    INDEX idx_created_at (created_at)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    product_category VARCHAR(100) NOT NULL,
    launch_date DATE NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_category (product_category),
    INDEX idx_launch_date (launch_date),
    INDEX idx_price (base_price)
);

CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_type ENUM('Free', 'Basic', 'Pro', 'Enterprise') NOT NULL,
    billing_cycle ENUM('Monthly', 'Quarterly', 'Annual') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    status ENUM('active', 'cancelled', 'expired', 'paused') DEFAULT 'active',
    monthly_revenue DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_plan_type (plan_type),
    INDEX idx_status (status),
    INDEX idx_start_date (start_date),
    INDEX idx_monthly_revenue (monthly_revenue)
);

CREATE TABLE subscription_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    added_date DATE NOT NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_subscription_id (subscription_id),
    INDEX idx_product_id (product_id),
    INDEX idx_added_date (added_date)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'Bank Transfer', 'PayPal', 'Crypto', 'Wire Transfer') NOT NULL,
    payment_status ENUM('Success', 'Failed', 'Pending', 'Refunded') NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    transaction_id VARCHAR(200) UNIQUE,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE CASCADE,
    INDEX idx_subscription_id (subscription_id),
    INDEX idx_payment_date (payment_date),
    INDEX idx_payment_status (payment_status),
    INDEX idx_amount (amount)
);

CREATE TABLE user_activities (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    activity_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activity_type ENUM('Login', 'Feature_Use', 'Support_Ticket', 'API_Call', 'Download', 'Upload') NOT NULL,
    session_duration INT DEFAULT 0,
    features_used INT DEFAULT 0,
    api_calls INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id),
    INDEX idx_activity_date (activity_date),
    INDEX idx_activity_type (activity_type)
);

SHOW TABLES;

DESCRIBE users;
DESCRIBE products;
DESCRIBE subscriptions;
DESCRIBE subscription_items;
DESCRIBE payments;
DESCRIBE user_activities;

