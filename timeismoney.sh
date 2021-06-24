#!/bin/bash

known_compatible_distros=(
                        "Ubuntu"
                        "Debian"
                        "Fedora"
                        "Red Hat"
                        "Arch"
                    )

function detect_distro_phase() {

    for i in "${known_compatible_distros[@]}"; do
        uname -a | grep "${i}" -i > /dev/null
        if [ "$?" = "0" ]; then
            distro="${i^}"
            break
        fi
    done
}

detect_distro_phase

case $distro in

    Ubuntu)

        echo "----------------------------------------"
        echo ">       [1/11] Updating System         <"
        echo "----------------------------------------"
        yes | sudo apt update && sudo apt upgrade

        echo "-----------------------------------------"
        echo ">       [2/11] Removing Firefox         <"
        echo "-----------------------------------------"
        yes | sudo apt remove firefox
        sudo apt clean
        yes | sudo apt autoremove

        echo "---------------------------------------------"
        echo ">       [3/11] Removing LibreOffice         <"
        echo "---------------------------------------------"
        yes | sudo apt remove --purge libreoffice*
        sudo apt clean
        yes | sudo apt autoremove

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
            then
                echo "------------------------------------------------"
                echo ">       [4/11] Installing Gnome Tweaks         <"
                echo "------------------------------------------------"
                yes | sudo apt install gnome-tweaks
        fi

        echo "-------------------------------------------------"
        echo ">       [5/11] Installing Brave Browser         <"
        echo "-------------------------------------------------"
        yes | sudo apt install apt-transport-https curl
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        sudo apt update
        yes | sudo apt install brave-browser

        echo "------------------------------------------"
        echo ">       [6/11] Installing VSCode         <"
        echo "------------------------------------------"
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        yes | sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt update
        yes | sudo apt install code

        echo "-------------------------------------------"
        echo ">       [7/11] Installing Spotify         <"
        echo "-------------------------------------------"
        curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt-get update
        yes | sudo apt-get install spotify-client

        echo "-------------------------------------------"
        echo ">       [8/11] Installing Discord         <"
        echo "-------------------------------------------"
        cd ~/Downloads
        wget https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.deb
        yes | sudo apt install ./discord-0.0.15.deb

        echo "---------------------------------------------"
        echo ">       [9/11] Installing OnlyOffice         <"
        echo "---------------------------------------------"
        yes | sudo apt install flatpak
        flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        yes | flatpak install -y flathub org.onlyoffice.desktopeditors

        echo "-----------------------------------------------"
        echo ">       [10/11] Installing ZSH Shell         <"
        echo "-----------------------------------------------"
        yes | sudo apt install zsh
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        chsh -s /usr/bin/zsh

        echo "----------------------------------------------------------"
        echo ">       [11/11] Adding your bash and zsh aliases         <"
        echo "----------------------------------------------------------"
        echo -e '\n' >> ~/.bashrc
        echo '# Your aliases' >> ~/.bashrc
        echo 'alias cls="clear"' >> ~/.bashrc
        echo 'alias update="sudo apt update && sudo apt upgrade"' >> ~/.bashrc
        echo 'Added aliases to .bashrc'
        echo -e '\n' >> ~/.zshrc
        echo '# Your aliases' >> ~/.zshrc
        echo 'alias cls="clear"' >> ~/.zshrc
        echo 'alias update="sudo apt update && sudo apt upgrade"' >> ~/.zshrc
        echo 'Added aliases to .zshrc'

        echo "------------------------------------------------"
        echo ">       Phew, saved you a lot of time!         <"
        echo "------------------------------------------------"
        ;;
    
    Arch)

        echo "---------------------------------------"
        echo ">       [1/11] Updating System         <"
        echo "---------------------------------------"
        yes | sudo pacman -Syu

        echo "----------------------------------------"
        echo ">       [2/11] Removing Firefox         <"
        echo "----------------------------------------"
        yes | sudo pacman -Rs firefox
        sudo updatedb

        echo "--------------------------------------------"
        echo ">       [3/11] Removing LibreOffice         <"
        echo "--------------------------------------------"
        yes | sudo pacman -Rs libreoffice

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
            then
                echo "-----------------------------------------------"
                echo ">       [4/11] Installing Gnome Tweaks         <"
                echo "-----------------------------------------------"
                yes | sudo apt install gnome-tweaks
        fi

        echo "------------------------------------------------"
        echo ">       [5/11] Installing Brave Browser         <"
        echo "------------------------------------------------"
        yes | sudo pacman -S --needed git base-devel
        cd ~/Downloads
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        yes | yay -S brave

        echo "-----------------------------------------"
        echo ">       [6/11] Installing VSCode         <"
        echo "-----------------------------------------"
        cd ~/Downloads
        git clone https://AUR.archlinux.org/visual-studio-code-bin.git
        cd visual-studio-code-bin/
        makepkg -s
        yes | sudo pacman -U visual-studio-code-bin-*.pkg.tar.xz
        cd ../ && sudo rm -rfv visual-studio-code-bin/

        echo "------------------------------------------"
        echo ">       [7/11] Installing Spotify         <"
        echo "------------------------------------------"
        yes | sudo pacman -Sy flatpak
        flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        yes | flatpak install -y flathub com.spotify.Client

        echo "------------------------------------------"
        echo ">       [8/11] Installing Discord         <"
        echo "------------------------------------------"
        yes | flatpak install -y flathub com.discordapp.Discord

        echo "---------------------------------------------"
        echo ">       [9/11] Installing OnlyOffice         <"
        echo "---------------------------------------------"
        yes | flatpak install -y  flathub org.onlyoffice.desktopeditors

        echo "-----------------------------------------------"
        echo ">       [10/11] Installing ZSH Shell         <"
        echo "-----------------------------------------------"
        yes | sudo apt install zsh
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        chsh -s /usr/bin/zsh

        echo "----------------------------------------------------------"
        echo ">       [11/11] Adding your bash and zsh aliases         <"
        echo "----------------------------------------------------------"
        echo -e '\n' >> ~/.bashrc
        echo '# Your aliases' >> ~/.bashrc
        echo 'alias cls="clear"' >> ~/.bashrc
        echo 'alias update="sudo apt update && sudo apt upgrade"' >> ~/.bashrc
        echo 'Added aliases to .bashrc'
        echo -e '\n' >> ~/.zshrc
        echo '# Your aliases' >> ~/.zshrc
        echo 'alias cls="clear"' >> ~/.zshrc
        echo 'alias update="sudo apt update && sudo apt upgrade"' >> ~/.zshrc
        echo 'Added aliases to .zshrc'

        echo "------------------------------------------------"
        echo ">       Phew, saved you a lot of time!         <"
        echo "------------------------------------------------"
        ;;

esac
