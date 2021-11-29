#!/usr/bin/env bash
#
##############################################################################################################
#     ___      .______        ______  __    __          ___       _______ .___________. _______ .______      #
#    /   \     |   _  \      /      ||  |  |  |        /   \     |   ____||           ||   ____||   _  \     #
#   /  ^  \    |  |_)  |    |  ,----'|  |__|  |       /  ^  \    |  |__   `---|  |----`|  |__   |  |_)  |    #
#  /  /_\  \   |      /     |  |     |   __   |      /  /_\  \   |   __|      |  |     |   __|  |      /     #
# /  _____  \  |  |\  \----.|  `----.|  |  |  |     /  _____  \  |  |         |  |     |  |____ |  |\  \----.#
#/__/     \__\ | _| `._____| \______||__|  |__|    /__/     \__\ |__|         |__|     |_______|| _| `._____|#
###################                                                                         ##################
                  # __  .__   __.      _______..___________.     ___       __       __      #
                  #|  | |  \ |  |     /       ||           |    /   \     |  |     |  |     #
                  #|  | |   \|  |    |   (----``---|  |----`   /  ^  \    |  |     |  |     #
                  #|  | |  . `  |     \   \        |  |       /  /_\  \   |  |     |  |     #
                  #|  | |  |\   | .----)   |       |  |      /  _____  \  |  `----.|  `----.#
                  #|__| |__| \__| |_______/        |__|     /__/     \__\ |_______||_______|#
                  ###########################################################################                                                                                                                                                          

# arch-after-install.sh - Automates installation of packages after "essentials" after a base installation of Arch Linux.
#
# Site: ...
# Author: Tiago G. Manoel <tiago.g.manoel@gmail.com>
# Maintenance: Tiago G. Manoel <tiago.g.manoel@gmail.com>
#
# -----------------------------------------------------------------------------------------------------------------------
# This program automates the installation of "essential" software on the Arch Linux system after a base installation of it.
# Example: Graphic interfaces, network services, multimedia programs, office and etc...
#
# History:
#
#   v0.01 2021-11-26
#       - version starts (first services in operation) :)
#   v0.02 2021-11-26
#       - add softwares multilib and YAY Install
#   
# License: GPL. 
#
VERSION="Arch-After-Install 0.02"
USAGE_MESSAGE="
Usage: $(basename "$0") [-h | -V | -Y]
    
    -h      Help
    -V      Version
    -C      Changelog
    -Y      Yay Install
"
CHANGELOG="
Changelog: $(basename "$0")
    v0.01 2021-11-26
       - version starts (first services in operation) :)
    v0.02 2021-11-26
       - add softwares multilib and YAY Install
"
### Functions ###
declare -f PRIMARY_MENU         # Main Menu
declare -f SYSTEM_SOFTWARES     # Sofwares Menu
declare -f VERIFY_ROOT          # Check user Access
declare -f CHOSSE_DESKTOP       # Desktop Environment Menu
declare -f FILE                 # File Tools
declare -f MEDIA                # Media tools
declare -f FONTS                # Fonts ttf
declare -f VERIFY_DEPENDENCIES  # Check Dependencies
declare -f YAY_INSTALL          # Install the Yay

function VERIFY_ROOT()
{
    if [ "$(id -nu)" != "root" ]; then
        sudo -k
        pass=$(whiptail --backtitle "Installer" --title "Authentication required" --passwordbox "Installing requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $USER:" 12 50 3>&2 2>&1 1>&3-)
        exec sudo -S -p '' "$0" "$@" <<< "$pass"
        exit 1
    fi
}

function VERIFY_DEPENDENCIES()
{
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf # Add Multilib
    pacman -Syyu --noconfirm
    which whiptail || pacman -S libnewt --noconfirm
    which git || pacman -S git --noconfirm
}

function PRIMARY_MENU()
{
    declare main_menu # receive user information in main menu
    main_menu=$(whiptail --title "What do you want to install" --menu \
    "Use Space to select and TAB to navigate" 15 55 5 \
    "CHOSSE_DESKTOP" "Desktop Environment" \
    "SYSTEM_SOFTWARES" "Sofwares Menu"\
    "FILE" "File Tools" \
    "MEDIA" "Media tools and Plyers"\
    "FONTS" "Fonts ttf" \
    3>&1 1>&2 2>&3)
    case $? in # Receive the function to be called
        0) if [ main_menu != 0 ]; then $main_menu; else exit 0; fi
        ;;
        1) exit 0
        ;;
    esac

}

