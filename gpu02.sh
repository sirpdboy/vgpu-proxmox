#!/bin/sh
# Date: 2023/08/02
#
# Enable IO-MMU on PVE Server

cd ~
# 复制如下脚本，启用IO-MMU
echo ""
echo "********************************************"
echo "***  Enable IO-MMU on proxmox host       ***"
echo "********************************************"
# /etc/default/grub 的GRUB_CMDLINE_LINUX_DEFAULT，增加 intel_iommu=on iommu=pt
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"/g' /etc/default/grub

echo ""
echo "    Update grub .... "
update-grub

# 加载 vfio vfio_iommu_type1 vfio_pci vfio_virqfd 4个Modules
echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd"  > /etc/modules

echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1 report_ignored_msrs=0" > /etc/modprobe.d/kvm.conf
echo "blacklist nouveau" >>/etc/modprobe.d/disable-nouveau.conf
echo "options nouveau modeset=0" >>/etc/modprobe.d/disable-nouveau.conf

update-initramfs -u -k all
echo ""
echo "    Proxmox set vgpu_unlock host reboot ............."

mkdir /etc/vgpu_unlock
cp -r ~/vgpu-proxmox/profile_override.toml /etc/vgpu_unlock/profile_override.toml
mkdir /etc/systemd/system/{nvidia-vgpud.service.d,nvidia-vgpu-mgr.service.d}
echo -e "[Service]\nEnvironment=LD_PRELOAD=/opt/vgpu_unlock-rs/target/release/libvgpu_unlock_rs.so" > /etc/systemd/system/nvidia-vgpud.service.d/vgpu_unlock.conf
echo -e "[Service]\nEnvironment=LD_PRELOAD=/opt/vgpu_unlock-rs/target/release/libvgpu_unlock_rs.so" > /etc/systemd/system/nvidia-vgpu-mgr.service.d/vgpu_unlock.conf

reboot

