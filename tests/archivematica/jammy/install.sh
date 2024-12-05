#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -x


function get_env_boolean() {
    local name="$1"
    local default="$2"
    local ret="${default}"
    if [ "${default}" == "true" ]; then
        if [ "${!name}" == "no" ] || [ "${!name}" == "false" ] || [ "${!name}" == "0" ]; then
            ret="false"
        fi
    fi
    if [ "${default}" == "false" ]; then
        if [ "${!name}" == "yes" ] || [ "${!name}" == "true" ] || [ "${!name}" == "1" ]; then
            ret="true"
        fi
    fi
    echo -n "${ret}"
}

search_enabled=$(get_env_boolean "SEARCH_ENABLED" "true")
local_repository=$(get_env_boolean "LOCAL_REPOSITORY" "false")

echo "~~~~~~~~ DEBUG ~~~~~~~~~~~~~~~~~~~~~~~~~~~"
while read -r line; do echo "$line=${!line}"; done < <(compgen -v | grep -v '[^[:lower:]_]' | grep -v '^_$')
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo debconf-set-selections <<< "archivematica-storage-service archivematica-storage-service/dbconfig-install boolean true"
sudo debconf-set-selections <<< "archivematica-storage-service archivematica-storage-service/mysql/app-pass password demo-ss"
sudo debconf-set-selections <<< "archivematica-storage-service archivematica-storage-service/app-password-confirm password demo-ss"
sudo debconf-set-selections <<< "archivematica-mcp-server archivematica-mcp-server/dbconfig-install boolean true"
sudo debconf-set-selections <<< "archivematica-mcp-server archivematica-mcp-server/mysql/app-pass password demo-am"
sudo debconf-set-selections <<< "archivematica-mcp-server archivematica-mcp-server/app-password-confirm password demo-am"

curl -fsSL https://packages.archivematica.org/1.17.x/key.asc | sudo gpg --dearmor -o /etc/apt/keyrings/archivematica-1.17.x.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/archivematica-1.17.x.gpg] http://packages.archivematica.org/1.17.x/ubuntu-externals jammy main" > /etc/apt/sources.list.d/archivematica-externals.list'

if [ "${local_repository}" == "true" ] ; then
    sudo -u root bash -c 'cat << EOF > /etc/apt/sources.list.d/archivematica.list
deb file:/am-packbuild/debs/jammy/_deb_repository ./
EOF'
else
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/archivematica-1.17.x.gpg] http://packages.archivematica.org/1.17.x/ubuntu jammy main" > /etc/apt/sources.list.d/archivematica.list'
fi

sudo apt-get -o Acquire::AllowInsecureRepositories=true update
sudo apt-get -y upgrade

sudo apt-get install -y openjdk-8-jre-headless mysql-server
sudo systemctl daemon-reload
sudo service mysql restart
sudo systemctl enable mysql

if [ "${search_enabled}" == "true" ] ; then
    curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /etc/apt/keyrings/elasticsearch-6.x.gpg
    echo "deb [signed-by=/etc/apt/keyrings/elasticsearch-6.x.gpg] https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
    sudo apt-get -o Acquire::AllowInsecureRepositories=true update
    sudo apt-get install -y elasticsearch
    sudo systemctl daemon-reload
    sudo service elasticsearch restart
    sudo systemctl enable elasticsearch
fi

sudo apt-get install -y --allow-unauthenticated archivematica-storage-service

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/storage /etc/nginx/sites-enabled/storage

sudo apt-get install -y --allow-unauthenticated archivematica-mcp-server
sudo apt-get install -y --allow-unauthenticated archivematica-dashboard
sudo apt-get install -y --allow-unauthenticated archivematica-mcp-client

if [ "${search_enabled}" != "true" ] ; then
    sudo sh -c 'echo "ARCHIVEMATICA_DASHBOARD_DASHBOARD_SEARCH_ENABLED=false" >> /etc/default/archivematica-dashboard'
    sudo sh -c 'echo "ARCHIVEMATICA_MCPSERVER_MCPSERVER_SEARCH_ENABLED=false" >> /etc/default/archivematica-mcp-server'
    sudo sh -c 'echo "ARCHIVEMATICA_MCPCLIENT_MCPCLIENT_SEARCH_ENABLED=false" >> /etc/default/archivematica-mcp-client'
fi

sudo ln -sf /etc/nginx/sites-available/dashboard.conf /etc/nginx/sites-enabled/dashboard.conf

sudo service clamav-freshclam restart
sleep 120s
sudo service clamav-daemon start
sudo service gearman-job-server restart
sudo service archivematica-mcp-server start
sudo service archivematica-mcp-client restart
sudo service archivematica-storage-service start
sudo service archivematica-dashboard restart
sudo service nginx restart

sudo -u archivematica bash -c " \
    set -a -e -x
    source /etc/default/archivematica-storage-service || \
        source /etc/sysconfig/archivematica-storage-service \
            || (echo 'Environment file not found'; exit 1)
    cd /usr/lib/archivematica/storage-service
      /usr/share/archivematica/virtualenvs/archivematica-storage-service/bin/python manage.py create_user \
          --username=admin \
          --password=archivematica \
          --email="example@example.com" \
          --api-key="apikey" \
          --superuser
";

sudo -u archivematica bash -c " \
    set -a -e -x
    source /etc/default/archivematica-dashboard || \
        source /etc/sysconfig/archivematica-dashboard \
            || (echo 'Environment file not found'; exit 1)
    cd /usr/share/archivematica/dashboard
      /usr/share/archivematica/virtualenvs/archivematica/bin/python manage.py install \
          --username="admin" \
          --password="archivematica" \
          --email="example@example.com" \
          --org-name="test" \
          --org-id="test" \
          --api-key="apikey" \
          --ss-url="http://localhost:8000" \
          --ss-user="admin" \
          --ss-api-key="apikey" \
          --site-url="http://localhost"
";

sudo -u archivematica bash -c " \
    set -a -e -x
    source /etc/default/archivematica-dashboard || \
        source /etc/sysconfig/archivematica-dashboard \
            || (echo 'Environment file not found'; exit 1)
    cd /usr/share/archivematica/dashboard
      /usr/share/archivematica/virtualenvs/archivematica/bin/python manage.py collectstatic --noinput --clear
";

sudo -u archivematica bash -c " \
    set -a -e -x
    source /etc/default/archivematica-dashboard || \
        source /etc/sysconfig/archivematica-dashboard \
            || (echo 'Environment file not found'; exit 1)
    cd /usr/share/archivematica/dashboard
      /usr/share/archivematica/virtualenvs/archivematica/bin/python manage.py compilemessages
";


sudo -u archivematica bash -c " \
    set -a -e -x
    source /etc/default/archivematica-storage-service || \
        source /etc/sysconfig/archivematica-storage-service \
            || (echo 'Environment file not found'; exit 1)
    cd /usr/lib/archivematica/storage-service
      /usr/share/archivematica/virtualenvs/archivematica-storage-service/bin/python manage.py collectstatic --noinput --clear
";

sudo -u archivematica bash -c " \
    set -a -e -x
    source /etc/default/archivematica-storage-service || \
        source /etc/sysconfig/archivematica-storage-service \
            || (echo 'Environment file not found'; exit 1)
    cd /usr/lib/archivematica/storage-service
      /usr/share/archivematica/virtualenvs/archivematica-storage-service/bin/python manage.py compilemessages
";
