FROM centos:centos7

MAINTAINER  Manas Ranjan Sahu <manas111@live.com>

# add tyhe repository for elasticsearch

ADD     elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
# install the required packages

RUN yum update -y && \
        yum install -y java-11-openjdk && \
        yum install -y java-11-openjdk-devel && \
	yum clean all

RUN	yum install elasticsearch-oss && \
        yum clean all

#Expose the port to connect from outside

EXPOSE 9200
#set the environment variables

ENV JAVA_HOME=/usr/lib/jvm/jre-11-openjdk \
        PATH=$PATH:$JAVA_HOME/bin \
        CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar \
        JAVA_VER=1.11.0

USER elasticsearch


CMD ["sh", "-c", "/usr/share/elasticsearch/bin/elasticsearch"]

