"""Exploratory analysis for Food Delivery Operations & Growth Analytics.
Run from the project root: python python/analysis.py
"""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
REPORTS = ROOT / "reports"
REPORTS.mkdir(exist_ok=True)

orders = pd.read_csv(DATA / "orders.csv", parse_dates=["order_datetime"])
customers = pd.read_csv(DATA / "customers.csv", parse_dates=["signup_date"])
restaurants = pd.read_csv(DATA / "restaurants.csv")
deliveries = pd.read_csv(DATA / "deliveries.csv", parse_dates=["pickup_datetime", "delivered_datetime"])
reasons = pd.read_csv(DATA / "cancellation_reasons.csv")

# Basic quality checks
assert orders["order_id"].is_unique, "Duplicate order IDs found"
assert orders["customer_id"].isin(customers["customer_id"]).all(), "Unknown customer ID"
assert orders["restaurant_id"].isin(restaurants["restaurant_id"]).all(), "Unknown restaurant ID"
assert orders["order_amount"].ge(0).all(), "Negative order amount found"

# Core KPIs
total_orders = len(orders)
delivered_orders = (orders.order_status == "Delivered").sum()
cancelled_orders = (orders.order_status == "Cancelled").sum()
delivered = orders[orders.order_status == "Delivered"]
aov = delivered.order_amount.mean()
cancellation_rate = cancelled_orders / total_orders * 100

kpis = pd.DataFrame({
    "metric": ["Total orders", "Delivered orders", "Cancelled orders",
               "Delivered GMV", "Average order value", "Cancellation rate (%)"],
    "value": [total_orders, delivered_orders, cancelled_orders,
              delivered.order_amount.sum(), aov, cancellation_rate]
})
kpis.to_csv(REPORTS / "kpi_summary.csv", index=False)

# Monthly trend
orders["month"] = orders.order_datetime.dt.to_period("M").astype(str)
monthly = orders.groupby("month").agg(
    total_orders=("order_id","count"),
    delivered_gmv=("order_amount", lambda s: s[orders.loc[s.index, "order_status"].eq("Delivered")].sum())
).reset_index()
monthly.to_csv(REPORTS / "monthly_trends.csv", index=False)

# Delivery performance
delivery_summary = deliveries.merge(
    orders[["order_id","restaurant_id"]], on="order_id", how="left"
).merge(restaurants[["restaurant_id","city"]], on="restaurant_id", how="left")
city_delivery = delivery_summary.groupby("city").delivery_minutes.agg(
    avg_delivery_minutes="mean", median_delivery_minutes="median", deliveries="count"
).reset_index()
city_delivery.to_csv(REPORTS / "delivery_by_city.csv", index=False)

# Customer repeat behavior
customer_orders = delivered.groupby("customer_id").order_id.nunique()
repeat_customers = int((customer_orders > 1).sum())
customer_summary = pd.DataFrame({
    "metric": ["Unique delivered customers", "Repeat customers", "Repeat customer rate (%)"],
    "value": [customer_orders.size, repeat_customers,
              repeat_customers / max(customer_orders.size, 1) * 100]
})
customer_summary.to_csv(REPORTS / "customer_summary.csv", index=False)

# Charts
monthly.plot(x="month", y="delivered_gmv", kind="line", marker="o", legend=False,
             title="Monthly Delivered GMV", figsize=(10,5))
plt.ylabel("GMV")
plt.tight_layout()
plt.savefig(REPORTS / "monthly_gmv.png", dpi=150)
plt.close()

city_delivery.sort_values("avg_delivery_minutes").plot(
    x="city", y="avg_delivery_minutes", kind="bar", legend=False,
    title="Average Delivery Time by City", figsize=(9,5)
)
plt.ylabel("Minutes")
plt.tight_layout()
plt.savefig(REPORTS / "delivery_time_by_city.png", dpi=150)
plt.close()

print("Analysis complete. See the reports/ folder.")
print(kpis.to_string(index=False))
