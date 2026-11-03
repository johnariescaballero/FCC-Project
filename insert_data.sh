#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Delete table data and reset serial
TRUNCATE_RESULT=$($PSQL "TRUNCATE TABLE teams, games RESTART IDENTITY CASCADE")
echo -e "Successfully deleted and reset table data\n"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then 
    # INSERT DATA TO TEAMS
    # Check if team_id exists and insert if not
    WINNER_ID_EXISTS=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID_EXISTS ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
      echo Inserted item: $WINNER
    fi

    OPPONENT_ID_EXISTS=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID_EXISTS ]]
    then 
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
      echo Inserted Item: $OPPONENT
    fi

    WINNER_ID_EXISTS=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID_EXISTS=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # ~~~ INSERT DATA TO GAMES TABLE ~~~
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
      VALUES ($YEAR, '$ROUND', $WINNER_ID_EXISTS, $OPPONENT_ID_EXISTS, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done