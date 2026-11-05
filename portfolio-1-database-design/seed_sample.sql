-- Small sample data used to verify the schema and constraints.
-- Large-scale data for performance testing is generated in Portfolio 2.
INSERT INTO customers (full_name, email, phone, password_hash) VALUES
 ('Ada Okafor',  'ada@example.com',   '08030000001', 'hash1'),
 ('Tunde Bello', 'tunde@example.com', '08030000002', 'hash2'),
 ('Zainab Musa', 'zainab@example.com','08030000003', 'hash3');

INSERT INTO addresses (customer_id, line1, city, state, postal_code, is_default) VALUES
 (1, '12 Allen Avenue',  'Ikeja',          'Lagos', '100271', TRUE),
 (2, '5 Adeola Odeku',   'Victoria Island','Lagos', '101241', TRUE),
 (3, '22 Wuse Zone 5',   'Abuja',          'FCT',   '900001', TRUE);

INSERT INTO sellers (business_name, email, rating) VALUES
 ('TechHub Nigeria', 'sales@techhub.example',      4.5),
 ('StyleCorner',     'hello@stylecorner.example',  4.1);

INSERT INTO categories (name, parent_category_id) VALUES
 ('Electronics', NULL),
 ('Phones', 1),
 ('Fashion', NULL);

INSERT INTO products (seller_id, category_id, sku, name, description, unit_price) VALUES
 (1, 2, 'PH-001', 'Smartphone X1',    '6.5in display, 128GB', 250000.00),
 (1, 1, 'EL-002', 'Wireless Earbuds', 'Bluetooth 5.3',         35000.00),
 (1, 2, 'PH-003', 'Phone Case',       'Shockproof',             5000.00),
 (2, 3, 'FA-001', 'Ankara Shirt',     'Cotton, size L',        12000.00),
 (2, 3, 'FA-002', 'Leather Sandals',  'Handmade',              18000.00);

INSERT INTO inventory (product_id, quantity_on_hand) VALUES
 (1, 20), (2, 50), (3, 200), (4, 40), (5, 15);

INSERT INTO orders (customer_id, shipping_address_id, status, total_amount) VALUES
 (1, 1, 'delivered', 260000.00),
 (2, 2, 'paid',       30000.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
 (1, 1, 1, 250000.00),
 (1, 3, 2,   5000.00),
 (2, 4, 1,  12000.00),
 (2, 5, 1,  18000.00);

INSERT INTO payments (order_id, method, amount, status, transaction_ref, paid_at) VALUES
 (1, 'card',          260000.00, 'successful', 'TXN-0001', now()),
 (2, 'bank_transfer',  30000.00, 'successful', 'TXN-0002', now());

INSERT INTO shipments (order_id, carrier, tracking_number, status, shipped_at, delivered_at) VALUES
 (1, 'GIG Logistics', 'TRK-1001', 'delivered',  now() - interval '3 days', now() - interval '1 day'),
 (2, 'DHL Express',   'TRK-1002', 'in_transit', now() - interval '1 day',  NULL);

INSERT INTO reviews (product_id, customer_id, rating, comment) VALUES
 (1, 1, 5, 'Excellent phone, fast delivery'),
 (3, 1, 4, 'Good case for the price');
