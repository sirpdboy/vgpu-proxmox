#!/bin/sh
# Date: 2023/08/02
#
# Phase 1: update source to mirrors.ustc.edu.cn

cp /etc/apt/sources.list /etc/apt/sources.list.backup
sed -i 's|^deb http://ftp.debian.org|deb https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list
sed -i 's|^deb http://security.debian.org|deb https://mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list

mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak
CODENAME=`cat /etc/os-release |grep PRETTY_NAME |cut -f 2 -d "(" |cut -f 1 -d ")"`
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian $CODENAME pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list


apt-mark hold proxmox-ve   

apt update && apt dist-upgrade -y
apt install -y git build-essential dkms pve-headers mdevctl

cd ~
# git clone https://github.com/sirpdboy/vgpu-proxmox.git vgpu-proxmox
# chmod +x ~/vgpu-proxmox/*.sh

cd /opt
git clone https://github.com/sirpdboy/vgpu_unlock-rs.git
curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal
source $HOME/.cargo/env
cd vgpu_unlock-rs/
cargo build --release
cd ~