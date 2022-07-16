#!/bin/bash
#create database link variable
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c "

if [[ $1 ]]
then
  #if not number for atomic_number
  if [[ ! $1 =~ ^[0-9]+$ ]]
    then
      #is simbol or name
      SYMBOL_ARG=$(echo $1 | cut -c1-2)
      if [[ $SYMBOL_ARG =~ ^[a-zA-Z]$  ]]
        then
          ELEMENT_INFO=$($PSQL "select * from elements where symbol ILIKE '$SYMBOL_ARG'")
        else
          ELEMENT_INFO=$($PSQL "select * from elements where name ~* '^$SYMBOL_ARG'")
      fi
    else
      ELEMENT_INFO=$($PSQL "select * from elements where atomic_number=$1") 
   fi
  #verify element is in database
  if [[ -z $ELEMENT_INFO ]]
  then
    echo "I could not find that element in the database."
  else  
    #database info into variables
    echo "$ELEMENT_INFO" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
      do
        #echo "element: $ATOMIC_NUMBER $SYMBOL $NAME"
        ELEMENT_PROPERTIES=$($PSQL "select type_id,atomic_mass,melting_point_celsius,boiling_point_celsius from properties where atomic_number = $ATOMIC_NUMBER" )
        echo "$ELEMENT_PROPERTIES" | while read TYPE_ID BAR ATOMIC_MASS BAR MELT_POINT BAR BOIL_POINT
          do
            #echo "properties : $TYPE_ID $ATOMIC_MASS $MELT_POINT $BOIL_POINT"
            #receive type from types table
            TYPE=$($PSQL "select type from types where type_id=$TYPE_ID")
            echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $(echo $TYPE | sed 's/ //g'), with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
          done 
      done
  fi  
else
  echo "Please provide an element as an argument."
fi
