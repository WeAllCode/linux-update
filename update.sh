#!/usr/bin/env bash

#
# This script updates all We All Code computers.
#
# bash <(curl -fsSL wac.fyi/juno)
#

VERSION="2.0.47"

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

DEBIAN_FRONTEND=noninteractive


# userrun() {
#     sudo -H -u $USER bash -c "$1";
# }

output() {
    printf "\n####################\n# %s\n####################\n" "$1";
    notify-send --urgency=low "$1"
}

debInst() {
    dpkg-query -Wf'${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

version() {
    output "Version: $VERSION";
}

# install() {
#     output "Install $1"

#     # sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -o=Dpkg::Use-Pty=0 --allow-remove-essential -y $1
#     sudo apt-get install --allow-remove-essential -y $1
# }

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

    # sudo apt-get -qq update
    sudo apt-get update
    # sudo apt -qq autoremove -y
    sudo apt autoremove -y

    # sudo DEBIAN_FRONTEND=noninteractive \
    #     apt-get \
    #     -qq \
    #     -o Dpkg::Options::="--force-confnew" \
    #     -y \
    #     --allow-downgrades \
    #     --allow-remove-essential \
    #     --allow-change-held-packages \
    #     dist-upgrade

    sudo DEBIAN_FRONTEND=noninteractive \
        apt-get \
        -o Dpkg::Options::="--force-confnew" \
        -y \
        --allow-downgrades \
        --allow-remove-essential \
        --allow-change-held-packages \
        dist-upgrade
}

# App Center
uninstallAppCenter() {
    output "Uninstalling appcenter"
    sudo apt-get autoremove --purge -y appcenter
}

uninstallSoftwareCenter() {
    output "Uninstalling software-center"
    sudo apt-get autoremove --purge -y software-center
}

uninstallUpdateManager() {
    output "Uninstalling update-manager"
    sudo apt-get autoremove --purge -y update-manager
}

uninstallAptitude() {
    output "Uninstalling aptitude"
    sudo apt-get autoremove --purge -y aptitude
}

uninstallAtom() {
    output "Uninstalling atom"
    sudo apt-get autoremove --purge -y atom
}

uninstallAudience() {
    output "Uninstalling audience"
    sudo apt-get autoremove --purge -y audience
}

uninstallEpiphany() {
    output "Uninstalling epiphany-browser"
    sudo apt-get autoremove --purge -y epiphany-browser
}

uninstallFirefox() {
    output "Uninstalling firefox"
    sudo apt-get autoremove --purge -y firefox

    sudo rm -rf "$HOMEDIR/.mozilla"
}

uninstallGoogleChrome() {
    output "Uninstalling google-chrome"
    sudo apt-get autoremove --purge -y \
        google-chrome \
        google-chrome-stable

    sudo rm -rf "$HOMEDIR/.config/google-chrome*"
}

uninstallGeary() {
    output "Uninstalling geary"
    sudo apt-get autoremove --purge -y geary
}

uninstallMail() {
    output "Uninstalling pantheon-mail"
    sudo apt-get autoremove --purge -y pantheon-mail
}

uninstallMusic() {
    output "Uninstalling noise"
    sudo apt-get autoremove --purge -y noise
}

uninstallCalendar() {
    output "Uninstalling maya-calendar"
    sudo apt-get autoremove --purge -y maya-calendar
}

uninstallCode() {
    output "Uninstalling io.elementary.code"
    sudo apt-get autoremove --purge -y io.elementary.code
}

uninstallPhotos() {
    output "Uninstalling pantheon-photos"
    sudo apt-get autoremove --purge -y pantheon-photos
}

uninstallScreenshot() {
    output "Uninstalling screenshot-tool"
    sudo apt-get autoremove --purge -y screenshot-tool
}

uninstallVim() {
    output "Uninstalling vim"
    sudo apt-get autoremove --purge -y "vim-*"
}

# Cleanup
autoRemove() {
    output "Cleanup"

    # sudo apt-get -qq autoremove -y
    sudo apt-get autoremove -y
    # sudo apt-get -qq autoclean -y
    sudo apt-get autoclean -y
}

installFirefox() {
    output "Installing firefox"

    sudo apt-get install -y firefox
}

installVSCode() {
    output "Installing VSCode"

    curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > "$HOMEDIR/microsoft.gpg"
    sudo install -o root -g root -m 644 "$HOMEDIR/microsoft.gpg" "/etc/apt/trusted.gpg.d/"
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    # sudo apt-get -qq install apt-transport-https
    sudo apt-get install -y apt-transport-https
    # sudo apt-get -qq update
    sudo apt-get update
    # sudo apt-get -qq install -y code # or code-insiders
    sudo apt-get install -y code # or code-insiders

    # Cleanup
    rm "$HOMEDIR/microsoft.gpg"

    # Reset Code settings
    output "Reset Code settings"
    rm -rf "$HOMEDIR/.config/Code"
    mkdir -p "$HOMEDIR/.config/Code/User/"
    wget -qLO "$HOMEDIR/.config/Code/User/settings.json" \
          "$URL$HOMEDIR/.config/Code/User/settings.json"

    chown -R $USER:$USER "$HOMEDIR/.config/"
}

