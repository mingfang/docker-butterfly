FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential python-dev python-pip

#Butterfly
RUN pip install butterfly

#Configuration
ADD . /docker
RUN ln -s /docker/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf
RUN ln -s /docker/supervisord-butterfly.conf /etc/supervisor/conf.d/supervisord-butterfly.conf

EXPOSE 22
