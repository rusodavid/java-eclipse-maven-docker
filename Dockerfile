FROM ubuntu:18.04

LABEL maintainer "David Ruiz <rusodavid@gmail.com>"

#install jdk 8
RUN apt-get update && \
    apt-get -y install openjdk-8-jdk \
        libgtk-3-0 \
	libgl1-mesa-dri \
        libgl1-mesa-glx \
	libcanberra-gtk3-module \
	wget \
        git \
	vim \
	zsh \
	--no-install-recommends

#install maven
RUN wget https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -P /tmp
RUN tar xf /tmp/apache-maven-*.tar.gz -C /opt
RUN ln -s /opt/apache-maven-*/bin/mvn /usr/bin/mvn

COPY maven.sh /etc/profile.d/maven.sh
RUN chmod +x /etc/profile.d/maven.sh

#install eclipse
RUN wget -O eclipse-java.tar.gz  http://mirror.ibcp.fr/pub/eclipse//technology/epp/downloads/release/2019-03/R/eclipse-java-2019-03-R-linux-gtk-x86_64.tar.gz --progress=dot
RUN tar xf eclipse-*.tar.gz && rm -f eclipse-*.tar.gz 
RUN echo "-Xms1024m" >> eclipse/eclipse.ini
RUN echo "-Xmx2048m" >> eclipse/eclipse.ini
RUN echo "-Dosgi.instance.area.default=/git" >> eclipse/eclipse.ini
RUN ln -s /eclipse/eclipse /usr/bin/eclipse

#install dbeaver
RUN wget --progress=bar:noscroll -O dbeaver.tar.gz https://dbeaver.io/files/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz
RUN tar xf dbeaver.tar.gz && rm -f dbeaver.tar.gz
RUN ln -s /dbeaver/dbeaver /usr/bin/dbeaver

#install soap-ui
RUN wget --progress=bar:noscroll -O soapui.tar.gz https://s3.amazonaws.com/downloads.eviware/soapuios/5.4.0/SoapUI-5.4.0-linux-bin.tar.gz
RUN mkdir soapui
RUN tar -zxf soapui.tar.gz -C soapui && rm -f soapui.tar.gz
RUN ln -s /soapui/SoapUI-5.4.0/bin/soapui.sh /usr/bin/soapui

#install OhMyZsh
ENV TERM=xterm
RUN apt-get install -y curl
RUN chsh -s $(which zsh)

#To avoid errors about dbus
ENV NO_AT_BRIDGE=1

# Set up the user 
ARG UNAME=developer 
ARG UID=1001 
ARG GID=1001 
ARG HOME=/home/${UNAME} 
RUN mkdir -p ${HOME} && \
    mkdir /${HOME}/.m2 && \
    mkdir /${HOME}/.m2/repository && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:${HOME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    gpasswd --add ${UNAME} adm

COPY settings.xml /${HOME}/.m2
RUN  chown ${UID}:${GID} -R ${HOME} 

USER ${UNAME} 
WORKDIR $HOME

RUN curl -L http://install.ohmyz.sh | sh || true


#debug
ENTRYPOINT [ "/bin/zsh" ]
