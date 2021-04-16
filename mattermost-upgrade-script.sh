#!/bin/bash

# Read input for desired Mattermost version to download
read -p "Enter new Mattermost version number: " MMVERSION

# Check to make sure URL is up before continuing
echo -e "\nChecking URL...\n"

if curl -I "https://releases.mattermost.com/$MMVERSION/mattermost-$MMVERSION-linux-amd64.tar.gz" 2>&1 | grep -q -w "200\|301" ; then
	echo -e "CURL: Response OKAY!\nContinuing upgrade...\n"
else
	echo -e "CURL: URL REPORTS - DOWN!!!\nPlease check Mattermost version and try again.\nExiting upgrade..." && exit 1
fi

# Download Mattermost
wget https://releases.mattermost.com/$MMVERSION/mattermost-$MMVERSION-linux-amd64.tar.gz

# Extract downloaded file
tar -xf mattermost-$MMVERSION-linux-amd64.tar.gz --transform='s,^[^/]\+,\0-upgrade,'

# Stop Mattermost service via SystemCTL
echo -e "Processing upgrade of Mattermost....\nMattermost service going down.\n"
sudo systemctl stop mattermost

# Backup data and application
cd /opt/ && sudo cp -ra mattermost/ mattermost-back-$(date +'%F-%H-%M')/

# Remove all files except special directories in the current Mattermost directory
sudo find mattermost/ mattermost/client/ -mindepth 1 -maxdepth 1 \! \( -type d \( -path mattermost/client -o -path mattermost/client/plugins -o -path mattermost/config -o -path mattermost/logs -o -path mattermost/plugins -o -path mattermost/data \) -prune \) | sort | sudo xargs rm -r

# Rename the plugins directory as to not interfere with the new installation
sudo mv mattermost/plugins/ mattermost/plugins~ && sudo mv mattermost/client/plugins/ mattermost/client/plugins~

# Change ownership of new Mattermost files to Mattermost user
sudo chown -hR mattermost:mattermost /home/keith/mattermost-upgrade/

# Copy new files to installation directory and remove temporary files
sudo cp -an /home/keith/mattermost-upgrade/. mattermost/
sudo rm -r /home/keith/mattermost-upgrade/

# Active CAP_NET_BIND_SERVICE to allow Mattermost to bind to low ports - uncomment the below command if Mattermost instance is serving web requests
#cd /opt/mattermost && sudo setcap cap_net_bind_service=+ep ./bin/mattermost

# Reinstate plugins directories
cd /opt/mattermost && sudo rsync -au plugins~/ plugins && sudo rm -rf plugins~ && sudo rsync -au client/plugins~/ client/plugins && sudo rm -rf client/plugins~

# Start Mattermost service via SystemCTL
echo -e "Restarting Mattermost service....\n"
sudo systemctl start mattermost
echo "Upgrade complete. Please check your Mattermost instance for version: $MMVERSION."