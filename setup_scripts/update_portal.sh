#!/usr/bin/env bash

cd
cd -
cd ~
echo "update smile plug portal page script"

echo "make backups"
echo "in /etc/nginx/"
sudo \cp /etc/nginx/nginx.conf /etc/nginx/nginx_original.conf
echo "in /usr/share/nginx/html/"
sudo \cp /usr/share/nginx/html/index.html /usr/share/nginx/html/index_original.html

echo "prepare the portal page"

cd ~/smile-plug-portal-web
git fetch --all
sudo git reset --hard origin/master

LAST_FOUR_MAC_ADDRESS="$(ip addr | grep link/ether | awk '{print $2}' | tail -1  | sed s/://g | tr '[:lower:]' '[:upper:]' | tail -c 5)"

cd ~/smile-pi/
GIT_HASH="$(git rev-parse HEAD)"

sudo sed -i 's@Administer@Administer Smile Plug (SMILE_'"$LAST_FOUR_MAC_ADDRESS"')@' ~/smile-plug-portal-web/src/templates/admin.html
sudo sed -i 's@breadcrumb-->@breadcrumb '"$GIT_HASH"' -->@' ~/smile-plug-portal-web/src/templates/admin.html

echo "build smile plug portal"
sudo rm -f ~/smile-pi/home.js
ruby ~/smile-pi/setup_files/build_portal.rb
sudo rm -f ~/smile-plug-portal-web/src/views/home.js
cp ~/smile-pi/home.js ~/smile-plug-portal-web/src/views/home.js
sudo rm ~/smile-plug-portal-web/src/templates/navbar.html
cp ~/smile-pi/setup_files/navbar_usb.html ~/smile-plug-portal-web/src/templates/navbar.html

sudo rm ~/smile-plug-portal-web/src/templates/about.html
cp ~/smile-pi/setup_files/about-edify.html ~/smile-plug-portal-web/src/templates/about.html

cd ~/smile-plug-portal-web/
sudo jake build

cd ~/smile-plug-portal-web/target/

echo "put in place new smile plug portal files, html js assets"
sudo rm -rf /usr/share/nginx/html/assets/
sudo rm -rf /usr/share/nginx/html/js/
sudo rm -rf /usr/share/nginx/html/index.html

sudo \cp -r ~/smile-plug-portal-web/target/assets/ /usr/share/nginx/html/assets/
sudo \cp -r ~/smile-plug-portal-web/target/js/ /usr/share/nginx/html/js/
sudo \cp -r ~/smile-plug-portal-web/target/index.html /usr/share/nginx/html/index.html

sudo rm /usr/share/nginx/html/assets/get-wifimac.php
sudo \cp -r ~/smile-pi/setup_files/get-wifimac.php /usr/share/nginx/html/assets/

echo "restart nginx"
sudo systemctl daemon-reload
sudo systemctl restart nginx

cd; cd -
cd ~/smile-pi
