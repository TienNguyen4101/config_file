#!/bin/bash

# Start the first process
service nginx start &
  
# Start the second process
service mariadb start &
  
service php7.4-fpm start &
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?
