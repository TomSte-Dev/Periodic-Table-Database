#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"


if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  #Get the element from the database
  #check if its a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    #if it is a number check by atomic number
    FIND_ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1;")
  else
    #its not a number and so check for words 
    FIND_ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1' OR name='$1';")
  fi
  
  if [[ -z $FIND_ELEMENT ]]
  then
    #not found in the database
    echo "I could not find that element in the database."
  else
    #found in database get results from elements table
    read ATOMIC_NUMBER BAR SYMBOL BAR NAME <<< "$FIND_ELEMENT"
    
    #get remaining results from other tables
    RESULT=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
    read TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT <<< $RESULT
    
    #display results
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
  
fi