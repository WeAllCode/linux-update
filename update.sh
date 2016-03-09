if [[ ! -a /etc/apt/sources.list.d/google-chrome.list ]]; then
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list';
fi

sudo add-apt-repository ppa:mpstark/elementary-tweaks-daily -y

sudo apt-get update
sudo apt-get dist-upgrade -y

command -v zeitgeist-daemon &> /dev/null
if [ $? -eq 0 ]; then
    zeitgeist-daemon --quit
fi
sudo apt-get --purge autoremove -y deja-dup indicator-messages empathy-* gnome-online-accounts activity-log-manager-common activity-log-manager-control-center zeitgeist zeitgeist-core zeitgeist-datahub midori-granite noise software-center update-manager scratch-text-editor modemmanager geary

sudo apt-get install -y elementary-tweaks gedit vim google-chrome-stable

sudo sed -i 's/\[Desktop Entry\]/[Desktop Entry]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop
sudo sed -i 's/\[NewWindow Shortcut Group\]/[NewWindow Shortcut Group]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop
sudo sed -i 's/\[NewIncognito Shortcut Group\]/[NewIncognito Shortcut Group]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop

sudo rm -rf ~/.config/midori ~/.config/google-chrome

sudo wget -qLO /opt/google/chrome/default_apps/external_extensions.json "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/external_extensions.json"

google-chrome-stable --no-first-run > /dev/null 2>&1 &
sleep 10
killall chrome
sleep 5

sudo sed -i 's/user",/user","password_manage_enabled":false,/' ~/.config/google-chrome/Default/Preferences

sudo sed -i 's/"restore_on_startup_migrated":true,/"restore_on_startup":4,"restore_on_startup_migrated":true,"startup_urls":["https:\/\/google.com\/"],/' ~/.config/google-chrome/Default/Preferences

sudo sed -i 's/"window_placement"/"clear_lso_data_enabled":true,"custom_chrome_frame":false,"pepper_flash_settings_enabled":true,"window_placement"/' ~/.config/google-chrome/Default/Preferences

sudo sed -i 's/"cjpalhdlnbpafiamejdnhcphjbkeiagm":{/"cjpalhdlnbpafiamejdnhcphjbkeiagm":{"browser_action_visible":false,/' ~/.config/google-chrome/Default/Preferences


rm ~/.config/plank/dock1/launchers/*.dockitem

wget -qLO ~/.config/plank/dock1/launchers/pantheon-files.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/pantheon-files.dockitem"

wget -qLO ~/.config/plank/dock1/launchers/gedit.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/gedit.dockitem"

wget -qLO ~/.config/plank/dock1/launchers/google-chrome.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/google-chrome.dockitem"

sed -i 's/HideMode=3/HideMode=0/g' ~/.config/plank/dock1/settings

sudo wget -qLO /usr/share/backgrounds/coderdojochi.png "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/coderdojochi.png"
gsettings set 'org.gnome.desktop.background' 'picture-uri' 'file:///usr/share/backgrounds/coderdojochi.png'
gsettings set 'org.gnome.desktop.background' 'picture-options' 'zoom'

gsettings set 'org.gnome.desktop.screensaver' 'lock-delay' 3600
gsettings set 'org.gnome.desktop.screensaver' 'lock-enabled' false
gsettings set 'org.gnome.desktop.screensaver' 'idle-activation-enabled' false

killall plank

sudo wget -qLO /usr/share/X11/xorg.conf.d/60-drag-and-drop-quirk.conf "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/60-drag-and-drop-quirk.conf"

sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo rm -rf {/root,/home/*}/.local/share/zeitgeist

sudo shutdown -r now
