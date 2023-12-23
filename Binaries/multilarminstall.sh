#!/bin/bash

#sudo curl -s -L https://bit.ly/multilarm-linux | bash

echo "====================Multilarm v1.2023 installer===================="

echo "Updating apps..."
sudo apt-get update && sudo apt-get upgrade -y

echo "Updating architecture..."
sudo dpkg --add-architecture i386

unamestr=$(uname -m)
if [[ "$unamestr" == 'x86_64' ]]; then
echo "Installing 64-bit libraries..."
aptDepends=( 
               zlib1g:amd64
               lib32stdc++6:amd64
               libasound2-plugins:amd64
           )
sudo apt-get install -y "${aptDepends[@]}"
fi

echo "Installing .NET runtime..."
sudo wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
sudo chmod +x ./dotnet-install.sh
sudo ./dotnet-install.sh --version latest --runtime dotnet
sudo rm ./dotnet-install.sh

echo "Creating environment variables..."

LINE="export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1"
FILE=$HOME/.bashrc
grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"

LINE="export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}"
FILE=$HOME/.bashrc
grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"

unamestr=$(uname -m)
if [[ "$unamestr" == 'x86_64' ]]; then
LINE="export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
FILE=$HOME/.bashrc
grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"
fi

LINE="/usr/local/lib"
FILE=/etc/ld.so.conf.d/libbass.conf
grep -qF "$LINE" "$FILE"  || echo "$LINE" | sudo tee --append "$FILE"

echo "Updating libraries..."
sudo ldconfig

echo "Installing audio drivers..."
unamestr=$(uname -m)
if [[ "$unamestr" == 'x86_64' ]]; then
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/Multilarm -O $HOME/Multilarm   
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/Multilarm.pdb -O $HOME/Multilarm.pdb   
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbass.so -O /usr/local/lib/libbass.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassenc.so -O /usr/local/lib/libbassenc.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassenc_flac.so -O /usr/local/lib/libbassenc_flac.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassenc_mp3.so -O /usr/local/lib/libbassenc_mp3.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassenc_ogg.so -O /usr/local/lib/libbassenc_ogg.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbassflac.so -O /usr/local/lib/libbassflac.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-x64/libbass-x64/libbasswv.so -O /usr/local/lib/libbasswv.so
else
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/Multilarm -O $HOME/Multilarm
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/Multilarm.pdb -O $HOME/Multilarm.pdb
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbass.so -O /usr/local/lib/libbass.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassenc.so -O /usr/local/lib/libbassenc.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassenc_flac.so -O /usr/local/lib/libbassenc_flac.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassenc_mp3.so -O /usr/local/lib/libbassenc_mp3.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassenc_ogg.so -O /usr/local/lib/libbassenc_ogg.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbassflac.so -O /usr/local/lib/libbassflac.so
   sudo wget https://zayeed.org/multilarm/Binaries/linux-arm/libbass-arm/libbasswv.so -O /usr/local/lib/libbasswv.so
fi

DIR="$HOME/Adhan"
if [ -d "$DIR" ]; then
echo "Sample library found - will not be downloaded."
else
echo "Sample library not found. Downloading and extracting..."
sudo wget https://zayeed.org/multilarm/Binaries/SampleRes.zip -O $HOME/SampleRes.zip
sudo unzip -o $HOME/SampleRes.zip -d $HOME
sudo rm $HOME/SampleRes.zip
fi

echo "Updating file permissions..."
sudo chmod 777 $HOME/Multilarm
sudo chmod 777 /usr/local/lib/libbass.so
sudo chmod 777 /usr/local/lib/libbassenc.so
sudo chmod 777 /usr/local/lib/libbassenc_flac.so
sudo chmod 777 /usr/local/lib/libbassenc_mp3.so
sudo chmod 777 /usr/local/lib/libbassenc_ogg.so
sudo chmod 777 /usr/local/lib/libbassflac.so
sudo chmod 777 /usr/local/lib/libbasswv.so

echo "Creating Multilarm service..."
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
echo "Please save your work and reboot. You can launch Multilarm by typing on terminal: " $HOME/Multilarm