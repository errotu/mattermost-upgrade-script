#!/bin/bash

################################################################################################
# The following script updates the local Mattermost instance to the newest version via cron.   #
# A backup of the instance will be taken.                                                      #
################################################################################################

# Establsh deployed Mattermost version via mmctl
deployedVersion=$(/opt/mattermost/bin/mmctl version | grep -w "Version:" | awk '{print $2}' | tr -d 'v')

# Establish latest Mattermost version via GitHub URL
latestVersion=$(curl -s https://github.com/mattermost/mattermost-server/releases | grep 'mattermost-server/releases/tag' | awk '{print $7}' | cut -d/ -f6 | tr -d '"' | sort -r | uniq | head -1 | tr -d 'v')

# Echo out versions for logging
echo -e "Deployed Mattermost version: $deployedVersion"
echo -e "Latest Mattermost version: $latestVersion"

# Define version function
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# Define upgrade function
function upgrade () {
    if curl -I "https://releases.mattermost.com/$latestVersion/mattermost-$latestVersion-linux-amd64.tar.gz" 2>&1 | grep -q -w "200\|301" ; then
        echo -e "CURL: Response OKAY! Continuing upgrade...\n"
    else
        echo -e "CURL: URL REPORTS DOWN!!! Please check Mattermost version URL and try again. Exiting upgrade..." && exit 1
    fi
    wget https://releases.mattermost.com/$latestVersion/mattermost-$latestVersion-linux-amd64.tar.gz -P /tmp/
    cd /tmp/ && tar -xf mattermost-$latestVersion-linux-amd64.tar.gz --transform='s,^[^/]\+,\0-upgrade,'
    rm /tmp/mattermost-$latestVersion-linux-amd64.tar.gz
    systemctl stop mattermost
    cp -ra /opt/mattermost/ /opt/mattermost-back-$(date +'%F-%H-%M')/
    find /opt/mattermost/ mattermost/client/ -mindepth 1 -maxdepth 1 \! \( -type d \( -path mattermost/client -o -path mattermost/client/plugins -o -path mattermost/config -o -path mattermost/logs -o -path mattermost/plugins -o -path mattermost/data \) -prune \) | sort | sudo xargs rm -r
    mv /opt/mattermost/plugins/ /opt/mattermost/plugins~ && mv /opt/mattermost/client/plugins/ /opt/mattermost/client/plugins~
    chown -hR mattermost:mattermost /tmp/mattermost-upgrade/
    cp -an /tmp/mattermost-upgrade/. /opt/mattermost/
    rm -r /tmp/mattermost-upgrade/
    # Active CAP_NET_BIND_SERVICE to allow Mattermost to bind to low ports - uncomment the below commands if the Mattermost instance is serving web requests
    #cd /opt/mattermost && setcap cap_net_bind_service=+ep ./bin/mattermost
    cd /opt/mattermost && rsync -au plugins~/ plugins && rm -rf plugins~ && rsync -au client/plugins~/ client/plugins && rm -rf client/plugins~
    systemctl start mattermost
    echo -e "Upgrade complete!"
}

# Compare versions
if [[ $(version $deployedVersion) -lt $(version $latestVersion) ]]; then
    echo -e "Deployed Mattermost version is behind latest. Conducting upgrade..."
    upgrade
    exit 0
elif [[ $(version $deployedVersion) -gt $(version $latestVersion) ]]; then
    echo -e "Deployed Mattermost version is ahead of latest. Exiting..."
    exit 0
elif [[ $(version $deployedVersion) -eq $(version $latestVersion) ]]; then
    echo -e "Deployed Mattermost version matches latest. Exiting..."
    exit 0
else
    echo -e "Unable to compare Mattermost versions. Exiting..."
    exit 1
fi