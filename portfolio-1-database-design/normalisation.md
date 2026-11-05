# Normalisation walkthrough (UNF to 3NF)

## Starting point: one flat "orders" sheet (UNF)

| order_id | order_date | customer_name | customer_email | customer_address | products | quantities | prices | seller_name | payment_method |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026-10-01 | Ada Okafor | ada@example.com | 12 Allen Ave, Ikeja | Smartphone X1, Phone Case | 1, 2 | 250000, 5000 | TechHub Nigeria | card |

**Problems:** repeating groups in `products`, `quantities` and `prices`; customer data repeated on every order (update anomaly); cannot record a product that has never been ordered (insertion anomaly); deleting the only order of a product loses the product (deletion anomaly).

## 1NF: atomic values, no repeating groups
One row per order line. Key becomes **(order_id, product_id)**.

`order_lines(order_id, product_id, order_date, customer_name, customer_email, customer_address, product_name, unit_price, quantity, seller_name, payment_method)`

## 2NF: remove partial dependencies
Dependencies on only part of the composite key:
- `order_id` alone determines order_date, customer details, payment_method.
- `product_id` alone determines product_name, price, seller_name.

Split into:
- `orders(order_id, order_date, customer_name, customer_email, customer_address, payment_method)`
- `products(product_id, product_name, unit_price, seller_name)`
- `order_items(order_id, product_id, quantity)`

## 3NF: remove transitive dependencies
- In `orders`: order_id -> customer_id -> (customer_name, email, address). Extract `customers` and `addresses`; payment_method moves to `payments` (an order can have several payment attempts).
- In `products`: product_id -> seller_id -> seller details. Extract `sellers`. Category is extracted to `categories`.
- Stock level changes independently of catalogue data, so it lives in `inventory`.
- Delivery attributes (carrier, tracking, dates) depend on the shipment, not the order, so they live in `shipments`.

## Result
11 tables: customers, addresses, sellers, categories, products, inventory, orders, order_items, payments, shipments, reviews. Every non-key attribute depends on the key, the whole key, and nothing but the key.

## Deliberate design decisions
- `order_items.unit_price` stores the price **at purchase time**. This is a historical fact, not a derived copy of `products.unit_price`, so it does not violate 3NF.
- `orders.total_amount` is stored for fast reporting and checked by the application/transaction (Portfolio 3). It is controlled redundancy; the trade-off is that it must be kept consistent with `order_items`.
