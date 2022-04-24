/* DML */

/*

CREATE TABLE devices
(
  id serial PRIMARY KEY,
  name text NOT NULL,
  created_at timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE parts
(
  id serial PRIMARY KEY,
  part_number integer UNIQUE NOT NULL,
  device_id integer REFERENCES devices(id)
);

INSERT INTO devices
  (name)
VALUES
  ('Accelerometer'),
  ('Gyroscope');

INSERT INTO parts
  (part_number, device_id)
VALUES
  (10, 1),
  (20, 1),
  (30, 1),
  (40, 2),
  (50, 2),
  (60, 2),
  (70, 2),
  (80, 2),
  (90, NULL),
  (100, NULL),
  (110, NULL);

SELECT devices.name, parts.part_number
FROM parts
  INNER JOIN devices
  ON parts.device_id = devices.id;

SELECT
  (SELECT name
  FROM devices
  WHERE devices.id = parts.device_id),
  part_number
FROM parts
WHERE parts.device_id IS NOT NULL;

SELECT *
FROM parts
WHERE part_number::text LIKE '3%'

SELECT devices.name, count(parts.id) AS num_parts
FROM devices
  LEFT OUTER JOIN parts -- Include all devices, even w/ no parts
  ON devices.id = parts.device_id
GROUP BY devices.name;

SELECT devices.name AS name, COUNT(parts.device_id)
FROM devices
  JOIN parts ON devices.id = parts.device_id
GROUP BY devices.name
ORDER BY devices.name DESC;

SELECT part_number, device_id
FROM parts
WHERE device_id IS NOT NULL;

SELECT part_number, device_id
FROM parts
WHERE device_id IS NULL;

INSERT INTO devices
  (name)
VALUES
  ('Magnetometer');
INSERT INTO parts
  (part_number, device_id)
VALUES
  (42, 3);

-- Option 1: Select only one device

SELECT name AS oldest_device
FROM devices
ORDER BY created_at ASC
LIMIT 1;

-- Option 2 (edge case): Select all devices that are the oldest

SELECT name
AS oldest_devices
FROM devices
WHERE created_at =
(SELECT min(created_at)
FROM devices)

UPDATE parts
SET device_id = 1
WHERE part_number = 70 OR part_number = 80;

UPDATE parts
SET device_id = 2
WHERE part_number = (SELECT min(part_number)
FROM parts);

UPDATE parts
SET device_id = 2
WHERE part_number IN
(SELECT part_number
FROM parts
ORDER BY part_number ASC
LIMIT 1);

-- Another option: Change device ids without needing to now parts #s

UPDATE parts
SET device_id = 1
WHERE part_number IN
(SELECT part_number
FROM parts
WHERE device_id = 2
ORDER BY part_number DESC
LIMIT 2);

*/

/* Advantage: No manual lookup of device id associated w/ accelerometer,
also deletes ANY part entries w/ accelerometer, even w/ differing device ids
- More holistically answers problem statement

DELETE FROM parts
WHERE part.device_id IN
(SELECT id
FROM devices
WHERE name = 'Accelerometer');

DELETE FROM devices
WHERE name = 'Accelerometer';

Further Exploration: How could we delete the device and parts at the same time?
- Idea 1: Condense into one table (`parts` includes the device name):
denormalized data (most likely want some separation)
- Idea 2: We could enforce deletion of any part referencing a given device
using an ON DELETE CASCADE clause for the foreign key of each part

*/

ALTER TABLE parts
  DROP CONSTRAINT parts_device_id_fkey;

ALTER TABLE PARTS
  ADD FOREIGN KEY (device_id)
  REFERENCES devices(id)
  ON DELETE CASCADE;