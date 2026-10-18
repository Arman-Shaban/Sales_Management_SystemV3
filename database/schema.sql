
CREATE TABLE IF NOT EXISTS customers (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT NOT NULL CHECK (length(trim(name)) > 0),
    email      TEXT NOT NULL UNIQUE,
    phone      TEXT NOT NULL DEFAULT '',
    address    TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS products (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    sku        TEXT NOT NULL UNIQUE CHECK (length(sku) > 0),
    name       TEXT NOT NULL CHECK (length(trim(name)) > 0),
    unit_price INTEGER NOT NULL CHECK (unit_price > 0),
    is_active  INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

-- One inventory row per product (assumption: single location).
CREATE TABLE IF NOT EXISTS inventory (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id    INTEGER NOT NULL UNIQUE REFERENCES products(id) ON DELETE RESTRICT,
    quantity      INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    reorder_level INTEGER NOT NULL DEFAULT 5 CHECK (reorder_level >= 0)
);

CREATE TABLE IF NOT EXISTS orders (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id  INTEGER NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    order_date   TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    status       TEXT NOT NULL DEFAULT 'CONFIRMED'
                 CHECK (status IN ('CONFIRMED', 'COMPLETED', 'CANCELLED')),
    total_amount INTEGER NOT NULL DEFAULT 0 CHECK (total_amount >= 0)
);

-- Composition: items die with their order. unit_price is the historical price.
CREATE TABLE IF NOT EXISTS order_items (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id   INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    unit_price INTEGER NOT NULL CHECK (unit_price >= 0),
    UNIQUE (order_id, product_id)
);

CREATE TABLE IF NOT EXISTS banks (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    name              TEXT NOT NULL UNIQUE CHECK (length(trim(name)) > 0),
    branch_code       TEXT NOT NULL DEFAULT '',
    account_reference TEXT NOT NULL DEFAULT ''   -- masked label only, never a real number
);

CREATE TABLE IF NOT EXISTS payment_transactions (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id   INTEGER NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    bank_id    INTEGER REFERENCES banks(id) ON DELETE RESTRICT,   -- optional (e.g. cash)
    amount     INTEGER NOT NULL CHECK (amount > 0),
    status     TEXT NOT NULL DEFAULT 'PENDING'
               CHECK (status IN ('PENDING', 'SUCCESSFUL', 'FAILED')),
    reference  TEXT UNIQUE,                                       -- blocks duplicate processing
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS deliveries (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id     INTEGER NOT NULL UNIQUE REFERENCES orders(id) ON DELETE RESTRICT,
    address      TEXT NOT NULL CHECK (length(trim(address)) > 0),
    status       TEXT NOT NULL DEFAULT 'PENDING'
                 CHECK (status IN ('PENDING', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    shipped_at   TEXT,
    delivered_at TEXT,
    created_at   TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS inventory_transactions (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    inventory_id     INTEGER NOT NULL REFERENCES inventory(id) ON DELETE RESTRICT,
    order_id         INTEGER REFERENCES orders(id) ON DELETE RESTRICT,
    transaction_type TEXT NOT NULL
                     CHECK (transaction_type IN ('ADDITION', 'SALE', 'RETURN', 'ADJUSTMENT', 'CANCELLATION')),
    quantity_change  INTEGER NOT NULL CHECK (quantity_change <> 0),
    note             TEXT NOT NULL DEFAULT '',
    created_at       TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE INDEX IF NOT EXISTS idx_customers_name        ON customers(name);
CREATE INDEX IF NOT EXISTS idx_products_name         ON products(name);
CREATE INDEX IF NOT EXISTS idx_orders_customer       ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date           ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status         ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_product   ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_payments_order        ON payment_transactions(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_status       ON payment_transactions(status);
CREATE INDEX IF NOT EXISTS idx_invtx_inventory       ON inventory_transactions(inventory_id);
CREATE INDEX IF NOT EXISTS idx_invtx_order           ON inventory_transactions(order_id);
