FROM ubuntu:18.10

LABEL maintainer "David Ruiz <rusodavid@gmail.com>"

#install jdk 8
RUN apt-get update && \
    apt-get -y install libgtk-3-0 \
	libgl1-mesa-dri \
        libgl1-mesa-glx \
	libcanberra-gtk-module \
	libcanberra-gtk3-module \
	wget \
	curl \
	p7zip \
        git \
	vim \
	zsh \
	--no-install-recommends

#install openjava
RUN apt-get -y install openjdk-8-jdk \
	libopenjfx-jni libopenjfx-java	

#install jdk
ARG JAVA_LN_VERSION=java-1.8.0_211-jdk-amd64
ARG JAVA_VERSION=jdk-8u211-linux-x64
ARG JAVA_DIR=jdk1.8.0_211

COPY ${JAVA_VERSION}.tar.gz /
RUN tar -zxvf ${JAVA_VERSION}.tar.gz -C /usr/lib/jvm  
RUN chown -R root:root /usr/lib/jvm/${JAVA_DIR} && \
 ln -s /usr/lib/jvm/${JAVA_DIR} /usr/lib/jvm/${JAVA_LN_VERSION} && \ 
 update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/${JAVA_DIR}/bin/java" 1 && \
 update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/${JAVA_DIR}/bin/javac" 1 && \
 update-alternatives --set  java "/usr/lib/jvm/${JAVA_DIR}/bin/java" && \
 update-alternatives --set  javac "/usr/lib/jvm/${JAVA_DIR}/bin/javac" && \
 rm ${JAVA_VERSION}* 

#install maven
RUN wget --progress=dot:mega https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -P /tmp && \
 tar xf /tmp/apache-maven-*.tar.gz -C /opt && \
 ln -s /opt/apache-maven-*/bin/mvn /usr/bin/mvn
#COPY maven.sh /etc/profile.d/maven.sh
#RUN chmod +x /etc/profile.d/maven.sh

#install eclipse
RUN wget -O eclipse-java.tar.gz  http://mirror.ibcp.fr/pub/eclipse//technology/epp/downloads/release/2019-03/R/eclipse-java-2019-03-R-linux-gtk-x86_64.tar.gz --progress=dot:mega && \
 tar xf eclipse-*.tar.gz && rm -f eclipse-*.tar.gz && \
 echo "-Xms1024m" >> eclipse/eclipse.ini && \
 echo "-Xmx2048m" >> eclipse/eclipse.ini && \
 echo "-Dosgi.instance.area.default=/git" >> eclipse/eclipse.ini && \
 ln -s /eclipse/eclipse /usr/bin/eclipse

#install intellij
ARG INTELLIJ_VERSION=191.6707.61
ARG INTELLIJ_CONFIG=idea-IC-config
RUN wget -O intellij.tar.gz  https://download.jetbrains.com/idea/ideaIC-2019.1.1.tar.gz --progress=dot:mega && \
 tar xf intellij.tar.gz && rm -f intellij.tar.gz 
COPY idea.properties /idea-IC-${INTELLIJ_VERSION}/bin/idea.properties
COPY ${INTELLIJ_CONFIG}/ /${INTELLIJ_CONFIG}/ 
RUN ln -s /idea-IC-${INTELLIJ_VERSION}/bin/idea.sh /usr/bin/intellij

#install dbeaver
RUN wget --progress=dot:mega -O dbeaver.tar.gz https://dbeaver.io/files/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz && \
 tar xf dbeaver.tar.gz && rm -f dbeaver.tar.gz && \
 ln -s /dbeaver/dbeaver /usr/bin/dbeaver  

#install soap-ui
ARG SOAPUI_VERSION=5.5.0
RUN wget --progress=dot:mega -O soapui.tar.gz https://s3.amazonaws.com/downloads.eviware/soapuios/${SOAPUI_VERSION}/SoapUI-${SOAPUI_VERSION}-linux-bin.tar.gz && \
 tar -xf soapui.tar.gz && rm -f soapui.tar.gz && \
 ln -s /SoapUI-${SOAPUI_VERSION}/bin/soapui.sh /usr/bin/soapui

#install OhMyZsh
ENV TERM=xterm
RUN chsh -s $(which zsh)

#To avoid errors about dbus
ENV NO_AT_BRIDGE=1


#sudo (to remove)
RUN apt-get install -y sudo

# Set up the user 
ARG UNAME=developer 
ARG UID=1001 
ARG GID=1001 
ARG HOME=/home/${UNAME}

RUN addgroup --gid ${GID} developer
RUN useradd -m -u ${UID} -g ${GID} developer && echo "developer:developer" | chpasswd && adduser developer sudo

RUN mkdir /${HOME}/.m2 && \
    mkdir /${HOME}/.m2/repository 

COPY settings.xml /${HOME}/.m2
RUN chown -R developer:developer ${HOME} 
RUN chown -R developer:developer ${INTELLIJ_CONFIG} 
RUN chown -R developer:developer /idea-IC-${INTELLIJ_VERSION}
RUN chown -R developer:developer /SoapUI-${SOAPUI_VERSION}

COPY .dbeaver4 ${HOME}/.dbeaver4
RUN chown -R developer:developer ${HOME}/.dbeaver4 
COPY .dbeaver-drivers ${HOME}/.dbeaver-drivers 
RUN chown -R developer:developer ${HOME}/.dbeaver-drivers 

USER ${UNAME} 
WORKDIR $HOME

RUN curl -L http://install.ohmyz.sh | sh || true

ENTRYPOINT [ "/bin/zsh" ]
