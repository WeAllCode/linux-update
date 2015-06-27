if [[ ! -a /etc/apt/sources.list.d/google-chrome.list ]]; then
  # echo " - Adding Chrome to sources list"
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
fi

sudo add-apt-repository ppa:mpstark/elementary-tweaks-daily -y

echo " - Running update"
sudo apt-get update -qq
sudo apt-get dist-upgrade -qq -y

echo " - Remove zeitgeist, gnome online indicator and telepathy, and unused apps"
zeitgeist-daemon --quit
sudo apt-get -qq --purge autoremove -y deja-dup indicator-messages empathy-* gnome-online-accounts activity-log-manager-common activity-log-manager-control-center zeitgeist zeitgeist-core zeitgeist-datahub midori-granite noise software-center update-manager scratch-text-editor modemmanager geary

echo " - Installing apps"

sudo apt-get install elementary-tweaks
sudo apt-get install -qq -y gedit
sudo apt-get install -qq -y vim
sudo apt-get install -qq -y google-chrome-stable

# echo " - Fix Google Chrome double icon bug"
sudo sed -i 's/\[Desktop Entry\]/[Desktop Entry]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop
sudo sed -i 's/\[NewWindow Shortcut Group\]/[NewWindow Shortcut Group]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop
sudo sed -i 's/\[NewIncognito Shortcut Group\]/[NewIncognito Shortcut Group]\nStartupWMClass=Google-chrome-stable/g' /usr/share/applications/google-chrome.desktop

# echo " - Set up Google Chrome profile"
sudo rm -rf ~/.config/midori

echo " - Updating Dock."

echo " -- Clear current Dock."
rm ~/.config/plank/dock1/launchers/*.dockitem

echo " -- Adding Files to dock."
wget -qLO ~/.config/plank/dock1/launchers/pantheon-files.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/pantheon-files.dockitem"

echo " -- Adding gedit to dock."
wget -qLO ~/.config/plank/dock1/launchers/gedit.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/gedit.dockitem"

echo " -- Adding Chrome to dock."
wget -qLO ~/.config/plank/dock1/launchers/google-chrome.dockitem "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/google-chrome.dockitem"

echo " -- Disable Dock Autohide"
sed -i 's/HideMode=3/HideMode=0/g' ~/.config/plank/dock1/settings

# echo " - Set background"
# sudo wget -qLO /usr/share/backgrounds/coderdojochi.png "https://raw.githubusercontent.com/CoderDojoChi/linux-update/master/coderdojochi.png"
# gsettings set 'org.gnome.desktop.background' 'picture-uri' 'file:///usr/share/backgrounds/coderdojochi.png'
# gsettings set 'org.gnome.desktop.background' 'picture-options' 'zoom'

# echo " -- Restarting Dock"
# killall plank

# # echo " - Make toolbar always transparent"
# # gsettings set 'org.pantheon.desktop.wingpanel' 'auto-adjust-alpha' false
# # gsettings set 'org.pantheon.desktop.wingpanel' 'background-alpha' 0.0
# # killall wingpanel

# echo " - Cleaning up."
sudo apt-get autoremove -qq -y
sudo apt-get autoclean -qq -y
sudo rm -fr {/root,/home/*}/.local/share/zeitgeist

# # echo " - Restarting"
# # sudo shutdown -r now
