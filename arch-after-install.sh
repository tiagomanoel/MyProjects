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
#   v0.03 2021-12-18
#       - add function i3 install
#       - add function office install
#   
# License: GPL. 
#
VERSION="Arch-After-Install 0.03"
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
    v0.03 2021-12-18
        - add function i3 install
        - add function office install       
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
declare -f OFFICE_INSTALL       # Install Tools of Offices
declare -f READ_USER            # Enter the name of your system user

function READ_USER()
{
    name=$(whiptail --title "Enter the name of your system user" --inputbox "type the below::" 10 60 3>&1 1>&2 2>&3)
    statussaida=$?
    if [ $statussaida = 0 ]; then
        user_comum="$name"
        else
        echo "Canceled!"
        exit 1
    fi

}

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
    xdg-user-dirs-update
}

function PRIMARY_MENU()
{
    declare main_menu # receive user information in main menu
    main_menu=$(whiptail --title "What do you want to install" --menu \
    "Use Space to select and TAB to navigate" 15 55 5 \
    "CHOSSE_DESKTOP" "Desktop Environment" \
    "SYSTEM_SOFTWARES" "Sofwares Menu" \
    "FILE" "File Tools" \
    "MEDIA" "Media tools and Plyers" \
    "FONTS" "Fonts ttf" \
    "OFFICE_INSTALL" "Tools of Offices" \
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
    "I3-GAPS" "I3wm" \
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
                    systemctl enable acpid
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
                    systemctl enable acpid
                    PRIMARY_MENU
                else
                    CHOSSE_DESKTOP
            fi        
        ;;
        I3-GAPS ) if whiptail --title "Do you want to Install?" --yesno "$software" --scrolltext 10 50
                then
                    declare -f I3_GAPS
                    function I3_GAPS()
                    {
                        #Functions#
                        declare -f Install_Softwares
                        declare -f Configure_Ambient
                        declare -f Enable_Services

                        function Install_Softwares()
                        {
                            pacman -S i3-gaps i3status dmenu ttf-dejavu xorg xorg-xinit xfce4-terminal lolcat pipewire pipewire-alsa pipewire-pulse pipewire-jack pavucontrol \
                            zsh wget ranger lynx avahi bluez bluez-utils openssh acpi acpid lxappearance arandr xdg-user-dirs feh gvfs gvfs-mtp gvfs-nfs gvfs-smb \
                            thunar thunar-archive-plugin thunar-volman wget gedit picom --noconfirm
                        }
                        
                        function Configure_Ambient()
                        {
                            #cp /etc/X11/xinit/xinitrc /home/$user_comum/.xinitrc
                            #sed -i '/exec/,/twm/ s/^/#/' /home/$user_comum/.xinitrc
                            xdg-user-dirs-update
                            echo "exec i3" >> /home/$user_comum/.xinitrc
                            autostart="if [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then
                                exec startx
                            fi"
                            echo "$autostart" >> /home/"$user_comum"/.bashrc
                            i3config="# This file has been auto-generated by i3-config-wizard(1).
                                # It will not be overwritten, so edit it as you like.
                                #
                                # Should you change your keyboard layout some time, delete
                                # this file and re-run i3-config-wizard(1).
                                #

                                # i3 config file (v4)
                                #
                                # Please see https://i3wm.org/docs/userguide.html for a complete reference!

                                set \$mod Mod1

                                # Font for window titles. Will also be used by the bar unless a different font
                                # is used in the bar {} block below.
                                font pango:dejavu 10

                                # This font is widely installed, provides lots of unicode glyphs, right-to-left
                                # text rendering and scalability on retina/hidpi displays (thanks to pango).
                                #font pango:DejaVu Sans Mono 8

                                # Start XDG autostart .desktop files using dex. See also
                                # https://wiki.archlinux.org/index.php/XDG_Autostart
                                exec --no-startup-id dex --autostart --environment i3

                                # The combination of xss-lock, nm-applet and pactl is a popular choice, so
                                # they are included here as an example. Modify as you see fit.

                                # xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
                                # screen before suspend. Use loginctl lock-session to lock your screen.
                                exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork

                                # NetworkManager is the most popular way to manage wireless networks on Linux,
                                # and nm-applet is a desktop environment-independent system tray GUI for it.
                                exec --no-startup-id nm-applet

                                # Use pactl to adjust volume in PulseAudio.
                                set \$refresh_i3status killall -SIGUSR1 i3status
                                bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && \$refresh_i3status
                                bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && \$refresh_i3status
                                bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && \$refresh_i3status
                                bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && \$refresh_i3status

                                # Use Mouse+\$mod to drag floating windows to their wanted position
                                floating_modifier \$mod

                                # start a terminal
                                bindsym \$mod+Return exec i3-sensible-terminal

                                # kill focused window
                                bindsym \$mod+Shift+q kill

                                # start dmenu (a program launcher)
                                bindsym \$mod+d exec --no-startup-id dmenu_run
                                # A more modern dmenu replacement is rofi:
                                # bindcode \$mod+40 exec \"rofi -modi drun,run -show drun\"
                                # There also is i3-dmenu-desktop which only displays applications shipping a
                                # .desktop file. It is a wrapper around dmenu, so you need that installed.
                                # bindcode \$mod+40 exec --no-startup-id i3-dmenu-desktop

                                # change focus
                                bindsym \$mod+j focus left
                                bindsym \$mod+k focus down
                                bindsym \$mod+l focus up
                                bindsym \$mod+ccedilla focus right

                                # alternatively, you can use the cursor keys:
                                bindsym \$mod+Left focus left
                                bindsym \$mod+Down focus down
                                bindsym \$mod+Up focus up
                                bindsym \$mod+Right focus right

                                # move focused window
                                bindsym \$mod+Shift+j move left
                                bindsym \$mod+Shift+k move down
                                bindsym \$mod+Shift+l move up
                                bindsym \$mod+Shift+ccedilla move right

                                # alternatively, you can use the cursor keys:
                                bindsym \$mod+Shift+Left move left
                                bindsym \$mod+Shift+Down move down
                                bindsym \$mod+Shift+Up move up
                                bindsym \$mod+Shift+Right move right

                                # split in horizontal orientation
                                bindsym \$mod+h split h

                                # split in vertical orientation
                                bindsym \$mod+v split v

                                # enter fullscreen mode for the focused container
                                bindsym \$mod+f fullscreen toggle

                                # change container layout (stacked, tabbed, toggle split)
                                bindsym \$mod+s layout stacking
                                bindsym \$mod+w layout tabbed
                                bindsym \$mod+e layout toggle split

                                # toggle tiling / floating
                                bindsym \$mod+Shift+space floating toggle

                                # change focus between tiling / floating windows
                                bindsym \$mod+space focus mode_toggle

                                # focus the parent container
                                bindsym \$mod+a focus parent

                                # focus the child container
                                #bindsym \$mod+d focus child

                                # Define names for default workspaces for which we configure key bindings later on.
                                # We use variables to avoid repeating the names in multiple places.
                                set \$ws1 \"1\"
                                set \$ws2 \"2\"
                                set \$ws3 \"3\"
                                set \$ws4 \"4\"
                                set \$ws5 \"5\"
                                set \$ws6 \"6\"
                                set \$ws7 \"7\"
                                set \$ws8 \"8\"
                                set \$ws9 \"9\"
                                set \$ws10 \"10\"

                                # switch to workspace
                                bindsym \$mod+1 workspace number \$ws1
                                bindsym \$mod+2 workspace number \$ws2
                                bindsym \$mod+3 workspace number \$ws3
                                bindsym \$mod+4 workspace number \$ws4
                                bindsym \$mod+5 workspace number \$ws5
                                bindsym \$mod+6 workspace number \$ws6
                                bindsym \$mod+7 workspace number \$ws7
                                bindsym \$mod+8 workspace number \$ws8
                                bindsym \$mod+9 workspace number \$ws9
                                bindsym \$mod+0 workspace number \$ws10

                                # move focused container to workspace
                                bindsym \$mod+Shift+1 move container to workspace number \$ws1
                                bindsym \$mod+Shift+2 move container to workspace number \$ws2
                                bindsym \$mod+Shift+3 move container to workspace number \$ws3
                                bindsym \$mod+Shift+4 move container to workspace number \$ws4
                                bindsym \$mod+Shift+5 move container to workspace number \$ws5
                                bindsym \$mod+Shift+6 move container to workspace number \$ws6
                                bindsym \$mod+Shift+7 move container to workspace number \$ws7
                                bindsym \$mod+Shift+8 move container to workspace number \$ws8
                                bindsym \$mod+Shift+9 move container to workspace number \$ws9
                                bindsym \$mod+Shift+0 move container to workspace number \$ws10

                                # reload the configuration file
                                bindsym \$mod+Shift+c reload
                                # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
                                bindsym \$mod+Shift+r restart
                                # exit i3 (logs you out of your X session)
                                bindsym \$mod+Shift+e exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'\"

                                # resize window (you can also use the mouse for that)
                                mode \"resize\" {
                                        # These bindings trigger as soon as you enter the resize mode

                                        # Pressing left will shrink the window’s width.
                                        # Pressing right will grow the window’s width.
                                        # Pressing up will shrink the window’s height.
                                        # Pressing down will grow the window’s height.
                                        bindsym j resize shrink width 10 px or 10 ppt
                                        bindsym k resize grow height 10 px or 10 ppt
                                        bindsym l resize shrink height 10 px or 10 ppt
                                        bindsym ccedilla resize grow width 10 px or 10 ppt

                                        # same bindings, but for the arrow keys
                                        bindsym Left resize shrink width 10 px or 10 ppt
                                        bindsym Down resize grow height 10 px or 10 ppt
                                        bindsym Up resize shrink height 10 px or 10 ppt
                                        bindsym Right resize grow width 10 px or 10 ppt

                                        # back to normal: Enter or Escape or \$mod+r
                                        bindsym Return mode \"default\"
                                        bindsym Escape mode \"default\"
                                        bindsym \$mod+r mode \"default\"
                                }
                                
                                ###I3-Gaps###
                                for_window [class=^.*\"] border pixel 3
                                gaps inner 5
                                gaps outer 5

                                ###BorderVolor###
                                # class				        border		backgr.		text		indicator
                                client.focused			    #4c7899		#285577		#ffffff		#2e9ef4
                                client.focused_inctive		#333333		#5f676a		#ffffff		#484e50
                                client.unfocused		    #333333		#222222		#888888		#292d2e
                                client.urgent			    #2f343a		#900000		#ffffff		#900000	

                                bindsym \$mod+r mode \"resize\"

                                # Start i3bar to display a workspace bar (plus the system information i3status
                                # finds out, if available)
                                bar {
                                        status_command i3status
                                }
                                exec picom &
                                exec --no-startup-id feh --bg-fill ~/.wallpapers/wallpaper01.jpg"
                            
                            mkdir -p /home/"$user_comum"/.config/i3
                            mkdir /home/"$user_comum"/.wallpapers
                            echo "$i3config" > /home/"$user_comum"/.config/i3/config
                            wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1GmPAqSNBAkIjfv8ry8IgrT-ulTPlVVi_' -O /home/$user_comum/.wallpapers/wallpaper01.jpg  
                            chown "$user_comum" /home/"$user_comum" -R
                        }


                        
                        function Enable_Services()
                        {
                            systemctl enable NetworkManager
                            systemctl enable avahi
                            systemctl enable sshd
                            systemctl enable bluetooth
                            systemctl enable acpid  
                        }

                        #EXEC
                        Install_Softwares
                        Configure_Ambient
                        Enable_Services
                    }
                    I3_GAPS
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
    "lsb-release" "System Information" OFF \
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
            makepkg -si --noconfirm
            rm -rf /tmp/yay-git
            exit 0
        ;;
            1) exit 0 
        ;;
    esac
}

function OFFICE_INSTALL()
{
    declare -f MENU
    declare -f INSTALL
    function MENU()
    {
        MENU=$(whiptail --title "What do you want to install" --menu \
        "Use Space to select and TAB to navigate" 15 55 5 \
        "Libre-Office" "" \
        3>&1 1>&2 2>&3)
        case "$?" in
            0) if [[ MENU != 0 ]]; then
                    INSTALL
            fi
            ;;
            1) PRIMARY_MENU
            ;;
            *) exit 0
            ;;
        esac        
    }
    function INSTALL()
    {    
            case $MENU in # Receive the function to be called
                Libre-Office) pacman -S libreoffice-fresh libreoffice-fresh-pt-br --noconfirm ;;    
            esac
    }
    MENU
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
READ_USER
VERIFY_DEPENDENCIES
PRIMARY_MENU




