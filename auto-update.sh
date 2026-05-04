#!/bin/bash

TIMESTAMP=$(date +%y/%m/%d-%H:%M)
echo "${TIMESTAMP}"

#Load current version
CURRENTMCBVERSION=$(cat /home/mcserver/current_version.txt)
echo "Current version: ${CURRENTMCBVERSION}"

#Grab newest version
#(Old way, broken by site update) DOWNLOAD_URL=$(curl -H "Accept-Encoding: identity" -H "Acc>
DOWNLOAD_URL=$(curl https://net-secondary.web.minecraft-services.net/api/v1.0/download/links>
LATESTMCBVERSION=$(echo "$DOWNLOAD_URL" | grep -oP '\d+\.\d+\.\d+\.\d+')
echo "Latest version: ${LATESTMCBVERSION}"

if [[ "$LATESTMCBVERSION" == "" ]]
then
    echo "An error occurred fetching the latest version"
    echo "Download URL = $DOWNLOAD_URL"
    exit
fi

#Compare current with newest
if [[ "$CURRENTMCBVERSION" == "$LATESTMCBVERSION" ]]
then
    echo "Up to date!"
    echo "$CURRENTMCBVERSION vs $LATESTMCBVERSION"
    exit
fi
echo "$TIMESTAMP - Outdated! Proceeding with update" >> /home/mcserver/update.log
echo "Current:$CURRENTMCBVERSION - Newest:$LATESTMCBVERSION" >> /home/mcserver/update.log

#Stop server
echo "Stopping server"
sudo systemctl stop mcbedrock

#Zip and save server to backup folder
cd /home/mcserver
zip -r "/home/mcserver/backup/mcb_${CURRENTMCBVERSION}_$(date +%y%m%d).zip" minecraft_bedroc>
echo "World backed up"

#Backup settings
sudo cp /home/mcserver/minecraft_bedrock/server.properties /home/mcserver/backup/server.prop>
sudo cp /home/mcserver/minecraft_bedrock/permissions.json /home/mcserver/backup/permissions.>
sudo cp /home/mcserver/minecraft_bedrock/allowlist.json /home/mcserver/backup/allowlist.json>
echo "Settings saved"

#Download newest version
sudo wget -U "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; BEDROCK-UPDATER)" $DOWNLOAD>
echo "Latest downloaded"

#Install newest version
sudo unzip -o /home/mcserver/versions/bedrock-server-${LATESTMCBVERSION}.zip -d /home/mcserv>
echo "Latest installed"

#Restore settings
sudo mv /home/mcserver/backup/server.properties.bkup /home/mcserver/minecraft_bedrock/server>
sudo mv /home/mcserver/backup/permissions.json.bkup /home/mcserver/minecraft_bedrock/permiss>
sudo mv /home/mcserver/backup/allowlist.json.bkup /home/mcserver/minecraft_bedrock/allowlist>
echo "Settings restored"

#Save the current version
echo $LATESTMCBVERSION > '/home/mcserver/current_version.txt'

#Start the server
echo "Starting the server!"
sudo systemctl start mcbedrock

echo "Update complete!"
