-- Script to reset the state of the periodic_table database.
-- Resets the databases to how they were after periodic_table_setup.sql is run
-- in case any hard-to-fix mistakes have been made.
-- Expected to be run with (super)user postgres.

-- Drop the current periodic_table database
DROP DATABASE periodic_table;

-- Copy over from periodic_table_orig
CREATE DATABASE periodic_table
  TEMPLATE periodic_table_orig
  OWNER freecodecamp;

-- Make sure freecodecamp also owns the tables
\connect periodic_table
ALTER TABLE properties OWNER TO freecodecamp;
ALTER TABLE elements OWNER TO freecodecamp;
