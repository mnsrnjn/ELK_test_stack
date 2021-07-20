FROM centos:centos7

MAINTAINER  Manas Ranjan Sahu <manas111@live.com>

# add the repository for logstash

ADD elasticstack.repo /etc/yum.repos.d/elasticstack.repo.repo

# install the required packages

RUN yum update -y && \
	yum install -y java-11-openjdk && \
	yum install -y 	java-11-openjdk-devel && \
	yum clean all

RUN yum install -y logstash && \
	yum clean all && \
	

#set the environment variables

ENV JAVA_HOME=/usr/lib/jvm/jre-11-openjdk \
	PATH=$PATH:$JAVA_HOME/bin \
	CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar \
	JAVA_VER=1.11.0 
	

EXPOSE 5042



CMD ["/usr/share/logstash/bin/logstash"]




