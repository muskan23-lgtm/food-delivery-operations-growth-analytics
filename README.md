# Food Delivery Operations & Growth Analytics

An end-to-end portfolio starter project for business operations and data analytics. It uses **synthetic practice data**, not real Swiggy/Zomato/company transactions.

## Business objective
Analyze food delivery orders, revenue, customer repeat behavior, restaurant performance, cancellations and delivery efficiency. Convert the findings into practical operational recommendations.

## Dataset
The `data/` folder contains:
- `customers.csv` — 1,200 customer records
- `restaurants.csv` — 120 restaurant records
- `orders.csv` — 10,000 order records
- `deliveries.csv` — delivery records for delivered orders
- `order_items.csv` — item-level order details
- `cancellation_reasons.csv` — cancellation reasons for cancelled orders

The data is generated for learning and portfolio practice. It does not represent actual market performance.

## Quick start
1. Install Python 3.9+.
2. Create and activate a virtual environment (optional but recommended).
3. Install dependencies:
   `pip install -r requirements.txt`
4. Run the analysis:
   `python python/analysis.py`
5. Review generated outputs in `reports/`.
6. Open `sql/business_analysis_queries.sql` in PostgreSQL after importing the CSVs into tables named `orders`, `customers`, `restaurants`, `deliveries`, and `cancellation_reasons`.
7. Follow `powerbi/POWER_BI_GUIDE.md` to build the dashboard in Power BI.

## Suggested business questions
- Which cities and restaurants generate the highest delivered GMV?
- What is the cancellation rate, and what are the most common reasons?
- Which hours have the highest order volume?
- Which cities have the longest average delivery times?
- What proportion of customers place more than one delivered order?
- How does monthly GMV change over time?

## Important metric definitions
- **Delivered GMV:** sum of `order_amount` for orders with status `Delivered`. This is gross order value in this practice dataset, not accounting revenue or platform commission.
- **AOV:** delivered GMV divided by delivered orders.
- **Cancellation rate:** cancelled orders divided by all orders.
- **Repeat customer:** customer with more than one delivered order in the dataset.
- **Delivery time:** minutes from order creation to delivered timestamp, represented by `delivery_minutes`.

## Data model
`customers` 1-to-many `orders`; `restaurants` 1-to-many `orders`; `orders` 1-to-zero/one `deliveries` for delivered orders; `orders` 1-to-zero/one `cancellation_reasons` for cancelled orders.

## Portfolio guidance
Do not claim business impact or cost savings unless your analysis demonstrates them. In your README or presentation, separate observed results from recommendations. Be ready to explain data generation, joins, KPI definitions, data-quality checks and dashboard design.
