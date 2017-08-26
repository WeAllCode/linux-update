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


# Update Script Running
userrun 'notify-send --urgency=critical "Update Script Running"'


# Adding Google to package manager
output "Adding Google to package manager"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -

rm -rf /etc/apt/sources.list.d/google-chrome.list*

wget -qLO /etc/apt/sources.list.d/google-chrome.list \
     "$URL/etc/apt/sources.list.d/google-chrome.list"


# VS Code
output "Adding VS Code to package manager"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'


# Adding Elementary Tweaks to package manager
output "Adding Elementary Tweaks to package manager"
add-apt-repository ppa:philip.scott/elementary-tweaks -y


# Uninstalling unused packages
output "Uninstalling unused packages"
command -v zeitgeist-daemon &> /dev/null
if [ $? -eq 0 ]; then
    zeitgeist-daemon --quit
fi

apt-get autoremove --purge -y \
    activity-log-manager-common \
    activity-log-manager-control-center \
    atom \
    deja-dup \
    elementary-tweaks \
    empathy-* \
    firefox* \
    geary \
    google-chrome-beta \
    gnome-online-accounts \
    indicator-messages \
    midori-granite \
    modemmanager \
    noise \
    scratch-text-editor \
    software-center \
    update-manager \
    zeitgeist \
    zeitgeist-core \
    zeitgeist-datahub


# Upgrading system
output "Upgrading system"
apt-get update
apt-get dist-upgrade -y


