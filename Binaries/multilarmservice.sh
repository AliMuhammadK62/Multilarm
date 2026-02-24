#!/bin/bash

echo "Creating Multilarm service..."
create_multilarm_service() {
    CURRENT_USER=$(whoami)
    sudo tee "/etc/systemd/system/multilarm.service" > /dev/null <<EOL

[Unit]
Description=Multilarm
After=network.target

[Service]
ExecStart=$HOME/Multilarm
Restart=always
RestartSec=5s
User=$CURRENT_USER
WorkingDirectory=$HOME
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL
}

if [[ ! -f "/etc/systemd/system/multilarm.service" ]]; then
    create_multilarm_service
    if ! sudo systemctl enable multilarm.service; then
        echo "Failed to enable Multilarm service."
        exit 1
    fi

    if ! sudo systemctl start multilarm.service; then
        echo "Failed to start Multilarm service."
        exit 1
    fi
    echo "Systemd service created and enabled for Multilarm."
else
    echo "Systemd service already exists for Multilarm."
fi

echo "The service has been created and started. Please reboot your system to ensure the service runs properly on startup."