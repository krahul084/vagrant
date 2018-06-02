#!/bin/bash
#script to install nagios core on centos 7
lamp_packages=( "httpd" "mariadb-server" "mariadb" "php" "php-mysql" "php-fpm" "elinks" )
lamp_services=( httpd mariadb )

#script_utils=( pv dialog )
yum install -y  >> /dev/null 2> /dev/null

#Function to install the prerequisite packages
install_packages() {
    packages=("$@")
    for i in "${packages[@]}"; do
      echo "Installing $i"
      is_installed=$(yum info $i| grep Repo | awk '{print $3 }' )
      if [ "$is_installed" != "installed" ]; then
          yum install -y "$i"  > /dev/null
          install_stat=$?
          if [ "$install_stat" -eq 0 ]; then
              echo "$i is installed"
              sleep 1
          else
              echo "Installation of $i failed!, Please take a moment to troubleshoot exiting with exit code-90"
              exit 90
          fi
      fi
    done
}

start_lamp() {
    systemctl start httpd.service
    systemctl enable httpd.service
    systemctl start mariadb
    systemctl restart httpd.service
}

check_services() {
    services=("$@")
    for serv in ${services[@]}; do
      echo "Checking Service $serv"
      is_running=$(systemctl status $serv |grep -i active | awk '{print $3}')
      if [ "$is_running" == "(running)" ]; then
        echo "$serv is running, Proceeding with further configuration"
        sleep 1
      else
         echo "$serv dead, please troubleshoot to proceed further exiting with exit code-91"
         exit 91
      fi
    done
}

#Installing, starting and checking the Lamp Packages
install_packages ${lamp_packages[@]} && start_lamp && check_services ${lamp_services[@]}
sleep 5
echo "Lamp is successfully installed and running"
