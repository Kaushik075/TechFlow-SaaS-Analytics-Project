# TechFlow-SaaS-Analytics-Project

---

## Overview

This project demonstrates advanced SQL techniques on a large-scale SaaS subscription analytics dataset. It covers user, subscription, payment, product, and user activity data with over 1,000,000 synthetic records designed for real-world business insights.

---

## Project Objective

To analyze SaaS subscription lifecycle, revenue metrics, user engagement, customer segmentation, churn risk, and product performance using complex SQL queries that drive actionable business decisions 

---


## Data Sources and Schema

- `users`: Customer demographics and company info  
- `subscriptions`: Subscription start/end dates, plan types, revenue  
- `subscription_items`: Products within each subscription  
- `payments`: Payment history linked to subscriptions  
- `products`: Product catalog info  
- `user_activities`: Detailed user engagement data by product  

Refer to the database schema and relationships diagram for details.

---

## Key Features

- Data generation of over 1 million realistic SaaS data points using Python and Faker  
- Advanced SQL queries with window functions, CTEs, joins, and aggregates  
- Business-focused questions covering acquisition, growth, retention, and monetization  
- Emphasis on query performance on large datasets  
- Clear documentation and explanations for each problem addressed  

---

## Business Questions

### 1 - 10

- How many users do we have in each country? Show top 10 countries.  
- What’s the total monthly revenue for each subscription plan type?  
- Which products are included in the most subscriptions?  
- What’s the payment success rate by payment method?  
- Average session duration and activity count by activity type?  
- Calculate customer lifetime value from payments.  
- Monthly subscription growth trends over 2 years.  
- Customer segmentation based on Recency, Frequency, and Monetary value.  
- Prepare feature dataset for churn prediction.  
- Analyze revenue components for forecasting.  

### 11 - 20

- List top 10 customers by total payments received.  
- Show subscription count and growth month-over-month for last year.  
- Products frequently purchased together.  
- Monthly churn counts for past year.  
- Revenue attributed per product.  
- Top users by average features used.  
- Retention rate by plan type after 6 months.  
- Products with highest revenue volatility.  
- Average days to first payment post-subscription.  
- Enterprise plan revenue share percentage.  

---

## Prerequisites

- MySQL Server and Workbench installed  
- Python 3 with packages: `mysql-connector-python`, `faker`, `pandas`, `numpy`  

---

## Setup & Data Generation

- Run the SQL schema scripts in MySQL Workbench  
- Execute the Python data generation scripts to insert synthetic data  
- Validate data using sample count queries  

---

## How to Use

- Explore each business question via provided clean, documented SQL queries  
- Modify queries for further analysis or custom insights  
- Use project materials as portfolio evidence of your SQL expertise  

---

## Project Structure
├── schema/ # SQL DDL scripts
├── data_generation/ # Python data generation scripts
├── queries/ # SQL query files & problem statements
├── docs/ # Documentation & ER diagrams
└── README.md # This file

---

## Table Relationships

users (1) ──── (M) subscriptions (1) ──── (M) subscription_items
│ │
│ └── (M) payments
│
└── (M) user_activities (M) ──── (1) products

---

## Contribution

Feel free to fork, modify, and submit pull requests. Contact for collaboration or feedback.


--- 


