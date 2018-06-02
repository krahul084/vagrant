#!/bin/bash
#script to install and configure Ansible
ansible_packages=( "epel-release" "ansible" )


#Function to install the ansible packages
install_packages() {
    packages=("$@")
    for i in "${packages[@]}"; do
      echo "Installing $i"
      is_installed=$(yum info $i| grep Repo | awk '{print $3 }' )
      if [ "$is_installed" != "installed" ]; then
          yum clean all > /dev/null
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

#Configuring the ansible user

configure_ansible() {
	useradd -G wheel -s /bin/bash  -d /home/ansible ansible
	echo "ansible:riseNshine" | chpasswd
	if [ $? -eq 0 ]; then
	    echo "Configuration Successful"
	else
	    echo "Configuration failed"
	    exit 91
	fi
}

#Actual implementation
install_packages ${ansible_packages[@]} && configure_ansible
