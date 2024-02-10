#!/bin/bash
# Script to interactively query the periodic_table database.

# First, test that exactly one argument was provided
if [[ $# -eq 0 ]]; then
  echo 'Please provide an element as an argument.'
  exit # 1
elif [[ $# -gt 1 ]]; then
  echo 'Only one element at a time can be provided.'
  exit # 2
fi
# We're (fairly) sure only one element was provided
TARGET="$1"
if [[ -z "$TARGET" ]]; then
  echo 'The input parameter cannot be empty.'
  exit # 1
fi

# Routine used to make the psql queries
PSQL='psql --username=freecodecamp --dbname=periodic_table -t --csv -c'

# Determine if the input was the atomic number, symbol, or name
# Use that order of precedence (number, symbol, name)
# Need the atomic number to query properties

# Is the input entirely numeric?
# Don't like querying atomic_number with non-integers
if [[ $TARGET =~ ^[0-9]+$ ]]; then
  RESULT="$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $TARGET")"
else
  RESULT="$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$TARGET'")"
  if [[ -z "$RESULT" ]]; then
    RESULT="$($PSQL "SELECT atomic_number FROM elements WHERE name = '$TARGET'")"
  fi
fi

# If the result is still empty, the element was not found
if [[ -z "$RESULT" ]]; then
  echo 'I could not find that element in the database.'
  exit # 3
fi
# If the result is not empty it should be the atomic_number
ATOMIC_NUMBER="$RESULT"

# Check: Was this the correct value?
# Get all info from the elements table
RESULT="$($PSQL "SELECT name, symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")"
IFS=',' read NAME SYMBOL <<< "$(echo "$RESULT")"
# Print result during testing
# printf 'You chose element %s (%s) with atomic number %d.\n' "$NAME" "$SYMBOL" "$ATOMIC_NUMBER"

# Query the properties table and print the results
QUERY='SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius '
QUERY+='FROM properties JOIN types USING(type_id) '
QUERY+="WHERE atomic_number = $ATOMIC_NUMBER"
RESULT="$($PSQL "$QUERY")"
IFS=',' read METAL_TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$(echo "$RESULT")"
TEMPLATE='The element with atomic number %d is %s (%s). '
TEMPLATE+='It'"'"'s a %s, with a mass of %s amu. '
TEMPLATE+='%s has a melting point of %s celsius and a boiling point of %s celsius.\n'
printf "$TEMPLATE" "$ATOMIC_NUMBER" "$NAME" "$SYMBOL" "$METAL_TYPE" "$ATOMIC_MASS" "$NAME" "$MELTING_POINT" "$BOILING_POINT"
exit # 0
