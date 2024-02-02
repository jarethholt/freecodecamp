#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\nTotal number of goals in all games from winning teams:"
echo "$($PSQL "SELECT SUM(winner_goals) FROM games")"

echo -e "\nTotal number of goals in all games from both teams combined:"
echo "$($PSQL "SELECT SUM(winner_goals) + SUM(opponent_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams:"
echo "$($PSQL "SELECT AVG(winner_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams rounded to two decimal places:"
echo "$($PSQL "SELECT ROUND(AVG(winner_goals), 2) FROM games")"

echo -e "\nAverage number of goals in all games from both teams:"
# echo "$($PSQL "SELECT AVG(winner_goals) + AVG(opponent_goals) FROM games")"
# expected_output expects this to have 16 decimal places
# The default implementation uses 20 decimal places, despite the previous AVG using 16...
echo "$($PSQL "SELECT ROUND(AVG(winner_goals) + AVG(opponent_goals), 16) FROM games")"

echo -e "\nMost goals scored in a single game by one team:"
echo "$($PSQL "SELECT MAX(winner_goals) FROM games")"

echo -e "\nNumber of games where the winning team scored more than two goals:"
echo "$($PSQL "SELECT COUNT(*) FROM games WHERE winner_goals > 2")"

echo -e "\nWinner of the 2018 tournament team name:"
echo "$($PSQL "SELECT name FROM teams JOIN games ON teams.team_id = games.winner_id WHERE year = 2018 AND round = 'Final'")"
# Possibly more efficient version depending on dataset sizes?
# This limits the size of the tables being joined first
# echo  "$($PSQL "SELECT name FROM teams JOIN (SELECT winner_id AS team_id FROM games WHERE year = 2018 AND round = 'Final') g USING(team_id)")"

echo -e "\nList of teams who played in the 2014 'Eighth-Final' round:"
# I found several solutions to this of varying complexity
# echo "$($PSQL "SELECT name FROM (SELECT * FROM teams LEFT JOIN (SELECT year, winner_id AS team_id FROM games WHERE year=2014 AND round='Eighth-Final') g1 USING(team_id)) winners LEFT JOIN (SELECT year, opponent_id AS team_id FROM games WHERE year=2014 AND round='Eighth-Final') g2 USING(team_id) WHERE winners.year IS NOT NULL OR g2.year IS NOT NULL ORDER BY name")"
# echo "$($PSQL "WITH g AS (SELECT winner_id, opponent_id FROM games WHERE year=2014 AND round='Eighth-Final') SELECT name FROM teams FULL JOIN (SELECT winner_id FROM g) g1 ON teams.team_id=g1.winner_id FULL JOIN (SELECT opponent_id FROM g) g2 ON teams.team_id=g2.opponent_id WHERE winner_id IS NOT NULL OR opponent_id IS NOT NULL ORDER BY name")"
# echo "$($PSQL "SELECT name FROM teams WHERE team_id IN (SELECT winner_id FROM games WHERE year = 2014 AND round = 'Eighth-Final') OR team_id IN (SELECT opponent_id FROM games WHERE year = 2014 AND round = 'Eighth-Final') ORDER BY name")"
echo "$($PSQL "WITH g AS (SELECT winner_id, opponent_id FROM games WHERE year=2014 AND round='Eighth-Final') SELECT name FROM teams WHERE team_id IN (SELECT winner_id FROM g) OR team_id IN (SELECT opponent_id FROM g) ORDER BY name")"

echo -e "\nList of unique winning team names in the whole data set:"
echo "$($PSQL "SELECT DISTINCT name FROM teams JOIN games ON teams.team_id = games.winner_id ORDER BY name")"

echo -e "\nYear and team name of all the champions:"
echo "$($PSQL "SELECT year, name FROM games JOIN teams ON games.winner_id = teams.team_id WHERE round = 'Final' ORDER BY year")"
# Optimize to use smaller tables before joining
# echo "$($PSQL "SELECT year, name FROM (SELECT year, winner_id FROM games WHERE round = 'Final') g ")"
# If the answer is expecting the string literals instead of the formatted table:
# echo "$($PSQL "SELECT CAST(year AS VARCHAR) || '|' || name FROM (SELECT year, winner_id FROM games WHERE round='Final') g LEFT JOIN teams ON g.winner_id=teams.team_id ORDER BY year")"

echo -e "\nList of teams that start with 'Co':"
echo "$($PSQL "SELECT name FROM teams WHERE name LIKE 'Co%' ORDER BY name")"
