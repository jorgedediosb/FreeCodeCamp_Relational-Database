#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


# Eliminar registros existentes en las tablas 'teams' y 'games'
$PSQL "DELETE FROM teams;"

# Leer el archivo 'games.csv' y extraer los equipos/países que participan
cut -d ',' -f 3,4 games.csv | tail -n +2 | tr ',' '\n' | sort -u | while IFS= read -r TEAM
do
  # Escapar comillas en el nombre del equipo para evitar problemas en la consulta SQL
  TEAM_ESCAPED=$(echo "$TEAM" | sed "s/'/''/g")

  # Insertar equipo en la tabla 'teams' evitando duplicados
  $PSQL "INSERT INTO teams(name) VALUES ('$TEAM_ESCAPED') ON CONFLICT (name) DO NOTHING;"

  echo "Inserted team: $TEAM_ESCAPED"
done

# Reiniciar el contador de la secuencia para 'team_id'
$PSQL "SELECT setval('teams_team_id_seq', 1, false);"

# Eliminar registros existentes en la tabla 'games'
$PSQL "DELETE FROM games;"

# Leer el archivo 'games.csv' y extraer los datos para insertar en la tabla 'games'
tail -n +2 games.csv | while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Escapar comillas en los datos para evitar problemas en la consulta SQL
  ROUND_ESCAPED=$(echo "$ROUND" | sed "s/'/''/g")
  WINNER_ESCAPED=$(echo "$WINNER" | sed "s/'/''/g")
  OPPONENT_ESCAPED=$(echo "$OPPONENT" | sed "s/'/''/g")

  # Obtener los team_id de la tabla 'teams'
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER_ESCAPED'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT_ESCAPED'")

  # Insertar datos en la tabla 'games'
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$YEAR', '$ROUND_ESCAPED', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS');"

  echo "Inserted match: $YEAR, $ROUND, $WINNER vs $OPPONENT"
done
