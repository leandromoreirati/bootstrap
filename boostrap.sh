#!/bin/bash
# -------------------------
ZSH_FILE="/home/lmoreira/.zshrc"
ASDF_PLUGIN_LIST_FILE="$PWD/list_plugin.txt"
TOOL_VERSION_FILE="/home/lmoreira/.tool-versions"
TOOL_VERSION_FILE_TEMP="/tmp/.tool-versions"
DOCKER_VERSION="5:19.03.15~3-0~debian-buster"
MICROSOFT_GPG_KEY=`sudo ls -l /usr/share/keyrings/microsoft-archive-keyring.gpg | awk '{print $9}'`
DOCKER_GPG_KEY=`sudo ls -l /usr/share/keyrings/docker-archive-keyring.gpg | awk '{print $9}'`
ASDF_INSTALL_DIR=`ls -la /home/lmoreira/| grep ".asdf"| awk '{print $9}'`
OH_MY_ZSH_INSTALL_DIR=`find /home/lmoreira/ -type d -iname ".oh-my-zsh"`
VIRTUALIZATION_EXTENSION_ENABLE=`egrep -c '(vmx|svm)' /proc/cpuinfo`
GOOGLE_CHROME=`sudo dpkg -l | grep chrome | awk '{print $2}'`

set -o pipefail

PACKET_LIST="apt-transport-https \
                              ca-certificates \
                              vim \
                              wget \
                              gnupg2 \
                              jq \
                              lsb-release"

echo "# -------------- INSTALL PRE-REEQUISITE -------------- #"
$(which sudo) $(which apt-get) install -y $PACKET_LIST

echo "# -------------- GENERAL -------------- #"
cd ~
echo "set mouse=r" >> ~/.vimrc

echo "# -------------- INSTALL OH MY ZSH -------------- #"
if [ -z $OH_MY_ZSH_INSTALL_DIR ] ; then

  $(which git) clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 
  $(which git) clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 
fi

echo "# -------------- INSTALL ASDF -------------- #"
if [ -d "$ASDF_INSTALL_DIR" ] ; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    echo " " >> $ZSH_FILE
    echo "# add to your Shell" >> $ZSH_FILE
    echo ". $HOME/.asdf/asdf.sh" >> $ZSH_FILE
    echo " " >> $ZSH_FILE
    echo "# append completions to fpath" >> $ZSH_FILE
    echo "fpath=(\${ASDF_DIR}/completions \$fpath)" >> $ZSH_FILE
    echo " " >> $ZSH_FILE
    echo "# initialise completions with ZSH's compinit" >> $ZSH_FILE
    echo "autoload -Uz compinit" >> $ZSH_FILE
    echo "compinit" >> $ZSH_FILE

    ASDF_ADD_ON="git terraform docker docker-compose asdf zsh-syntax-highlighting zsh-autosuggestions"

    $(which sed) -i 's/plugins=(git)/plugins=('"${ASDF_ADD_ON}"')/g' $ZSH_FILE
fi

echo "# -------------- INSTALL ASDF PLUGINS -------------- #"
$(which rm) $TOOL_VERSION_FILE
$(which touch) $TOOL_VERSION_FILE

