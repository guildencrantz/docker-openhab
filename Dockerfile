FROM centos:7
MAINTAINER "Matt Henkel" <guildencrantz@menagerie.cc>

RUN yum -y update && \
    yum clean all

RUN yum -y install tar unzip && \
    yum clean all

ADD jdk.md5sum /jdk.md5sum

RUN set -x                                                                  && \
    curl -sOL -H 'Cookie: oraclelicense=accept-securebackup-cookie'            \
        'http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm' && \
    md5sum -c jdk.md5sum                                                    && \
    rm jdk.md5sum                                                           && \
    rpm -i jdk-7u79-linux-x64.rpm                                           && \
    rm jdk-7u79-linux-x64.rpm                                               && \
    echo 'export JAVA_HOME=/usr/java/jdk1.7.0_79' >/etc/bashrc

# Basic openhab install
RUN set -x                                         && \
    mkdir /openhab                                 && \
    cd /openhab                                    && \
    curl -sOL 'https://openhab.ci.cloudbees.com/job/openHAB/lastSuccessfulBuild/artifact/distribution/target/distribution-1.7.0-SNAPSHOT-runtime.zip' && \
    unzip distribution-1.7.0-SNAPSHOT-runtime.zip  && \
    rm distribution-1.7.0-SNAPSHOT-runtime.zip     && \
    cd addons                                      && \
    curl -sOL 'https://openhab.ci.cloudbees.com/job/openHAB/lastSuccessfulBuild/artifact/distribution/target/distribution-1.7.0-SNAPSHOT-addons.zip'  && \
    unzip distribution-1.7.0-SNAPSHOT-addons.zip org.openhab.binding.http-1.7.0-SNAPSHOT.jar

# Additional bindings
RUN set -x                                                                  && \
    cd /openhab/addons                                                      && \
    unzip distribution-1.7.0-SNAPSHOT-addons.zip org.openhab.binding.nest-1.7.0-SNAPSHOT.jar  && \
    unzip distribution-1.7.0-SNAPSHOT-addons.zip org.openhab.binding.sonos-1.7.0-SNAPSHOT.jar

VOLUME ["/openhab/configurations"]

CMD ["/openhab/start.sh"]
