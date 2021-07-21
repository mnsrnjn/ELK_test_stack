# ELK-stack
 

This is a basic level code for testing the ELK stack on docker.
In this example following containers are created using dockercompose and dockerfile.

For the containers need to be created some environmen variables needed to be set.
In the first step SSL certificated will be created then in the next step using docker composi following containers will be created
1. three node cluster of elastic search
2.kibana
3.logstash
4.filebeat
5.meticbeat
6.packetbeat


The files needs tobe downloaded or cloned for the containes creation

the enviromment file will be  similar but necessarili that it will be same.

$docker-compose -f create_certificates.yml run --rm create_certs 

this command will create the required ssl certificates for each instance listed in the instances.yml file.
Once certificates are generated we can docker-compose to create the container.

docker-compose up -d --build

This will build the required images and will create the container.