function CHOSSE_DESKTOP()
{
    declare software # receive information from the user in the software menu
    software=$(whiptail --title "Make for Installed" --menu \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 10 35 4 \
    "GNOME" "Ambient Gnome" \
    "PLASMA" "Kde Plasma" \
    3>&1 1>&2 2>&3)
    case $software in
        GNOME   )  if whiptail --title "Do you want to Install?" --yesno "$software" --scrolltext 10 50
                then
                    [ $? == 0 ] && pacman -S xorg xorg-server gnome fwupd gnome-packagekit networkmanager avahi bluez openssh gnome-software-packagekit-plugin \
                    archlinux-appstream-data --noconfirm 
                    systemctl enable NetworkManager
                    systemctl enable gdm.service
                    systemctl enable avahi
                    systemctl enable sshd
                    systemctl enable bluetooth
                    PRIMARY_MENU
                else
                    CHOSSE_DESKTOP
            fi        
        ;;
        PLASMA  ) if whiptail --title "Do you want to Install?" --yesno "$software" --scrolltext 10 50
                then
                    [ $? == 0 ] && pacman -S xorg plasma dolphin konsole packagekit-qt5 archlinux-appstream-data fwupd networkmanager avahi bluez mtpfs \
                    sshfs openssh kdeconnect --noconfirm
                    systemctl enable NetworkManager
                    systemctl enable bluetooth
                    systemctl enable sshd
                    systemctl enable sddm.service
                    systemctl enable avahi
                    PRIMARY_MENU
                else
                    CHOSSE_DESKTOP
            fi        
        ;;
        *       )
                if [ $? == 1 ]; then PRIMARY_MENU; fi
    esac
}

function SYSTEM_SOFTWARES()
{
    declare software # receive information from the user in the software menu
    software=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 30 75 20 \
    "acpi" "Hardware Information" OFF \
    "acpid" "Hardware Information" OFF \
    "avahi" "Zero-Configuration Networking" OFF \
    "alacritty" "Terminal Emulator" OFF \
    "bash-completion" "auto complete in bash" OFF \
    "bluez bluez-utils" "Bluetooth" OFF \
    "dosfstools mtools" "Filesystem Utility" OFF \
    "flatpak" "Sandbox on Linux" OFF \
    "fwupd" "Daemon to Update Firmware" OFF \
    "git" "Gihub" OFF \
    "reflector" "Mirros  search" OFF \
    "wget" "Download Manager" OFF \
    "iwd" "Wifi CLI" OFF \
    "jdk-openjdk" "Open Java" OFF \
    "lm_sensors" "Hardware Information" OFF \
    "mtpfs" "Media Transfer Protocol" OFF \
    "neofetch" "Hardware and Softwares Information" OFF \
    "networkmanager" "Network" OFF \
    "nfs-utils" "Network File System" OFF \
    "rsync" "fast incremental file transfer" OFF \
    "sshfs" "FUSE-based filesystem client" OFF \
    "sudo" "ROOT for users" OFF \
    "samba" "share with windows" OFF \
    "vulkan-tools" "Vulkan api tools" OFF \
    "lib32-vulkan-icd-loader" "lib 32 Vulkan" OFF \
    "wine" "windows compatibility layer" OFF \
    "wine-gecko" "windows compatibility layer" OFF \
    "wine-mono" "windows compatibility layer" OFF \
    "winetricks" "windows compatibility layer" OFF \
    "nvidia nvidia-settings" "Drivers" OFF \
    "nvidia-utils" "Drivers" OFF \
    "opencl-nvidia" "Drivers" OFF \
    "lib32-nvidia-utils" "Drivers" OFF \
    "packagekit-qt5" "Packagekit of kde" OFF \
    "xdg-user-dirs" "User Directories" OFF \
    "zsh" "Shell" OFF \
    "pipewire" "Sound for linux" OFF \
    "pipewire-alsa" "Sound for linux" OFF \
    "pipewire-jack" "Sound for linux" OFF \
    "pipewire-pulse" "Sound for linux" OFF \
    3>&1 1>&2 2>&3)
    case $? in
        0) if whiptail --title "Do you want to Install?" --yesno "$software" --scrolltext 10 50
                then
                [ $? == 0 ] && pacman -S $software --noconfirm; PRIMARY_MENU
                else
                SYSTEM_SOFTWARES
            fi  
        ;;
        1) PRIMARY_MENU 
        ;;
        *) exit 0
        ;;
    esac

}

function FILE()
{
    declare software # receive information from the user in the software menu
    software=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 30 75 20 \
    "gzip unrar p7zip" "file archiver" OFF \
    3>&1 1>&2 2>&3)
    case $? in
        0) if whiptail --title "Do you want to Install?" --yesno "$software" --scrolltext 10 50
                then
                [ $? == 0 ] && pacman -S $software --noconfirm; PRIMARY_MENU
                else
                FONTS
            fi  
        ;;
        1) PRIMARY_MENU 
        ;;
        *) exit 0
        ;;
    esac

}

