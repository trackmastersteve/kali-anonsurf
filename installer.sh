#!/bin/bash

# Ensure we are running as root
if [ $(id -u) -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi

# For upgrades and sanity check, remove any existing i2p.list file
rm -f /etc/apt/sources.list.d/i2p.list

# Compile the i2p ppa
echo "deb https://deb.i2p2.de/ unstable main" > /etc/apt/sources.list.d/i2p.list # Default config reads repos from sources.list.d
wget https://geti2p.net/_static/i2p-debian-repo.key.asc -O /tmp/i2p-debian-repo.key.asc # Get the latest i2p repo pubkey
apt-key add /tmp/i2p-debian-repo.key.asc # Import the key
rm /tmp/i2p-debian-repo.key.asc # delete the temp key
apt update # Update repos

if [[ -n $(cat /etc/os-release |grep kali) ]]
then
	apt install libservlet3.1-java 
	wget http://ftp.us.debian.org/debian/pool/main/j/jetty9/libjetty9-java_9.4.38-1_all.deb
	dpkg -i libjetty9-java_9.4.38-1_all.deb # This should succeed without error
	apt install libecj-java libgetopt-java libservlet3.1-java glassfish-javaee ttf-dejavu i2p i2p-router libjbigi-jni #installs i2p and other dependencies
	apt -f install # resolves anything else in a broken state
fi

apt install -y i2p-keyring #this will ensure you get updates to the repository's GPG key
apt install -y secure-delete tor i2p # install dependencies, just in case

# Configure and install the .deb
dpkg-deb -b kali-anonsurf-deb-src/ kali-anonsurf.deb # Build the deb package
dpkg -i kali-anonsurf.deb || (apt -f install && dpkg -i kali-anonsurf.deb) # this will automatically install the required packages

exit 0
