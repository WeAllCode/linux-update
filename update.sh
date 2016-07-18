notify-send --urgency=critical "Updating System"

# Adding Google to package manager
notify-send --urgency=low "Adding Google to package manager"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo wget -qLP /etc/apt/sources.list.d/ "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/google-chrome.list"

# Adding Elementary Tweaks to package manager
notify-send --urgency=low "Adding Elementary Tweaks to package manager"
sudo add-apt-repository ppa:mpstark/elementary-tweaks-daily -y

# Upgrading system
notify-send --urgency=low "Upgrading system"
sudo apt-get update
sudo apt-get dist-upgrade -y

# Uninstalling unused packages
notify-send --urgency=low "Uninstalling unused packages"
command -v zeitgeist-daemon &> /dev/null
if [ $? -eq 0 ]; then
    zeitgeist-daemon --quit
fi
sudo apt-get --purge autoremove -y deja-dup indicator-messages empathy-* gnome-online-accounts activity-log-manager-common activity-log-manager-control-center zeitgeist zeitgeist-core zeitgeist-datahub midori-granite noise software-center update-manager scratch-text-editor modemmanager geary

# Installing elementary-tweaks
notify-send --urgency=low "Installing elementary-tweaks"
sudo apt-get install -y elementary-tweaks

# Installing gedit
notify-send --urgency=low "Installing gedit"
sudo apt-get install -y gedit

# Installing vim
notify-send --urgency=low "Installing vim"
sudo apt-get install -y vim

# Installing google-chrome-stable
notify-send --urgency=low "Installing google-chrome-beta"
sudo apt-get install -y google-chrome-beta

# sudo sed -i '/Group\]\|Desktop Entry/a StartupWMClass=Google-chrome-stable' /usr/share/applications/google-chrome.desktop

# sudo sed -i 's/\[Desktop Entry\]/[Desktop Entry]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop
# sudo sed -i 's/\[NewWindow Shortcut Group\]/[NewWindow Shortcut Group]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop
# sudo sed -i 's/\[NewIncognito Shortcut Group\]/[NewIncognito Shortcut Group]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop

sudo rm -rf ~/.config/midori ~/.config/google-chrome-beta

sudo wget -qLP /opt/google/chrome-beta/default_apps/ "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/external_extensions.json"

google-chrome-beta --no-first-run > /dev/null 2>&1 &
sleep 10
killall chrome
sleep 5

# Chrome: disable password manager
notify-send --urgency=low "Chrome: disable password manager"
sudo sed -i 's/user",/user","password_manage_enabled":false,/' ~/.config/google-chrome-beta/Default/Preferences

# Chrome: change startup URL to google.com
notify-send --urgency=low "Chrome: change startup URL to google.com"
sudo sed -i 's/"restore_on_startup_migrated":true,/"restore_on_startup":4,"restore_on_startup_migrated":true,"startup_urls":["https:\/\/google.com\/"],/' ~/.config/google-chrome-beta/Default/Preferences

# Chrome: turn off custome frame
notify-send --urgency=low "Chrome: turn off custome frame"
sudo sed -i 's/"window_placement"/"clear_lso_data_enabled":true,"custom_chrome_frame":false,"pepper_flash_settings_enabled":true,"window_placement"/' ~/.config/google-chrome-beta/Default/Preferences

sudo sed -i 's/"cjpalhdlnbpafiamejdnhcphjbkeiagm":{/"cjpalhdlnbpafiamejdnhcphjbkeiagm":{"browser_action_visible":false,/' ~/.config/google-chrome-beta/Default/Preferences

# Setting up the dock
notify-send --urgency=low "Setting up the dock"
rm ~/.config/plank/dock1/launchers/*.dockitem

wget -qLP ~/.config/plank/dock1/launchers/ "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/pantheon-files.dockitem"
wget -qLP ~/.config/plank/dock1/launchers/ "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/gedit.dockitem"
wget -qLP ~/.config/plank/dock1/launchers/ "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/google-chrome-beta.dockitem"

sed -i 's/HideMode=3/HideMode=0/g' ~/.config/plank/dock1/settings

# Changing desktop background
notify-send --urgency=low "Changing desktop background"
sudo wget -qLP /usr/share/backgrounds/ "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/coderdojochi.png"
gsettings set 'org.gnome.desktop.background' 'picture-uri' 'file:///usr/share/backgrounds/coderdojochi.png'
gsettings set 'org.gnome.desktop.background' 'picture-options' 'zoom'

# Setting screensaver settings
notify-send --urgency=low "Setting screensaver settings"
gsettings set 'org.gnome.desktop.screensaver' 'lock-delay' 3600
gsettings set 'org.gnome.desktop.screensaver' 'lock-enabled' false
gsettings set 'org.gnome.desktop.screensaver' 'idle-activation-enabled' false

killall plank

sudo wget -qLP /usr/share/X11/xorg.conf.d/ "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/60-drag-and-drop-quirk.conf"

# Cleanup
notify-send --urgency=low "Cleanup"
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo rm -rf {/root,/home/*}/.local/share/zeitgeist

# Remove old files that students might of saved
sudo rm -rf /home/coderdojochi/Downloads/*
sudo rm -rf /home/coderdojochi/Documents/*
sudo rm -rf /home/coderdojochi/Music/*
sudo rm -rf /home/coderdojochi/Pictures/*
sudo rm -rf /home/coderdojochi/Videos/*
sudo rm -rf /home/coderdojochi/Public/*
sudo rm -rf /home/coderdojochi/Templates/*

# Restarting in 1 minute
notify-send --urgency=low "Restarting in 1 minute"
sudo shutdown -r 1
