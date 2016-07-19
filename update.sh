URL='https://raw.githubusercontent.com/CoderDojoChi/linux-update/master'

HOMEDIR=/home/coderdojochi
SCRIPTDIR=/etc/init.d
SCRIPT=coderdojochi-phonehome
CONFDIR=/etc/init
CONF=$SCRIPT.conf

userrun() {
    sudo -H -u coderdojochi bash -c "$1";
}

output() {
    echo "\n\n####################\n# $1\n####################\n\n";
    userrun "notify-send --urgency=low '$1'";
}


# Install the coderdojochi-phone autoupdate script
if [ ! -f $CONFDIR/$CONF ]; then
    output "Installing phonehome config file"
    wget -qLO $CONFDIR/$CONF $URL/$CONFDIR/$CONF
fi

if [ ! -f $SCRIPTDIR/$SCRIPT ]; then
    output "Installing phonehome script"
    wget -qLO $SCRIPTDIR/$SCRIPT $URL/$SCRIPTDIR/$SCRIPT
fi


# Update Script Running
userrun 'notify-send --urgency=critical "Update Script Running"'


# Adding Google to package manager
output "Adding Google to package manager"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
wget -qLO /etc/apt/sources.list.d/google-chrome.list \
     "$URL/etc/apt/sources.list.d/google-chrome.list"


# Adding Elementary Tweaks to package manager
output "Adding Elementary Tweaks to package manager"
add-apt-repository ppa:mpstark/elementary-tweaks-daily -y


# Upgrading system
output "Upgrading system"
apt-get update
apt-get dist-upgrade -y


# Uninstalling unused packages
output "Uninstalling unused packages"
command -v zeitgeist-daemon &> /dev/null
if [ $? -eq 0 ]; then
    zeitgeist-daemon --quit
fi

apt-get autoremove --purge -y \
    activity-log-manager-common \
    activity-log-manager-control-center \
    deja-dup \
    empathy-* \
    geary \
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


# Installing git
output "Installing git"
apt-get install -y git


# Installing elementary-tweaks
output "Installing elementary-tweaks"
apt-get install -y elementary-tweaks


# Installing gedit
output "Installing gedit"
apt-get install -y gedit


# Installing vim
output "Installing vim"
apt-get install -y vim


# Installing atom
# output "Installing atom"
# wget -qLO /tmp/atom-amd64.deb https://github.com/atom/atom/releases/download/v1.8.0/atom-amd64.deb
# dpkg --install /tmp/atom-amd64.deb


# Installing google-chrome-stable
output "Installing google-chrome-beta"
rm -rf $HOMEDIR/.config/midori \
       $HOMEDIR/.config/google-chrome \
       $HOMEDIR/.config/google-chrome-beta

apt-get install -y google-chrome-beta

wget -qLO /opt/google/chrome-beta/default_apps/external_extensions.json \
     "$URL/opt/google/chrome-beta/default_apps/external_extensions.json"

userrun 'google-chrome-beta --no-first-run > /dev/null 2>&1 &'
userrun 'sleep 10'
userrun 'killall chrome'
userrun 'sleep 5'


# Chrome: disable password manager
output "Chrome: disable password manager"
sed -i 's/user",/user","password_manage_enabled":false,/' \
    $HOMEDIR/.config/google-chrome/Default/Preferences

sed -i 's/user",/user","password_manage_enabled":false,/' \
    $HOMEDIR/.config/google-chrome-beta/Default/Preferences


# Chrome: change startup URL to google.com
output "Chrome: change startup URL to google.com"

sed -i 's/"restore_on_startup_migrated":true,/"restore_on_startup":4,"restore_on_startup_migrated":true,"startup_urls":["https:\/\/google.com\/"],/' \
    $HOMEDIR/.config/google-chrome/Default/Preferences

sed -i 's/"restore_on_startup_migrated":true,/"restore_on_startup":4,"restore_on_startup_migrated":true,"startup_urls":["https:\/\/google.com\/"],/' \
    $HOMEDIR/.config/google-chrome-beta/Default/Preferences


# Chrome: turn off custome frame
output "Chrome: turn off custome frame"

wget -qLO /home/coderdojochi/.config/google-chrome-beta/Default/Preferences \
     "$URL/home/coderdojochi/.config/google-chrome-beta/Default/Preferences"

# Setting up the dock
output "Setting up the dock"
rm $HOMEDIR/.config/plank/dock1/launchers/*.dockitem

wget -qLO $HOMEDIR/.config/plank/dock1/launchers/pantheon-files.dockitem \
     "$URL$HOMEDIR/.config/plank/dock1/launchers/pantheon-files.dockitem"

wget -qLO $HOMEDIR/.config/plank/dock1/launchers/gedit.dockitem \
     "$URL$HOMEDIR/.config/plank/dock1/launchers/gedit.dockitem"

wget -qLO $HOMEDIR/.config/plank/dock1/launchers/google-chrome-beta.dockitem \
     "$URL$HOMEDIR/.config/plank/dock1/launchers/google-chrome-beta.dockitem"

sed -i 's/HideMode=3/HideMode=0/g' $HOMEDIR/.config/plank/dock1/settings


# Changing desktop background
output "Changing desktop background"
wget -qLO /usr/share/backgrounds/coderdojochi.png \
     "$URL/usr/share/backgrounds/coderdojochi.png"

sudo mv /usr/share/backgrounds/elementaryos-default
sudo ln -s /usr/share/backgrounds/coderdojochi.png \
           /usr/share/backgrounds/elementaryos-default

# userrun 'gsettings set "org.gnome.desktop.background" "picture-uri" "file:///usr/share/backgrounds/coderdojochi.png"'
userrun 'gsettings set "org.gnome.desktop.background" "picture-options" "zoom"'


# Setting screensaver settings
output "Setting screensaver settings"
userrun 'gsettings set "org.gnome.desktop.screensaver" "lock-delay" 3600'
userrun 'gsettings set "org.gnome.desktop.screensaver" "lock-enabled" false'
userrun 'gsettings set "org.gnome.desktop.screensaver" "idle-activation-enabled" false'
userrun 'gsettings set "org.gnome.desktop.session" "idle-delay" 0'


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


# Restarting in 1 minute
output "Restarting in 1 minute"
shutdown -r 1
