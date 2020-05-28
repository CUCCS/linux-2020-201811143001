#!/bin/bash

source ./environ.sh
apt-get install -y samba

# useradd -M -s /sbin/nologin "$smbuser"
useradd -M -s $(which nologin) "$smbuser"
echo "$smbuser:password" | chpasswd
# sed -i.bak 's#^\(smbuser:\)[^:]*\(:.*\)$#\$6$0Nf0oKzZw7$LWRXlj45pDhV/KHEISQhmOLr8hux2tB1DmzPvee0UrbvaOsjbcf3pBAd4RNdzJqdMnsmvC2/FCf7hECsDLhwU/#' /etc/shadow
(echo password; echo password) | smbpasswd -a "$smbuser"

cat<<EOT >>/etc/samba/smb.conf
[guest]
path = /home/samba/guest/
read only = yes
guest ok = yes

[demo]
path = /home/samba/demo/
read only = no
guest ok = no
force create mode = 0660
force directory mode = 2770
force user = "$smbuser"
force group = "$smbgroup"
EOT

smbpasswd -e "$smbuser"
groupadd "$smbgroup"
usermod -G "$smbgroup" "$smbuser"
mkdir -p /home/samba/guest/
mkdir -p /home/samba/demo/
chgrp -R "$smbgroup" /home/samba/guest/
chgrp -R "$smbgroup" /home/samba/demo/
chmod 2775 /home/samba/guest/
chmod 2770 /home/samba/demo/

service smbd restart
