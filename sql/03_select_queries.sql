-- Bars that order more than 5 types of beer

SELECT c.id, c.name, count(DISTINCT (p.id)) AS number_of_distinct_beers
FROM orders o
    JOIN customers c ON o.customer_id = c.id
    JOIN order_items oi ON o.id = oi.order_id
    JOIN product_packs pp ON oi.product_pack_id = pp.id
    JOIN products p ON pp.product_id = p.id
WHERE c.type = 'bar'
GROUP BY c.id, c.name
HAVING count(DISTINCT (p.id)) > 5
ORDER BY number_of_distinct_beers DESC;

-- Top 5 most requested beers
-- There are two possible interpretations of most requested beers.
-- 1. Most requested by volume sold
-- 2. Most requested by number of times ordered
-- The two are not necessarily the same

-- Most requested by volume sold
SELECT p.name, sum(pp.volume * oi.quantity) AS volume_sold
FROM products p
    JOIN product_packs pp ON p.id = pp.product_id
    JOIN order_items oi ON pp.id = oi.product_pack_id
GROUP BY p.id, p.name
ORDER BY volume_sold DESC
LIMIT 5;

-- Most requested by times ordered
SELECT p.name, count(DISTINCT oi.order_id) AS times_ordered
FROM products p
    JOIN product_packs pp ON p.id = pp.product_id
    JOIN order_items oi ON pp.id = oi.product_pack_id
GROUP BY p.name
ORDER BY times_ordered DESC
LIMIT 5;

-- Top 5 customers by total quantity ordered

SELECT c.name, sum(pp.volume * oi.quantity) AS volume
FROM customers c
    JOIN orders o ON c.id = o.customer_id
    JOIN order_items oi ON o.id = oi.order_id
    JOIN product_packs pp ON oi.product_pack_id = pp.id
GROUP BY c.id, c.name
ORDER BY volume DESC
LIMIT 5;

-- Beers that have never been ordered by the top 5 customers

SELECT p2.name
FROM products p2
WHERE p2.id NOT IN (
    SELECT pp.product_id
    FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN product_packs pp ON oi.product_pack_id = pp.id
    WHERE o.customer_id IN (
        SELECT c.id
        FROM customers c
            JOIN orders o ON c.id = o.customer_id
            JOIN order_items oi ON o.id = oi.order_id
            JOIN product_packs pp ON oi.product_pack_id = pp.id
        GROUP BY c.id
        ORDER BY sum(pp.volume * oi.quantity) DESC
        LIMIT 5
        )
    );

-- Top 5 vehicles that delivered the largest quantity of beer

SELECT v.license_plate, sum(oi.quantity * pp.volume) as volume_delivered
FROM vehicles v
    JOIN schedules s ON s.vehicle_id = v.id
    JOIN deliveries d ON d.schedule_id = s.id
    JOIN orders o ON o.id = d.order_id
    JOIN order_items oi ON oi.order_id = o.id
    JOIN product_packs pp ON pp.id = oi.product_pack_id
WHERE s.status = 'completed'
GROUP BY v.license_plate
ORDER BY volume_delivered DESC
LIMIT 5;

-- Top 5 drivers who completed the most deliveries and how many different vehicles they used during those deliveries

SELECT dr.id, dr.name,count(de.id) AS deliveries_made, count(DISTINCT s.vehicle_id) AS number_of_vehicles_used
FROM drivers dr
    JOIN schedules s ON s.driver_id = dr.id
    JOIN deliveries de ON de.schedule_id = s.id
WHERE s.status = 'completed'
GROUP BY dr.id, dr.name
ORDER BY deliveries_made DESC
LIMIT 5;

-- Customers who increased the amount of beer they ordered with each successive order

WITH ordered_orders_customers AS (
    SELECT o.id AS order_id,
           c.id AS customer_id,
           c.name AS customer_name,
           sum(oi.quantity * pp.volume) AS volume_sum,
           LAG(sum(oi.quantity * pp.volume)) OVER (PARTITION BY c.id ORDER BY o.id) AS previous_volume_sum
    FROM customers c
             JOIN orders o ON o.customer_id = c.id
             JOIN order_items oi ON oi.order_id = o.id
             JOIN product_packs pp ON oi.product_pack_id = pp.id
    GROUP BY o.id, c.id, c.name
    ORDER BY c.id, o.id
    )
        SELECT
            customer_id,
            customer_name
        FROM ordered_orders_customers
        WHERE customer_id NOT IN (
            SELECT customer_id
            FROM ordered_orders_customers
            WHERE volume_sum < previous_volume_sum
            ) AND previous_volume_sum IS NOT NULL
GROUP BY customer_id, customer_name
