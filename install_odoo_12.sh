#!/bin/bash
#print("Script de Intslacion odoo.
         #Autor:     Juan Garica / Root System Technology
         #Fecha:     18/02/2022
         #Verion:    12")
         
#Actualizamos el sistema:
#print("------ INCIO DE ACTUALIZACIONES DE SISTEMA ------")
sudo apt-get update && sudo apt-get upgrade
#print("------ FIN DE ACTUALIZACIONES DE SISTEMA ------")

#print("------ Creamos el usuario y grupo de sistema 'odoo': ------")
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo --gecos 'odoo' --group odoo
#print("------ Creamos en directorio en donde se almacenará el archivo de configuración y log de odoo: ------")
sudo mkdir /etc/odoo && sudo mkdir /var/log/odoo/
#print("------ Instalamos Postgres y librerías base del sistema: ------")
sudo apt-get update && sudo apt-get install postgresql postgresql-server-dev-10 build-essential python3-pil python3-lxml python-ldap3 python3-dev python3-pip python3-setuptools npm nodejs git libldap2-dev libsasl2-dev  libxml2-dev libxslt1-dev libjpeg-dev -y
#print("------ Descargamos odoo version 12 desde git: ------")
sudo git clone --depth 1 --branch 12.0 https://github.com/odoo/odoo /opt/odoo/odoo
#print("------ Damos permiso al directorio que contiene los archivos de OdooERP  e instalamos las dependencias de python3: ------")
sudo chown odoo:odoo /opt/odoo/ -R && sudo chown odoo:odoo /var/log/odoo/ -R && cd /opt/odoo/odoo && sudo pip3 install -r requirements.txt
#print("------ Usamos npm, que es el gestor de paquetes Node.js para instalar less: ------")
sudo npm install -g less less-plugin-clean-css -y && sudo ln -s /usr/bin/nodejs /usr/bin/node
#print("------ Descargamos dependencias e instalar wkhtmltopdf para generar PDF en odoo ------")
sudo apt install xfonts-base xfonts-75dpi -y
cd /tmp
wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb && sudo dpkg -i libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb && sudo dpkg -i wkhtmltox_0.12.6-1.focal_amd64.deb
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin/
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin/
#wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && sudo gunzip GeoLiteCity.dat.gz && sudo mkdir /usr/share/GeoIP/ && sudo mv GeoLiteCity.dat /usr/share/GeoIP/
#print("------ Creamos un usuario 'odoo' para la base de datos: ------")
sudo su - postgres -c "createuser -s odoo"
#print("------ Creamos la configuracion de Odoo: ------")
sudo su - odoo -c "/opt/odoo/odoo/odoo-bin --addons-path=/opt/odoo/odoo/addons -s --stop-after-init"
#print("------ Creamos el archivo de configuracion de odoo: ------")
sudo mv /opt/odoo/.odoorc /etc/odoo/odoo.conf
#print("------ Agregamos los siguientes parámetros al archivo de configuración de odoo: ------")
sudo sed -i "s,^\(logfile = \).*,\1"/var/log/odoo/odoo-server.log"," /etc/odoo/odoo.conf
#sudo sed -i "s,^\(logrotate = \).*,\1"True"," /etc/odoo/odoo.conf
#sudo sed -i "s,^\(proxy_mode = \).*,\1"True"," /etc/odoo/odoo.conf
#Creamos el archivo de inicio del servicio de Odoo:
sudo cp /opt/odoo/odoo/debian/init /etc/init.d/odoo && sudo chmod +x /etc/init.d/odoo
sudo ln -s /opt/odoo/odoo/odoo-bin /usr/bin/odoo
sudo update-rc.d -f odoo start 20 2 3 4 5 .
sudo service odoo start
