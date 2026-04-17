-- ================================================================
--  EnJoyCafe  —  database_setup.sql
--  Run this file ONCE in MySQL Workbench or phpMyAdmin (WAMP)
--  Steps:  Open > Paste > Execute All (lightning bolt icon)
-- ================================================================

CREATE DATABASE IF NOT EXISTS enjoycafe
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE enjoycafe;

-- ── Admin ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(50)  NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Default login: admin / admin123
INSERT INTO admin (username, password, full_name, email)
VALUES ('admin', SHA2('admin123',256), 'Café Administrator', 'admin@enjoycafe.com')
ON DUPLICATE KEY UPDATE username=username;

-- ── Categories ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    is_active   TINYINT(1) DEFAULT 1,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO categories (name, description) VALUES
('Hot Coffee',   'Freshly brewed hot coffee varieties'),
('Cold Coffee',  'Chilled and iced coffee beverages'),
('Sandwiches',   'Fresh and toasted sandwiches'),
('Snacks',       'Light bites and quick snacks'),
('Desserts',     'Sweet treats and desserts'),
('Beverages',    'Juices, shakes and other drinks');

-- ── Products ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    category_id  INT NOT NULL,
    name         VARCHAR(150) NOT NULL,
    description  TEXT,
    price        DECIMAL(8,2) NOT NULL,
    image_url    VARCHAR(255),
    is_available TINYINT(1) DEFAULT 1,
    is_featured  TINYINT(1) DEFAULT 0,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
INSERT INTO products (category_id, name, description, price, is_featured) VALUES
(1,'Espresso',             'Rich, bold single-shot espresso',                    80.00, 1),
(1,'Cappuccino',           'Classic espresso with steamed milk foam',            120.00, 1),
(1,'Latte',                'Smooth espresso with creamy steamed milk',           130.00, 1),
(1,'Americano',            'Espresso diluted with hot water',                    100.00, 0),
(1,'Flat White',           'Velvety microfoam over a double shot',               140.00, 0),
(1,'Mocha',                'Espresso blended with chocolate and steamed milk',   140.00, 0),
(2,'Cold Brew',            'Slow-steeped cold brew, smooth and strong',          150.00, 1),
(2,'Iced Latte',           'Chilled latte served over ice',                      140.00, 1),
(2,'Frappuccino',          'Blended iced coffee delight',                        160.00, 0),
(2,'Cold Cappuccino',      'Chilled cappuccino over ice cubes',                  130.00, 0),
(3,'Club Sandwich',        'Triple-decker with chicken, cheese and veggies',     180.00, 1),
(3,'Veg Grilled Sandwich', 'Grilled veggies with herbs and cheese',              140.00, 1),
(3,'Paneer Tikka Sandwich','Spicy paneer tikka filling, freshly toasted',        160.00, 0),
(3,'Chicken Mayo Sandwich','Tender chicken with creamy mayo',                    170.00, 0),
(4,'French Fries',         'Crispy golden fries served with dip',                 90.00, 0),
(4,'Garlic Bread',         'Toasted garlic butter bread sticks',                  80.00, 0),
(4,'Nachos',               'Crunchy nachos with salsa and cheese dip',           120.00, 0),
(5,'Chocolate Brownie',    'Warm fudge brownie served with vanilla ice cream',   130.00, 1),
(5,'Cheesecake Slice',     'New York style baked cheesecake',                    150.00, 0),
(5,'Waffle',               'Crispy waffle with maple syrup and butter',          140.00, 0),
(6,'Mango Shake',          'Fresh mango blended with cold milk',                 110.00, 0),
(6,'Oreo Shake',           'Thick Oreo cookie milkshake',                        130.00, 1),
(6,'Fresh Lime Soda',      'Chilled fresh lime with soda water',                  70.00, 0);

-- ── Customers ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    phone      VARCHAR(20),
    password   VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── Orders ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    customer_id      INT NOT NULL,
    total_amount     DECIMAL(10,2) NOT NULL,
    payment_method   ENUM('CARD','COD') DEFAULT 'COD',
    payment_status   ENUM('PENDING','PAID','FAILED') DEFAULT 'PENDING',
    order_status     ENUM('PENDING','CONFIRMED','PREPARING','READY','DELIVERED','CANCELLED') DEFAULT 'PENDING',
    delivery_address TEXT,
    notes            TEXT,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- ── Order Items ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(8,2) NOT NULL,
    subtotal   DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ── Staff ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS staff (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    role         VARCHAR(80)  NOT NULL,
    phone        VARCHAR(20),
    email        VARCHAR(150),
    joining_date DATE,
    shift        VARCHAR(50),
    photo_url    VARCHAR(255),
    is_active    TINYINT(1) DEFAULT 1,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO staff (full_name, role, phone, email, joining_date, shift) VALUES
('Ravi Kumar',   'Head Barista',  '9876543210', 'ravi@enjoycafe.com',  '2022-03-15', 'Morning'),
('Priya Sharma', 'Cashier',       '9123456780', 'priya@enjoycafe.com', '2023-01-10', 'Morning'),
('Arjun Nair',   'Kitchen Staff', '9988776655', 'arjun@enjoycafe.com', '2022-07-01', 'Evening'),
('Sneha Patil',  'Floor Manager', '9001122334', 'sneha@enjoycafe.com', '2021-11-20', 'Full Day');

-- ── Reviews ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reviews (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    name        VARCHAR(100),
    rating      TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    is_approved TINYINT(1) DEFAULT 0,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
);
INSERT INTO reviews (name, rating, comment, is_approved) VALUES
('Amit Desai',  5, 'Absolutely love the Cold Brew here! Best coffee in Pune.',      1),
('Meera Joshi', 5, 'The Club Sandwich and Cappuccino combo is unbeatable!',          1),
('Rahul Singh', 4, 'Great ambiance and very friendly staff. Will definitely return.', 1),
('Sana Khan',   5, 'EnJoyCafe is my go-to weekend spot. Love everything here!',     1),
('Dev Malhotra',4, 'Chocolate Brownie with ice cream — absolutely divine!',          1);

-- ================================================================
--  Setup complete!
--  Admin login → username: admin   password: admin123
-- ================================================================
