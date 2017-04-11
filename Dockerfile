# Build this image:  docker build -t mpi .
#

#FROM ubuntu:14.04
FROM paddledev/paddle:0.10.0rc2
MAINTAINER Ole Weidner <ole.weidner@ed.ac.uk>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y openssh-server zip unzip vim sudo \
gcc gfortran openmpi-checkpoint binutils wget curl git openmpi-bin openmpi-common libopenmpi-dev && \
pip install mpi4py numpy virtualenv scipy matplotlib lxml sqlalchemy suds ipython obspy && \
mkdir /var/run/sshd && \
echo 'root:tutorial' | chpasswd && \
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
# SSH login fix. Otherwise user is kicked off after login
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
echo "export VISIBLE=now" >> /etc/profile && \
adduser --disabled-password --gecos "" tutorial && \
echo "tutorial ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
mkdir /home/tutorial/.ssh/

ENV HOME /home/tutorial
ENV NOTVISIBLE "in users profile"

# ------------------------------------------------------------
# Set-Up SSH with our Github deploy key
# ------------------------------------------------------------

ADD ssh/config /home/tutorial/.ssh/config
ADD ssh/id_rsa.mpi /home/tutorial/.ssh/id_rsa
ADD ssh/id_rsa.mpi.pub /home/tutorial/.ssh/id_rsa.pub
ADD ssh/id_rsa.mpi.pub /home/tutorial/.ssh/authorized_keys

# ------------------------------------------------------------
# Copy Rosa's MPI4PY example scripts
# ------------------------------------------------------------

ADD mpi4py_benchmarks /home/tutorial/mpi4py_benchmarks

RUN chmod -R 600 /home/tutorial/.ssh/* && \
chown -R tutorial:tutorial /home/tutorial/.ssh && \
chown tutorial:tutorial /home/tutorial/mpi4py_benchmarks && \
# install dispel4py latest 
git clone https://github.com/dispel4py/dispel4py.git && \
cd dispel4py && python setup.py install

ADD tc_cross_correlation /home/tutorial/dispel4py/tc_cross_correlation
RUN chown tutorial:tutorial -R /home/tutorial/dispel4py/tc_cross_correlation
ADD command-preprocess.sh  /home/tutorial/.
ADD command-postprocess.sh  /home/tutorial/.
RUN chmod +x /home/tutorial/command-preprocess.sh  
RUN chown tutorial:tutorial /home/tutorial/command-preprocess.sh
RUN chmod +x /home/tutorial/command-postprocess.sh  
RUN chown tutorial:tutorial /home/tutorial/command-postprocess.sh
#---------------------------------------------------------------
#LD_LIBRARY_PATH
#---------------------------------------------------------------

RUN export LD_LIBRARY_PATH=/usr/lib/openmpi/lib/

WORKDIR /home/tutorial
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
