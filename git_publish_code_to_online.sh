#!/bin/bash

echo 'rsync start...'
cd /home/code/

echo -e "\033[34m"
echo 'git pull:'
git pull
echo -e "\033[0m"

echo ""
echo -e "\033[31m please input [y|n]:\c"
read IS
echo -e "\033[0m"
if [ $IS == 'y' ]
then

   echo -e "\033[34m"
   echo "rsync 192.168.1.2..."
   rsync --delete --exclude=webroot/uploads -artuzv -R * 192.168.1.2::webroot

   echo "rsync 192.168.1.3..."
   rsync --delete --exclude=webroot/uploads -artuzv -R * 192.168.1.3::webroot

   echo "rsync 192.168.1.4..."
   rsync --delete --exclude=webroot/uploads -artuzv -R * 192.168.1.4::webroot

   echo "rsync 192.168.1.5..."
   rsync --delete --exclude=webroot/uploads -artuzv -R * 192.168.1.5::webroot

   echo "rsync 192.168.1.6..."
   rsync --delete --exclude=webroot/uploads -artuzv -R * 192.168.1.6::webroot

   echo "rsync 192.168.1.7..."
   rsync --delete --exclude=webroot/uploads -artuzv -R * 192.168.1.7::webroot
                                                                                             
   echo -e "\033[0m"
else
   exit
fi