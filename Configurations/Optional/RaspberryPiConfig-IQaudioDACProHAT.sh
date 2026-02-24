#bash command to install: sudo curl -s -L https://bit.ly/RPiConfig-DACPro | bash
#!/bin/bash

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

echo "Starting Raspberry Pi setup automation..."

# 1. Install mosh
echo "Installing mosh..."
apt update
apt install -y mosh

# 2. Remove Raspberry Pi password

# Define the username for auto-login
USERNAME="root"

# Create directory for override if it doesn't exist
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/

# Write the override configuration to enable auto-login
sudo bash -c "cat > /etc/systemd/system/getty@tty1.service.d/override.conf" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF

# Reload systemd daemon to apply changes
#sudo systemctl daemon-reload

# Enable and restart getty@tty1 service to apply immediately
#sudo systemctl enable getty@tty1
#sudo systemctl restart getty@tty1

# 3. Run raspi-config in non-interactive mode to expand filesystem
echo "Running raspi-config to expand the filesystem..."
raspi-config --expand-rootfs

# 4. Configure sudoers for passwordless sudo
echo "Configuring sudoers for passwordless sudo..."
# Backup the current sudoers file
sudo cp /etc/sudoers /etc/sudoers.bak

# Use sed to perform the replacements
sudo sed -i \
  -e 's/^root\s\+ALL=(ALL:ALL)\s\+ALL$/root ALL=(ALL:ALL) NOPASSWD: ALL/' \
  -e 's/^%sudo\s\+ALL=(ALL:ALL)\s\+ALL$/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/' \
  /etc/sudoers

# Validate the sudoers file syntax
sudo visudo -c
if [ $? -eq 0 ]; then
  echo "Sudoers file updated successfully."
else
  echo "Error in sudoers file syntax. Restoring backup."
  sudo cp /etc/sudoers.bak /etc/sudoers
fi

# 5. Configure IQAudio DAC Pro
echo "Configuring IQAudio DAC Pro..."
BOOT_CONFIG="/boot/firmware/config.txt"

# Uncomment dtparam=i2s=on
sed -i '/^#*dtparam=i2s=on/ s/^#*//' "$BOOT_CONFIG"

# Comment out dtparam=audio=on
sed -i '/^dtparam=audio=on/ s/^/#/' "$BOOT_CONFIG"

# Add dtoverlay line if not present
if ! grep -q "^dtoverlay=iqaudio-dacplus" "$BOOT_CONFIG"; then
  echo "dtoverlay=iqaudio-dacplus" >> "$BOOT_CONFIG"
fi

# 6. Disable HDMI audio if dtoverlay=vc4-kms-v3d present
if grep -q "^dtoverlay=vc4-kms-v3d" "$BOOT_CONFIG"; then
  sed -i 's/^dtoverlay=vc4-kms-v3d.*/dtoverlay=vc4-kms-v3d,noaudio/' "$BOOT_CONFIG"
fi

echo "IQAudio DAC configuration completed."

# 7. Update and upgrade system packages
sudo apt update && apt upgrade -y

# 8. Configure SSH to permit root login
echo "Configuring SSH for root login..."
SSHD_CONFIG="/etc/ssh/sshd_config"
if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
  sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
else
  echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
fi
systemctl restart sshd

# 9. Run speaker test after reboot
#speaker-test -c2 -twav -l7

echo "All done! Your Raspberry Pi is now configured. Please reboot."