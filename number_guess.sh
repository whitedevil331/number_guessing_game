#!/bin/bash

# Set up PSQL variable for querying
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Check if the user exists
USER=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER ]]; then
  # User doesn't exist, so add them to the database
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
else
  # User exists, show their game stats
  echo "$USER" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Generate a secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Start the guessing game
echo "Guess the secret number between 1 and 1000:"

TRIES=0
while true; do
  read GUESS
  TRIES=$((TRIES + 1))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update user stats in the database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
if [[ -z $BEST_GAME || $TRIES -lt $BEST_GAME ]]; then
  BEST_GAME=$TRIES
fi

UPDATE_STATS=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID")
