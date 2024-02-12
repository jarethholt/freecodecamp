-- Script to initialize the database of guessing game players
-- Expected to be run using 'psql --username=freecodecamp --dbname=postgres'

-- Drop the old database and start anew
DROP DATABASE IF EXISTS number_guess;
CREATE DATABASE number_guess
  OWNER freecodecamp;
\connect number_guess

-- Create the table of player data
CREATE TABLE users(
  username VARCHAR(22) PRIMARY KEY,
  games_played INT NOT NULL,
  best_game INT NOT NULL
);
