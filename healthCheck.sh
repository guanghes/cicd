#!/bin/bash
while true; do
  echo -n `date` ":" >> /var/www/html/output.log
  curl http://th3.servegame.com/version >> /var/www/html/output.log
  echo -e " \n " >> /var/www/html/output.log
  sleep 1
done
