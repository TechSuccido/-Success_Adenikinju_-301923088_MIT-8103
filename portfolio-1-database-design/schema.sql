-- ShopSphere: multi-vendor e-commerce platform
-- Portfolio 1: relational schema (PostgreSQL 16), designed to 3NF.
-- Note: no secondary indexes yet. They are added deliberately in Portfolio 2
-- so the before/after execution plans show a real difference.

DROP TABLE IF EXISTS reviews, shipments, payments, order_items, orders,
    inventory, products, categories, sellers, addresses, customers CASCADE;

CREATE TABLE customers (
    customer_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name      VARCHAR(120) NOT NULL,
    email          VARCHAR(255) NOT NULL UNIQUE,
    phone          VARCHAR(20),
    password_hash  TEXT         NOT NULL,
    is_active      BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT chk_customer_email CHECK (email LIKE '%_@_%')
);

CREATE TABLE addresses (
    address_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  BIGINT       NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    line1        VARCHAR(200) NOT NULL,
    city         VARCHAR(80)  NOT NULL,
    state        VARCHAR(80)  NOT NULL,
    country      VARCHAR(60)  NOT NULL DEFAULT 'Nigeria',
    postal_code  VARCHAR(12),
    is_default   BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE TABLE sellers (
    seller_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    business_name  VARCHAR(150) NOT NULL UNIQUE,
    email          VARCHAR(255) NOT NULL UNIQUE,
    rating         NUMERIC(2,1) CHECK (rating BETWEEN 0 AND 5),
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE categories (
    category_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                VARCHAR(80) NOT NULL UNIQUE,
    parent_category_id  INT REFERENCES categories(category_id) ON DELETE SET NULL
);

CREATE TABLE products (
    product_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id    BIGINT        NOT NULL REFERENCES sellers(seller_id),
    category_id  INT           NOT NULL REFERENCES categories(category_id),
    sku          VARCHAR(40)   NOT NULL UNIQUE,
    name         VARCHAR(200)  NOT NULL,
    description  TEXT,
    unit_price   NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    status       VARCHAR(15)   NOT NULL DEFAULT 'active'
                 CHECK (status IN ('active','inactive','discontinued')),
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- 1:1 with products; kept separate because stock changes far more often
-- than catalogue data (reduces row churn and lock contention on products).
CREATE TABLE inventory (
    product_id        BIGINT PRIMARY KEY REFERENCES products(product_id) ON DELETE CASCADE,
    quantity_on_hand  INT         NOT NULL CHECK (quantity_on_hand >= 0),
    reorder_level     INT         NOT NULL DEFAULT 10 CHECK (reorder_level >= 0),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    order_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id          BIGINT        NOT NULL REFERENCES customers(customer_id),
    shipping_address_id  BIGINT        NOT NULL REFERENCES addresses(address_id),
    status               VARCHAR(15)   NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','paid','shipped','delivered','cancelled')),
    total_amount         NUMERIC(14,2) NOT NULL CHECK (total_amount >= 0),
    created_at           TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- Resolves the many-to-many between orders and products.
-- unit_price is a deliberate snapshot of the price at purchase time
-- (not a 3NF violation: it is a historical fact, not derived from products).
CREATE TABLE order_items (
    order_id    BIGINT        NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id  BIGINT        NOT NULL REFERENCES products(product_id),
    quantity    INT           NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id         BIGINT        NOT NULL REFERENCES orders(order_id),
    method           VARCHAR(20)   NOT NULL
                     CHECK (method IN ('card','bank_transfer','wallet','cash_on_delivery')),
    amount           NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    status           VARCHAR(15)   NOT NULL DEFAULT 'initiated'
                     CHECK (status IN ('initiated','successful','failed','refunded')),
    transaction_ref  VARCHAR(64)   NOT NULL UNIQUE,
    paid_at          TIMESTAMPTZ
);

CREATE TABLE shipments (
    shipment_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id         BIGINT      NOT NULL UNIQUE REFERENCES orders(order_id),
    carrier          VARCHAR(60) NOT NULL,
    tracking_number  VARCHAR(40) NOT NULL UNIQUE,
    status           VARCHAR(15) NOT NULL DEFAULT 'processing'
                     CHECK (status IN ('processing','in_transit','delivered','returned')),
    shipped_at       TIMESTAMPTZ,
    delivered_at     TIMESTAMPTZ,
    CONSTRAINT chk_ship_dates CHECK (delivered_at IS NULL OR shipped_at IS NULL OR delivered_at >= shipped_at)
);

CREATE TABLE reviews (
    review_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id   BIGINT   NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    customer_id  BIGINT   NOT NULL REFERENCES customers(customer_id),
    rating       SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_one_review_per_customer_product UNIQUE (product_id, customer_id)
);
