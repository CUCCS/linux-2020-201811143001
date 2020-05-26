#!/bin/bash
source ./environ.sh

apt update 
if [[ $? -ne 0 ]]; then
        echo "apt update failed!"
        exit
fi


apt-get install -y nfs-common || echo "Installation NFS client side failed" # && exit

mkdir -p $nfs_general_clt
mkdir -p $nfs_home_clt

mount $nfs_srv:$nfs_general_srv $nfs_general_clt
mount $nfs_srv:$nfs_home_srv $nfs_home_clt
