URL='https://raw.githubusercontent.com/CoderDojoChi/linux-update/master'

HOMEDIR=/home/coderdojochi

SCRIPTDIR=/etc/init.d
SCRIPT=coderdojochi-phonehome

CONFDIR=/etc/init
CONF=$SCRIPT.conf

CRONDIR=/etc/cron.d

MACHINE_TYPE=`uname -m`


output() {
    echo "\n\n####################\n# $1\n####################\n\n";
    notify-send --urgency=low "$1";
}


# Update Script Running
output "Update Script Running"
echo ".panel,.panel.maximized,.panel.translucent{background-color:red;}" | \
    sudo tee -a /usr/share/themes/elementary/gtk-3.0/apps.css
sudo killall wingpanel


# Cleanup files
output "Cleanup files"
sudo rm -rf /etc/apt/trusted.gpg.d/*


# Remove old files that students might of saved
sudo rm -rf $HOMEDIR/Documents/*
sudo rm -rf $HOMEDIR/Downloads/*
sudo rm -rf $HOMEDIR/Music/*
sudo rm -rf $HOMEDIR/Pictures/*
sudo rm -rf $HOMEDIR/Public/*
sudo rm -rf $HOMEDIR/Templates/*
sudo rm -rf $HOMEDIR/Videos/*


# Reset Code settings
sudo rm -rf $HOMEDIR/.config/Code/User/settings.json
wget -qLO $HOMEDIR/.config/Code/User/settings.json \
     "$URL$HOMEDIR/.config/Code/User/settings.json"


# Uninstalling unused packages
output "Uninstalling unused packages"
command -v zeitgeist-daemon &> /dev/null
if [ $? -eq 0 ]; then
    zeitgeist-daemon --quit
fi

sudo apt purge -qqy activity-log-manager-common
sudo apt purge -qqy activity-log-manager-control-center
sudo apt purge -qqy appcenter
sudo apt purge -qqy atom
sudo apt purge -qqy audience
sudo apt purge -qqy deja-dup
sudo apt purge -qqy elementary-tweaks
sudo apt purge -qqy empathy-*
sudo apt purge -qqy epiphany-*
sudo apt purge -qqy firefox*
sudo apt purge -qqy geary
sudo apt purge -qqy gnome-online-accounts
sudo apt purge -qqy indicator-messages
sudo apt purge -qqy midori-granite
sudo apt purge -qqy modemmanager
sudo apt purge -qqy noise
sudo apt purge -qqy pantheon-mail
sudo apt purge -qqy pantheon-photos*
sudo apt purge -qqy scratch-text-editor
sudo apt purge -qqy screenshot-tool
sudo apt purge -qqy simple-scan
sudo apt purge -qqy software-center
sudo apt purge -qqy update-manager
sudo apt purge -qqy zeitgeist
sudo apt purge -qqy zeitgeist-core
sudo apt purge -qqy zeitgeist-datahub

# Adding Google to package manager
output "Adding Google to package manager"
wget -qLO - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

sudo rm -rf /etc/apt/sources.list.d/google-chrome.list*

sudo wget -qLO /etc/apt/sources.list.d/google-chrome.list \
          "$URL/etc/apt/sources.list.d/google-chrome.list"


# VS Code
output "Adding VS Code to package manager"
curl https://packages.microsoft.com/keys/microsoft.asc | \
    sudo gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg

echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list


# Removing Elementary Tweaks from package manager
output "Removing Elementary Tweaks from package manager"
sudo add-apt-repository -r -y ppa:philip.scott/elementary-tweaks


# Upgrading system
output "Upgrading system"
sudo apt update -qy
sudo apt dist-upgrade -qy


# Cleanup
output "Cleanup"
sudo apt autoremove -qy
sudo rm -rf {/root,/home/*}/.local/share/zeitgeist


# Installing google-chrome-stable
output "Installing Google Chrome (stable)"
sudo rm -rf $HOMEDIR/.config/midori \
            $HOMEDIR/.config/google-chrome \
            $HOMEDIR/.config/google-chrome-stable


# Installing programs
output "Installing programs"
sudo apt install -qy code
sudo apt install -qy gedit
sudo apt install -qy git
sudo apt install -qy google-chrome-stable
sudo apt install -qy vim
sudo apt install -qy xbacklight


# Setting screen brightness to 100
output "Setting screen brightness to 100"
sudo xbacklight -set 100


# Configuring Google Chrome
output "Configuring Google Chrome"
wget -qLO /opt/google/chrome/default_apps/external_extensions.json \
     "$URL/opt/google/chrome/default_apps/external_extensions.json"


google-chrome-stable --no-first-run > /dev/null 2>&1 &
sleep 10
sudo killall chrome
sleep 5

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
sudo mv /usr/bin/gnome-keyring-daemon /usr/bin/gnome-keyring-daemon-bak
sudo killall gnome-keyring-daemon


# Setting up the dock
output "Setting up the dock"
rm -rf $HOMEDIR/.config/plank/dock1/launchers/*.dockitem

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
sudo wget -qLO /usr/share/backgrounds/coderdojochi.png \
          "$URL/usr/share/backgrounds/coderdojochi.png"

sudo mv /usr/share/backgrounds/elementaryos-default \
        /usr/share/backgrounds/elementaryos-default-bak

sudo ln -s /usr/share/backgrounds/coderdojochi.png \
           /usr/share/backgrounds/elementaryos-default

gsettings set "org.gnome.desktop.background" "picture-uri" "file:///usr/share/backgrounds/coderdojochi.png"
gsettings set "org.gnome.desktop.background" "picture-options" "zoom"


# Setting screensaver settings
output "Setting screensaver settings"
gsettings set "org.gnome.desktop.screensaver" "lock-delay" 3600
gsettings set "org.gnome.desktop.screensaver" "lock-enabled" false
gsettings set "org.gnome.desktop.screensaver" "idle-activation-enabled" false
gsettings set "org.gnome.desktop.session" "idle-delay" 0


# Setting Window Controls
# output "Setting Window Controls"
# gsettings set org.pantheon.desktop.gala.appearance button-layout :minimize,maximize,close
# gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'"'"'Gtk/DecorationLayout'"'"': <'"'"':minimize,maximize,close'"'"'>}"


# Disable guest login
output "Disable guest login"
sudo wget -qLO /usr/share/lightdm/lightdm.conf/40-pantheon-greeter.conf \
          "$URL/usr/share/lightdm/lightdm.conf/40-pantheon-greeter.conf"


# Restart dock
output "Restart dock"
sudo killall plank


# Fix drag and drop quirk
output "Fix drag and drop quirk"
sudo wget -qLO /usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf \
          "$URL/usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf"


# Install cdcformat script
output "Install cdcformat script"
sudo wget -qLO /usr/sbin/cdcformat \
          "$URL/usr/sbin/cdcformat"
sudo chmod +x /usr/sbin/cdcformat


# Installing phonehome config file
if [ ! -f $CONFDIR/$CONF ]; then
    output "Installing phonehome config file"
    sudo wget -qLO $CONFDIR/$CONF \
              $URL/$CONFDIR/$CONF
else
    output "Phonehome config file exists"
fi


# Installing phonehome script
output "Installing phonehome script"
sudo wget -qLO $SCRIPTDIR/$SCRIPT \
          $URL/$SCRIPTDIR/$SCRIPT
sudo chmod +x $SCRIPTDIR/$SCRIPT


# Installing phonehome cron
if [ ! -f $CRONDIR/$SCRIPT ]; then
    output "Installing phonehome cron"
    sudo wget -qLO $CRONDIR/$SCRIPT \
              $URL/$CRONDIR/$SCRIPT
else
    output "Phonehome cron exists"
fi


# Reset theme
output "Reset theme"
sudo sed -i '$ d' /usr/share/themes/elementary/gtk-3.0/apps.css
sudo killall wingpanel


# Open survey
xdg-open http://coderdojochi.com/survey/pre &> /dev/null &
