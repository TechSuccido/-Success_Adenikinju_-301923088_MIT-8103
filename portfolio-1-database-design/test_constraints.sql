-- Each statement below is EXPECTED TO FAIL. Run with:
--   psql -U shop -d shopsphere -f test_constraints.sql
-- Screenshot the error messages as evidence that the constraints work.
\echo '1. Duplicate email (UNIQUE)'
INSERT INTO customers (full_name,email,password_hash) VALUES ('Dup','ada@example.com','x');
\echo '2. Negative price (CHECK)'
INSERT INTO products (seller_id,category_id,sku,name,unit_price) VALUES (1,1,'BAD-1','Bad',-5);
\echo '3. Negative stock (CHECK)'
UPDATE inventory SET quantity_on_hand = -1 WHERE product_id = 1;
\echo '4. Order for non-existent customer (FOREIGN KEY)'
INSERT INTO orders (customer_id,shipping_address_id,total_amount) VALUES (999,1,100);
\echo '5. Invalid order status (CHECK)'
UPDATE orders SET status = 'teleported' WHERE order_id = 1;
\echo '6. Same product twice in one order (composite PRIMARY KEY)'
INSERT INTO order_items VALUES (1,1,1,250000.00);
\echo '7. Second review by same customer for same product (UNIQUE)'
INSERT INTO reviews (product_id,customer_id,rating) VALUES (1,1,3);
\echo '8. Rating out of range (CHECK)'
INSERT INTO reviews (product_id,customer_id,rating) VALUES (2,1,9);
\echo '9. Delivered before shipped (CHECK)'
UPDATE shipments SET delivered_at = shipped_at - interval '1 day' WHERE shipment_id = 1;