for list in ` $(which cat) $ASDF_PLUGIN_LIST_FILE | awk '{ print $1"  "$2"  "$3 }'`; do
  PLUGIN=`echo $list | awk -F "|" '{ print $1}' `
  PLUGIN_URL=`echo $list | awk -F  "|" '{ print $2} '`
  PLUGIN_VERSION=`echo $list | awk -F  "|" '{ print $3} '`

    if [ ! -z `asdf list $PLUGIN` ] ; then

      echo "Plugin $PLUGIN installed!"

    else

        if [ $PLUGIN != "python" ] || [ ! -z $PLUGIN_VERSION ]; then
           VERSION=${PLUGIN_VERSION:-"latest"}

          echo $PLUGIN $VERSION

          asdf plugin-add $PLUGIN $PLUGIN_URL

          asdf install $PLUGIN $VERSION

        else
        version=${PLUGIN_VERSION:-"latest"}
        echo $PLUGIN $VERSION
            echo $PLUGIN
               $(which sudo) $(which apt-get) update
               $(which sudo) $(which apt-get) install -y --no-install-recommends \
                                                                 make build-essential libssl-dev \
                                                                 zlib1g-dev libbz2-dev libreadline-dev \
                                                                 libsqlite3-dev wget curl llvm \
                                                                 libncurses5-dev xz-utils tk-dev \
                                                                 libxml2-dev libxmlsec1-dev \
                                                                 libffi-dev liblzma-dev
                 asdf plugin-add $PLUGIN $PLUGIN_URL
                 asdf install $PLUGIN $PLUGIN_VERSION
                
        fi
    fi
    ASDF_PLUGINS_VERSION=`asdf list $PLUGIN`
    echo $PLUGIN $ASDF_PLUGINS_VERSION | $(which tee) -a $TOOL_VERSION_FILE

done

echo "# -------------- K8S AUTPCOMPLETE ------------- #"
echo 'source <(kubectl completion zsh)' >> $ZSH_FILE

echo "# -------------- SORTING TOOL VERSION --------- #"
$(which cat) $TOOL_VERSION_FILE | $(which sort) > $TOOL_VERSION_FILE_TEMP

$(which cat) $TOOL_VERSION_FILE_TEMP > $TOOL_VERSION_FILE

echo "# -------------- GIT CONFIG ------------------- #"
echo "GIT_EDITOR=\"vim\"" >> $ZSH_FILE
echo "GITHUB_PAT=\"\"" >> $ZSH_FILE

echo "# -------------- INSTALL DOCKER --------------- #"
if [ -z $DOCKER_GPG_KEY ] ; then
$(which curl) -fsSL https://download.docker.com/linux/debian/gpg | $(which sudo) gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    if [  ! -z $DOCKER_VERSION ]; then
       DOCKER_VERSION=${DOCKER_VERSION:-5:19.03.15~3-0~debian-buster}

          $(which sudo) $(which apt-get) update

          $(which sudo) $(which apt-get) install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io
    else
           $(which sudo) $(which apt-get) install -y docker-ce docker-ce-cli containerd.io

    fi

$(which sudo) usermod -aG docker $USER

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

$(which sudo) $(which systemctl) enable docker
$(which sudo) $(which systemctl) daemon-reload
$(which sudo) $(which systemctl) restart docker

fi

echo "# -------------- INSTALL VSCODE ------------- #"
if [  -z $MICROSOFT_GPG_KEY ]; then

    $(which curl) https://packages.microsoft.com/keys/microsoft.asc | $(which sudo) $(which gpg) --dearmor > /tmp/microsoft.gpg
    $(which sudo) $(which install) -o root -g root -m 644 /tmp/microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
    $(which sudo) sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg]     https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    $(which sudo) $(which apt-get) update
    $(which sudo) $(which apt-get) install -y code
fi

set -x
echo "# -------------- INSTALL GOOGLE CHROME ------------- #"
if [ -z $GOOGLE_CHROME ]; then

$(which wget) https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb

$(which sudo) $(which apt) install -y /tmp/google-chrome-stable_current_amd64.deb
fi

echo "# -------------- INSTALL KVM ------------- #"
if [  $VIRTUALIZATION_EXTENSION_ENABLE  != 0 ]; then 
    $(which sudo) $(which apt-get) install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager 
    
    $(which sudo) $(which virsh) net-start default

    $(which sudo) $(which virsh) net-autostart default

    $(which sudo) modprobe vhost_net

    $(which echo) "vhost_net" | sudo  tee -a /etc/modules

    $(which lsmod) | grep vhost

    $(which sudo) $(which gpasswd) -a $1 libvirt

    $(which sudo) $(which gpasswd) -a  $1 libvirt-qemu

    $(which sudo) $(which newgrp) libvirt

   $(which sudo) $(which newgrp) libvirt-qemu

else

  echo "Virtualization support disable, verify your computer bios!"

fi

echo "$1"