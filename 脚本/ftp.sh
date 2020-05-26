#!/bin/bash

source ./environ.sh


apt update 
if [[ $? -ne 0 ]]; then
	echo "apt update failed!"
	exit
fi


if [ ! -f /etc/vsftpd.conf.bak ];then 
	cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
else apt install -y vsftpd || echo "Installation failed" && exit
fi


sed -i -e '/anonymous_enable=/s/NO/YES/g;/anonymous_enable=/s/#//g' /etc/vsftpd.conf
sed -i -e '/local_enable=/s/NO/YES/g;/local_enable=/s/#//g' /etc/vsftpd.conf
sed -i -e '/write_enable=/s/NO/YES/g;/write_enable=/s/#//g' /etc/vsftpd.conf
sed -i -e '/chroot_local_user=/s/NO/YES/g;/chroot_local_user=/s/#//g' /etc/vsftpd.conf
sed -i -e '/anon_upload_enable=/s/YES/NO/g;/anon_upload_enable=/s/#//g' /etc/vsftpd.conf
sed -i -e '/anon_mkdir_write_enable=/s/YES/NO/g' /etc/vsftpd.conf
sed -i -e '/xferlog_file=/s/#//g' /etc/vsftpd.conf

## prepare anonymous directory 
mkdir -p "$ANONY_DIR"
chown nobody:nogroup "$ANONY_DIR"
echo "vsftpd test file for anonymous user" | tee "${ANONY_DIR}/test_a.txt"


## prepare directory for known user 

#if [[ $(id -u $user) -eq 1 ]]; then 
if [[ $(grep -c "^$user:" /etc/passwd) -eq 0 ]];then
	useradd "$user"
	echo "$user:sammy" | chpasswd
else echo "User $user already exists~"
fi

if [[ ! -d "$USER_DIR" ]];then mkdir "$USER_DIR" ;fi
chown nobody:nogroup "$USER_DIR"
chmod a-w "$USER_DIR"

WRITEABLE_DIR="${USER_DIR}/files"
mkdir -p "$WRITEABLE_DIR"
chown $user:$user "$WRITEABLE_DIR"
echo "vsftpd test file for the login user" | tee "${WRITEABLE_DIR}/test_u.txt"


echo sammy > /etc/vsftpd.userlist
echo anonymous >> /etc/vsftpd.userlist


if [[ -z $(cat /etc/vsftpd.conf | grep "userlist_file=/etc/vsftpd.userlist") ]];then
cat<<EOT >>/etc/vsftpd.conf

local_root=/home/%LOCAL_ROOT%/ftp
userlist_file=/etc/vsftpd.userlist
userlist_enable=YES
userlist_deny=NO

anon_root=/var/ftp/
no_anon_password=YES
hide_ids=YES
pasv_min_port=40000
pasv_max_port=50000

tcp_wrappers=YES
EOT
fi

sed -i -e "s#%LOCAL_ROOT%#/home/$user/ftp#g" /etc/vsftpd.conf

grep -q "vsftpd: ALL"  /etc/hosts.deny || echo "vsftpd: ALL" >> /etc/hosts.deny
grep -q "vsftpd:127.0.0.1"  /etc/hosts.deny || echo "vsftpd:127.0.0.1" >> /etc/hosts.allow

service vsftpd restart
