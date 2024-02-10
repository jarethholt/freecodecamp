-- Script to be executed using (super)user postgres when first starting project.
-- This script does the following:
-- 1) Copy the original periodic_table to periodic_table_orig in case of messups;
-- 2) Create the user freecodecamp and default database freecodecamp; and
-- 3) Change the owner of periodic_table to freecodecamp.
-- This script will not work if run a second time. To reset the state after this
-- script has been run, use periodic_table_reset.sql.

-- Copy the original periodic_table to periodic_table_orig
CREATE DATABASE periodic_table_orig TEMPLATE periodic_table;

-- Create the user freecodecamp and their default database
CREATE USER freecodecamp;
CREATE DATABASE freecodecamp OWNER freecodecamp;

-- Change the owner of periodic_table to freecodecamp
ALTER DATABASE periodic_table OWNER TO freecodecamp;
