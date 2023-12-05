#!/bin/bash

echo "====================Multilarm v1.2023 installer===================="

sudo apt-get update && sudo apt-get upgrade -y

aptDepends=( 
               lib64z1
               lib32stdc++6
               libasound2-plugins:amd64
           )

sudo apt-get install -y "${aptDepends[@]}"

LINE="export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1"
FILE=$HOME/.bashrc
grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"

LINE="export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}"
FILE=$HOME/.bashrc
grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"

LINE="/usr/local/lib"
FILE=/etc/ld.so.conf.d/libbass.conf
grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"

sudo ldconfig

unamestr=$(uname -m)
if [[ "$unamestr" == 'x86_64' ]]; then
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/Multilarm -O $HOME/Multilarm   
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/Multilarm.pdb -O $HOME/Multilarm.pdb   
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbass.so -O /usr/local/lib/libbass.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassalac.so -O /usr/local/lib/libbassalac.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassape.so -O /usr/local/lib/libbassape.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbasscd.so -O /usr/local/lib/libbasscd.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassdsd.so -O /usr/local/lib/libbassdsd.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassflac.so -O /usr/local/lib/libbassflac.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbasshls.so -O /usr/local/lib/libbasshls.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassmidi.so -O /usr/local/lib/libbassmidi.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassmix.so -O /usr/local/lib/libbassmix.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassopus.so -O /usr/local/lib/libbassopus.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbasswebm.so -O /usr/local/lib/libbasswebm.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbasswv.so -O /usr/local/lib/libbasswv.so
else
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/Multilarm -O $HOME/Multilarm
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/Multilarm.pdb -O $HOME/Multilarm.pdb
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbass.so -O /usr/local/lib/libbass.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassalac.so -O /usr/local/lib/libbassalac.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassape.so -O /usr/local/lib/libbassape.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbasscd.so -O /usr/local/lib/libbasscd.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassdsd.so -O /usr/local/lib/libbassdsd.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassflac.so -O /usr/local/lib/libbassflac.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbasshls.so -O /usr/local/lib/libbasshls.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassmidi.so -O /usr/local/lib/libbassmidi.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassmix.so -O /usr/local/lib/libbassmix.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassopus.so -O /usr/local/lib/libbassopus.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbasswebm.so -O /usr/local/lib/libbasswebm.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbasswv.so -O /usr/local/lib/libbasswv.so
fi

DIR="$HOME/Adhan"
if [ -d "$DIR" ]; then
echo "Sample library detected - will not be downloaded."
else
echo "Sample library not found. Downloading and extracting..."
sudo wget https://zayeed.org/multilarm/Binaries/SampleRes.zip -O $HOME/SampleRes.zip
sudo unzip -o $HOME/SampleRes.zip -d $HOME
sudo rm $HOME/SampleRes.zip
fi

sudo chmod 777 $HOME/Multilarm
sudo chmod 777 /usr/local/lib/libbass.so
sudo chmod 777 /usr/local/lib/libbassalac.so
sudo chmod 777 /usr/local/lib/libbassape.so
sudo chmod 777 /usr/local/lib/libbasscd.so
sudo chmod 777 /usr/local/lib/libbassdsd.so
sudo chmod 777 /usr/local/lib/libbassflac.so
sudo chmod 777 /usr/local/lib/libbasshls.so
sudo chmod 777 /usr/local/lib/libbassmidi.so
sudo chmod 777 /usr/local/lib/libbassmix.so
sudo chmod 777 /usr/local/lib/libbassopus.so
sudo chmod 777 /usr/local/lib/libbasswebm.so
sudo chmod 777 /usr/local/lib/libbasswv.so

create_multilarm_service() {
    CURRENT_USER=$(whoami)
    HOME_DIR=$(eval echo ~$CURRENT_USER)

    sudo tee "/etc/systemd/system/multilarm.service" > /dev/null <<EOL
[Unit]
Description=Multilarm
After=network.target

[Service]
ExecStart=$HOME_DIR/Multilarm
Restart=always
User=$CURRENT_USER
WorkingDirectory=$HOME_DIR
StandardOutput=/var/log/multilarm.log
StandardError=/var/log/multilarm_error.log

[Install]
WantedBy=multi-user.target
EOL
}

if [[ ! -f "/etc/systemd/system/multilarm.service" ]]; then
    create_multilarm_service
    sudo systemctl enable multilarm.service
    sudo systemctl start multilarm.service
    echo "Systemd service created and enabled for Multilarm."
else
    echo "Systemd service already exists for Multilarm."
fi

echo "======================Finished successfully!======================"
