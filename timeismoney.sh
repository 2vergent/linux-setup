#!/bin/bash

echo "---------------------------------"
echo ">       Updating System         <"
echo "---------------------------------"
sudo apt update && sudo apt upgrade

echo "----------------------------------"
echo ">       Removing Firefox         <"
echo "----------------------------------"
sudo apt remove firefox
sudo apt clean
sudo apt autoremove

echo "--------------------------------------"
echo ">       Removing LibreOffice         <"
echo "--------------------------------------"
sudo apt remove --purge libreoffice*
sudo apt clean
sudo apt autoremove

echo "-----------------------------------------"
echo ">       Installing Gnome Tweaks         <"
echo "-----------------------------------------"
function detect_gnome()
{
    ps -e | grep -E '^.* gnome-session$' > /dev/null
    if [ $? -ne 0 ];
    then
    return 0
    fi
    VERSION=`gnome-session --version | awk '{print $2}'`
    DESKTOP="GNOME"
    return 1
}

if detect_gnome;
    then sudo apt install gnome-tweaks
fi

echo "------------------------------------------"
echo ">       Installing Brave Browser         <"
echo "------------------------------------------"
sudo apt install apt-transport-https curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser

echo "-----------------------------------"
echo ">       Installing VSCode         <"
echo "-----------------------------------"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code

echo "------------------------------------"
echo ">       Installing Spotify         <"
echo "------------------------------------"
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client

echo "------------------------------------"
echo ">       Installing Discord         <"
echo "------------------------------------"
wget https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.deb
sudo apt install ./discord-0.0.15.deb

echo "---------------------------------------"
echo ">       Installing OnlyOffice         <"
echo "---------------------------------------"
sudo apt install flatpak
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.onlyoffice.desktopeditors
flatpak clean

echo "------------------------------------------------"
echo ">       Phew, saved you a lot of time!         <"
echo "------------------------------------------------"
