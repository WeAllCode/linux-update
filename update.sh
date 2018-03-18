URL='https://raw.githubusercontent.com/CoderDojoChi/linux-update/master'

HOMEDIR=/home/coderdojochi

SCRIPTDIR=/etc/init.d
SCRIPT=coderdojochi-phonehome

CONFDIR=/etc/init
CONF=$SCRIPT.conf

CRONDIR=/etc/cron.d

MACHINE_TYPE=`uname -m`


userrun() {
    sudo -H -u coderdojochi bash -c "$1";
}

output() {
    echo "\n\n####################\n# $1\n####################\n\n";
    userrun "notify-send --urgency=low '$1'";
}

debInst() {
    dpkg-query -Wf'${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

install() {
    if [ debInst "$1" -eq 0 ]; then
        apt install -y "$1"
    fi
}

uninstall() {
    if debInst "$1"; then
        if [ -x "$2" ]; then
            apt-get remove -y "$2"
        else
            apt-get remove -y "$1"
        fi
    fi
}



# Update Script Running
output "Update Script Running"
echo ".panel,.panel.maximized,.panel.translucent{background-color:red;}" >> /usr/share/themes/elementary/gtk-3.0/apps.css
killall wingpanel


# Cleanup files
output "Cleanup files"
rm -rf /etc/apt/trusted.gpg.d/*


# Remove old files that students might of saved
rm -rf $HOMEDIR/Documents/*
rm -rf $HOMEDIR/Downloads/*
rm -rf $HOMEDIR/Music/*
rm -rf $HOMEDIR/Pictures/*
rm -rf $HOMEDIR/Public/*
rm -rf $HOMEDIR/Templates/*
rm -rf $HOMEDIR/Videos/*

# ---
# # Adding Google to package manager
# output "Adding Google to package manager"
# wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -

# Remove Google apt source
output "Remove Google apt source"
rm -rf /etc/apt/sources.list.d/google-chrome.list*

# wget -qLO /etc/apt/sources.list.d/google-chrome.list \
#      "$URL/etc/apt/sources.list.d/google-chrome.list"


# ---
# Adding VS Code to package manager
output "Adding VS Code to package manager"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'


# ---
# # Removing Elementary Tweaks from package manager
# output "Removing Elementary Tweaks from package manager"
# add-apt-repository -r -y ppa:philip.scott/elementary-tweaks


# ---
# Uninstalling unused packages
output "Uninstalling unused packages"

output "Uninstall activity log"
uninstall activity-log-manager-common
uninstall activity-log-manager-control-center


output "Uninstall App Center"
command -v zeitgeist-daemon &> /dev/null
if [ $? -eq 0 ]; then
    zeitgeist-daemon --quit
fi

uninstall appcenter
uninstall software-center
uninstall update-manager
uninstall zeitgeist
uninstall zeitgeist-core
uninstall zeitgeist-datahub

rm -rf {/root,/home/*}/.local/share/zeitgeist


output "Uninstall aptitude"
uninstall "aptitude"


output "Uninstall Atom"
uninstall "atom"


output "Uninstall Audience"
uninstall "audience"


output "Uninstall deja-dup"
uninstall "deja-dup"


# output "Uninstall Elementary Tweaks"
# uninstall "elementary-tweaks"


output "Uninstall Empathy"
uninstall "empathy-*" "^empathy-.*"


output "Uninstall Epiphany"
uninstall "epiphany-*" "^epiphany-.*"


# output "Uninstall Firefox"
# uninstall "firefox*" "^firefox.*"


output "Uninstall Geary"
uninstall "geary"


output "Uninstall Google"
uninstall "google-*" "^google-.*"


output "Uninstall Gnome Online Accounts"
uninstall "gnome-online-accounts"
uninstall "indicator-messages"


output "Uninstall Midori"
uninstall "midori-granite"
rm -rf "$HOMEDIR/.config/midori"


output "Uninstall Mode Manager"
uninstall "modemmanager"


output "Uninstall Noise"
uninstall "noise"


output "Uninstall Pantheon Mail"
uninstall "pantheon-mail"


output "Uninstall Pantheon Photos"
uninstall "pantheon-photos*" "^pantheon-photos.*"


output "Uninstall Scatch Text Editor"
uninstall "scratch-text-editor"


output "Uninstall Screenshot Tool"
uninstall "screenshot-tool"


output "Uninstall Simple Scan"
uninstall "simple-scan"


# ---
# Upgrading system
output "Upgrading system"
apt update
apt dist-upgrade -y


# Cleanup
output "Cleanup"
apt-get autoremove -y
apt-get autoclean -y



# # Installing google-chrome-stable
# output "Installing Google Chrome (stable)"
# rm -rf "$HOMEDIR/.config/google-chrome" \
#        "$HOMEDIR/.config/google-chrome-stable"

# ---
# Installing programs
output "Installing programs"


output "Installing Firefox"
install "firefox"


output "Installing Visual Studio Code"
install "code"


output "Installing gedit"
install "gedit"


output "Installing git"
install "git"


# output "Installing Google Chrome Stable"
# install "google-chrome-stable"

output "Installing vim"
install "vim"


output "Installing xbacklight"
install "xbacklight"


# ---
# Reset Code settings
output "Reset Code settings"
wget -qLO "$HOMEDIR/.config/Code/User/settings.json" \
      "$URL$HOMEDIR/.config/Code/User/settings.json"


# ---
# Setting screen brightness to 100
output "Setting screen brightness to 100"
xbacklight -set 100


# ---
# Configuring Google Chrome
# output "Configuring Google Chrome"
# wget -qLO /opt/google/chrome/default_apps/external_extensions.json \
#    "$URL/opt/google/chrome/default_apps/external_extensions.json"
# 
# userrun 'google-chrome-stable --no-first-run > /dev/null 2>&1 &'
# userrun 'sleep 10'
# userrun 'killall chrome'
# userrun 'sleep 5'
# 
# # Disabling Google's Custom Frame
# if grep -q "custom_chrome_frame" $HOMEDIR/.config/google-chrome/Default/Preferences; then
#     # Already in the file, change true to false
#     sed -i 's/"custom_chrome_frame":true/"custom_chrome_frame":false/' \
#        $HOMEDIR/.config/google-chrome/Default/Preferences
# else
#     # Not in the file, add it to the file before "window_placement"
#     sed -i 's/"window_placement"/"custom_chrome_frame":false,"window_placement"/' \
#        $HOMEDIR/.config/google-chrome/Default/Preferences
# fi
# 
# # Clear browser history
# if grep -q "clear_lso_data_enabled" $HOMEDIR/.config/google-chrome/Default/Preferences; then
#     # Already in the file, change true to false
#     sed -i 's/"clear_lso_data_enabled":false/"clear_lso_data_enabled":true/' \
#        $HOMEDIR/.config/google-chrome/Default/Preferences
# else
#     # Not in the file, add it to the file before "window_placement"
#     sed -i 's/"window_placement"/"clear_lso_data_enabled":true,"window_placement"/' \
#        $HOMEDIR/.config/google-chrome/Default/Preferences
# fi
# 
# # Enable pepper flash in browser
# if grep -q "pepper_flash_settings_enabled" $HOMEDIR/.config/google-chrome/Default/Preferences; then
#     # Already in the file, change true to false
#     sed -i 's/"pepper_flash_settings_enabled":false/"pepper_flash_settings_enabled":true/' \
#        $HOMEDIR/.config/google-chrome/Default/Preferences
# else
#     # Not in the file, add it to the file before "window_placement"
#     sed -i 's/"window_placement"/"pepper_flash_settings_enabled":true,"window_placement"/' \
#        $HOMEDIR/.config/google-chrome/Default/Preferences
# fi
# 
# # Fixing Chrome Keyring issue
# output "Fixing Chrome Keyring issue"
# mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon-bak
# killall gnome-keyring-daemon


# ---
# Setting up the dock
output "Setting up the dock"
rm "$HOMEDIR/.config/plank/dock1/launchers/*.dockitem"

wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/pantheon-files.dockitem" \
      "$URL$HOMEDIR/.config/plank/dock1/launchers/pantheon-files.dockitem"

wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/code.dockitem" \
      "$URL$HOMEDIR/.config/plank/dock1/launchers/code.dockitem"

# wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/google-chrome.dockitem" \
#       "$URL$HOMEDIR/.config/plank/dock1/launchers/google-chrome.dockitem"

wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/firefox.dockitem" \
      "$URL$HOMEDIR/.config/plank/dock1/launchers/firefox.dockitem"

# wget -qLO "$HOMEDIR/.config/plank/dock1/launchers/chromium-browser.dockitem" \
#       "$URL$HOMEDIR/.config/plank/dock1/launchers/chromium-browser.dockitem"


# If 0, the dock won't hide.
sed -i 's/HideMode=3/HideMode=0/g' \
    "$HOMEDIR/.config/plank/dock1/settings"


# List of *.dockitems files on this dock.
sed -i 's/DockItems=*/DockItems=pantheon-files.dockitem;;code.dockitem;;firefox.dockitem/g' \
    "$HOMEDIR/.config/plank/dock1/settings"


# ---
# Changing desktop background
output "Changing desktop background"
wget -qLO "/usr/share/backgrounds/coderdojochi.png" \
      "$URL/usr/share/backgrounds/coderdojochi.png"

mv "/usr/share/backgrounds/elementaryos-default" \
   "/usr/share/backgrounds/elementaryos-default-bak"

ln -s "/usr/share/backgrounds/coderdojochi.png" \
      "/usr/share/backgrounds/elementaryos-default"

userrun 'gsettings set "org.gnome.desktop.background" "picture-uri" "file:///usr/share/backgrounds/coderdojochi.png"'
userrun 'gsettings set "org.gnome.desktop.background" "picture-options" "zoom"'


# Setting screensaver settings
output "Setting screensaver settings"
userrun 'gsettings set "org.gnome.desktop.screensaver" "lock-delay" 3600'
userrun 'gsettings set "org.gnome.desktop.screensaver" "lock-enabled" false'
userrun 'gsettings set "org.gnome.desktop.screensaver" "idle-activation-enabled" false'
userrun 'gsettings set "org.gnome.desktop.session" "idle-delay" 0'


# Setting Window Controls
# output "Setting Window Controls"
# userrun 'gsettings set org.pantheon.desktop.gala.appearance button-layout :minimize,maximize,close'
# userrun 'gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'"'"'Gtk/DecorationLayout'"'"': <'"'"':minimize,maximize,close'"'"'>}"'


# Disable guest login
output "Disable guest login"
wget -qLO "/usr/share/lightdm/lightdm.conf/40-pantheon-greeter.conf" \
      "$URL/usr/share/lightdm/lightdm.conf/40-pantheon-greeter.conf"


# Restart dock
output "Restart dock"
killall plank


# Fix drag and drop quirk
output "Fix drag and drop quirk"
wget -qLO "/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf" \
      "$URL/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf" 


# Install cdcformat script
output "Install cdcformat script"
wget -qLO "/usr/sbin/cdcformat" \
      "$URL/usr/sbin/cdcformat"
chmod +x "/usr/sbin/cdcformat"


# Installing phonehome config file
if [ ! -f "$CONFDIR/$CONF" ]; then
    output "Installing phonehome config file"
    wget -qLO "$CONFDIR/$CONF" \
         "$URL/$CONFDIR/$CONF"
else
    output "Phonehome config file exists"
fi


# Installing phonehome script
output "Installing phonehome script"
wget -qLO "$SCRIPTDIR/$SCRIPT" \ 
     "$URL/$SCRIPTDIR/$SCRIPT"
chmod +x "$SCRIPTDIR/$SCRIPT"


# Installing phonehome cron
if [ ! -f "$CRONDIR/$SCRIPT" ]; then
    output "Installing phonehome cron"
    wget -qLO "$CRONDIR/$SCRIPT" \
         "$URL/$CRONDIR/$SCRIPT"
else
    output "Phonehome cron exists"
fi


# Reset theme
output "Reset theme"
sed -i '$ d' "/usr/share/themes/elementary/gtk-3.0/apps.css"
killall wingpanel

# Set ownership
chown -R coderdojochi:coderdojochi "$HOMEDIR/.config/"

# Open survey
userrun "xdg-open http://coderdojochi.com/survey/pre &>/dev/null"


# Restarting in 1 minute
# output "Restarting in 1 minute"
# shutdown -r 1

