#!/usr/bin/env bash

#
# This script updates all We All Code computers.
#
# bash <(curl -fsSL wac.fyi/update)
#
# or
#
# wac-update
#

VERSION="2.0.68"

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
    notify-send --urgency=low "$1"
}

debInst() {
    dpkg-query -Wf'${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

version() {
    output "Version: $VERSION";
}

askToContinue() {
    read -p "Do you want to continue? (y/N) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo    # (optional) move to a new line
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
    fi
}

# Reset ~/.bashrc settings
setBashrc() {
    output "Reset ~/.bashrc settings"
    wget -qLO "$HOMEDIR/.bashrc" \
          "$URL/$HOMEDIR/.bashrc"

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
}

# Update System
aptUpdate() {
    output "Update System"

    # sudo apt-get -qq update
    sudo apt update
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

    sudo apt install -y software-properties-common
}

# App Center
uninstallAppCenter() {
    output "Uninstalling appcenter"
    sudo apt autoremove --purge -y appcenter
}

uninstallSoftwareCenter() {
    output "Uninstalling software-center"
    sudo apt autoremove --purge -y software-center
}

uninstallUpdateManager() {
    output "Uninstalling update-manager"
    sudo apt autoremove --purge -y update-manager
}

uninstallAptitude() {
    output "Uninstalling aptitude"
    sudo apt autoremove --purge -y aptitude
}

uninstallAtom() {
    output "Uninstalling atom"
    sudo apt autoremove --purge -y atom
}

uninstallVideos() {
    output "Uninstalling audience"
    sudo apt autoremove --purge -y audience
}

uninstallEpiphany() {
    output "Uninstalling epiphany-browser"
    sudo apt autoremove --purge -y epiphany-browser
}

uninstallFirefox() {
    output "Uninstalling firefox"

    # Kill firefox if running
    killall firefox

    # Uninstall firefox
    sudo apt autoremove --purge -y firefox

    # Remove mozilla folder
    sudo rm -rf "$HOMEDIR/.mozilla"
}

uninstallGoogleChrome() {
    output "Uninstalling google-chrome"
    sudo apt autoremove --purge -y \
        google-chrome \
        google-chrome-stable

    sudo rm -rf "$HOMEDIR/.config/google-chrome*"
}

uninstallGeary() {
    output "Uninstalling geary"
    sudo apt autoremove --purge -y geary
}

uninstallMail() {
    output "Uninstalling pantheon-mail"
    sudo apt autoremove --purge -y pantheon-mail
}

uninstallMusic() {
    output "Uninstalling noise"
    sudo apt autoremove --purge -y noise
}

uninstallCalendar() {
    output "Uninstalling maya-calendar"
    sudo apt autoremove --purge -y maya-calendar
}

uninstallCode() {
    output "Uninstalling io.elementary.code"
    sudo apt autoremove --purge -y io.elementary.code
}

uninstallPhotos() {
    output "Uninstalling pantheon-photos"
    sudo apt autoremove --purge -y pantheon-photos
}

uninstallScreenshot() {
    output "Uninstalling screenshot-tool"
    sudo apt autoremove --purge -y screenshot-tool
}

uninstallVim() {
    output "Uninstalling vim"
    sudo apt autoremove --purge -y "vim-*"
}

# Cleanup
autoRemove() {
    output "Cleanup"

    # sudo apt-get -qq autoremove -y
    sudo apt autoremove -y
    # sudo apt-get -qq autoclean -y
    sudo apt autoclean -y
}

installFirefox() {
    output "Installing firefox"

    sudo apt install -y firefox
}

installVSCode() {
    output "Installing VSCode"

    killall -9 code

    curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > "$HOMEDIR/microsoft.gpg"
    sudo install -o root -g root -m 644 "$HOMEDIR/microsoft.gpg" "/etc/apt/trusted.gpg.d/"
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    # sudo apt-get -qq install apt-transport-https
    sudo apt install -y apt-transport-https
    # sudo apt-get -qq update
    sudo apt update
    # sudo apt-get -qq install -y code # or code-insiders
    sudo apt install -y code # or code-insiders

    # Cleanup
    rm "$HOMEDIR/microsoft.gpg"

    # Reset Code settings
    output "Reset Code settings"
    rm -rf "$HOMEDIR/.config/Code"
    mkdir -p "$HOMEDIR/.config/Code/User/globalStorage/"

    wget -qLO "$HOMEDIR/.config/Code/User/settings.json" \
         "$URL/$HOMEDIR/.config/Code/User/settings.json"

    wget -qLO "$HOMEDIR/.config/Code/User/locale.json" \
         "$URL/$HOMEDIR/.config/Code/User/locale.json"

    wget -qLO "$HOMEDIR/.config/Code/User/extensions.json" \
         "$URL/$HOMEDIR/.config/Code/User/extensions.json"

    wget -qLO "$HOMEDIR/.config/Code/User/globalStorage/state.vscdb" \
         "$URL/$HOMEDIR/.config/Code/User/globalStorage/state.vscdb"


    chown -R $USER:$USER "$HOMEDIR/.config/"
}

installVSCodium() {
    output "Installing VSCodium"

    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo apt-key add -

    echo 'deb https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list

    sudo apt update
    sudo apt update --fix-missing

    sudo apt install codium
}

installGit() {
    output "Installing git"

    sudo apt install -y git
}

installPython() {
    output "Installing python3"

    sudo apt install -y python3 python3-pip
}

installVim() {
    output "Installing vim"

    sudo apt install -y vim
}

installBacklight() {
    output "Installing xbacklight"

    sudo apt install -y xbacklight
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

    sudo add-apt-repository -y ppa:ricotz/docky
    sudo apt-get update
    sudo apt install -y plank

    rm $HOMEDIR/.config/plank/dock1/launchers/*.dockitem

    cd "$HOMEDIR/.config/plank/dock1/launchers/"

    wget -q "$URL/$HOMEDIR/.config/plank/dock1/launchers/io.elementary.files.dockitem"
    wget -q "$URL/$HOMEDIR/.config/plank/dock1/launchers/code.dockitem"
    wget -q "$URL/$HOMEDIR/.config/plank/dock1/launchers/firefox.dockitem"

    # chown -R $USER:$USER "$HOMEDIR/.config/"

    gsettings set net.launchpad.plank.dock.settings:/ zoom-percent 150
    # gsettings set net.launchpad.plank.dock.settings:/ dock-items "['io.elementary.files.dockitem', 'code.dockitem', 'firefox.dockitem']"

    sleep 1
    # Restart dock
    killall plank

    cd -
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
    xdg-open "https://wac.fyi/survey" &>/dev/null
}

# addElementaryTweaks() {
#     output "Adding Elementary Tweaks"
#     install software-properties-common
#     add-apt-repository -y ppa:philip.scott/elementary-tweaks
#     output "Installing elementary tweaks"
#     install "elementary-tweaks"
# }

# disableGuestLogin() {
#     # Disable guest login
#     output "Disable guest login"
#     wget -qLO "/usr/share/lightdm/lightdm.conf.d/40-pantheon-greeter.conf" \
#           "$URL/usr/share/lightdm/lightdm.conf.d/40-pantheon-greeter.conf"
# }

# fixDragAndDropQuirk() {
#     # Fix drag and drop quirk
#     output "Fix drag and drop quirk"
#     wget -qLO "/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf" \
#           "$URL/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf"
# }

# installFormatScript() {
#     # Install cdcformat script
#     output "Install cdcformat script"
#     sudo wget -qLO "/usr/sbin/wac-format" \
#                "$URL/usr/sbin/wac- format"
#
#     sudo chmod +x "/usr/sbin/wac-format"
# }

# installPhoneHomeScript() {
#     # Installing phonehome config file
#     if [ ! -f "$CONFDIR/$CONF" ]; then
#         output "Installing phonehome config file"
#         wget -qLO "$CONFDIR/$CONF" \
#              "$URL/$CONFDIR/$CONF"
#     else
#         output "Phonehome config file exists"
#     fi
#
#
#     # Installing phonehome script
#     output "Installing phonehome script"
#     wget -qLO $SCRIPTDIR/$SCRIPT \
#           $URL$SCRIPTDIR/$SCRIPT
#     chmod +x $SCRIPTDIR/$SCRIPT
#
#
#     # Installing phonehome cron
#     if [ ! -f "$CRONDIR/$SCRIPT" ]; then
#         output "Installing phonehome cron"
#         wget -qLO "$CRONDIR/$SCRIPT" \
#              "$URL$CRONDIR/$SCRIPT"
#     else
#         output "Phonehome cron exists"
#     fi
# }


# Update Script Running
output "Update Script Running"

version
askToContinue

setBashrc
# setCustomTheme

setMute
cleanOldFiles
aptUpdate

# uninstallAppCenter
# uninstallSoftwareCenter
# uninstallUpdateManager
# uninstallAptitude
# uninstallAtom
uninstallVideos
uninstallEpiphany
uninstallFirefox
uninstallGoogleChrome
uninstallVim
# uninstallGeary
uninstallMail
uninstallMusic
uninstallCalendar
uninstallCode
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

# unsetCustomTheme

openSurvey

# Restarting in 1 minute
# output "Restarting in 1 minute"
# shutdown -r 1