installVSCodium() {
    output "Installing VSCodium"

    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo apt-key add -

    echo 'deb https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list

    sudo apt-get update
    sudo apt-get update --fix-missing

    sudo apt install codium
}

installGit() {
    output "Installing git"

    sudo apt-get install -y git
}

installPython() {
    output "Installing python3"

    sudo apt-get install -y python3 python3-pip
}

installVim() {
    output "Installing vim"

    sudo apt-get install -y vim
}

installBacklight() {
    output "Installing xbacklight"

    sudo apt-get install -y xbacklight
}

setBrightness() {
    output "Setting screen brightness to 100"

    xbacklight -set 100
}

installPythonPackages() {
    output "Installing Python packages"

    pip3 install --upgrade --force-reinstall weallcode_robot
}

updateDock() {
    output "Setting up the dock"

    rm $HOMEDIR/.config/plank/dock1/launchers/*.dockitem

    wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/io.elementary.files.dockitem" \
          "$URL$HOMEDIR/.config/plank/dock1/launchers/io.elementary.files.dockitem"

    wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/code.dockitem" \
          "$URL$HOMEDIR/.config/plank/dock1/launchers/code.dockitem"

    wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/firefox.dockitem" \
          "$URL$HOMEDIR/.config/plank/dock1/launchers/firefox.dockitem"

    # chown -R $USER:$USER "$HOMEDIR/.config/"

    gsettings set net.launchpad.plank.dock.settings:/ dock-items "['io.elementary.files.dockitem', 'code.dockitem', 'firefox.dockitem']"

    # Restart dock
    killall plank
}


# Changing desktop background
updateBackground() {
    output "Changing desktop background"
    sudo wget -qLO "/usr/share/backgrounds/weallcode-background.png" \
               "$URL/usr/share/backgrounds/weallcode-background.png"

    sudo mv "/usr/share/backgrounds/elementaryos-default" \
            "/usr/share/backgrounds/elementaryos-default-bak"


    sudo ln -s "/usr/share/backgrounds/weallcode-background.png" \
               "/usr/share/backgrounds/elementaryos-default"

    gsettings set "org.gnome.desktop.background" "picture-uri" "file:///usr/share/backgrounds/weallcode-background.png"
    gsettings set "org.gnome.desktop.background" "picture-options" "zoom"

}

# Setting screensaver settings
updateScreensaver() {
    output "Setting screensaver settings"

    gsettings set org.gnome.desktop.screensaver lock-delay 7200
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
    gsettings set org.gnome.desktop.session idle-delay 300
}

updateFilesControl() {
    output "Setting files control settings"

    # Disable Single Click open file/folders
    gsettings set io.elementary.files.preferences single-click false

    # Setting Window Controls
    gsettings set org.pantheon.desktop.gala.appearance button-layout ":minimize,maximize,close"

    gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/DialogsUseHeader': <0>, 'Gtk/EnablePrimaryPaste': <0>, 'Gtk/ShellShowsAppMenu': <0>, 'Gtk/DecorationLayout': <':minimize,maximize,close'>}"

    # gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/DialogsUseHeader': <0>, 'Gtk/ShellShowsAppMenu': <0>, 'Gtk/DecorationLayout': <'close:menu,maximize'>}"

}

fixRotateBug() {
    sudo systemctl mask iio-sensor-proxy.service
}

openSurvey() {
    # Open survey
    xdg-open "http://coderdojochi.com/survey/pre" &>/dev/null
}


# Update Script Running
output "Update Script Running"

version
setBashrc
setCustomTheme

setMute
cleanOldFiles
aptUpdate

# uninstallAppCenter
# uninstallSoftwareCenter
# uninstallUpdateManager
# uninstallAptitude
# uninstallAtom
# uninstallAudience
# uninstallEpiphany
uninstallFirefox
uninstallGoogleChrome
uninstallVim
# uninstallGeary
# uninstallMail
# uninstallMusic
# uninstallCalendar
# uninstallCode
# uninstallPhotos
# uninstallScreenshot

autoRemove

installFirefox
installVSCode
# installVSCodium
installGit
installPython
installVim
installBacklight

setBrightness
installPythonPackages

updateDock
updateBackground
updateScreensaver
updateFilesControl

fixRotateBug

unsetCustomTheme

openSurvey


# # ---
# # Adding Elementary Tweaks
# output "Adding Elementary Tweaks"
# install software-properties-common
# add-apt-repository -y ppa:philip.scott/elementary-tweaks
# output "Installing elementary tweaks"
# install "elementary-tweaks"




# # Disable guest login
# output "Disable guest login"
# wget -qLO "/usr/share/lightdm/lightdm.conf.d/40-pantheon-greeter.conf" \
#       "$URL/usr/share/lightdm/lightdm.conf.d/40-pantheon-greeter.conf"


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


# Restarting in 1 minute
# output "Restarting in 1 minute"
# shutdown -r 1

