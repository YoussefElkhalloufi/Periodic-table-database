#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Check if no argument is provided
if [ $# -eq 0 ]; then
  echo "Please provide an element as an argument."
else
  # Get the argument
  arg="$1"

  # Query the database based on the argument
  if [[ "$arg" =~ ^[0-9]+$ ]]; then
    # If it's a number, query by atomic number
    QUERY="SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
           FROM elements e
           JOIN properties p ON e.atomic_number = p.atomic_number
           JOIN types t ON p.type_id = t.type_id
           WHERE e.atomic_number = $arg;"
  else
    # Otherwise, query by symbol or name
    QUERY="SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
           FROM elements e
           JOIN properties p ON e.atomic_number = p.atomic_number
           JOIN types t ON p.type_id = t.type_id
           WHERE e.symbol = '$arg' OR e.name = '$arg';"
  fi

  # Execute the query
  ELEMENT_INFO=$($PSQL "$QUERY")

  # Process and format the output
  if [ -z "$ELEMENT_INFO" ]; then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT_INFO" | while IFS="|" read -r atomic_number symbol name type atomic_mass melting_point boiling_point
    do
      # Trim leading and trailing spaces
      atomic_number=$(echo "$atomic_number" | xargs)
      symbol=$(echo "$symbol" | xargs)
      name=$(echo "$name" | xargs)
      type=$(echo "$type" | xargs)
      atomic_mass=$(echo "$atomic_mass" | xargs)
      melting_point=$(echo "$melting_point" | xargs)
      boiling_point=$(echo "$boiling_point" | xargs)

      # Format and print the result
      echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    done
  fi
fi
