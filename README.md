# Mattermost Upgrade Script (BASH) - Uberspace
The mattermost-upgrade-script.sh is used to update a Mattermost instance on the [uberspace hosting service](https://uberspace.de) to a specified version. For more details on the installation of Mattermost on an uberspace, see this [tutorial](https://lab.uberspace.de/guide_mattermost/).

## Supported Features
As of right now, the script only works on the machine for which the Mattermost instance is running. User will need to either manually enter in the version of Mattermost they wish to download and install or use the cronjob version for automatic updates.

## Credits
This script is largely based on the [Mattermost upgrade script by KallanX](https://github.com/KallanX/mattermost-upgrade-script). I uncommented the parts not needed for a Mattermost instance hosted on an uberspace server, removed everything requiring root access, changed the directories and replaced systemctl with supervisorctl.
I also adjusted the "How to Run" in this ReadMe.

## How to Run
### The Manual Installer (with interaction)
Download the current version of the script, make it executable and execute it.

    wget https://raw.githubusercontent.com/errotu/mattermost-upgrade-script/main/mattermost-upgrade-script.sh && chmod +x mattermost-upgrade-script.sh
    ./mattermost-upgrade-script.sh

### The Automatic Installer (as Cronjob)

The cron script should be fully automated. Script also assumes the 'mmctl' location is '~/mattermost/bin'. It is also recommended to save the output from the script to a custom log file as shown in the example.

Download the current version of the script and make it executable.

    wget https://raw.githubusercontent.com/errotu/mattermost-upgrade-script/main/cron-mm-upgrade-script.sh && chmod +x cron-mm-upgrade-script.sh

Add a new cronjob:

    crontab -e



To use the automated 'post upgrade notification', export the variables before running the script. Use the handle, not the display name for Team and Channel (it's the same string which is used in the URL). For example, this cronjob would be executed every Friday morning, 3am, and send the logs to the channel "Example Channel" of the team "Example Team".
    
    MM_TEAM = 'example-team'
    MM_CHANNEL = 'example-channel'
    
    0   3   *   *  5       $HOME/cron-mm-upgrade-script.sh > $HOME/logs/mm-upgrade.log


Please be aware that you first need to [authenticate a user](https://docs.mattermost.com/manage/mmctl-command-line-tool.html#mmctl-auth-login) for being able to post with mmctl. To do this, execute the following command and follow the instructions:

    ~/mattermost/bin/mmctl auth login [instance url]
