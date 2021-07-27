# Exit on Error
set -e

CONFIG_DIR=/usr/share/elasticsearch/config
OUTPUT_FILE=/secrets/elasticsearch.keystore
NATIVE_FILE=$CONFIG_DIR/elasticsearch.keystore
OUTPUT_DIR=/secrets
CA_DIR=/secrets/certificate_authority
KEYSTORES_DIR=$OUTPUT_DIR/keystores
CERT_DIR=$OUTPUT_DIR/certificates
CA_P12=$CA_DIR/elastic-stack-ca.p12
CA_ZIP=$CA_DIR/ca.zip
CA_CERT=/secrets/certificate_authority/ca/ca.crt
CA_KEY=/secrets/certificate_authority/ca/ca.key
BUNDLE_ZIP=$OUTPUT_DIR/bundle.zip
CERT_KEYSTORES_ZIP=$OUTPUT_DIR/cert_keystores.zip
HTTP_ZIP=$OUTPUT_DIR/http.zip

yum install unzip openssl -y

create_self_signed_ca()
{

    bin/elasticsearch-certutil ca --pass "" --pem --out $CA_ZIP --silent
    unzip $CA_ZIP -d $CA_DIR

    bin/elasticsearch-certutil ca --pass "" --out $CA_P12 --silent

}

create_certificates()
{

    bin/elasticsearch-certutil cert --silent --in $CONFIG_DIR/instances.yml --out $CERT_KEYSTORES_ZIP --ca $CA_P12 --ca-pass "" --pass ""
    unzip $CERT_KEYSTORES_ZIP -d $KEYSTORES_DIR

    bin/elasticsearch-certutil cert --silent --in $CONFIG_DIR/instances.yml --out $BUNDLE_ZIP --ca-cert $CA_CERT --ca-key $CA_KEY --ca-pass "" --pem
    unzip $BUNDLE_ZIP -d $CERT_DIR
}

setup_passwords()
{

    bin/elasticsearch-setup-passwords auto -u "https://0.0.0.0:9200" -v --batch
}

create_keystore()
{

    elasticsearch-keystore create >> /dev/null

    ## Setting Bootstrap Password

    (echo "$ELASTIC_PASSWORD" | elasticsearch-keystore add -x 'bootstrap.password')

    # Replace current Keystore
    if [ -f "$OUTPUT_FILE" ]; then
        echo "Remove old elasticsearch.keystore"
        rm $OUTPUT_FILE
    fi

    #setup_passwords
    echo "Saving new elasticsearch.keystore"
    mv $NATIVE_FILE $OUTPUT_FILE
    chmod 0644 $OUTPUT_FILE


}


remove_existing_certificates()
{

    for f in $OUTPUT_DIR/* ; do
        if [ -d "$f" ]; then
            echo "Removing directory $f"
            rm -rf $f
        fi
        if [ -f "$f" ]; then
            echo "Removing file $f"
            rm $f
        fi
    done
}

create_directory_structure()
{

    echo "Creating Certificate Authority Directory..."
    mkdir $CA_DIR
    echo "Creating Keystores Directory..."
    mkdir $KEYSTORES_DIR
    echo "Creating Certificates Directory..."
    mkdir $CERT_DIR
}

rename_swag_confs()
{
    if [ "$SUBDOMAIN" ]; then
        cp "/swag/nginx/proxy-confs/kibana.subdomain.conf.sample" "/swag/nginx/proxy-confs/$SUBDOMAIN.subdomain.conf"
        #mv "/swag/nginx/proxy-confs/kibana.subdomain.conf.sample" "/swag/nginx/proxy-confs/$SUBDOMAIN.subdomain.conf"
        sed -i -e "s/REPLACE_ME.*;/$SUBDOMAIN.*;/" "/swag/nginx/proxy-confs/$SUBDOMAIN.subdomain.conf"
    elif [ "$SUBFOLDER" ]; then
        cp "/swag/nginx/proxy-confs/kibana.subfolder.conf.sample" "/swag/nginx/proxy-confs/$SUBFOLDER.subfolder.conf"
        sed -e "s/\\REPLACE_ME/\\$SUBFOLDER/" "/swag/nginx/proxy-confs/$SUBFOLDER.subfolder.conf"
    else
        echo "No SUBDOMAIN or SUBFOLDER variable set.... skipping ...."
    fi
}

remove_existing_certificates
create_directory_structure
create_keystore
create_self_signed_ca
create_certificates

openssl pkcs8 -in /secrets/certificates/logstash/logstash.key -topk8 -nocrypt -out /secrets/certificates/logstash/logstash.pkcs8.key



chown -R 1000:0 $OUTPUT_DIR

