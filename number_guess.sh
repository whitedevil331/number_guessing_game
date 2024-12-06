#!/bin/bash

# PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if user exists in the database
USER=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER ]]; then
  # If the username doesn't exist, welcome them and insert into the database
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # If the username exists, print their previous stats
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random secret number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Start the guessing game
echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

while true; do
  read GUESS

  # Check if the guess is an integer
  if [[ ! "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Increment the guess count
  ((GUESS_COUNT++))

  # Check if the guess is correct
  if [[ "$GUESS" -lt "$SECRET_NUMBER" ]]; then
    echo "It's higher than that, guess again:"
  elif [[ "$GUESS" -gt "$SECRET_NUMBER" ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Update the number of games played and best game score
    NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
    if [[ $BEST_GAME -eq 0 || $GUESS_COUNT -lt $BEST_GAME ]]; then
      NEW_BEST_GAME=$GUESS_COUNT
    else
      NEW_BEST_GAME=$BEST_GAME
    fi

    # Update the database with new stats
    UPDATE_USER=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NEW_BEST_GAME WHERE username='$USERNAME'")
    
    break
  fi
done
#done