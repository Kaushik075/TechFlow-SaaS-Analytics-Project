import mysql.connector
from faker import Faker
import random
import pandas as pd
from datetime import datetime, timedelta
import numpy as np

# Initialize Faker
fake = Faker()
fake.seed_instance(42)  # For reproducible data

# MySQL connection configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',  
    'password': 'kaushikyeddanapudi_75',  
    'database': 'techflow_analytics',
    'charset': 'utf8mb4'
}

def connect_to_mysql():
    """Establish MySQL connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        print("✅ Connected to MySQL successfully!")
        return connection
    except mysql.connector.Error as e:
        print(f"❌ Error connecting to MySQL: {e}")
        return None

def generate_users(connection, num_users=100000):
    print(f"🔄 Generating {num_users:,} users...")
    cursor = connection.cursor()
    industries = ['Technology', 'Healthcare', 'Finance', 'Retail', 'Manufacturing', 
                 'Education', 'Media', 'Real Estate', 'Consulting', 'Non-Profit']
    countries = ['USA', 'Canada', 'UK', 'Germany', 'France', 'Australia', 
                 'Japan', 'India', 'Brazil', 'Netherlands']
    batch_size = 5000
    users_data = []
    for i in range(num_users):
        email = fake.unique.email()
        first_name = fake.first_name()
        last_name = fake.last_name()
        company_name = fake.company()
        industry = random.choice(industries)
        country = random.choice(countries)
        created_at = fake.date_time_between(start_date='-3y', end_date='now')
        last_login = fake.date_time_between(start_date=created_at, end_date='now') if random.random() > 0.1 else None
        users_data.append((email, first_name, last_name, company_name, industry, country, created_at, last_login))
        if len(users_data) >= batch_size:
            cursor.executemany("""
                INSERT INTO users (email, first_name, last_name, company_name, industry, country, created_at, last_login)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, users_data)
            connection.commit()
            print(f"   Inserted {i+1:,} users...")
            users_data = []
    if users_data:
        cursor.executemany("""
            INSERT INTO users (email, first_name, last_name, company_name, industry, country, created_at, last_login)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, users_data)
        connection.commit()
    cursor.close()
    print(f"✅ Generated {num_users:,} users successfully!")

def generate_products(connection, num_products=50):
    print(f"🔄 Generating {num_products} products...")
    cursor = connection.cursor()
    products_data = [
        ('ProjectFlow Pro', 'Project Management', '2020-01-15', 49.99, True),
        ('ProjectFlow Enterprise', 'Project Management', '2020-06-01', 199.99, True),
        ('DataViz Analytics', 'Analytics', '2019-03-20', 79.99, True),
        ('DataViz Professional', 'Analytics', '2021-01-10', 149.99, True),
        ('MarketBot Basic', 'Marketing Automation', '2020-09-15', 99.99, True),
        ('MarketBot Advanced', 'Marketing Automation', '2021-05-20', 299.99, True),
        ('SupportDesk Starter', 'Customer Support', '2019-11-30', 29.99, True),
        ('SupportDesk Pro', 'Customer Support', '2020-08-15', 89.99, True),
        ('API Gateway Basic', 'API Services', '2021-02-28', 19.99, True),
        ('API Gateway Enterprise', 'API Services', '2021-07-10', 199.99, True),
        ('AI Insights Starter', 'AI/ML Tools', '2022-01-15', 129.99, True),
        ('AI Insights Professional', 'AI/ML Tools', '2022-06-01', 499.99, True),
    ]
    categories = ['Analytics', 'Marketing Automation', 'Project Management', 
                  'Customer Support', 'AI/ML Tools', 'API Services']
    for i in range(len(products_data), num_products):
        category = random.choice(categories)
        product_name = f"{category.split()[0]}Tool {fake.word().title()}"
        launch_date = fake.date_between(start_date='-4y', end_date='now')
        base_price = round(random.uniform(9.99, 999.99), 2)
        is_active = random.choice([True, True, True, False])  # 75% active
        products_data.append((product_name, category, launch_date, base_price, is_active))
    cursor.executemany("""
        INSERT INTO products (product_name, product_category, launch_date, base_price, is_active)
        VALUES (%s, %s, %s, %s, %s)
    """, products_data)
    connection.commit()
    cursor.close()
    print(f"✅ Generated {num_products} products successfully!")

def generate_subscriptions(connection, num_subscriptions=300000):
    print(f"🔄 Generating {num_subscriptions:,} subscriptions...")
    cursor = connection.cursor()
    cursor.execute("SELECT user_id FROM users")
    user_ids = [row[0] for row in cursor.fetchall()]
    plan_types = ['Free', 'Basic', 'Pro', 'Enterprise']
    billing_cycles = ['Monthly', 'Quarterly', 'Annual']
    statuses = ['active', 'cancelled', 'expired', 'paused']
    plan_prices = {'Free': 0, 'Basic': random.uniform(29, 99), 'Pro': random.uniform(99, 299), 'Enterprise': random.uniform(299, 999)}
    batch_size = 5000
    subscriptions_data = []
    for i in range(num_subscriptions):
        user_id = random.choice(user_ids)
        plan_type = random.choice(plan_types)
        billing_cycle = random.choice(billing_cycles)
        start_date = fake.date_between(start_date='-3y', end_date='now')
        status = 'active' if random.random() < 0.8 else random.choice(statuses[1:])
        end_date = None if status == 'active' else fake.date_between(start_date=start_date, end_date='now')
        monthly_revenue = plan_prices[plan_type] * random.uniform(0.8, 1.2)
        discount_percent = random.choice([0, 5, 10, 15, 20]) if random.random() < 0.3 else 0
        subscriptions_data.append((user_id, plan_type, billing_cycle, start_date, end_date, status, monthly_revenue, discount_percent))
        if len(subscriptions_data) >= batch_size:
            cursor.executemany("""
                INSERT INTO subscriptions (user_id, plan_type, billing_cycle, start_date, end_date, status, monthly_revenue, discount_percent)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, subscriptions_data)
            connection.commit()
            print(f"   Inserted {i + 1:,} subscriptions...")
            subscriptions_data = []
    if subscriptions_data:
        cursor.executemany("""
            INSERT INTO subscriptions (user_id, plan_type, billing_cycle, start_date, end_date, status, monthly_revenue, discount_percent)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, subscriptions_data)
        connection.commit()
    cursor.close()
    print(f"✅ Generated {num_subscriptions:,} subscriptions successfully!")

def generate_subscription_items(connection, num_items=500000):
    print(f"🔄 Generating {num_items:,} subscription items...")
    cursor = connection.cursor()
    cursor.execute("SELECT subscription_id FROM subscriptions")
    subscription_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT product_id, base_price FROM products WHERE is_active = TRUE")
    products = cursor.fetchall()
    batch_size = 5000
    items_data = []
    for i in range(num_items):
        subscription_id = random.choice(subscription_ids)
        product_id, base_price = random.choice(products)
        quantity = random.randint(1, 20)
        unit_price = float(base_price) * random.uniform(0.8, 1.2)
        added_date = fake.date_between(start_date='-3y', end_date='now')
        items_data.append((subscription_id, product_id, quantity, unit_price, added_date))
        if len(items_data) >= batch_size:
            cursor.executemany("""
                INSERT INTO subscription_items (subscription_id, product_id, quantity, unit_price, added_date)
                VALUES (%s, %s, %s, %s, %s)
            """, items_data)
            connection.commit()
            print(f"   Inserted {i + 1:,} subscription items...")
            items_data = []
    if items_data:
        cursor.executemany("""
            INSERT INTO subscription_items (subscription_id, product_id, quantity, unit_price, added_date)
            VALUES (%s, %s, %s, %s, %s)
        """, items_data)
        connection.commit()
    cursor.close()
    print(f"✅ Generated {num_items:,} subscription items successfully!")

def generate_payments(connection, num_payments=800000):
    print(f"🔄 Generating {num_payments:,} payments...")
    cursor = connection.cursor()
    cursor.execute("SELECT subscription_id, monthly_revenue FROM subscriptions WHERE status = 'active'")
    subscriptions = cursor.fetchall()
    payment_methods = ['Credit Card', 'Bank Transfer', 'PayPal', 'Crypto', 'Wire Transfer']
    payment_statuses = ['Success', 'Failed', 'Pending', 'Refunded']
    currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
    batch_size = 5000
    payments_data = []
    for i in range(num_payments):
        subscription_id, monthly_revenue = random.choice(subscriptions)
        payment_date = fake.date_time_between(start_date='-3y', end_date='now')
        amount = float(monthly_revenue) * random.uniform(0.95, 1.05)
        payment_method = random.choice(payment_methods)
        payment_status = 'Success' if random.random() < 0.85 else random.choice(payment_statuses[1:])
        currency = random.choice(currencies)
        transaction_id = fake.uuid4()
        payments_data.append((subscription_id, payment_date, amount, payment_method, payment_status, currency, transaction_id))
        if len(payments_data) >= batch_size:
            cursor.executemany("""
                INSERT INTO payments (subscription_id, payment_date, amount, payment_method, payment_status, currency, transaction_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, payments_data)
            connection.commit()
            print(f"   Inserted {i + 1:,} payments...")
            payments_data = []
    if payments_data:
        cursor.executemany("""
            INSERT INTO payments (subscription_id, payment_date, amount, payment_method, payment_status, currency, transaction_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, payments_data)
        connection.commit()
    cursor.close()
    print(f"✅ Generated {num_payments:,} payments successfully!")

def generate_user_activities(connection, num_activities=2000000):
    print(f"🔄 Generating {num_activities:,} user activities...")
    cursor = connection.cursor()
    cursor.execute("SELECT user_id FROM users")
    user_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT product_id FROM products WHERE is_active = TRUE")
    product_ids = [row[0] for row in cursor.fetchall()]
    activity_types = ['Login', 'Feature_Use', 'Support_Ticket', 'API_Call', 'Download', 'Upload']
    batch_size = 10000
    activities_data = []
    for i in range(num_activities):
        user_id = random.choice(user_ids)
        product_id = random.choice(product_ids)
        activity_date = fake.date_time_between(start_date='-2y', end_date='now')
        activity_type = random.choice(activity_types)
        session_duration = random.randint(1, 480)
        features_used = random.randint(0, 50)
        api_calls = random.randint(0, 1000) if activity_type == 'API_Call' else random.randint(0, 50)
        activities_data.append((user_id, product_id, activity_date, activity_type, session_duration, features_used, api_calls))
        if len(activities_data) >= batch_size:
            cursor.executemany("""
                INSERT INTO user_activities (user_id, product_id, activity_date, activity_type, session_duration, features_used, api_calls)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, activities_data)
            connection.commit()
            print(f"   Inserted {i + 1:,} user activities...")
            activities_data = []
    if activities_data:
        cursor.executemany("""
            INSERT INTO user_activities (user_id, product_id, activity_date, activity_type, session_duration, features_used, api_calls)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, activities_data)
        connection.commit()
    cursor.close()
    print(f"✅ Generated {num_activities:,} user activities successfully!")

def main():
    print("🚀 Starting TechFlow data generation...")
    print("=" * 50)
    
    connection = connect_to_mysql()
    if not connection:
        return
    try:
        generate_users(connection, 100000)
        generate_products(connection, 50)
        generate_subscriptions(connection, 300000)
        generate_subscription_items(connection, 500000)
        generate_payments(connection, 800000)
        generate_user_activities(connection, 2000000)
        
        print("=" * 50)
        print("🎉 Data generation completed successfully!")
    except Exception as e:
        print(f"❌ Error during data generation: {e}")
    finally:
        connection.close()
        print("\n🔒 Database connection closed.")

if __name__ == "__main__":
    main()
