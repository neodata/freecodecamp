#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to insert data from games.csv into worldcup database

# Truncate the teams table to start fresh
echo $($PSQL "TRUNCATE teams")

# Read teams from games.csv
cat games.csv | while IFS="," read _ _ WINNER OPPONENT _ _
do
  if [[ $WINNER != "winner" ]] && [[ $OPPONENT != "opponent" ]]
  then
    # Insert winner if not already in the teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    if [[ -z $WINNER_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
    fi

    # Insert opponent if not already in the teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
    fi
  fi
done


# Truncate the games table to start fresh
echo $($PSQL "TRUNCATE games")

# Read game data from games.csv
cat games.csv | while IFS="," read year round winner_name opponent_name winner_goals opponent_goals
do
  if [[ $winner_name != "winner" ]] && [[ $opponent_name != "opponent" ]]
  then
    # Get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner_name'")
    
    # Get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent_name'")

    # Insert game data into the games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)")

    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games: $year $round $winner_name vs $opponent_name"
    fi
  fi
done


# ====================================================================================================================================================


#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\nTotal number of goals in all games from winning teams:"
echo "$($PSQL "SELECT SUM(winner_goals) FROM games")"

echo -e "\nTotal number of goals in all games from both teams combined:"
echo "$($PSQL "SELECT SUM(winner_goals + opponent_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams:"
echo "$($PSQL "SELECT AVG(winner_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams rounded to two decimal places:"
echo "$($PSQL "SELECT ROUND(AVG(winner_goals), 2) FROM games")"

echo -e "\nAverage number of goals in all games from both teams:"
echo "$($PSQL "SELECT AVG(winner_goals + opponent_goals) FROM games")"

echo -e "\nMost goals scored in a single game by one team:"
echo "$($PSQL "SELECT MAX(GREATEST(winner_goals, opponent_goals)) FROM games")"

echo -e "\nNumber of games where the winning team scored more than two goals:"
echo "$($PSQL "SELECT COUNT(*) FROM games WHERE winner_goals > 2")"

echo -e "\nWinner of the 2018 tournament team name:"
echo "$($PSQL "SELECT t.name FROM teams t JOIN games g ON t.team_id = g.winner_id WHERE g.year = 2018 AND g.round = 'Final'")"

echo -e "\nList of teams who played in the 2014 'Eighth-Final' round:"
echo "$($PSQL "SELECT DISTINCT t.name FROM teams t JOIN games g ON t.team_id = g.winner_id OR t.team_id = g.opponent_id WHERE g.year = 2014 AND g.round = 'Eighth-Final'")"

echo -e "\nList of unique winning team names in the whole data set:"
echo "$($PSQL "SELECT DISTINCT name FROM teams WHERE team_id IN (SELECT winner_id FROM games)")"

echo -e "\nYear and team name of all the champions:"
echo "$($PSQL "SELECT g.year, t.name FROM games g INNER JOIN teams t ON g.winner_id = t.team_id WHERE round = 'Final' ORDER BY g.year")"

echo -e "\nList of teams that start with 'Co':"
echo "$($PSQL "SELECT name FROM teams WHERE name ILIKE 'Co%'")"
