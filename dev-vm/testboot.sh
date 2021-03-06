#!/bin/bash

# script to setup Fedora VM to use it :-
# sudo usermod -aG wheel $USERNAME
# ./setup_vm.sh -g <github id>
# Note if we don't specify github id will clone master repo instead of your own fork for ovn-kubenetes repo.

set +x

function setup_fedora_vm() {
	#change to use cgroupsv1 instead of cgroupsv2
	sudo sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& systemd.unified_cgroup_hierarchy=0/' /etc/default/grub
	sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

        sudo dnf -y upgrade
        sudo dnf -y update

        sudo dnf -y install dnf-plugins-core

        #install git
        sudo dnf -y install git

        git config --global user.name "Sanjeev Rampal"
        git config --global user.email "srampal@redhat.com"

        sudo dnf -y install gcc 


	#install Go v1.16
	mkdir -p $HOME/go/src
	mkdir -p $HOME/go/bin

        #sync

	#git clone https://github.com/udhos/update-golang.git
	#pushd update-golang
	#./update-golang.sh
	#popd

	export GOPATH=$HOME/go
	export PATH=$PATH:$GOPATH/bin
	export PATH=$PATH:/usr/local/go/bin
	export PATH=$PATH:$HOME/bin

        

	#rm -rf ./update-golang

        #install golang
        sudo dnf -y install golang

	#install docker

        # add repo
        sudo dnf config-manager --add-repo \
              https://download.docker.com/linux/fedora/docker-ce.repo

	sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose
	sudo systemctl enable docker
	sudo systemctl start docker
	sudo groupadd docker
	sudo usermod -g docker $USER

	#Install virtualization tools
	sudo dnf groupinfo virtualization
	sudo dnf group install -y --with-optional virtualization
	sudo systemctl start libvirtd
	sudo systemctl enable libvirtd

	#Install kind
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
	chmod +x ./kind
	sudo mv ./kind /usr/local/bin

	#Install kubectl
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
 #	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/kubectl

	#Install j2
	sudo dnf install -y snapd
	sudo ln -s /var/lib/snapd/snap /snap
	sudo snap install -y j2

	#Install make
	sudo dnf install -y make

	#Install tmate
	sudo dnf install -y tmate
	
	#Install asciinema for console demo
	sudo dnf install -y asciinema
	
        sudo dnf -y install firewalld 

        sudo systemctl enable firewalld
        sudo systemctl start firewalld

	#Change firewall to use iptables
	sudo sed -i "s/^FirewallBackend\=.*/FirewallBackend=iptables/" "/etc/firewalld/firewalld.conf"
	sudo systemctl restart firewalld

	#Install xterm
	sudo dnf install -y xterm

	#Instal gvim
	#sudo dnf install -y vim-X11

	#install Goland
	#sudo snap install goland --classic
	
	#install Lens
	sudo snap install kontena-lens --classic
	
	# install oc CLI tool
	# https://access.redhat.com/downloads/content/290/ver=4.7/rhel---8/4.7.1/x86_64/product-software
	# need latest version to be able to rin oc adm must-gather

	#install wireshark
	sudo dnf install -y wireshark
	sudo usermod -a -G wireshark $USER

	#install awscli
	sudo dnf install -y awscli
	
	#install gcloud cli
	#sudo snap install google-cloud-sdk --classic
	
	#install Protobuf
	sudo snap install protobuf --classic

	# clone upstream repo
	cd $GOPATH/src
	if [[ -z "$mygitid" ]]; then
	    git clone https://github.com/ovn-org/ovn-kubernetes.git
	else 		
	    git clone https://github.com/$mygitid/ovn-kubernetes.git
	fi

	#clone k8s
	cd $GOPATH/src
	mkdir k8s.io; cd k8s.io
	git clone https://github.com/kubernetes/kubernetes.git
	#build e2e test binary
	pushd $GOPATH/src/k8s.io/kubernetes
	make WHAT="test/e2e/e2e.test vendor/github.com/onsi/ginkgo/ginkgo"
	popd

        echo "alias kc=kubectl" >> ${HOME}/.bashrc
	echo "export GOPATH=$HOME/go" >> ${HOME}/.bashrc
	echo "export PATH=$PATH:$GOPATH/bin" >> ${HOME}/.bashrc
	echo "export PATH=$PATH:/usr/local/go/bin" >> ${HOME}/.bashrc
	echo "export PATH=$PATH:$HOME/bin" >> ${HOME}/.bashrc
        echo "export KUBECONFIG=${HOME}/admin.conf" >> ${HOME}/.bashrc

	#Reboot
	sudo reboot
}

while getopts g: flag
do
    case "${flag}" in
        g) mygitid=${OPTARG};;
        *) echo "Invalid arg";;
    esac
done

export mygitid=srampal

echo "Git userID: $mygitid";

sudo usermod -g wheel $USER

setup_fedora_vm

