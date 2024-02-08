#!/bin/bash
# Script to prompt a customer for a salon appointment

# Constant used to make SQL calls easier
# Note that using WSL on Windows requires psql.exe
PSQL='psql --username=freecodecamp --dbname=salon -t --csv -c'

# Retrieve the list of services for use later
RESULT="$($PSQL "SELECT service_id, name FROM services")"
# On Windows, many results have to be scrubbed of carriage returns
# RESULT="${RESULT//$'\r'}"

# Echo the result into a read statement
# The while loop is executed in a subshell if piped to
# Need to use a here-string to persist the data
declare -a SERVICE_IDS SERVICES
while IFS=',' read SERVICE_ID SERVICE; do
    SERVICE_IDS+=("$SERVICE_ID")
    SERVICES+=("$SERVICE")
done <<< "$(echo "$RESULT")"
N_SERVICES="${#SERVICES[@]}"  # Number of services available

# Greet the user
printf '\n%s\n\n' 'xXx  Punk It Up!  xXx'
printf '%s\n' 'Welcome to the Punk It Up appointment requester.'
printf '%s\n\n' 'Please choose one of the services below:'

# Function to print the list of services and read a chosen service ID
# This function didn't seem to make CodeRoad happy about reading service_id_selected...
declare SERVICE_ID_SELECTED
display_services () {
    for (( i=0; i<N_SERVICES; i++ )); do
        printf '%d) %s\n' "${SERVICE_IDS[$i]}" "${SERVICES[$i]}"
    done
    read -p "Choose a service: " SERVICE_ID_SELECTED
}

# Simple function to look up the index of the given ID
# Returns 1 if no index was found
# This is really only needed if the SERVICE_IDS get out of order
# so that SERVICE_IDS[i] != i+1 for all i
get_service_index () {
    for index in "${!SERVICE_IDS[@]}"; do
        if [[ ${SERVICE_IDS[index]} = $1 ]]; then
            printf '%d\n' "$index"
            return 0
        fi
    done
    return 1
}

# Keep asking the user to name a valid service
ERR_TEMPLATE='\nI could not find service %s. Please choose another:\n\n'
while :; do
    # Display services and read an input
    # display_services
    for (( i=0; i<N_SERVICES; i++ )); do
      printf '%d) %s\n' "${SERVICE_IDS[$i]}" "${SERVICES[$i]}"
    done
    # read -p "Choose a service: " SERVICE_ID_SELECTED
    read SERVICE_ID_SELECTED
    # Find the index of the given service ID
    # If an ID is found, break the while loop here
    SERVICE_INDEX=$(get_service_index "$SERVICE_ID_SELECTED") && break
    # Otherwise, display an error message and try again
    printf "$ERR_TEMPLATE" "$SERVICE_ID_SELECTED"
done
# A valid service was chosen
SERVICE="${SERVICES[$SERVICE_INDEX]}"
printf '\nYou chose service %d: %s\n\n' "$SERVICE_ID_SELECTED" "$SERVICE"

# Ask the user for their phone number
# read -p "What is your phone number?"$'\n' CUSTOMER_PHONE
printf 'What is your phone number?\n'
read CUSTOMER_PHONE
# Check the customers database for this phone number
CUSTOMER_ID_QUERY="SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'"
CUSTOMER_ID="$($PSQL "$CUSTOMER_ID_QUERY")"
# CUSTOMER_ID="${CUSTOMER_ID//$'\r'}"
if [[ -z "$CUSTOMER_ID" ]]; then
    # This customer is not currently in the database
    # Prompt them for their name and add them
    # read -p "I do not have a record for that phone number. What is your name?"$'\n' CUSTOMER_NAME
    printf 'I do not have a record for that phone number. What is your name?\n'
    read CUSTOMER_NAME
    # Enter this new customer in the database and retrieve the ID
    $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" > /dev/null
    CUSTOMER_ID="$($PSQL "$CUSTOMER_ID_QUERY")"
    # CUSTOMER_ID="${CUSTOMER_ID//$'\r'}"
fi

# Ask for an appointment time
printf '\n'
# read -p "What time would you like your appointment?"$'\n' SERVICE_TIME
printf 'What time would you like your appointment?\n'
read SERVICE_TIME

# Add the appointment to the appointments table
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" > /dev/null

# Print a summary message and exit
printf '\nI have put you down for a %s at %s, %s.\n' "$SERVICE" "$SERVICE_TIME" "$CUSTOMER_NAME"
