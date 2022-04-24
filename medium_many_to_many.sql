/* Medium: Many to Many */

/* Relationship:

customers >O---O< services

cardinality = m:m, modality = optional on both sides

*/

/*

CREATE TABLE customers
(
  id serial PRIMARY KEY,
  name text NOT NULL,
  payment_token char(8) NOT NULL
);

CREATE TABLE services
(
  id serial PRIMARY KEY,
  description text NOT NULL,
  price numeric(10, 2) NOT NULL CHECK (price >= 0.00)
);

INSERT INTO customers
  (name, payment_token)
VALUES
  ('Pat Johnson', 'XHGOAHEQ'),
  ('Nancy Monreal', 'JKWQPJKL'),
  ('Lynn Blake', 'KLZXWEEE'),
  ('Chen Ke-Hua', 'KWETYCVX'),
  ('Scott Lakso', 'UUEAPQPS'),
  ('Jim Pornot', 'XKJEYAZA');

INSERT INTO services
  (description, price)
VALUES
  ('Unix Hosting', 5.95),
  ('DNS', 4.95),
  ('Whois Registration', 1.95),
  ('High Bandwidth', 15.00),
  ('Business Support', 250.00),
  ('Dedicated Hosting', 50.00),
  ('Bulk Email', 250.00),
  ('One-to-one Training', 999.00);

CREATE TABLE customers_services
(
  id serial PRIMARY KEY,
  customer_id integer REFERENCES customers(id) ON DELETE CASCADE,
  service_id integer REFERENCES services(id),
  UNIQUE(customer_id, service_id)
);

INSERT INTO customers_services
  (customer_id, service_id)
VALUES
  (1, 1),
  (1, 2),
  (1, 3),
  (3, 1),
  (3, 2),
  (3, 3),
  (3, 4),
  (3, 5),
  (4, 1),
  (4, 4),
  (5, 1),
  (5, 2),
  (5, 6),
  (6, 1),
  (6, 6),
  (6, 7);

ALTER TABLE customers
ADD UNIQUE (payment_token),
ADD CHECK (payment_token ~ '^[A-Z]{8}$')

ALTER TABLE customers_services
ALTER COLUMN customer_id SET NOT NULL,
ALTER COLUMN service_id SET NOT NULL;

-- Option 1: Using joins

-- Note: If a customer's id is included in `customer_services`, they
-- must have a service

SELECT DISTINCT customers.*
FROM customers
  INNER JOIN customers_services
  ON customers.id = customers_services.customer_id;

-- Option 2: Using subqueries

SELECT DISTINCT customers.*
FROM customers
WHERE id IN (SELECT customer_id FROM  customers_services);

-- Option 1: Using joins

SELECT customers.*
FROM customers
  LEFT OUTER JOIN customers_services
  ON customers.id = customers_services.customer_id
WHERE customers_services.service_id IS NULL;
  
-- Option 2: Using subqueries

SELECT customers.*
FROM customers
WHERE id NOT IN (SELECT customer_id FROM customers_services);

SELECT customers.*, services.*
FROM customers
  FULL OUTER JOIN customers_services
  ON customers.id = customers_services.customer_id
  FULL OUTER JOIN services
  ON services.id = customers_services.service_id
WHERE customers_services.id IS NULL;

SELECT services.description
FROM customers_services
  RIGHT OUTER JOIN services
  ON services.id = customers_services.service_id
WHERE customers_services.customer_id IS NULL;

SELECT customers.name, string_agg(services.description, ', ') AS services
FROM customers
  LEFT OUTER JOIN customers_services
  ON customers.id = customers_services.customer_id
  LEFT OUTER JOIN services
  ON services.id = customers_services.service_id
GROUP BY customers.id;

-- Goal: Display services on separate rows
-- Idea: Hide name w/ case condition if the previous (lag) is the same as the
-- current; only show the name if the previous name is separate

SELECT CASE WHEN customers.name = lag(customers.name) OVER (ORDER BY customers.name)
            THEN ''
            ELSE customers.name
       END,
       services.description
FROM customers
LEFT OUTER JOIN customers_services
             ON customer_id = customers.id
LEFT OUTER JOIN services
             ON services.id = service_id;

-- Solution 1: Using Joins

SELECT services.description, count(customers_services.id)
FROM services
  LEFT OUTER JOIN customers_services
  ON services.id = customers_services.service_id
GROUP BY services.id
HAVING count(customers_services.id) >= 3;

-- Solution 2: Subqueries?

-- SELECT services.description
-- FROM services
-- WHERE customers_services.service_id = services.id

Goal: Select the total price paid for services by all customers.
- Create a table with all customer-service combinations
- Sum prices for all associated services
- Note: We don't need customer information

SELECT sum(services.price) AS gross
FROM customers_services
  INNER JOIN services
  ON services.id = customers_services.service_id;

INSERT INTO customers
  (name, payment_token)
VALUES
  ('John Doe', 'EYODHLCN');

INSERT INTO customers_services
  (customer_id, service_id)
VALUES
  (7, 1),
  (7, 2),
  (7, 3);

-- Query 1: The current income received from big ticket services

-- Step 1: Create a table w/ all customer-service combos w/ services > 100
-- Step 2: Sum the prices of all these combos

SELECT sum(services.price)
FROM customers_services
  INNER JOIN services
  ON services.id = customers_services.service_id
WHERE services.price > 100;

-- Query 2: Find the hypothetical maximum if every customer bought every 
-- big ticket company item (idea: use a cross join!)

-- Step 1: Create the cross join

SELECT SUM(services.price)
FROM customers CROSS JOIN services
WHERE services.price > 100;

Further Exploration: Usages of cross join: Generally, cross joins will be
hypothetical scenarios, because creating all possible combinations of data
is not that useful.

Some ideas:
- We have two databases: shirts and pants. We want to know all the possible
outfits that could be made. Perhaps we want to know the count of those outfits
(and we're too lazy just to count them ourselves).ABORT

SELECT * FROM
shirts CROSS JOIN pants;

SELECT count(*) FROM
shirts CROSS JOIN pants;

-- Using subqueries:

SELECT (SELECT count(id) FROM customers) *
       (SELECT sum(price) FROM services WHERE price > 100)
       AS hypothetical_revenue;

SELECT * FROM customers CROSS JOIN services CROSS JOIN customers_services;

Since we have ON DELETE CASCADE clauses on our foreign key constraints,
we need only delete the service and customer in question. This does not apply
for the services.

DELETE FROM customers_services
WHERE service_id =
(SELECT id FROM services WHERE description = 'Bulk Email');

DELETE FROM services
WHERE description = 'Bulk Email';

DELETE FROM customers
WHERE name = 'Chen Ke-Hua';

*/