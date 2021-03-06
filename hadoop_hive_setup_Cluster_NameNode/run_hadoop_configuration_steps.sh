
#####################################################################
   Steps to Get an Hadoop 2.4 Cluster with one node Up and Running
#####################################################################

#1. Installing Java v1.8:

sudo add-apt-repository ppa:webupd8team/java 
sudo apt-get update 
sudo apt-get install oracle-java8-installer

#1.a ) Edit Profile Path.
#vi /etc/profile

echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle/" >> /etc/profile
echo "PATH=$PATH:$HOME/bin:$JAVA_HOME/bin" >> /etc/profile
echo "export JAVA_HOME" >> /etc/profile
echo "export PATH" >> /etc/profile

. /etc/profile
java -version

# Confirm it as current upt to data JAva 8 release.
 

#2. Adding dedicated Hadoop system user, like hduser.

sudo addgroup --force-badname Hadoop
sudo adduser --ingroup Hadoop hduser

#3. Configuring SSH access:

su - hduser

ssh-keygen -t rsa -P ""
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

#4. Disabling IPv6.

#sudo gedit /etc/sysctl.conf
#disable ipv6
#net.ipv6.conf.all.disable_ipv6 = 1
#net.ipv6.conf.default.disable_ipv6 = 1
#net.ipv6.conf.lo.disable_ipv6 = 1



#5. Hadoop Installation:
cd /usr/local
mkdir hadoop
cd hadoop
wget http://apache.mirrors.pair.com/hadoop/common/stable2/hadoop-2.4.1.tar.gz
tar xvzf hadoop-2.4.1.tar.gz
mv hadoop-2.4.1 hadoop
cd /usr/local
sudo chown -R hduser hadoop

#6. Configuring Hadoop

# 6.a. yarn-site.xml:
# 6.b. core-site.xml
# 6.c. mapred-site.xml
# 6.d. hdfs-site.xml
# 6.e. Update $HOME/.bashrc

cd /usr/local/hadoop/hadoop-2.4.1/etc/hadoop

#jpac@ubuntu:/usr/local/hadoop/hadoop-2.4.1/etc/hadoop$ ls
#capacity-scheduler.xml      httpfs-site.xml
#configuration.xsl           log4j.properties
#container-executor.cfg      mapred-env.cmd
#core-site.xml               mapred-env.sh
#hadoop-env.cmd              mapred-queues.xml.template
#hadoop-env.sh               mapred-site.xml.template
#hadoop-metrics2.properties  slaves
#hadoop-metrics.properties   ssl-client.xml.example
#hadoop-policy.xml           ssl-server.xml.example
#hdfs-site.xml               yarn-env.cmd
#httpfs-env.sh               yarn-env.sh
#httpfs-log4j.properties     yarn-site.xml
#httpfs-signature.secret
#jpac@ubuntu:/usr/local/hadoop/hadoop-2.4.1/etc/hadoop$

vi yarn-site.xml
#<configuration>
#<!-- Site specific YARN configuration properties -->
#<property>
#<name>yarn.nodemanager.aux-services</name>
#<value>mapreduce_shuffle</value>
#</property>
#<property>
#<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
#<value>org.apache.hadoop.mapred.ShuffleHandler</value>
#</property>
#</configuration>


#vi core-site.xml
#<configuration>
#<property>
#<name>fs.default.name</name>
#<value>hdfs://localhost:9000</value>
#</property>
#</configuration>


cp mapred-site.xml.template mapred-site.xml
#vi mapred-site.xml
########### ADD NEXT LINES 
#<configuration>
#<property>
#<name>mapreduce.framework.name</name>
#<value>yarn</value>
#</property>
#</configuration>

#vi hdfs-site.xml
########### ADD NEXT LINES
#<configuration>
#<property>
#<name>dfs.replication</name>
#<value>1</value>
#</property>
#<property>
#<name>dfs.namenode.name.dir</name>
#<value>file:/usr/local/hadoop/hadoop-2.4.1/yarn_data/hdfs/namenode</value>
#</property>
#<property>
#<name>dfs.datanode.data.dir</name>
#<value>file:/usr/local/hadoop/hadoop-2.4.1/yarn_data/hdfs/datanode</value>
#</property>
#</configuration>


vi .bashrc
# Set Hadoop-related environment variables
echo "export HADOOP_PREFIX=/usr/local/hadoop" >> ~/.bashrc
echo "export HADOOP_HOME=/usr/local/hadoop" >> ~/.bashrc
echo "export HADOOP_MAPRED_HOME=${HADOOP_HOME}" >> ~/.bashrc
echo "export HADOOP_COMMON_HOME=${HADOOP_HOME}" >> ~/.bashrc
echo "export HADOOP_HDFS_HOME=${HADOOP_HOME}" >> ~/.bashrc
echo "export YARN_HOME=${HADOOP_HOME}" >> ~/.bashrc
echo "export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop" >> ~/.bashrc
# Native Path
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native" >> ~/.bashrc
echo "export HADOOP_OPTS=-Djava.library.path=$HADOOP_PREFIX/lib" >> ~/.bashrc
#Java path
echo "export JAVA_HOME='/usr/lib/jvm/java-8-oracle/'" >> ~/.bashrc
# Add Hadoop bin/ directory to PATH
echo "export PATH=$PATH:$HADOOP_HOME/bin:$JAVA_PATH/bin:$HADOOP_HOME/sbin" >> ~/.bashrc

#Formatting and Starting/Stopping the HDFS filesystem via the NameNode:

#makedirs

mkdir -p $HADOOP_HOME/yarn_data/hdfs/namenode
sudo mkdir -p $HADOOP_HOME/yarn_data/hdfs/namenode
mkdir -p $HADOOP_HOME/yarn_data/hdfs/datanode

#i. The first step to starting up your Hadoop installation is formatting the Hadoop filesystem
# which is implemented on top of the local filesystem of your cluster.
# You need to do this the first time you set up a Hadoop cluster.
# Do not format a running Hadoop filesystem as you will lose all the data currently in the cluster (in HDFS).
# To format the filesystem (which simply initializes the directory specified by the dfs.name.dir variable), run the
 
cd $HADOOP_HOME
hadoop namenode -format
hadoop datanode -format
#ii. Start Hadoop Daemons by running the following commands:

#Name node: $ 
hadoop-daemon.sh start namenode
#Data node: $ 
hadoop-daemon.sh start datanode
#Resource Manager: $ 
yarn-daemon.sh start resourcemanager 
#Node Manager: $ 
yarn-daemon.sh start nodemanager
#Job History Server: $ 
mr-jobhistory-daemon.sh start historyserver

#hduser@ubuntu:~$ 
jps
#2712 NameNode
#3240 JobHistoryServer
#3017 NodeManager
#2889 ResourceManager
#2794 DataNode
#3291 Jps
#hduser@ubuntu:~$

#hduser@ubuntu:/usr/local/hadoop/hadoop-2.4.1$

#v. Stop Hadoop by running the following command

#$ 
stop-dfs.sh
#$ 
stop-yarn.sh

#Hadoop Web Interfaces:Hadoop comes with several web interfaces which are by default  available at these locations:

#HDFS Namenode and check health using http://localhost:50070
#HDFS Secondary Namenode status using http://localhost:50090

#File System Check Utility

#$
hadoop fsck - /tmp
