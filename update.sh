#!/usr/bin/env bash

#
# This script updates all We All Code computers.
#
# bash <(curl -fsSL "wac.fyi/juno?$RANDOM")
#

VERSION="2.0.33"

URL="https://raw.githubusercontent.com/WeAllCode/linux-update/juno"

# Set username
# USER=$(whoami)
USER='weallcode'
# MACHINE_TYPE=$(uname -m)

# Set home
HOMEDIR="/home/$USER"

# SCRIPTDIR="/etc/init.d"
# SCRIPT="weallcode-phonehome"

# CONFDIR="/etc/init"
# CONF="$SCRIPT.conf"

# CRONDIR="/etc/cron.d"


# userrun() {
#     sudo -H -u $USER bash -c "$1";
# }

output() {
    printf "\n####################\n# %s\n####################\n" "$1";
    # userrun "notify-send --urgency=low '$1'";
}

debInst() {
    dpkg-query -Wf'${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

version() {
    output "Version: $VERSION";
}

install() {
    output "Install $1"

    debInst "$1"
    if [ $? -eq 1 ]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -o=Dpkg::Use-Pty=0 --allow-remove-essential -y "$1"
    fi
}

uninstall() {
    output "Uninstall $1"

    if debInst "$1"; then
        if [ -x "$2" ]; then
            sudo apt-get -qq autoremove --purge -y "$2"
        else
            sudo apt-get -qq autoremove --purge -y "$1"
        fi
    fi
}

# Reset ~/.bashrc settings
setBashrc() {
    output "Reset ~/.bashrc settings"
    wget -qLO "$HOMEDIR/.bashrc" \
          "$URL$HOMEDIR/.bashrc"

    source "$HOMEDIR/.bashrc"
}


# Set custom theme to indicate update running
setCustomTheme() {
    output "Set custom theme to indicate update running"

    # Add custom css file to theme
    grep -q "custom.css" /usr/share/themes/elementary/gtk-3.0/gtk.css

    if [ $? -eq 1 ]
    then
        echo '@import url("custom.css");' | sudo tee -a /usr/share/themes/elementary/gtk-3.0/gtk.css > /dev/null
    fi

    sudo wget -qLO "/usr/share/themes/elementary/gtk-3.0/custom.css" \
        "$URL/usr/share/themes/elementary/gtk-3.0/custom.css"

    killall wingpanel
}


# Reset theme
unsetCustomTheme() {
    output "Reset theme"
    sudo rm -rf /usr/share/themes/elementary/gtk-3.0/custom.css
    killall wingpanel
}

# Set sound volume to 0
setMute() {
    output "Set sound volume to 0"
    amixer -q -D pulse sset Master 0
}

# Cleanup files
cleanOldFiles() {
    output "Cleanup files"
    sudo rm -rf "/etc/apt/trusted.gpg.d/*"

    # Remove old files that students might of saved
    sudo rm -rf "$HOMEDIR/Documents/*"
    sudo rm -rf "$HOMEDIR/Downloads/*"
    sudo rm -rf "$HOMEDIR/Music/*"
    sudo rm -rf "$HOMEDIR/Pictures/*"
    sudo rm -rf "$HOMEDIR/Public/*"
    sudo rm -rf "$HOMEDIR/Templates/*"
    sudo rm -rf "$HOMEDIR/Videos/*"

    # Remove firefox files
    sudo rm -rf "$HOMEDIR/.mozilla/"
}

# Update System
aptUpdate() {
    output "Update System"

    sudo apt-get -qq update
    sudo apt -qq autoremove -y
    # sudo apt -qq dist-upgrade -y

    sudo DEBIAN_FRONTEND=noninteractive \
        apt-get \
        -qq \
        -o Dpkg::Options::="--force-confnew" \
        -y \
        --allow-downgrades \
        --allow-remove-essential \
        --allow-change-held-packages \
        dist-upgrade
}

# App Center
uninstallAppCenter() {
    command -v zeitgeist-daemon &> /dev/null
    if [ $? -eq 0 ]; then
        zeitgeist-daemon --quit
    fi

    uninstall appcenter
    uninstall zeitgeist
    uninstall zeitgeist-core
    uninstall zeitgeist-datahub
    uninstall io.elementary.appcenter

    sudo rm -rf {/root,/home/*}/.local/share/zeitgeist
}

uninstallSoftwareCenter() {
    uninstall "software-center"
}

uninstallUpdateManager() {
    uninstall "update-manager"
}

uninstallAptitude() {
    uninstall "aptitude"
}

uninstallAtom() {
    uninstall "atom"
}

uninstallAudience() {
    uninstall "audience"
}

uninstallEpiphany() {
    uninstall "epiphany-browser"
}

uninstallFirefox() {
    uninstall "firefox"
    sudo rm -rf "$HOMEDIR/.mozilla"
}

uninstallGoogleChrome() {
    uninstall "google-chrome"
    uninstall "google-chrome-stable"
    sudo rm -rf "$HOMEDIR/.config/google-chrome*"
}

uninstallGeary() {
    uninstall "geary"
}

uninstallMail() {
    uninstall "pantheon-mail"
}

uninstallMusic() {
    uninstall "noise"
}

uninstallCalendar() {
    uninstall "maya-calendar"
}

uninstallCode() {
    uninstall "io.elementary.code"
}

uninstallPhotos() {
    uninstall "pantheon-photos"
}

uninstallScreenshot() {
    uninstall "screenshot-tool"
}

# Cleanup
autoRemove() {
    output "Cleanup"
    sudo apt-get -qq autoremove -y
    sudo apt-get -qq autoclean -y
}

installFirefox() {
    install 'firefox'
}

installVSCode() {
    curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > "$HOMEDIR/microsoft.gpg"
    sudo install -o root -g root -m 644 "$HOMEDIR/microsoft.gpg" "/etc/apt/trusted.gpg.d/"
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    sudo apt-get -qq install apt-transport-https
    sudo apt-get -qq update
    sudo apt-get -qq install code # or code-insiders

    # Cleanup
    rm "$HOMEDIR/microsoft.gpg"

    # Reset Code settings
    output "Reset Code settings"
    rm -rf "$HOMEDIR/.config/Code"
    mkdir -p "$HOMEDIR/.config/Code/User/"
    wget -qLO "$HOMEDIR/.config/Code/User/settings.json" \
          "$URL$HOMEDIR/.config/Code/User/settings.json"


    # VSCodium
    # wget -qO - "https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg" | sudo apt-key add -

    # echo 'deb https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/debs/ vscodium main' | sudo tee --append "/etc/apt/sources.list"

    # install codium
}

installGit() {
    install 'git'
}

installPython() {
    install 'python3'
    install "python3-pip"
}

installVim() {
    install 'vim'
}

installBacklight() {
    install 'xbacklight'
}

# Update Script Running
output "Update Script Running"

version
setBashrc
setCustomTheme
unsetCustomTheme
setMute
cleanOldFiles
aptUpdate

# uninstallAppCenter
# uninstallSoftwareCenter
# uninstallUpdateManager
uninstallAptitude
uninstallAtom
uninstallAudience
uninstallEpiphany
uninstallFirefox
uninstallGoogleChrome
uninstallGeary
uninstallMail
uninstallMusic
uninstallCalendar
uninstallCode
uninstallPhotos
uninstallScreenshot

autoRemove

installFirefox
installVSCode
installGit
installPython
installVim
installBacklight



# # ---
# # Adding Elementary Tweaks
# output "Adding Elementary Tweaks"
# install software-properties-common
# add-apt-repository -y ppa:philip.scott/elementary-tweaks
# output "Installing elementary tweaks"
# install "elementary-tweaks"






# # ---
# # Setting screen brightness to 100
# output "Setting screen brightness to 100"
# xbacklight -set 100


# # ---
# # Installing Python packages
# output "Installing Python packages"
# pip3 install --upgrade --force-reinstall weallcode_robot


# # ---
# # Configuring Google Chrome
# # output "Configuring Google Chrome"
# # wget -qLO /opt/google/chrome/default_apps/external_extensions.json \
# #    "$URL/opt/google/chrome/default_apps/external_extensions.json"
# #
# # userrun 'google-chrome-stable --no-first-run > /dev/null 2>&1 &'
# # userrun 'sleep 10'
# # userrun 'killall chrome'
# # userrun 'sleep 5'
# #
# # # Disabling Google's Custom Frame
# # if grep -q "custom_chrome_frame" $HOMEDIR/.config/google-chrome/Default/Preferences; then
# #     # Already in the file, change true to false
# #     sed -i 's/"custom_chrome_frame":true/"custom_chrome_frame":false/' \
# #        $HOMEDIR/.config/google-chrome/Default/Preferences
# # else
# #     # Not in the file, add it to the file before "window_placement"
# #     sed -i 's/"window_placement"/"custom_chrome_frame":false,"window_placement"/' \
# #        $HOMEDIR/.config/google-chrome/Default/Preferences
# # fi
# #
# # # Clear browser history
# # if grep -q "clear_lso_data_enabled" $HOMEDIR/.config/google-chrome/Default/Preferences; then
# #     # Already in the file, change true to false
# #     sed -i 's/"clear_lso_data_enabled":false/"clear_lso_data_enabled":true/' \
# #        $HOMEDIR/.config/google-chrome/Default/Preferences
# # else
# #     # Not in the file, add it to the file before "window_placement"
# #     sed -i 's/"window_placement"/"clear_lso_data_enabled":true,"window_placement"/' \
# #        $HOMEDIR/.config/google-chrome/Default/Preferences
# # fi
# #
# # # Enable pepper flash in browser
# # if grep -q "pepper_flash_settings_enabled" $HOMEDIR/.config/google-chrome/Default/Preferences; then
# #     # Already in the file, change true to false
# #     sed -i 's/"pepper_flash_settings_enabled":false/"pepper_flash_settings_enabled":true/' \
# #        $HOMEDIR/.config/google-chrome/Default/Preferences
# # else
# #     # Not in the file, add it to the file before "window_placement"
# #     sed -i 's/"window_placement"/"pepper_flash_settings_enabled":true,"window_placement"/' \
# #        $HOMEDIR/.config/google-chrome/Default/Preferences
# # fi
# #
# # # Fixing Chrome Keyring issue
# # output "Fixing Chrome Keyring issue"
# # mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon-bak
# # killall gnome-keyring-daemon


# # ---
# # Setting up the dock
# output "Setting up the dock"
# rm $HOMEDIR/.config/plank/dock1/launchers/*.dockitem

# wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/pantheon-files.dockitem" \
#       "$URL$HOMEDIR/.config/plank/dock1/launchers/pantheon-files.dockitem"

# wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/code.dockitem" \
#       "$URL$HOMEDIR/.config/plank/dock1/launchers/code.dockitem"

# # wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/google-chrome.dockitem" \
# #       "$URL$HOMEDIR/.config/plank/dock1/launchers/google-chrome.dockitem"

# wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/firefox.dockitem" \
#       "$URL$HOMEDIR/.config/plank/dock1/launchers/firefox.dockitem"

# # wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/chromium-browser.dockitem" \
# #       "$URL$HOMEDIR/.config/plank/dock1/launchers/chromium-browser.dockitem"


# # If 0, the dock won't hide.
# sed -i 's/HideMode=3/HideMode=0/g' \
#     "$HOMEDIR/.config/plank/dock1/settings"


# # List of *.dockitems files on this dock.
# sed -i 's/DockItems=*/DockItems=pantheon-files.dockitem;;code.dockitem;;firefox.dockitem/g' \
#     "$HOMEDIR/.config/plank/dock1/settings"


# # ---
# # Changing desktop background
# output "Changing desktop background"
# wget -qLO "/usr/share/backgrounds/weallcode-background.png" \
#       "$URL/usr/share/backgrounds/weallcode-background.png"

# mv "/usr/share/backgrounds/elementaryos-default" \
#    "/usr/share/backgrounds/elementaryos-default-bak"

# ln -s "/usr/share/backgrounds/weallcode-background.png" \
#       "/usr/share/backgrounds/elementaryos-default"

# userrun 'gsettings set "org.gnome.desktop.background" "picture-uri" "file:///usr/share/backgrounds/weallcode-background.png"'
# userrun 'gsettings set "org.gnome.desktop.background" "picture-options" "zoom"'


# # Setting screensaver settings
# output "Setting screensaver settings"
# userrun 'gsettings set "org.gnome.desktop.screensaver" "lock-delay" 3600'
# userrun 'gsettings set "org.gnome.desktop.screensaver" "lock-enabled" false'
# userrun 'gsettings set "org.gnome.desktop.screensaver" "idle-activation-enabled" false'
# userrun 'gsettings set "org.gnome.desktop.session" "idle-delay" 0'


# # Disable Single Click open file/folders
# output "Disable Single Click open file/folders"
# userrun 'gsettings set org.pantheon.files.preferences single-click false'


# # Setting Window Controls
# # output "Setting Window Controls"
# # userrun 'gsettings set org.pantheon.desktop.gala.appearance button-layout :minimize,maximize,close'
# # userrun 'gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'"'"'Gtk/DecorationLayout'"'"': <'"'"':minimize,maximize,close'"'"'>}"'


# # Disable guest login
# output "Disable guest login"
# wget -qLO "/usr/share/lightdm/lightdm.conf.d/40-pantheon-greeter.conf" \
#       "$URL/usr/share/lightdm/lightdm.conf.d/40-pantheon-greeter.conf"


# # Restart dock
# output "Restart dock"
# killall plank


# # Fix drag and drop quirk
# output "Fix drag and drop quirk"
# wget -qLO "/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf" \
#       "$URL/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf"


# # Install cdcformat script
# output "Install cdcformat script"
# wget -qLO "/usr/sbin/cdcformat" \
#       "$URL/usr/sbin/cdcformat"
# chmod +x "/usr/sbin/cdcformat"


# # Installing phonehome config file
# if [ ! -f "$CONFDIR/$CONF" ]; then
#     output "Installing phonehome config file"
#     wget -qLO "$CONFDIR/$CONF" \
#          "$URL/$CONFDIR/$CONF"
# else
#     output "Phonehome config file exists"
# fi


# # Installing phonehome script
# output "Installing phonehome script"
# wget -qLO $SCRIPTDIR/$SCRIPT \
#       $URL$SCRIPTDIR/$SCRIPT
# chmod +x $SCRIPTDIR/$SCRIPT


# # Installing phonehome cron
# if [ ! -f "$CRONDIR/$SCRIPT" ]; then
#     output "Installing phonehome cron"
#     wget -qLO "$CRONDIR/$SCRIPT" \
#          "$URL$CRONDIR/$SCRIPT"
# else
#     output "Phonehome cron exists"
# fi



# Set ownership
# chown -R $USER:$USER "$HOMEDIR/.config/"

# Open survey
# userrun "xdg-open http://coderdojochi.com/survey/pre &>/dev/null"


# Restarting in 1 minute
# output "Restarting in 1 minute"
# shutdown -r 1

