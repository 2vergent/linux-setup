#!/bin/bash

known_compatible_distros=(
                        "Ubuntu"
                        "Debian"
                        "Arch"
                        "Manjaro"
                    )

function detect_distro_phase() 
{
    for i in "${known_compatible_distros[@]}"; 
    do
        uname -a | grep "${i}" -i > /dev/null
        if [ "$?" = "0" ]; 
            then
                distro="${i^}"
                break
        fi
    done
}

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

detect_distro_phase

case $distro in

    Ubuntu | Debian)

        echo "----------------------------------------"
        echo ">       [1/10] Updating System         <"
        echo "----------------------------------------"
        yes | sudo apt update && sudo apt upgrade && sudo apt install git

        echo "------------------------------------------"
        echo ">       [2/10] Installing Firefox         <"
        echo "------------------------------------------"
        sudo apt install firefox

        echo "---------------------------------------------"
        echo ">       [3/10] Removing LibreOffice         <"
        echo "---------------------------------------------"
        yes | sudo apt remove --purge libreoffice*
        sudo apt clean
        yes | sudo apt autoremove

        if detect_gnome;
            then
                echo "------------------------------------------------"
                echo ">       [4/10] Installing Gnome Tweaks         <"
                echo "------------------------------------------------"
                yes | sudo apt install gnome-tweaks
                gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
        else
            echo "------------------------------------------------------------------"
            echo ">       [4/10] Gnome not detected, skipping gnome-tweaks         <"
            echo "------------------------------------------------------------------"
        fi

        echo "------------------------------------------"
        echo ">       [5/10] Installing VSCode         <"
        echo "------------------------------------------"
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        yes | sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt update
        yes | sudo apt install code

        echo "-------------------------------------------"
        echo ">       [6/10] Installing Spotify         <"
        echo "-------------------------------------------"
        curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt-get update
        yes | sudo apt-get install spotify-client

        echo "-------------------------------------------"
        echo ">       [7/10] Installing Discord         <"
        echo "-------------------------------------------"
        cd ~/Downloads
        wget https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.deb
        yes | sudo apt install ./discord-0.0.15.deb

        echo "---------------------------------------------"
        echo ">       [8/10] Installing OnlyOffice         <"
        echo "---------------------------------------------"
        yes | sudo apt install flatpak
        flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak install -y flathub org.onlyoffice.desktopeditors

        echo "-------------------------------------------------------------"
        echo ">       [9/10] Installing ZSH Shell and ZSH plugins        <"
        echo "-------------------------------------------------------------"
        yes | sudo apt install zsh
        yes n | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

        echo "-----------------------------------------------------------"
        echo ">       [10/10] Updating .bashrc and .zshrc files         <"
        echo "-----------------------------------------------------------"
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
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
        sed -i '/^ZSH_THEME=/s/=.*/="powerlevel10k\/powerlevel10k"/' ~/.zshrc
        echo 'Set ZSH theme to Powerlevel10k'
        sed -i '/^plugins=/s/=.*/=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
        echo 'Updated new plugins in .zshrc'

        echo "--------------------------------------------------------"
        echo "> Authentication required for making ZSH defualt shell <"
        echo "--------------------------------------------------------"
        chsh -s /usr/bin/zsh

        echo "------------------------------------------------"
        echo ">       Phew, saved you a lot of time!         <"
        echo "------------------------------------------------"
        ;;
    
    Arch | Manjaro)

        echo "---------------------------------------"
        echo ">       [1/10] Updating System         <"
        echo "---------------------------------------"
        yes | sudo pacman -Syu
        sudo pacman -S git

        echo "------------------------------------------"
        echo ">       [2/10] Installing Firefox         <"
        echo "------------------------------------------"
        sudo pacman -S firefox

        echo "--------------------------------------------"
        echo ">       [3/10] Removing LibreOffice         <"
        echo "--------------------------------------------"
        yes | sudo pacman -Rs libreoffice

        if detect_gnome;
            then
                echo "-----------------------------------------------"
                echo ">       [4/10] Installing Gnome Tweaks         <"
                echo "-----------------------------------------------"
                yes | sudo pacman -S gnome-tweaks
                gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
        else
            echo "------------------------------------------------------------------"
            echo ">       [4/10] Gnome not detected, skipping gnome-tweaks         <"
            echo "------------------------------------------------------------------"
        fi

        echo "-----------------------------------------"
        echo ">       [5/10] Installing VSCode         <"
        echo "-----------------------------------------"
        cd ~/Downloads
        git clone https://AUR.archlinux.org/visual-studio-code-bin.git
        cd visual-studio-code-bin/
        makepkg -s
        yes | sudo pacman -U visual-studio-code-bin-*.pkg.tar.xz
        cd ../ && sudo rm -rfv visual-studio-code-bin/

        echo "------------------------------------------"
        echo ">       [6/10] Installing Spotify         <"
        echo "------------------------------------------"
        yes | sudo pacman -Sy flatpak
        flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak install -y flathub com.spotify.Client

        echo "------------------------------------------"
        echo ">       [7/10] Installing Discord         <"
        echo "------------------------------------------"
        flatpak install -y flathub com.discordapp.Discord

        echo "---------------------------------------------"
        echo ">       [8/10] Installing OnlyOffice         <"
        echo "---------------------------------------------"
        flatpak install -y  flathub org.onlyoffice.desktopeditors

        echo "-------------------------------------------------------------"
        echo ">       [9/10] Installing ZSH Shell and ZSH plugins        <"
        echo "-------------------------------------------------------------"
        yes | sudo pacman -S zsh
        yes n | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

        echo "----------------------------------------------------------"
        echo ">       [10/10] Adding your bash and zsh aliases         <"
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
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
        sed -i '/^ZSH_THEME=/s/=.*/="powerlevel10k\/powerlevel10k"/' ~/.zshrc
        echo 'Set ZSH theme to Powerlevel10k'
        sed -i '/^plugins=/s/=.*/=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
        echo 'Updated new plugins in .zshrc'

        echo "--------------------------------------------------------"
        echo "> Authentication required for making ZSH defualt shell <"
        echo "--------------------------------------------------------"
        chsh -s /usr/bin/zsh

        echo "------------------------------------------------"
        echo ">       Phew, saved you a lot of time!         <"
        echo "------------------------------------------------"
        ;;

esac
