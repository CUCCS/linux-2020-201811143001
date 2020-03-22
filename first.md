第一次作业

要求：

- 定制一个普通用户名和默认密码
- 定制安装OpenSSH Server
- 安装过程禁止自动联网更新软件包

问题：

- 如何配置无人值守安装iso并在Virtualbox中完成自动化安装？
- Virtualbox安装完Ubuntu之后新添加的网卡如何实现系统开机自动启用和自动获取IP？
- 如何使用sftp在虚拟机和宿主机之间传输文件？

安装环境：
- Virtualbox
- Ubuntu 18.04.4Server amd64.iso 
- psftp(putty自带)
- 录屏工具
-putty(Putty 自带)

在主虚拟机手动安装Ubuntu-18.04-server-amd64.iso磁盘

# 添加双网卡

![双网卡](/新文件/双网卡.png)

添加Host-only网卡后
输入ifconfig发现host-only网卡并未启动，使用命令
sudo ifconfig enp0s8 up
sudo dhclient enp0s8
手动启动

重新输入命令查看网卡IP

![新网卡](/新文件/新网卡.png)

获取ip：
Host-only:192.168.56.102

# 下载putty

![putty](/新文件/putty.png)

(putty的界面↑)

pytty连接虚拟机，个人理解是换了一个交互界面登录虚拟机里的用户，ssh的方式操作更方便

![登录](/新文件/登录.png)

在左上角可以显示我的用户名@主机名和当前路径

(之前遇到的小问题：
Putty下载时候最开始下错了,下成了只有putty.exe插件的，后来改下了对的版本)

# 把用于ubuntu18.04.4镜像文件用psftp从Windows传进虚拟机

![psftp](/新文件/psftp.png)

# 挂载ubuntu镜像：

- 在当前用户目录下创建一个用于挂载iso镜像文件的目录
mkdir loopdir

- 挂载iso镜像文件到该目录
Sudo mount -o loop ubuntu-18.04.4-server-amd64.iso loopdir

- 创建一个工作目录用于克隆光盘内容
mkdir cd

- 同步光盘内容到目标工作目录
rsync -av loopdir/ cd

- 卸载iso镜像
Sudo umount loopdir

- 进入目标工作目录
cd cd/

# # 编辑Ubuntu安装引导界面增加一个新菜单项入口

vim isolinux/txt.cfg

添加以下内容到该文件后强制保存退出

label autoinstall
  menu label ^Auto Install Ubuntu Server
  kernel /install/vmlinuz
  append  file=/cdrom/preseed/ubuntu-server-autoinstall.seed debian-installer/locale=en_US console-setup/layoutcode=us keyboard-configuration/layoutcode=us console-setup/ask_detect=false localechooser/translation/warn-light=true localechooser/translation/warn-severe=true initrd=/install/initrd.gz root=/dev/ram rw quiet

# 添加preseed文件
提前阅读并编辑定制Ubuntu官方提供的示例preseed.cfg，并将该文件保存到刚才创建的工作目录/home/cuc/cd/preseed/ubuntu-server-autoinstall.seed

![seed](/新文件/seed.png)

最后一个就是了↑

![seed2](/新文件/seed2.png)

seed文件编辑(部分改动)后↑

(遇到的问题：修改后的seed文件时，psftp无法直接传到preseed目录，需要先传到/home/yanglan/,再通过mv命令传到/home/yanglan/cd/presee下面)

# 修改isolinux.cfg：

将timeout 300 改为timeout 10。(可选)

# 重新生成MD5校验和：
![md5sum](/新文件/md5sum.png)

重新生成custom.iso：

IMAGE=custom.iso
BUILD=cd/
sudo mkisofs -r -V "Custom Ubuntu Install CD" \
-cache-inodes \
-J -l -b isolinux/isolinux.bin \
-c isolinux/boot.cat -no-emul-boot \
-boot-load-size 4 -boot-info-table \
-o $IMAGE $BUILD

(遇到的问题：命令确实如预料中一样出现错误了，照着csdn上的提示先
apt-get update
然后
apt-get install genisoimage)

# 移动custom.iso
虚拟机（/home/yanglan/cd/）这个目录会出现custom.iso这个镜像，使用命令
mv custom.iso ../把它移动到/home/yanglan

然后打开psftp窗口
get custom.iso

![custom.iso](/新文件/custom.png)

(磁盘custom.iso就传送到电脑中Putty文件夹中了)

# 录屏
<https://weibo.com/tv/v/IzGtCxJyJ?fid=1034:4485047168729091?\>

(用微博上传的，bili审核不过，里面不小心把轰猫的声音录进去了orz)

# 参考资料
<https://www.optbbs.com/thread-5938685-1-1.html>

<https://github.com/CUCCS/linux-2019-Wzy-CC/pull/1/commits/84f0cfd7dc9e78c0e0497a3adfa15eec3d190733#diff-0c30bf8f4d14e914df352d58a860aa46>

<https://github.com/CUCCS/linux-2019-cloud0606/blob/lab1/lab1/%E5%AE%9E%E9%AA%8C%E6%8A%A5%E5%91%8A.md>

<https://m.baidu.com/sf_baijiahao/s?id=1627579189827205640&wfr=spider&for=pc>
<https://jingyan.baidu.com/article/3c48dd34d379dde10ae35854.html>

# 对比老师提供的seed文件和官方示例

差异：使用vimdiff工具可以通过高亮部分查看到两个文件的差异

具体差异：
1.11行，改变额外可选的地区和语言，随后增加一行，跳过安装时选择语言

2.40行到44行：减少linkwait、dhcp等网络配置的等待时间

3.49行，禁止网络自动配置

4.60行到64行，配置网络

5.76行设置系统的主机名

6.77行修改域名，dhcp分配到的主机名和域名的优先级将会高于此处

7.82行强制设置主机名，无视dhcp所分配的主机名

8.140行和141行设置用户全名和用户名

9.143行144行设置密码

10.151行d-i netcfg/hostname string 
isc-vm-host,允许弱密码，避免中间过程没有实现自动化

11.166行设置时区，169行，安装期间禁止通过NTP server设置时间

12.178行，如果系统有空间，可以仅对该空间做分区

13.205行，lvm分区是，逻辑卷的大小为最大

14.213行，multi预定义分区策略，分为/home,/var,/tmp分区

15.335行，禁止使用网络镜像

16.363行，改为server安装包

17.368行，选择预安装的软件为openssh-server

18.371行，禁止软件自动升级

19.379行，自动安全更新软件