function MEDIA()
{
    declare software # receive information from the user in the software menu
    software=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 30 75 20 \
    "mpv" "Media Player" OFF \
    "vlc" "Media Player" OFF \
    "ffmpeg" "convert and stream audio and video" OFF \
    "ffmpegthumbnailer" "Miniatures" OFF \
    "emby-server" "Personal media server" OFF \
    3>&1 1>&2 2>&3)
    case $? in
        0) if whiptail --title "Do you want to Install?" --yesno "$software" --scrolltext 10 50
                then
                [ $? == 0 ] && pacman -S $software --noconfirm; PRIMARY_MENU
                else
                MEDIA
            fi  
        ;;
        1) PRIMARY_MENU 
        ;;
        *) exit 0
        ;;
    esac

}

function FONTS()
{
    declare software # receive information from the user in the software menu
    software=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 30 40 20 \
    "ttc-iosevka" "" OFF \
    "ttf-anonymous-pro" "" OFF \
    "ttf-arphic-ukai" "" OFF \
    "ttf-arphic-uming" "" OFF \
    "ttf-baekmuk" "" OFF \
    "ttf-bitstream-vera" "" OFF \
    "ttf-caladea" "" OFF \
    "ttf-carlito" "" OFF \
    "ttf-cormorant" "" OFF \
    "ttf-croscore" "" OFF \
    "ttf-dejavu" "" OFF \
    "ttf-eurof" "" OFF \
    "ttf-droid" "" OFF \
    "ttf-fantasque-sans-mono" "" OFF \
    "ttf-fira-code" "" OFF \
    "ttf-fira-mono" "" OFF \
    "ttf-fira-sans" "" OFF \
    "ttf-font-awesome" "" OFF \
    "ttf-hanazono" "" OFF \
    "ttf-hannom" "" OFF \
    "ttf-ibm-plex" "" OFF \
    "ttf-inconsolata" "" OFF \
    "ttf-indic-otf" "" OFF \
    "ttf-ionicons" "" OFF \
    "ttf-jetbrains-mono" "" OFF \
    "ttf-joypixels" "" OFF \
    "ttf-junicode" "" OFF \
    "ttf-khmer" "" OFF \
    "ttf-lato" "" OFF \
    "ttf-liberation" "" OFF \
    "ttf-linux-libertine" "" OFF \
    "ttf-linux-libertine-g" "" OFF \
    "ttf-monofur" "" OFF \
    "ttf-nerd-fonts-symbols" "" OFF \
    "ttf-proggy-clean" "" OFF \
    "ttf-roboto" "" OFF \
    "ttf-roboto-mono" "" OFF \
    "ttf-sarasa-gothic" "" OFF \
    "ttf-sazanami" "" OFF \
    "ttf-tibetan-machine" "" OFF \
    "ttf-ubuntu-font-family" "" OFF \
    3>&1 1>&2 2>&3)
    case $? in
        0) if whiptail --title "Do you want to Install?" --yesno "$software" --scrolltext 10 50
                then
                [ $? == 0 ] && pacman -S $software --noconfirm; PRIMARY_MENU
                else
                FONTS
            fi  
        ;;
        1) PRIMARY_MENU 
        ;;
        *) exit 0
        ;;
    esac

}

function YAY_INSTALL()
{
    whiptail --title "Do you want to Install Yay-git?" --yesno "Yay is a Helper, used to manage packages in AUR repositories" 10 50
    case $? in
        0) which yay && echo "YAY Installed" && exit 0
            which git || sudo pacman -S git --noconfirm
            cd /tmp
            git clone http://aur.archlinux.org/yay-git
            cd yay-git
            makepkg -si
            rm -rf /tmp/yay-git
            exit 0
        ;;
            1) exit 0 
        ;;
    esac
}

# Handling of command-line options
while test -n "$1"
do
    case $1 in
        -h | --help     ) echo "$USAGE_MESSAGE"; exit 0 ;;
        -V | --version  ) echo "$VERSION";       exit 0 ;;
        -C | --changelog) echo "$CHANGELOG";     exit 0 ;;
        -Y | --yay      ) YAY_INSTALL                   ;;
        *) if test -n "$1"
            then
                echo Invalid: $1
                exit 1
            fi    
        ;;
    esac
shift
done

# EXEC
VERIFY_ROOT
VERIFY_DEPENDENCIES
PRIMARY_MENU

