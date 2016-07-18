notify-send --urgency=critical "Updating System"

# Adding Google to package manager
notify-send --urgency=low "Adding Google to package manager"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
wget -qLO /etc/apt/sources.list.d/google-chrome.list "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/google-chrome.list"

# Adding Elementary Tweaks to package manager
notify-send --urgency=low "Adding Elementary Tweaks to package manager"
add-apt-repository ppa:mpstark/elementary-tweaks-daily -y

# Upgrading system
notify-send --urgency=low "Upgrading system"
apt-get update
apt-get dist-upgrade -y

# Uninstalling unused packages
notify-send --urgency=low "Uninstalling unused packages"
command -v zeitgeist-daemon &> /dev/null
if [ $? -eq 0 ]; then
    zeitgeist-daemon --quit
fi
apt-get --purge autoremove -y deja-dup indicator-messages empathy-* gnome-online-accounts activity-log-manager-common activity-log-manager-control-center zeitgeist zeitgeist-core zeitgeist-datahub midori-granite noise software-center update-manager scratch-text-editor modemmanager geary

# Installing elementary-tweaks
notify-send --urgency=low "Installing elementary-tweaks"
apt-get install -y elementary-tweaks

# Installing gedit
notify-send --urgency=low "Installing gedit"
apt-get install -y gedit

# Installing vim
notify-send --urgency=low "Installing vim"
apt-get install -y vim

# Installing google-chrome-stable
notify-send --urgency=low "Installing google-chrome-stable"
apt-get install -y google-chrome-stable

sed -i 's/\[Desktop Entry\]/[Desktop Entry]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop
sed -i 's/\[NewWindow Shortcut Group\]/[NewWindow Shortcut Group]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop
sed -i 's/\[NewIncognito Shortcut Group\]/[NewIncognito Shortcut Group]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop

rm -rf ~/.config/midori ~/.config/google-chrome

wget -qLO /opt/google/chrome/default_apps/external_extensions.json "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/external_extensions.json"

google-chrome-stable --no-first-run > /dev/null 2>&1 &
sleep 10
killall chrome
sleep 5

sed -i 's/user",/user","password_manage_enabled":false,/' ~/.config/google-chrome/Default/Preferences

sed -i 's/"restore_on_startup_migrated":true,/"restore_on_startup":4,"restore_on_startup_migrated":true,"startup_urls":["https:\/\/google.com\/"],/' ~/.config/google-chrome/Default/Preferences

sed -i 's/"window_placement"/"clear_lso_data_enabled":true,"custom_chrome_frame":false,"pepper_flash_settings_enabled":true,"window_placement"/' ~/.config/google-chrome/Default/Preferences

sed -i 's/"cjpalhdlnbpafiamejdnhcphjbkeiagm":{/"cjpalhdlnbpafiamejdnhcphjbkeiagm":{"browser_action_visible":false,/' ~/.config/google-chrome/Default/Preferences

# Setting up the dock
notify-send --urgency=low "Setting up the dock"
rm ~/.config/plank/dock1/launchers/*.dockitem

wget -qLO ~/.config/plank/dock1/launchers/pantheon-files.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/pantheon-files.dockitem"

wget -qLO ~/.config/plank/dock1/launchers/gedit.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/gedit.dockitem"

wget -qLO ~/.config/plank/dock1/launchers/google-chrome.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/google-chrome.dockitem"

sed -i 's/HideMode=3/HideMode=0/g' ~/.config/plank/dock1/settings

# Changing desktop background
notify-send --urgency=low "Changing desktop background"
wget -qLO /usr/share/backgrounds/coderdojochi.png "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/coderdojochi.png"
gsettings set 'org.gnome.desktop.background' 'picture-uri' 'file:///usr/share/backgrounds/coderdojochi.png'
gsettings set 'org.gnome.desktop.background' 'picture-options' 'zoom'

# Setting screensaver settings
notify-send --urgency=low "Setting screensaver settings"
gsettings set 'org.gnome.desktop.screensaver' 'lock-delay' 3600
gsettings set 'org.gnome.desktop.screensaver' 'lock-enabled' false
gsettings set 'org.gnome.desktop.screensaver' 'idle-activation-enabled' false

killall plank

wget -qLO /usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/60-drag-and-drop-quirk.conf"

# Cleanup
notify-send --urgency=low "Cleanup"
apt-get autoremove -y
apt-get autoclean -y
rm -rf {/root,/home/*}/.local/share/zeitgeist

# Remove old files that students might of saved
rm -rf /home/coderdojochi/Downloads/*
rm -rf /home/coderdojochi/Documents/*
rm -rf /home/coderdojochi/Music/*
rm -rf /home/coderdojochi/Pictures/*
rm -rf /home/coderdojochi/Videos/*
rm -rf /home/coderdojochi/Public/*
rm -rf /home/coderdojochi/Templates/*

# Restarting in 1 minute
notify-send --urgency=low "Restarting in 1 minute"
shutdown -r 1
