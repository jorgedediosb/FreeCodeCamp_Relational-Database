#!/bin/bash

# Program that counts down to zero from a given argument

if [[ $1 -ge 0 ]]
then
  echo -e "\n~~ Countdown Timer ~~\n"
  for (( i = $1; i >= 0; i-- ))
  do
    echo $i
    sleep 1
  done

while [[ $I -ge 0 ]]
do
  echo $I
  (( I-- ))
  sleep 1
done
else
  echo Include a positive integer as the first argument.
fi
