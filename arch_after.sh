#!/bin/bash

### Variables ###
declare MAIN_MENU # receive user information in main menu
declare SOFTWARES # receive information from the user in the software menu

### Functions ###
declare -f PRIMARY_MENU         # Main Menu
declare -f SYSTEM_SOFTWARES     # Sofwares Menu
declare -f VERIFY_ROOT          # Check user Access
declare -f CHOSSE_DESKTOP       # Desktop Environment Menu
declare -f FILE                 # File Tools
declare -f MEDIA                # Media tools
declare -f FONTS                # Fonts ttf

### make sure this is run as root ###
function VERIFY_ROOT()
{
	uid=$(id -ur)
	if [ "$uid" != "0" ]; then
	        echo "ERROR: This script must be run as root."
		if [ -x /usr/bin/sudo ]; then
			echo "try: sudo $0"
		fi
	        exit 1
	fi
}

### PRIMARY MENU ###
function PRIMARY_MENU()
{
    MAIN_MENU=$(whiptail --title "What do you want to install" --radiolist \
    "Use Space to select and TAB to navigate" 15 80 5 \
    "CHOSSE_DESKTOP" "Desktop Environment Menu" OFF \
    "SYSTEM_SOFTWARES" "Softwares of System" OFF \
    "FILE" "Compactors" OFF \
    "MEDIA" "Codecs and Players" OFF \
    "FONTS" "Text Fonts" OFF \
    3>&1 1>&2 2>&3)
    case $? in # Receive the function to be called
        0) if [ MAIN_MENU != 0 ]; then $MAIN_MENU; else exit 0; fi
        ;;
        1) exit 0
        ;;
    esac

}

# Choose your Ambient Graphic
function CHOSSE_DESKTOP()
{
    SOFTWARES=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 15 60 4 \
    "GNOME" "Ambient Gnome" OFF \
    "PLASMA" "Kde Plasma" OFF \
    3>&1 1>&2 2>&3)
    case $SOFTWARES in
        GNOME)        
            pacman -S xorg xorg-server gnome fwupd gnome-packagekit networkmanager #--nocomfirm 
            systemctl enable NetworkManager
            systemctl enable gdm.srvice
        ;;
        PLASMA) echo plasma
            pacman -S xorg plasma packagekit-qt5 packagekit-qt5 fwupd appstream networkmanager #--nocomfirm
            systemctl enable NetworkManager
            systemctl enable sddm.service
        ;;
        *)
            if [ $? == 1 ]; then PRIMARY_MENU; fi
    esac
}

function SYSTEM_SOFTWARES()
{
    SOFTWARES=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 30 75 20 \
    "acpi" "Hardware Information" OFF \
    "acpid" "Hardware Information" OFF \
    "avahi" "Zero-Configuration Networking" OFF \
    "alacritty" "Terminal Emulator" OFF \
    "bash-completion" "auto complete in bash" OFF \
    "bluez bluez-utils" "Bluetooth" OFF \
    "bash-completion" "Auto complete for Bash" OFF \
    "dosfstools mtools" "Filesystem Utility" OFF \
    "flatpak" "Sandbox on Linux" OFF \
    "fwupd" "Daemon to Update Firmware" OFF \
    "git" "Gihub" OFF \
    "neofetch" "System Info" OFF \
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
    "traker" "search tool and metadata database GNOME" OFF \
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
    "Drivers Nvidia" "Drivers" OFF \
    "packagekit-qt5" "Packagekit of kde" OFF \
    "xdg-user-dirs" "User Directories" OFF \
    "zsh" "Shell" OFF \
    "pipewire" "Sound for linux" OFF \
    "pipewire-alsa" "Sound for linux" OFF \
    "pipewire-jack" "Sound for linux" OFF \
    "pipewire-pulse" "Sound for linux" OFF \
    3>&1 1>&2 2>&3)
    case $? in
        0) pacman -S $SOFTWARES
        ;;
        1) PRIMARY_MENU 
        ;;
        *) exit 0
        ;;
    esac

}

function FILE()
{
    SOFTWARES=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 30 75 20 \
    "gzip unrar p7zip" "file archiver" OFF \
    3>&1 1>&2 2>&3)
    case $? in
        0) pacman -S $SOFTWARES
        ;;
        1) PRIMARY_MENU 
        ;;
        *) exit 0
        ;;
    esac

}

function MEDIA()
{
    SOFTWARES=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 30 75 20 \
    "mpv" "Media Player" OFF \
    "vlc" "Media Player" OFF \
    "ffmpeg" "convert and stream audio and video" OFF \
    "ffmpegthumbnailer" "Miniatures" OFF \
    "emby-server" "Personal media server" OFF \
    3>&1 1>&2 2>&3)
    case $? in
        0) pacman -S $SOFTWARES
        ;;
        1) PRIMARY_MENU 
        ;;
        *) exit 0
        ;;
    esac

}

function FONTS()
{
    SOFTWARES=$(whiptail --title "Make for Installed" --checklist --separate-output \
    "Use the Key 'SPACE' for selection!" --ok-button "INSTALL" --cancel-button "VOLTAR" 30 75 20 \
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
        0) pacman -S $SOFTWARES
        ;;
        1) PRIMARY_MENU 
        ;;
        *) exit 0
        ;;
    esac

}

# EXEC
VERIFY_ROOT
PRIMARY_MENU

