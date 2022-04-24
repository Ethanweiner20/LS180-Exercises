/* DDL Exercises */

/*

CREATE TABLE stars
(
  id serial PRIMARY KEY,
  name varchar(25) UNIQUE NOT NULL,
  distance integer NOT NULL,
  spectral_type char(1),
  companions integer NOT NULL,
  CHECK (distance > 0),
  CHECK (companions >= 0)
);

CREATE TABLE planets
(
  id serial PRIMARY KEY,
  designation char(1) UNIQUE,
  mass integer
);

- Add a foreign key (star_id) => Referential integrity
- Add a star to each planet
- Add a NOT NULL constraint to star_id => required

ALTER TABLE planets
ADD COLUMN star_id integer
REFERENCES stars
(id);

ALTER TABLE planets
ALTER COLUMN star_id
SET
NOT NULL;


ALTER TABLE stars
ALTER COLUMN name TYPE
varchar
(50);

What will happen if the `stars` table already contains data, and we try to
update the data type?

Guess: All values in the `name` column will need to be casted to the new
data type (`varchar(50)`). Will it throw an error, or will the casting be
allowed? It works! The casting was allowed. I imagine that if we tried
to alter the column to be a data type incompatible with already-present values,
an error would be raised (e.g. integer or decreasing the size such that values
can no longer fit).

ALTER TABLE stars
ALTER COLUMN name TYPE
varchar
(25);

INSERT INTO stars
  (name, distance, spectral_type, companions)
VALUES
  ('Alpha Centauri B', 4, 'K', 3);

ALTER TABLE stars
ALTER COLUMN name TYPE
varchar
(50);

Note: We can alter the type of our distance column from integer -> real
because integer types can properly be cast to reals.


ALTER TABLE stars
ALTER distance TYPE real;

Even with integer data, the column type conversion should behave without error,
because the casting from integers to reals is able to be performed by SQL
for any integer.

ALTER TABLE stars
ALTER COLUMN distance TYPE
integer;

INSERT INTO stars
  (name, distance, spectral_type, companions)
VALUES
  ('Alpha Orionis', 643, 'M', 9);

ALTER TABLE stars
ALTER COLUMN distance TYPE
numeric ;

ALTER TABLE stars
ALTER COLUMN spectral_type
SET
NOT NULL;

ALTER TABLE stars
ADD CONSTRAINT spectral_type_characters
CHECK (spectral_type IN ('O', 'B', 'A', 'F', 'G', 'K', 'M'));

More succintly:

ALTER TABLE stars
ALTER spectral_type SET NOT NULL,
ADD CHECK (spectral_type IN ('O', 'B', 'A', 'F', 'G', 'K', 'M'));

Scenario: We have some data existing in `stars` that either doesn't have a
`spectral_type` or has an invalid `spectral_type`, violating the constraints
we wish to add. We can't add those constraints in the current state.ABORT

In order to properly add constraints, we must adjust the data in some way such
that the columns don't violate the constraints.

We must add non-null valid spectral types for each of the stars BEFORE adding
a constraint.

ALTER TABLE stars
DROP CONSTRAINT spectral_type_characters
,
DROP CONSTRAINT stars_spectral_type_check
,
ALTER COLUMN spectral_type
DROP NOT NULL;

INSERT INTO stars
  (name, distance, companions)
VALUES
  ('Epsilon Eridani', 10.5, 0);

INSERT INTO stars
  (name, distance, spectral_type, companions)
VALUES
  ('Lacaille 9352', 10.68, 'X', 0);

ALTER TABLE stars
ADD CHECK (spectral_type IN ('O', 'B', 'A', 'F', 'G', 'K', 'M'))
,
ALTER COLUMN spectral_type
SET
NOT NULL;


ALTER TABLE stars
DROP CONSTRAINT stars_spectral_type_check;

CREATE TYPE spectral_type_enum AS ENUM
('O', 'B', 'A', 'F', 'G', 'K', 'M');

ALTER TABLE stars
ALTER COLUMN spectral_type TYPE
spectral_type_enum
USING spectral_type::spectral_type_enum;

ALTER TABLE planets
ALTER mass
TYPE
numeric,
ALTER mass
SET
NOT NULL,
ADD CHECK
(mass > 0),
ALTER designation
SET
NOT NULL;

ALTER TABLE planets
ADD COLUMN semi_major_axis numeric NOT NULL;

If `planets` already contained some data, we can not add a new NOT NULL column
to `planets`, because any existing rows would contain no value for the new
column, thus violating that NOT NULL constraint. To fix this, we'd have to add
the column, then add data, then add the NOT NULL constraint once data is 
inputted for that column.

ALTER TABLE planets
DROP COLUMN semi_major_axis;

DELETE FROM stars;
INSERT INTO stars
  (name, distance, spectral_type, companions)
VALUES
  ('Alpha Centauri B', 4.37, 'K', 3);
INSERT INTO stars
  (name, distance, spectral_type, companions)
VALUES
  ('Epsilon Eridani', 10.5, 'K', 0);

INSERT INTO planets
  (designation, mass, star_id)
VALUES
  ('b', 0.0036, 9);
-- check star_id; see note below
INSERT INTO planets
  (designation, mass, star_id)
VALUES
  ('c', 0.1, 10); -- check star_id; see note below

ALTER TABLE planets
ADD COLUMN semi_major_axis numeric;

UPDATE planets
SET semi_major_axis = 0.04
WHERE id = 1;

UPDATE planets
SET semi_major_axis = 40
WHERE id = 2;

ALTER TABLE planets
ALTER COLUMN semi_major_axis
SET
NOT NULL;

*/

CREATE TABLE moons
(
  id serial PRIMARY KEY,
  designation integer NOT NULL CHECK(designation >= 1),
  semi_major_axis numeric CHECK(semi_major_axis > 0.0),
  mass numeric CHECK(mass > 0.0),
  planet_id integer NOT NULL REFERENCES planets(id)
);