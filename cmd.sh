#!/bin/bash

# Start the first process
/usr/sbin/httpd -DFOREGROUND &
  
# Start the second process
/usr/sbin/shibd &
  
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?