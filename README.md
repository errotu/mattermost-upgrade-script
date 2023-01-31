# Mattermost Upgrade Script (BASH)

The mattermost-upgrade-script.sh is used to update a Mattermost instance to a specified version.

## Supported Features

As of right now, the script only works on the machine for which the Mattermost instance is running. User will need to manually enter in the version of Mattermost they wish to download and install. Script requires root permissions. 

## How to Run

    git clone https://github.com/KallanX/mattermost-upgrade-script.git
    cd mattermost-upgrade-script
    chmod +x mattermost-upgrade-script.sh
    ./mattermost-upgrade-script.sh

## Notes on Cron Script

The cron script should be fully automated. Requires the ROOT account to function. Script also assumes the 'mmctl' location is '/opt/mattermost/bin'. It is also recommended to save the output from the script to a custom log file as shown in the example.

To use the automated 'post upgrade notification', export the variables before running the script.

Root Crontab Example:

``` bash
crontab -l

0       4       *       *       1       MM_TEAM=<TEAM> MM_CHANNEL=<CHANNEL> /home/<USER>/cron-mm-upgrade-script.sh > /var/log/mm-upgrade.log
```

Please be aware that you first need to [authenticate a user](https://docs.mattermost.com/manage/mmctl-command-line-tool.html#mmctl-auth-login) for being able to post the 'upgrade notification' with mmctl. To do this, execute the following command and follow the instructions:

    /opt/mattermost/bin/mmctl auth login [instance url]
