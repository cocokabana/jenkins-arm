FROM resin/rpi-raspbian:latest

# Make sure we don't get notifications we can't answer during building.
ENV    DEBIAN_FRONTEND noninteractive


# Get system up to date to start with.
RUN    apt-get update; apt-get --yes upgrade; apt-get --yes install \
       apt-transport-https \
       ca-certificates \
       curl \
       gnupg2 \
       software-properties-common \ 
       libapparmor-dev


# The special trick here is to download and install the Oracle Java 8 installer from Launchpad.net
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

# Setup docker repo
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - && \
    echo "deb [arch=armhf] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Make sure the Oracle Java 8 license is pre-accepted, and install Java 8 + Docker
RUN    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
       echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
       apt-get update && \
       apt-get --yes install oracle-java8-installer docker-ce ; apt-get clean

ENV JENKINS_HOME /usr/local/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50000

RUN mkdir -p /usr/local/jenkins
RUN useradd --no-create-home --shell /bin/sh jenkins 
RUN chown -R jenkins:jenkins /usr/local/jenkins/
ADD http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war /usr/local/jenkins.war
RUN chmod 644 /usr/local/jenkins.war

ENTRYPOINT ["/usr/bin/java", "-jar", "/usr/local/jenkins.war"]

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

CMD [""]
