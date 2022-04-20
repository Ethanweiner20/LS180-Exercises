/* Easy 1 */

CREATE TABLE birds
(
  id serial PRIMARY KEY,
  name character varying(25),
  age integer,
  species character varying(15)
);

INSERT INTO birds
  (name, age, species)
VALUES
  ('Charlie', 3, 'Finch');
INSERT INTO birds
  (name, age, species)
VALUES
  ('Allie', 5, 'Owl');
INSERT INTO birds
  (name, age, species)
VALUES
  ('Jennifer', 3, 'Magpie');
INSERT INTO birds
  (name, age, species)
VALUES
  ('Jamie', 4, 'Owl');
INSERT INTO birds
  (name, age, species)
VALUES
  ('Roy', 8, 'Crow');

/*
Further Exploration

The form of INSERT INTO without column names expects values to be entered in
the order in which the columns appear in the table itself. That is, the default
list of column names is simply the columns of the table in their declared order.
*/

SELECT *
FROM birds;

SELECT *
FROM birds
WHERE age < 5;

-- Test First

SELECT *
FROM birds
WHERE species = 'Crow';

-- Perform update second

UPDATE birds
SET species = 'Raven'
WHERE species = 'Crow';

-- Further Exploration

SELECT *
FROM birds
WHERE name = 'Jamie';

UPDATE birds
SET species = 'Hawk'
WHERE name = 'Jamie';

SELECT *
FROM birds
WHERE age = 3 AND species = 'Finch';

DELETE FROM birds WHERE age = 3 AND species = 'Finch';

-- Write new constraint

ALTER TABLE birds
  ADD CONSTRAINT non_negative_age CHECK (age >= 0);

-- Test new constraint (should fail)

INSERT INTO birds
  (age)
VALUES
  (-3);

DROP TABLE IF EXISTS birds;

-- Note: Database must be closed to delete it

DROP DATABASE animals;

