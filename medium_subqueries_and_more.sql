/* Medium: Subqueries and More */

/*

CREATE TABLE bidders
(
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE items
(
  id serial PRIMARY KEY,
  name text NOT NULL,
  initial_price numeric(6, 2) NOT NULL,
  sales_price numeric(6, 2)
);

Note: Create a composite index for bidder_id and item_id, but they need not
be unique

CREATE TABLE bids
(
  id serial PRIMARY KEY,
  bidder_id integer NOT NULL REFERENCES bidders(id) ON DELETE CASCADE,
  item_id integer NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  amount numeric(6, 2) NOT NULL
);

ALTER TABLE items
ADD CHECK (initial_price BETWEEN 0.01 AND 1000.00),
ADD CHECK (sales_price BETWEEN 0.01 AND 1000.00); 

ALTER TABLE bids
ADD CHECK (amount BETWEEN 0.01 AND 1000.00);

SELECT name AS "Bid On Items" FROM items
WHERE id IN (SELECT item_id FROM bids);

SELECT name AS "Not Bid On" FROM items
WHERE id NOT IN (SELECT item_id FROM bids);

SELECT name FROM bidders
WHERE id IN (SELECT bidder_id FROM bids);

SELECT name FROM bidders
WHERE EXISTS
(SELECT 1 FROM bids WHERE bidders.id = bids.bidder_id);

Using a join:

SELECT DISTINCT bidders.name FROM bidders
INNER JOIN bids
ON bidders.id = bids.bidder_id;

Query From a Virtual Table:
1. Create a virtual table containing the # of bids from each individual bidder
  - Idea: Group by bidder_ids + count
2. Select thee largest count from this virtual table

-- ORDER BY / LIMIT combo

SELECT num_bids AS max
FROM (SELECT count(id) AS num_bids FROM bids GROUP BY bidder_id) AS counts
ORDER BY num_bids DESC
LIMIT 1;

-- Using the max function

SELECT max(bid_counts.count)
FROM (SELECT count(id) FROM bids GROUP BY bidder_id) AS bid_counts;

-- Without using a virtual table

SELECT count(id) AS "max_bids" FROM bids
GROUP BY bidder_id
ORDER BY max_bids DESC
LIMIT 1;

SELECT items.name,
  (SELECT count(id) FROM bids WHERE bids.item_id = items.id)
FROM items;

SELECT items.name, count(bids.id)
FROM items
LEFT OUTER JOIN bids
ON items.id = bids.item_id
GROUP BY items.id
ORDER BY items.id;

Goal: Display the id for an item that matches the given data, without using AND.

Possible tools:
- Subqueries: scalar -- 3 scalar queries?

Idea: Create 3 subqueries for each piece of data, select the intersection of the
3 subqueries by joining them

-- Using a subquery

SELECT candidates_1.id AS "Matching ID"
  FROM (SELECT id FROM items WHERE name = 'Painting') AS candidates_1
  INNER JOIN (SELECT id FROM items WHERE initial_price = 100.0) AS candidates_2
  ON candidates_1.id = candidates_2.id
  INNER JOIN (SELECT id FROM items WHERE sales_price = 250.0) AS candidates_3
  ON candidates_1.id = candidates_3.id;

-- Not using a subquery: Construct a virtual + match w/ this row using row-wise
-- comparison

SELECT id FROM items AS "Matching ID"
WHERE ROW(name, initial_price, sales_price) = ROW('Painting', 100, 250.0)

*/

/* Assessing SQL Statements */

/*

EXPLAIN ANALYZE SELECT name FROM bidders
WHERE EXISTS
(SELECT 1 FROM bids WHERE bidders.id = bids.bidder_id);

*/

/*

Using the `EXPLAIN` SQL command provides a query plan with various
cost estimations. The total cost value of this query is 66.47. The subquerying
clearly plays into the structure of the plan: there are two `seq sac` with each
node nested in one another. It appears that the cost values of the outer query
and inner subquery are relatively equivalent (22.70 to 30.88), probably due to
the fact that they traverse a similar number of rows.

When using `EXPLAIN ANALYZE` however, we can see the actual times used for
planning and execution. These values diverge a bit from the cost estimates:
for example, the subquery takes nearly 3 times as long as the outer query,
despite their cost estimates being relatively similar.

*/

/*
-- Subquery all the counts, select the maximum
EXPLAIN ANALYZE SELECT MAX(bid_counts.count) FROM
  (SELECT COUNT(bidder_id) FROM bids GROUP BY bidder_id) AS bid_counts;

-- Selects the counts of each group, orders by counts, limits answer to 1
EXPLAIN ANALYZE SELECT COUNT(bidder_id) AS max_bid FROM bids
  GROUP BY bidder_id
  ORDER BY max_bid DESC
  LIMIT 1;
*/

/*
Guess: Second query takes longer because it sorts the entire result set,
whereas the first query simply takes the maximum on the result set (which
Postgres probably has an internal mechanism for that is faster than sorting).
*/

/*

-- Comparing scalar subqueries to joins:
EXPLAIN ANALYZE SELECT name,
(SELECT COUNT(item_id) FROM bids WHERE item_id = items.id)
FROM items;

EXPLAIN ANALYZE SELECT items.name, count(bids.id)
FROM items
LEFT OUTER JOIN bids
ON items.id = bids.item_id
GROUP BY items.id;

*/

/*
Scalar subquerying:

For each item:
- Perform a subquery to select the count (note: each subquery is only limited
to a low # of rows, because we've filtered)

Join:

- Create the virtual table w/ all the bids
- Condense down into items, determining the count for each item

Extra step = Grouping

The join table query plan shows that there's more nested operations PostGres
must perform (as indicated by the existence of more nodes), which generally,
will increase the time needed to be performed.

On the other hand, the scalar subquery is a much more resource-intensive
operation, despite the slight time reduction it offers. That's important to
keep in mind.

*/