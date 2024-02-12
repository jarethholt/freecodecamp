#!/bin/bash
# Script to play a number guessing game and record results.

# Command to use when querying the database
PSQL='psql --username=freecodecamp --dbname=number_guess -t --no-align -c '

# Right from the start, generate a number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Ask for the username
# read -p 'Enter your username:' USERNAME
echo 'Enter your username:'
read USERNAME

# See if this user is in the database
RESULT="$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")"
if [[ -z "$RESULT" ]]; then
  # The user is not in the database; it is a new player
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  PLAYER_KNOWN=0
  GAMES_PLAYED=0
else
  # The user is in the database; parse the result
  IFS='|' read USERNAME GAMES_PLAYED BEST_GAME <<< "$(echo "$RESULT")"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  # MSG="Welcome back, $USERNAME! "
  # if (( GAMES_PLAYED == 1 )); then
  #   MSG+="You have played $GAMES_PLAYED game, "
  # else
  #   MSG+="You have played $GAMES_PLAYED games, "
  # fi
  # if (( BEST_GAME == 1 )); then
  #   MSG+="and your best game took $BEST_GAME guess."
  # else
  #   MSG+="and your best game took $BEST_GAME guesses."
  # fi
  # echo "$MSG"
  PLAYER_KNOWN=1
fi

# Play the number-guessing game
NUMBER_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
read GUESS
while :; do
  # Is the guess a valid integer?
  if ! [[ $GUESS =~ ^[1-9][0-9]+$ ]]; then
    # Need to ask again and restart the loop
    # DO NOT update NUMBER_OF_GUESSES!
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi

  # The guess was valid, so update NUMBER_OF_GUESSES
  (( NUMBER_OF_GUESSES++ ))
  # Check the value of the guess
  if (( GUESS == SECRET_NUMBER )); then
    # Break out of while loop
    break
  elif (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  read GUESS
done
# The number was finally guessed correctly
(( GAMES_PLAYED++ ))

# Update the database
if (( PLAYER_KNOWN == 0 )); then
  # Insert a new player into the database
  RESULT="$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES ('$USERNAME', $GAMES_PLAYED, $NUMBER_OF_GUESSES)")"
else
  # Update this player
  # Ternary operator to determine minimum of BEST_GAME and NUMBER_OF_GUESSES
  BEST_GAME=$(( BEST_GAME < NUMBER_OF_GUESSES ? BEST_GAME : NUMBER_OF_GUESSES ))
  RESULT="$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")"
fi

# Make sure the exit notification is the last thing done by the script
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
exit 0
