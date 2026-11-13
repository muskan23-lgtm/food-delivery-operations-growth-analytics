# Power BI Dashboard Guide

## Import
Load these CSV files from `data/`:
- customers.csv
- restaurants.csv
- orders.csv
- deliveries.csv
- cancellation_reasons.csv

## Suggested relationships
- customers[customer_id] 1 -> * orders[customer_id]
- restaurants[restaurant_id] 1 -> * orders[restaurant_id]
- orders[order_id] 1 -> 0..1 deliveries[order_id]
- orders[order_id] 1 -> 0..1 cancellation_reasons[order_id]

If Power BI does not infer the relationships, create them in Model view. Keep filter direction single unless you have a clear reason otherwise.

## Suggested measures (DAX)
```DAX
Total Orders = COUNTROWS(orders)

Delivered Orders =
CALCULATE([Total Orders], orders[order_status] = "Delivered")

Cancelled Orders =
CALCULATE([Total Orders], orders[order_status] = "Cancelled")

Delivered GMV =
CALCULATE(SUM(orders[order_amount]), orders[order_status] = "Delivered")

Average Order Value =
DIVIDE([Delivered GMV], [Delivered Orders])

Cancellation Rate =
DIVIDE([Cancelled Orders], [Total Orders])

Average Delivery Minutes =
AVERAGE(deliveries[delivery_minutes])

Repeat Customers =
COUNTROWS(
    FILTER(
        VALUES(orders[customer_id]),
        CALCULATE(COUNTROWS(orders), orders[order_status] = "Delivered") > 1
    )
)
```

## Dashboard pages
1. Executive Overview: Total Orders, Delivered GMV, AOV, Cancellation Rate, monthly trend.
2. Delivery Operations: Average delivery minutes by city, delivery-time distribution, delayed deliveries (define threshold transparently).
3. Customer & Restaurant: Repeat customers, top restaurants by GMV, cuisine mix, city performance.
4. Cancellations: Cancellation reasons, cancellation rate by restaurant/city.

## Design tips
Use slicers for date, city, cuisine and order status. Add a short insight text box explaining what each page reveals. Validate totals against SQL before publishing.
