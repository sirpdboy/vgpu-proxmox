#!/bin/sh
# Date: 2023/08/02
#
# Install NVIDIA Linux vGPU Driver 525.85.07
echo ""
echo "********************************************"
echo "*** Install NVIDIA vGPU Driver 525.85.07 ***"
echo "********************************************"
cd ~
echo "    Downloading NVIDIA driver "
wget http://www1.deskpool.com:9000/software/NVIDIA-Linux-x86_64-525.85.07-vgpu-kvm.run
chmod +x ./NVIDIA-Linux-x86_64-525.85.07-vgpu-kvm.run
./NVIDIA-Linux-x86_64-525.85.07-vgpu-kvm.run --apply-patch ~/vgpu-proxmox/525.85.07.patch
echo ""
echo "    Extracting driver .... "
chmod +x ./NVIDIA-Linux-x86_64-525.85.07-vgpu-kvm-custom.run
./NVIDIA-Linux-x86_64-525.85.07-vgpu-kvm-custom.run -x
cd NVIDIA-Linux-x86_64-525.85.07-vgpu-kvm-custom/

echo ""
echo "    Patching NVIDIA driver "
sed -i 's|.open             = nv_vgpu_vfio_open|.open_device = nv_vgpu_vfio_open|g'    kernel/nvidia-vgpu-vfio/nvidia-vgpu-vfio.c
sed -i 's|.release          = nv_vgpu_vfio_close|.close_device = nv_vgpu_vfio_close|g'    kernel/nvidia-vgpu-vfio/nvidia-vgpu-vfio.c

echo ""
echo "    Installing driver .... "
chmod +x nvidia-installer
./nvidia-installer -dkms

echo ""
echo "    deamon-reload && rebooting ...."
systemctl daemon-reload
reboot