# Cleanup
output "Cleanup"
apt-get autoremove -y
apt-get autoclean -y
rm -rf {/root,/home/*}/.local/share/zeitgeist


# Remove old files that students might of saved
rm -rf $HOMEDIR/Documents/*
rm -rf $HOMEDIR/Downloads/*
rm -rf $HOMEDIR/Music/*
rm -rf $HOMEDIR/Pictures/*
rm -rf $HOMEDIR/Public/*
rm -rf $HOMEDIR/Templates/*
rm -rf $HOMEDIR/Videos/*


# Reset Code settings
wget -qLO $HOMEDIR/.config/Code/User/settings.json \
     "$URL$HOMEDIR/.config/Code/User/settings.json"
     

# Installing google-chrome-stable
output "Installing Google Chrome (stable)"
rm -rf $HOMEDIR/.config/midori \
     $HOMEDIR/.config/google-chrome \
     $HOMEDIR/.config/google-chrome-stable


# Installing programs
output "Installing programs"
apt-get install -y \
    code \
    gedit \
    git \
    google-chrome-stable \
    vim \
    xbacklight


# Setting screen brightness to 100
output "Setting screen brightness to 100"
xbacklight -set 100


# Configuring Google Chrome
output "Configuring Google Chrome"
wget -qLO /opt/google/chrome/default_apps/external_extensions.json \
   "$URL/opt/google/chrome/default_apps/external_extensions.json"


userrun 'google-chrome-stable --no-first-run > /dev/null 2>&1 &'
userrun 'sleep 10'
userrun 'killall chrome'
userrun 'sleep 5'

# Disabling Google's Custom Frame
if grep -q "custom_chrome_frame" $HOMEDIR/.config/google-chrome/Default/Preferences; then
    # Already in the file, change true to false
    sed -i 's/"custom_chrome_frame":true/"custom_chrome_frame":false/' \
       $HOMEDIR/.config/google-chrome/Default/Preferences
else
    # Not in the file, add it to the file before "window_placement"
    sed -i 's/"window_placement"/"custom_chrome_frame":false,"window_placement"/' \
       $HOMEDIR/.config/google-chrome/Default/Preferences
fi


# Clear browser history
if grep -q "clear_lso_data_enabled" $HOMEDIR/.config/google-chrome/Default/Preferences; then
    # Already in the file, change true to false
    sed -i 's/"clear_lso_data_enabled":false/"clear_lso_data_enabled":true/' \
       $HOMEDIR/.config/google-chrome/Default/Preferences
else
    # Not in the file, add it to the file before "window_placement"
    sed -i 's/"window_placement"/"clear_lso_data_enabled":true,"window_placement"/' \
       $HOMEDIR/.config/google-chrome/Default/Preferences
fi

# Enable pepper flash in browser
if grep -q "pepper_flash_settings_enabled" $HOMEDIR/.config/google-chrome/Default/Preferences; then
    # Already in the file, change true to false
    sed -i 's/"pepper_flash_settings_enabled":false/"pepper_flash_settings_enabled":true/' \
       $HOMEDIR/.config/google-chrome/Default/Preferences
else
    # Not in the file, add it to the file before "window_placement"
    sed -i 's/"window_placement"/"pepper_flash_settings_enabled":true,"window_placement"/' \
       $HOMEDIR/.config/google-chrome/Default/Preferences
fi


# Fixing Chrome Keyring issue
output "Fixing Chrome Keyring issue"
mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon-bak
killall gnome-keyring-daemon


# Setting up the dock
output "Setting up the dock"
rm $HOMEDIR/.config/plank/dock1/launchers/*.dockitem

wget -qLO $HOMEDIR/.config/plank/dock1/launchers/pantheon-files.dockitem \
     "$URL$HOMEDIR/.config/plank/dock1/launchers/pantheon-files.dockitem"

wget -qLO $HOMEDIR/.config/plank/dock1/launchers/code.dockitem \
     "$URL$HOMEDIR/.config/plank/dock1/launchers/code.dockitem"

wget -qLO $HOMEDIR/.config/plank/dock1/launchers/google-chrome.dockitem \
     "$URL$HOMEDIR/.config/plank/dock1/launchers/google-chrome.dockitem"

wget -qLO $HOMEDIR/.config/plank/dock1/launchers/chromium-browser.dockitem \
     "$URL$HOMEDIR/.config/plank/dock1/launchers/chromium-browser.dockitem"

# If 0, the dock won't hide.
sed -i 's/HideMode=3/HideMode=0/g' $HOMEDIR/.config/plank/dock1/settings

# List of *.dockitems files on this dock.
sed -i 's/DockItems=*/DockItems=pantheon-files.dockitem;;code.dockitem;;google-chrome-beta.dockitem/g' $HOMEDIR/.config/plank/dock1/settings

# Changing desktop background
output "Changing desktop background"
wget -qLO /usr/share/backgrounds/coderdojochi.png \
     "$URL/usr/share/backgrounds/coderdojochi.png"

mv /usr/share/backgrounds/elementaryos-default \
   /usr/share/backgrounds/elementaryos-default-bak

ln -s /usr/share/backgrounds/coderdojochi.png \
      /usr/share/backgrounds/elementaryos-default

userrun 'gsettings set "org.gnome.desktop.background" "picture-uri" "file:///usr/share/backgrounds/coderdojochi.png"'
userrun 'gsettings set "org.gnome.desktop.background" "picture-options" "zoom"'


# Setting screensaver settings
output "Setting screensaver settings"
userrun 'gsettings set "org.gnome.desktop.screensaver" "lock-delay" 3600'
userrun 'gsettings set "org.gnome.desktop.screensaver" "lock-enabled" false'
userrun 'gsettings set "org.gnome.desktop.screensaver" "idle-activation-enabled" false'
userrun 'gsettings set "org.gnome.desktop.session" "idle-delay" 0'


# Setting Window Controls
output "Setting Window Controls"
gsettings set org.pantheon.desktop.gala.appearance button-layout :minimize,maximize,close
gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/DecorationLayout': <':minimize,maximize,close'>}"


# Disable guest login
output "Disable guest login"
wget -qLO /usr/share/lightdm/lightdm.conf/40-pantheon-greeter.conf \
     "$URL/usr/share/lightdm/lightdm.conf/40-pantheon-greeter.conf"


# Restart dock
output "Restart dock"
killall plank


# Fix drag and drop quirk
output "Fix drag and drop quirk"
wget -qLO /usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf \
     "$URL/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf"


# Install cdcformat script
output "Install cdcformat script"
wget -qLO /usr/sbin/cdcformat \
     "$URL/usr/sbin/cdcformat"
chmod +x /usr/sbin/cdcformat


# Installing phonehome config file
if [ ! -f $CONFDIR/$CONF ]; then
    output "Installing phonehome config file"
    wget -qLO $CONFDIR/$CONF $URL/$CONFDIR/$CONF
else
    output "Phonehome config file exists"
fi


# Installing phonehome script
output "Installing phonehome script"
wget -qLO $SCRIPTDIR/$SCRIPT $URL/$SCRIPTDIR/$SCRIPT
chmod +x $SCRIPTDIR/$SCRIPT


# Installing phonehome cron
if [ ! -f $CRONDIR/$SCRIPT ]; then
    output "Installing phonehome cron"
    wget -qLO $CRONDIR/$SCRIPT $URL/$CRONDIR/$SCRIPT
else
    output "Phonehome cron exists"
fi


# Restarting in 1 minute
# output "Restarting in 1 minute"
# shutdown -r 1

