# Mattermost Upgrade Script (BASH)
The mattermost-upgrade-script.sh is used to update a Mattermost instance to a specified version.

## Supported Features
As of right now, the script only works on the machine for which the Mattermost instance is running. User will need to manually enter in the version of Mattermost they wish to download and install. Script requires root permissions. 

## How to Run

    git clone https://github.com/KallanX/mattermost-upgrade-script.git
    cd mattermost-upgrade-script
    chmod +x mattermost-upgrade-script.sh
    ./mattermost-upgrade-script.sh

## Future Enhancements
- Built-in support to update remote Mattermost systems.
- Additional options support to adhere to various deployment setups.