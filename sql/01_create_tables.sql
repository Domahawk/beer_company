DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS product_packs;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          description TEXT NOT NULL,
                          tagline TEXT NOT NULL,
                          abv DECIMAL(3,1) NOT NULL
);

CREATE TABLE product_packs (
                               id SERIAL PRIMARY KEY,
                               product_id INT NOT NULL,
                               type VARCHAR(10) NOT NULL,
                               price_per_liter DECIMAL(5,2) NOT NULL,
                               volume DECIMAL(4,2) NOT NULL,

                               CONSTRAINT fk_products_product_packs FOREIGN KEY (product_id) REFERENCES products(id),
                               CONSTRAINT chk_product_packs_type CHECK ( type IN ('bottle', 'crate', 'keg') ),
                               CONSTRAINT unq_product_type_volume UNIQUE (product_id, type, volume)
);

CREATE TABLE customers (
                           id SERIAL PRIMARY KEY,
                           name VARCHAR(255) NOT NULL,
                           type VARCHAR(20) NOT NULL,
                           address TEXT,
                           city VARCHAR(100),
                           country VARCHAR(100),

                           CONSTRAINT chk_customers_type CHECK ( type IN ('store', 'bar') )
);

CREATE TABLE orders (
                        id SERIAL PRIMARY KEY,
                        customer_id INT NOT NULL,
                        delivery_address TEXT NOT NULL,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                        CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE order_items (
                             id SERIAL PRIMARY KEY,
                             order_id INT NOT NULL,
                             product_pack_id INT NOT NULL,
                             quantity INT NOT NULL,
                             unit_price NUMERIC(10,2) NOT NULL,

                             CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id),
                             CONSTRAINT fk_order_items_product_pack FOREIGN KEY (product_pack_id) REFERENCES product_packs(id),
                             CONSTRAINT unq_product_order UNIQUE (order_id, product_pack_id)

);

CREATE TABLE drivers (
                         id SERIAL PRIMARY KEY,
                         name VARCHAR(255) NOT NULL,
                         phone VARCHAR(50)
);

CREATE TABLE vehicles (
                          id SERIAL PRIMARY KEY,
                          license_plate VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE schedules (
                           id SERIAL PRIMARY KEY,
                           driver_id INT NOT NULL,
                           vehicle_id INT NOT NULL,
                           assigned_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           assigned_to TIMESTAMP,
                           status VARCHAR(20) NOT NULL DEFAULT 'planned',

                           CONSTRAINT chk_assignment_status CHECK (status IN ('planned', 'active', 'completed')),
                           CONSTRAINT fk_assignment_driver FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
                           CONSTRAINT fk_assignment_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

CREATE TABLE deliveries (
                            id SERIAL PRIMARY KEY,
                            order_id INT NOT NULL UNIQUE,
                            schedule_id INT NOT NULL,
                            delivered_at TIMESTAMP,

                            CONSTRAINT fk_deliveries_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
                            CONSTRAINT fk_deliveries_schedules FOREIGN KEY (schedule_id) REFERENCES schedules(id)
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_pack_id ON order_items(product_pack_id);
CREATE INDEX idx_schedules_driver_id ON schedules(driver_id);
CREATE INDEX idx_schedules_vehicle_id ON schedules(vehicle_id);
CREATE UNIQUE INDEX idx_unq_active_driver ON schedules(driver_id) WHERE status = 'active';
CREATE UNIQUE INDEX idx_unq_active_vehicle ON schedules(vehicle_id) WHERE status = 'active';
