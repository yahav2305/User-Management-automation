# User-Management-Automation

## Explanation

This project assumes:
- An offline network
- Users must use [802.1x](https://en.wikipedia.org/wiki/IEEE_802.1X) certificate based network authentication
- Users must use an OpenVPN Access Server certificate to access network services
- Users must use Active Directory to authenticate with network services
- A self-signed certificate chain for HTTPS
- A private python registry but no ansible-galaxy registry
- OpenVPN runs as a Docker service on a server
- EJBCA runs as a Docker service on a server
The project can be also adapted to work online in different environments with different constraints.

When users are created their files will be copied to the relevant USBs. This is done to ease installing a new Arch Linux PC or changing the hostname of an existing Arch Linux PC. The required scripts to do those jobs are not part of this project.

## Version Compatability
This project has been tested to work with EJBCA version 9.1.1 CE and OpenVPN Access Server 2.14.3

## Creating a user
This job will create a user in Active Directory, OVPN Access Server and .1X SubCA.

The user's OVPN file, VPN password and .1X cert will be saved in one of the following locations:
- If a USB with the directory **arch-installer** at its base is connected to the PC, the VPN file will be saved in that folder under the folder **vpn**, while the password file will be saved in the Downloads folder of the current user. This is done so that while installing the OS on the PC the password won't be exposed to the internet. Make sure to put the password file in the correct location after the PC is installed according to the guide. The .1X cert will be saved in the **certs** directory next to the **vpn** directory
- If a USB with the directory **change-hostname** at its base is connected to the PC, the VPN file and VPN password will be saved in the **vpn** directory inside of the **change-hostname** directory in the USB. The .1x certificate will be saved in the **certs** directory inside of the **change-hostname** directory in the USB.
- If there is no USB that fits the above that is connected to the PC, the VPN file and VPN password will be saved at the local downloads directory under the folder **vpn**, while the .1X cert will be saved in the **certs** directory under the local downloads directory.

Do note that if both a USB with the directory **arch-installer** at its base is connected to the PC while a USB with the directory **change-hostname** at its base is connected to the PC, the VPN files will be placed in one of the USBs at random. For this reason it is not recommened to connect both at the same time

Steps to run the job:
1. Only needs to be done once - Log in to Github registry with your username and password (in order to pull the ansible image):
    ````sh
    docker login ghcr.io
    ````
1. Fill out the job parameters using the **params.env** file inside of the create-new-user folder (Make sure not to commit the value of the variables in the **params.env** file!)
1. Run the **run.sh** file inside of the job folder
    ```sh
    sudo bash ./create-new-user/run.sh
    ```
1. You are done!

## Deleting a user
This job will delete an existing user in Active Directory, the OVPN Access Server and the .1X SubCA.

1. Only needs to be done once - Log in to Github registry with your username and password (in order to pull the ansible image):
    ````sh
    docker login ghcr.io
    ````
1. Fill out the job parameters using the `params.env` file inside of the delete-user folder (Make sure not to commit the value of the variables in the `params.env` file!)
1. Run the `run.sh` file inside of the job folder
    ```sh
    sudo bash ./delete-user/run.sh
    ```
1. You are done!