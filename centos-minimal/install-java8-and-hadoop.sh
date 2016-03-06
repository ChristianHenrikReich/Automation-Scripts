#!/bin/bash
# Script for handling installing of wget (id needed)
# Installs Java 8 and Hadoop mercyless. But it is exptected to
# run on a clean minimal CentOS 7 installation

echo -e "\e[32mChecking for wget\e[39m"

if [ ! -f /usr/bin/wget ]; then
	yum -y install wget
else
	echo -e "\e[32mFound, no action taken\e[39m"
fi

echo -e "\e[32mFetching Java 8 from Oracle\e[39m"
#wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-linux-x64.rpm"

echo -e "\e[32mInstalling Java 8\e[39m"
sudo rpm -ivh jdk-8u74-linux-x64.rpm

echo -e "\e[32mWriting the Java env to /etc/profile.d/java-env.sh\e[39m"

if [ -f /etc/profile.d/java-env.sh ]; then
        rm /etc/profile.d/java-env.sh
fi

echo "#!/bin/bash
export JAVA_HOME=\"/usr/java/jdk1.8.0_74/bin/java\"
export JRE_HOME=\"/usr/java/jdk1.8.0_74/jre/bin/java\"
PATH=\$PATH:\$HOME/bin:JAVA_HOME:JRE_HOME
" >> /etc/profile.d/java-env.sh
chmod 777 /etc/profile.d/java-env.sh

echo -e "\e[32mSetting up Hadoop user credentials\e[39m"
#useradd hadoop
#passwd hadoop

echo -e "\e[32mCreating SSH keys for hadoop user\e[39m"
##su - hadoop
##ssh-keygen -t rsa
##cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
##chmod 0600 ~/.ssh/authorized_keys
##exit

#sudo -u hadoop -H sh -c "cd ~;ssh-keygen -t rsa;cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys;chmod 0600 ~/.ssh/authorized_keys"

echo -e "\e[32mFetching Hadoop-2.7.2\e[39m"
cd /home/hadoop
#wget http://apache.claz.org/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz
echo -e "\e[32mUnpacking\e[39m"
tar xzf hadoop-2.7.2.tar.gz
echo -e "\e[32mCreating sym link\e[39m"
ln -s hadoop-2.7.2 hadoop

echo -e "\e[32mWriting the Java env to /etc/profile.d/hadoop-env.sh\e[39m"

if [ -f /etc/profile.d/hadoop-env.sh ]; then
        rm /etc/profile.d/hadoop-env.sh
fi

echo "#!/bin/bash
export HADOOP_HOME=/home/hadoop/hadoop
export HADOOP_INSTALL=\$HADOOP_HOME
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export PATH=\$PATH:$HADOOP_HOME/sbin:\$HADOOP_HOME/bin
" >> /etc/profile.d/hadoop-env.sh
chmod 777 /etc/profile.d/hadoop-env.sh




