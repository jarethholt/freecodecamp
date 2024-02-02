#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


# Make sure the database exists
echo $(psql --username=freecodecamp --dbname=postgres -c "CREATE DATABASE worldcup")

# Reset the tables to start over
echo $($PSQL 'TRUNCATE TABLE games, teams RESTART IDENTITY')
echo $($PSQL 'DROP TABLE games, teams')

# Create the teams table
echo $($PSQL 'CREATE TABLE teams()')
echo $($PSQL 'ALTER TABLE teams ADD COLUMN team_id SERIAL PRIMARY KEY')
echo $($PSQL 'ALTER TABLE teams ADD COLUMN name VARCHAR(20) UNIQUE NOT NULL')

# Create the games table
echo $($PSQL 'CREATE TABLE games()')
echo $($PSQL 'ALTER TABLE games ADD COLUMN game_id SERIAL PRIMARY KEY')
echo $($PSQL 'ALTER TABLE games ADD COLUMN year INT NOT NULL')
echo $($PSQL 'ALTER TABLE games ADD COLUMN round VARCHAR(20) NOT NULL')
echo $($PSQL 'ALTER TABLE games ADD COLUMN winner_id INT REFERENCES teams(team_id) NOT NULL')
echo $($PSQL 'ALTER TABLE games ADD COLUMN opponent_id INT REFERENCES teams(team_id) NOT NULL')
echo $($PSQL 'ALTER TABLE games ADD COLUMN winner_goals INT NOT NULL')
echo $($PSQL 'ALTER TABLE games ADD COLUMN opponent_goals INT NOT NULL')


# Read the CSV file
while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  # Skip the header line
  if [[ "$year" == 'year' ]]; then
    continue
  fi

  # Get the winner ID from the teams table
  winner_id_query="SELECT team_id FROM teams WHERE name='$winner'"
  winner_id=$($PSQL "$winner_id_query")
  if [[ -z "$winner_id" ]]; then
    $($PSQL "INSERT INTO teams(name) VALUES('$winner')")
    echo "Inserted into table teams value $winner"
    winner_id=$($PSQL "$winner_id_query")
  fi
  echo "Winner $winner ID $winner_id"

  # Get the opponent ID from the teams table
  opponent_id_query="SELECT team_id FROM teams WHERE name='$opponent'"
  opponent_id=$($PSQL "$opponent_id_query")
  if [[ -z "$opponent_id" ]]; then
    $($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
    echo "Inserted into table teams value $opponent"
    opponent_id=$($PSQL "$opponent_id_query")
  fi
  echo "Opponent $opponent ID $opponent_id"

  # With the team IDs we can now put this row in the games table
  game_query="INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES "
  game_query+="($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)"
  $($PSQL "$game_query")
  echo "Inserted into games row year=$year, round=$round, winner=$winner"
done < games.csv
