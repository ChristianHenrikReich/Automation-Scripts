#!/bin/bash
# Script for handling installing of wget (id needed)
# Installs Java 8 and Hadoop mercyless. But it is exptected to
# run on a clean minimal CentOS 7 installation

MACFORTHISNODE="$(cat /sys/class/net/eth0/address)"

echo -e "\e[32mAssuming ${MACFORTHISNODE} is MAC for this node\e[39m" 

read -p "Enter IP for this name node: " ip_for_this_node
read -p "Enter Gateway for this name node: " gateway_for_this_node
read -p "Enter Netmask for this name node: " netmask_for_this_node

read -p "Start installation? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Nn]$ ]]
then
    exit 1
fi


echo -e "\e[32mChecking for wget\e[39m"

if [ ! -f /usr/bin/wget ]; then
	yum -y install wget
else
	echo -e "\e[32mFound, no action taken\e[39m"
fi

echo -e "\e[32mFetching Java 8 from Oracle\e[39m"
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-linux-x64.rpm"

echo -e "\e[32mInstalling Java 8\e[39m"
sudo rpm -ivh jdk-8u74-linux-x64.rpm

echo -e "\e[32mWriting the Java env to /etc/profile.d/java-env.sh\e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/profile.d/java-env.sh -O /etc/profile.d/java-env.sh
chmod 644 /etc/profile.d/java-env.sh

echo -e "\e[32mSetting up Hadoop user credentials\e[39m"
useradd hadoop

echo -e "\e[32mCreating SSH keys for hadoop user\e[39m"

sudo -u hadoop -H sh -c "cd ~;echo -e 'y\n'|ssh-keygen -t rsa -P \"\" -f ~/.ssh/id_rsa;cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys;chmod 0600 ~/.ssh/authorized_keys"

echo -e "\e[32mFetching Hadoop-2.7.2\e[39m"
cd /home/hadoop
wget http://apache.claz.org/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz
echo -e "\e[32mUnpacking\e[39m"
tar xzf hadoop-2.7.2.tar.gz
echo -e "\e[32mCreating sym link\e[39m"
ln -s hadoop-2.7.2 hadoop
chown hadoop -R /home/hadoop

echo -e "\e[32mWriting the Hadoop env to /etc/profile.d/hadoop-env.sh\e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/profile.d/hadoop-env.sh -O /etc/profile.d/hadoop-env.sh
chmod 644 /etc/profile.d/hadoop-env.sh

echo -e "\e[32mUpdating core-site.xml\e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/hadoop/name-node/core-site.xml -O /home/hadoop/hadoop/etc/hadoop/core-site.xml

echo -e "\e[32mUpdating hdfs-site.xml\e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/hadoop/name-node/hdfs-site.xml -O /home/hadoop/hadoop/etc/hadoop/hdfs-site.xml

echo -e "\e[32mUpdating mapred-site.xml\e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/hadoop/name-node/mapred-site.xml -O /home/hadoop/hadoop/etc/hadoop/mapred-site.xml

echo -e "\e[32mUpdating yarn-site.xml \e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/hadoop/name-node/yarn-site.xml -O /home/hadoop/hadoop/etc/hadoop/yarn-site.xml 

echo -e "\e[32mUpdating start-dsf \e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/hadoop/sbin/start-dfs.sh -O /home/hadoop/hadoop/sbin/start-dfs.sh

echo -e "\e[32mUpdating start-yarn \e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/hadoop/sbin/start-yarn.sh -O /home/hadoop/hadoop/sbin/start-yarn.sh

echo -e "\e[32m/etc/sysconfig/network-scripts/ifcfg-eth0 \e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/sysconfig/ifcfg-eth0 -O /etc/sysconfig/network-scripts/ifcfg-eth0

echo -e "\e[32mUpdating IPs\e[39m"
sed -i -e "s/%%NameNodeIp%%/$ip_for_this_node/g" /home/hadoop/hadoop/etc/hadoop/hdfs-site.xml
sed -i -e "s/%%NameNodeIp%%/$ip_for_this_node/g" /home/hadoop/hadoop/etc/hadoop/core-site.xml
sed -i -e "s/%%NameNodeIp%%/$ip_for_this_node/g" /home/hadoop/hadoop/etc/hadoop/yarn-site.xml

sed -i -e "s/%%IpForThisNode%%/$ip_for_this_node/g" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i -e "s/%%GatewayForThisNode%%/$gateway_for_this_node/g" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i -e "s/%%NetmaskForThisNode%%/$netmask_for_this_node/g" /etc/sysconfig/network-scripts/ifcfg-eth0


. /etc/profile.d/java-env.sh
. /etc/profile.d/hadoop-env.sh

echo -e "\e[32mFormatting namenode \e[39m"
hdfs namenode -format

echo -e "\e[32mOpening TCP port 8088, 50070, 50075, 50090, 50105, 50030, 50060 in firewall and reloads\e[39m"
firewall-cmd --zone=public --add-port=8088/tcp --permanent
firewall-cmd --zone=public --add-port=8020/tcp --permanent
firewall-cmd --zone=public --add-port=8025/tcp --permanent
firewall-cmd --zone=public --add-port=8030/tcp --permanent
firewall-cmd --zone=public --add-port=8050/tcp --permanent
firewall-cmd --zone=public --add-port=50070/tcp --permanent
firewall-cmd --zone=public --add-port=50075/tcp --permanent
firewall-cmd --zone=public --add-port=50090/tcp --permanent
firewall-cmd --zone=public --add-port=50105/tcp --permanent
firewall-cmd --zone=public --add-port=50030/tcp --permanent
firewall-cmd --zone=public --add-port=50060/tcp --permanent
firewall-cmd --reload

echo -e "\e[32mInitial start \e[39m"
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\e[32mFecthing and installing start scripts \e[39m"
wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/init.d/hadoop-dsf -O /etc/init.d/hadoop-dsf
chmod 755 /etc/init.d/hadoop-dsf

wget https://raw.githubusercontent.com/ChristianHenrikReich/automation-scripts/master/centos-minimal/etc/init.d/hadoop-yarn -O /etc/init.d/hadoop-yarn
chmod 755 /etc/init.d/hadoop-yarn

cd /etc/init.d/
chkconfig hadoop-dsf --add
chkconfig hadoop-yarn --add
chkconfig hadoop-dsf on
chkconfig hadoop-yarn on

echo -e "\e[32mDone, please reboot to get the full effect.\e[39m"




