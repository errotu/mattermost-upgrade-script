#!/bin/bash

# Read input for desired Mattermost version to download
read -p "Enter new Mattermost version number: " MMVERSION

# Check to make sure URL is up before continuing
echo
echo "Checking URL..."
echo

if curl -I "https://releases.mattermost.com/$MMVERSION/mattermost-$MMVERSION-linux-amd64.tar.gz" 2>&1 | grep -q -w "200\|301" ; then
	echo "CURL: Response OKAY!"
	echo "Continuing upgrade..."
	echo
else
	echo "CURL: Response DOWN!!!" 
	echo "Please check Mattermost version and try again."
	echo "Exiting upgrade..."
	exit 1
fi

# Download Mattermost
wget https://releases.mattermost.com/$MMVERSION/mattermost-$MMVERSION-linux-amd64.tar.gz


# Extract downloaded file
tar -xf mattermost-$MMVERSION-linux-amd64.tar.gz --transform='s,^[^/]\+,\0-upgrade,'


# Stop Mattermost service via SystemCTL
echo "Processing upgrade of Mattermost...."
echo
echo "Mattermost service going down."
sudo systemctl stop mattermost


# Backup data and application
cd /opt/
sudo cp -ra mattermost/ mattermost-back-$(date +'%F-%H-%M')/


# Remove all files except special directories in the current Mattermost directory
sudo find mattermost/ mattermost/client/ -mindepth 1 -maxdepth 1 \! \( -type d \( -path mattermost/client -o -path mattermost/client/plugins -o -path mattermost/config -o -path mattermost/logs -o -path mattermost/plugins -o -path mattermost/data \) -prune \) | sort | sudo xargs rm -r


# Rename the plugins directory as to not interfere with the new installation
sudo mv mattermost/plugins/ mattermost/plugins~
sudo mv mattermost/client/plugins/ mattermost/client/plugins~


# Change ownership of new Mattermost files to Mattermost user
sudo chown -hR mattermost:mattermost /home/keith/mattermost-upgrade/


# Copy new files to installation directory and remove temporary files
sudo cp -an /home/keith/mattermost-upgrade/. mattermost/
sudo rm -r /home/keith/mattermost-upgrade/

# Uncomment the below 'cd' command if Mattermost instance is serving web requests
# Active CAP_NET_BIND_SERVICE to allow Mattermost to bind to low ports
#cd /opt/mattermost && sudo setcap cap_net_bind_service=+ep ./bin/mattermost


# Reinstate plugins directories
cd /opt/mattermost
sudo rsync -au plugins~/ plugins
sudo rm -rf plugins~
sudo rsync -au client/plugins~/ client/plugins
sudo rm -rf client/plugins~


# Start Mattermost service via SystemCTL
echo
echo "Restarting Mattermost service...."
sudo systemctl start mattermost
echo
echo "Upgrade complete. Please check your Mattermost instance for version: $MMVERSION."