# Configure environment
export CONDA_DIR=/opt/conda
export PATH=$CONDA_DIR/bin:$PATH
export SHELL=/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Install dependencies
apt-get update
apt-get install -yq --no-install-recommends \
git \
vim \
wget \
build-essential \
python-dev \
ca-certificates \
bzip2 \
unzip \
libsm6 \
pandoc \
texlive-latex-base \
texlive-latex-extra \
texlive-fonts-extra \
texlive-fonts-recommended
apt-get clean

# Install conda
mkdir -p $CONDA_DIR
echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
/bin/bash Miniconda3-latest-Linux-x86_64.sh -f -b -p $CONDA_DIR
rm Miniconda3-latest-Linux-x86_64.sh
$CONDA_DIR/bin/conda install --yes conda==4.3.21

# Install Jupyter notebook
conda install --yes 'notebook=5.0*' terminado
conda clean -yt

#Create Jupyter working folders
mkdir /root/work
mkdir /root/.jupyter
mkdir /root/.local

# Spark dependencies
export APACHE_SPARK_VERSION=2.1.1
apt-get -y update
apt-get install -y --no-install-recommends openjdk-7-jre-headless
apt-get clean
echo 'Downloading Spark. Hold tight..'
wget -qO - http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz | tar -xz -C /usr/local/
cd /usr/local
ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7 spark

# Scala Spark kernel (build and cleanup)

#cd /tmp
#echo 'deb http://dl.bintray.com/sbt/debian /' > /etc/apt/sources.list.d/sbt.list
#apt-get update
#apt-get install -yq --force-yes --no-install-recommends sbt
##cd spark-kernel
#sbt compile -Xms1024M -Xmx2048M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=1024M
#sbt pack
##mv kernel/target/pack /opt/sparkkernel
##chmod +x /opt/sparkkernel
#rm -rf ~/.ivy2
#rm -rf ~/.sbt
##rm -rf /tmp/spark-kernel
#apt-get remove -y sbt

apt-get clean
# Spark env
export SPARK_HOME=/usr/local/spark
# TO BE CHECK ONCE INSTALLED
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip

# Install Python packages
conda install --yes 'ipython' 'ipywidgets' 'pandas' 'matplotlib' 'scipy' 'seaborn' 'scikit-learn' pyzmq
conda clean -yt

# Scala Spark and Pyspark kernels
mkdir -p /opt/conda/share/jupyter/kernels/scala
mkdir -p /opt/conda/share/jupyter/kernels/pyspark

cp /vagrant/kernels/scala.json /opt/conda/share/jupyter/kernels/scala/kernel.json
cp /vagrant/kernels/pyspark.json /opt/conda/share/jupyter/kernels/pyspark/kernel.json

#Jupyter added in logon script rc.local (executed before login as root)
echo ' Setting up local rc path'

echo '#!/bin/sh -e' > /etc/rc.local
echo 'export CONDA_DIR=/opt/conda' >> /etc/rc.local
echo 'export PATH=$CONDA_DIR/bin:$PATH' >> /etc/rc.local
echo 'export SPARK_HOME=/usr/local/spark' >> /etc/rc.local
echo 'export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip' >> /etc/rc.local
echo "jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir='/home/vagrant' & " >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local

#bash script to start Jupyter (in case the logon script doesn't work)
cp /vagrant/startJupyter.sh /