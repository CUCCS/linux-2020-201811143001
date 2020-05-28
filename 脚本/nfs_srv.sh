#!/bin/bash

source ./environ.sh

apt update 
if [[ $? -ne 0 ]]; then
        echo "apt update failed!"
        exit
fi


apt-get install -y nfs-kernel-server || echo "Installation NFS server side failed" 

mkdir $nfs_general_srv -p
chown nobody:nogroup $nfs_general_srv


touch /etc/exports
#sudo cat "$nfs_general_srv    $nfs_clt(rw,sync,no_subtree_check)" > /etc/exports
# read only
#sudo cat "$nfs_home_srv    $nfs_clt(r,sync,no_subtree_check)" >> /etc/exports

cat<<EOT >/etc/exports
$nfs_general_srv    $nfs_clt(rw,sync,no_subtree_check)
$nfs_home_srv    $nfs_clt(rw,sync,no_root_squash,no_subtree_check)
EOT

systemctl restart nfs-kernel-server