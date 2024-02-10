-- Script to implement all the fixes to the periodic_table database.
-- Expected to be run with --username=freecodecamp --dbname=periodic_table.

-- Delete the fake element with atomic number 1000
-- Table order doesn't matter (yet) but should be properties first
DELETE FROM properties
  WHERE atomic_number = 1000;
DELETE FROM elements
  WHERE atomic_number = 1000;

-- Add the element with atomic number 9 to your database. Its
-- name is Fluorine, symbol is F, mass is 18.998, melting point is -220,
-- boiling point is -188.1, and it's a nonmetal
-- Add the element with atomic number 10 to your database. Its
-- name is Neon, symbol is Ne, mass is 20.18, melting point is -248.6,
-- boiling point is -246.1, and it's a nonmetal
INSERT INTO elements(
  atomic_number, symbol, name
) VALUES
  (9, 'F', 'Fluorine'),
  (10, 'Ne', 'Neon');
INSERT INTO properties(
  atomic_number, weight, melting_point, boiling_point, type
) VALUES
  (9, 18.998, -220, -188.1, 'nonmetal'),
  (10, 20.18, -248.6, -246.1, 'nonmetal');

-- Rename the weight column to atomic_mass
-- Rename the melting_point column to melting_point_celsius
-- and the boiling_point column to boiling_point_celsius
ALTER TABLE properties
  RENAME COLUMN weight TO atomic_mass;
ALTER TABLE properties
  RENAME COLUMN melting_point TO melting_point_celsius;
ALTER TABLE properties
  RENAME COLUMN boiling_point TO boiling_point_celsius;

-- melting_point_celsius and boiling_point_celsius columns should be NOT NULL
ALTER TABLE properties
  ALTER COLUMN melting_point_celsius SET NOT NULL,
  ALTER COLUMN boiling_point_celsius SET NOT NULL;

-- Add the UNIQUE constraint to the symbol and name columns from the elements table
ALTER TABLE elements
  ADD CONSTRAINT elements_symbol_key UNIQUE(symbol),
  ADD CONSTRAINT elements_name_key UNIQUE(name);

-- symbol and name columns should have the NOT NULL constraint
ALTER TABLE elements
  ALTER COLUMN symbol SET NOT NULL,
  ALTER COLUMN name SET NOT NULL;

-- atomic_number from the properties table should be a foreign key
-- that references the column of the same name in the elements table
ALTER TABLE properties
  ADD CONSTRAINT properties_atomic_number_fkey
    FOREIGN KEY(atomic_number)
    REFERENCES elements(atomic_number);

-- Create a types table that will store the three types of elements
-- types should have a type_id column that is an integer and the primary key
-- types should have a type column VARCHAR NOT NULL
CREATE TABLE types(
  type_id SERIAL PRIMARY KEY,
  type VARCHAR(30) UNIQUE NOT NULL
);

-- Add the different types from the properties table to types
INSERT INTO types(type)
  SELECT DISTINCT type FROM properties
    WHERE type IS NOT NULL;

-- Change properties.type into properties.type_id INT NOT NULL
ALTER TABLE properties
  ADD COLUMN type_id INT REFERENCES types(type_id);
UPDATE properties
  SET type_id = types.type_id FROM types
    WHERE properties.type = types.type;
ALTER TABLE properties
  ALTER COLUMN type_id SET NOT NULL,
  DROP COLUMN type;

-- Capitalize the first letter of all the symbol values in the elements table
UPDATE elements
  SET symbol = INITCAP(symbol);

-- Remove all the trailing zeros after the decimals from each
-- row of the atomic_mass column. You may need to adjust a data type to
-- DECIMAL for this. The final values they should be are in the
-- atomic_mass.txt file
ALTER TABLE properties
  ALTER COLUMN atomic_mass TYPE NUMERIC;
UPDATE properties
  SET atomic_mass = TRIM(TRAILING '0' FROM atomic_mass::TEXT)::NUMERIC;
