#!/usr/bin/env bash

shopt -s nullglob

if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi
CURRENT_USER="$(getent passwd 1000 | cut -d: -f1)"

# Set output folder to Arch install USB or change_hostname USB if exists, otherwise save in downloads
for mount in /run/media/"$CURRENT_USER"/*; do
  for folder in "arch-installer" "change-hostname"; do
    if [ -d "$mount/$folder" ]; then
      USB_PATH="$mount"
      USB_TYPE="$folder"
    fi
  done
done

# Change directory to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || { echo "Could not cd to $SCRIPT_DIR"; exit 1; }

# Create directories for output files
mkdir ./ansible/{vpn_profiles,dot1x_certs}
chown -R 1000:1000 ./ansible/{vpn_profiles,dot1x_certs}

docker compose run --rm ansible

# User already exists: notify, cleanup and exit
if [ -f "./ansible/dot1x_certs/already-exists.p12" ] || [ -f "./ansible/vpn_profiles/already-exists.ovpn" ] || [ -f "./ansible/ad-already-exists" ]; then
  rm -rf ./ansible/dot1x_certs
  rm -rf ./ansible/vpn_profiles
  rm -rf ./ansible/ad-already-exists

  echo "User already exists in Active Directory and/or OVPN and/or EJBCA .1X SubCA, check the ansible logs above"
  echo "If required to run again make sure to delete the user from Active Directory, the OVPN access server and the EJBCA .1X SubCA"

  exit 1
fi

# Arch installer USB: Move OVPN and .1x file to USB, txt file to downloads
if [[ "$USB_TYPE" == "arch-installer" ]]; then
  # OVPN file
  sudo -u "$CURRENT_USER" mkdir -p "$USB_PATH/$USB_TYPE/arch-install/vpn"
  sudo -u "$CURRENT_USER" mv ./ansible/vpn_profiles/*.ovpn "$USB_PATH/$USB_TYPE/arch-install/vpn"
  # txt file
  sudo -u "$CURRENT_USER" mkdir -p "/home/$CURRENT_USER/Downloads/vpn"
  sudo -u "$CURRENT_USER" mv ./ansible/vpn_profiles/*.txt "/home/$CURRENT_USER/Downloads/vpn"
  # .1X cert
  sudo -u "$CURRENT_USER" mkdir -p "$USB_PATH/$USB_TYPE/arch-install/certs"
  sudo -u "$CURRENT_USER" mv ./ansible/dot1x_certs/*.p12 "$USB_PATH/$USB_TYPE/arch-install/certs"
# Change hostname USB: Move VPN to USB, .1X file to downloads
elif [[ "$USB_TYPE" == "change-hostname" ]]; then
  # OVPN files
  sudo -u "$CURRENT_USER" mkdir -p "$USB_PATH/$USB_TYPE/vpn"
  sudo -u "$CURRENT_USER" mv ./ansible/vpn_profiles/* "$USB_PATH/$USB_TYPE/vpn"
  # .1X cert
  sudo -u "$CURRENT_USER" mkdir -p "/home/$CURRENT_USER/Downloads/certs"
  sudo -u "$CURRENT_USER" mv ./ansible/dot1x_certs/*.p12 "/home/$CURRENT_USER/Downloads/certs"
# No USB Found, move VPN files and .1X files to downloads folder
else
  # OVPN files
  sudo -u "$CURRENT_USER" mkdir -p "/home/$CURRENT_USER/Downloads/vpn"
  sudo -u "$CURRENT_USER" mv ./ansible/vpn_profiles/* "/home/$CURRENT_USER/Downloads/vpn"
  # .1X file
  sudo -u "$CURRENT_USER" mkdir -p "/home/$CURRENT_USER/Downloads/certs"
  sudo -u "$CURRENT_USER" mv ./ansible/dot1x_certs/* "/home/$CURRENT_USER/Downloads/certs"
fi
rmdir ./ansible/{vpn_profiles,dot1x_certs}

# Notify user
source ./params.env
echo "User $username created in active directory, OVPN Access Server and .1X SubCA"
if [[ "$USB_TYPE" == "arch-installer" ]]; then
  echo "Its OVPN file can be found in $USB_PATH/$USB_TYPE/arch-install/vpn"
  echo "Its VPN password file can be found in /home/$CURRENT_USER/Downloads/vpn"
  echo "Its .1X certificate file can be found in $USB_PATH/$USB_TYPE/arch-install/certs"
  echo "Make sure to first install the OS, then copy the text file according to the guide"
elif [[ "$USB_TYPE" == "change-hostname" ]]; then
  echo "Its OVPN file and VPN password file can be found in $USB_PATH/$USB_TYPE/vpn"
  echo "Its .1X certificate file can be found in /home/$CURRENT_USER/Downloads/certs"
else
  echo "Its OVPN file and VPN password file can be found in /home/$CURRENT_USER/Downloads/vpn"
  echo "Its .1X certificate file can be found in /home/$CURRENT_USER/Downloads/certs"
fi
