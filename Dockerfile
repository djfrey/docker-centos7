FROM centos:8


ARG uid=1000
ARG gid=1000

RUN dnf -y --disablerepo '*' --enablerepo=extras swap centos-linux-repos centos-stream-repos
RUN dnf -y distro-sync


#Apache and utils
RUN	yum -y update \
	&& yum --setopt=tsflags=nodocs -y install \    
	httpd \
    httpd-tools \
    mod_ssl \
    make \
	unzip \
    curl \
    wget \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

#Python
    RUN yum groupinstall "Development Tools" -y
    RUN yum install openssl-devel libffi-devel bzip2-devel -y

    RUN wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz && \
    tar xvf Python-3.10.0.tgz && \
    cd Python-3.10.*/ && \    
    ./configure --enable-optimizations && \
    make altinstall
    RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3.10 get-pip.py
    #Symlinks for the lazy...    
    RUN ln -s /usr/local/bin/python3.10 /usr/local/bin/python    
    #Remove source files    
    RUN rm -f Python-3.10.0.tgz && rm -rf Python-3.10.0/ && rm -f get-pip.py
#End python
#Node
    RUN dnf module install nodejs:18/common -y
#End node
#Oracle
#    RUN yum install -y https://download.oracle.com/otn_software/linux/instantclient/215000/oracle-instantclient-basic-21.5.0.0.0-1.el8.x86_64.rpm && \
#    yum install -y https://download.oracle.com/otn_software/linux/instantclient/215000/oracle-instantclient-devel-21.5.0.0.0-1.el8.x86_64.rpm && \
#    yum install -y https://download.oracle.com/otn_software/linux/instantclient/215000/oracle-instantclient-sqlplus-21.5.0.0.0-1.el8.x86_64.rpm && \
#    echo "/usr/lib/oracle/21/client64/lib" > /etc/ld.so.conf.d/oracle-instantclient.conf
#    ENV PATH=$PATH:/usr/lib/oracle/21/client64/bin LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/oracle/21/client64/lib ORACLE_HOME=/usr/lib/oracle/21/client64    
#    RUN ldconfig
#    RUN yum update -y
#    RUN yum remove -y unixODBC-utf16
#    RUN yum clean all -y
#    RUN pip3 install --no-cache-dir cx_Oracle
#End Oracle
#Salesforce     
    RUN wget https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.xz && \
    mkdir /opt/sfdx && \
    tar xJf sfdx-linux-x64.tar.xz -C /opt/sfdx --strip-components 1
    ENV PATH=/opt/sfdx/bin:$PATH
    ENV SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
    #Install Python SF library
    RUN pip3 install --no-cache-dir simple_salesforce
#End salesforce
#SF ODBC
    RUN mkdir /opt/salesforceodbc
    COPY ./salesforce/devart-odbc-salesforce.x86_64.rpm /opt/salesforceodbc/devart-odbc-salesforce.x86_64.rpm    
    RUN yum localinstall /opt/salesforceodbc/devart-odbc-salesforce.x86_64.rpm -y    
    COPY ./etc/odbc.ini /etc/odbc.ini 
#End SF ODBC
#Google
    RUN mkdir /opt/google && cd ./opt/google
    RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-432.0.0-linux-x86_64.tar.gz
    RUN tar -xf google-cloud-cli-432.0.0-linux-x86_64.tar.gz
    RUN yes | ./google-cloud-sdk/install.sh 
#Libreoffice, installs in /usr/bin
    RUN yum install -y java-11-openjdk-headless.x86_64 libreoffice-core libreoffice-writer libreoffice-calc && \
    JAVA_11=$(alternatives --display java | grep 'family java-11-openjdk' | cut -d' ' -f1) && \
    alternatives --set java $JAVA_11   
#End Libreoffice
#PHP 8.1
    RUN dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm && \
    dnf install -y epel-release && \
    dnf module enable php:remi-8.1 -y && \
    dnf install -y php
    #COPY ./etc/pki/tls/certs/cacert.pem /etc/pki/tls/certs/cacert.pem
    COPY ./etc/php.d/99-user.ini /etc/php.d/99-user.ini
    COPY ./etc/php.d/20-curl.ini /etc/php.d/20-curl.ini
    # Install PHP modules
    RUN yum -y install php php-bcmath php-cli php-common php-gd php-intl php-json php-ldap php-mbstring \
    php-mysqlnd php-pdo php-pear php-soap php-xml php-xmlrpc php-pecl-zip php-devel systemtap-sdt-devel php-odbc \
    php-grpc
    #Oracle support
#    ENV PHP_DTRACE=yes
#    RUN echo | C_INCLUDE_PATH=/usr/include/oracle/21/client64 pecl install oci8
#    RUN echo "extension=oci8.so" > /etc/php.d/30-oci8.ini    
    #Necessary to run PHP FPM 
    RUN mkdir /run/php-fpm 
#Shibboleth
#    COPY ./etc/yum.repos.d/shibboleth.repo /etc/yum.repos.d/shibboleth.repo
#    RUN yum update -y
#    RUN yum install -y shibboleth.x86_64
    #Geerate new keys if necessary
    #RUN /etc/shibboleth/./keygen.sh -f -u shibd -g shibd -y 10 -h local.advancement-services.ncsu.edu -e https://local.advancement-services.ncsu.edu/sp/shibboleth
    #RUN mv sp-key.pem /etc/shibboleth/sp-key.pem
    #RUN mv sp-cert.pem /etc/shibboleth/sp-cert.pem    
    #The following two keys are for Shib 3
    #RUN /etc/shibboleth/./keygen.sh -f -u shibd -g shibd -y 10 -n sp-encrypt -h local.advancement-services.ncsu.edu -e https://local.advancement-services.ncsu.edu/sp/shibboleth
    #RUN /etc/shibboleth/./keygen.sh -f -u shibd -g shibd -y 10 -n sp-signing -h local.advancement-services.ncsu.edu -e https://local.advancement-services.ncsu.edu/sp/shibboleth
    #RUN wget https://docs.shib.ncsu.edu/docs/sample30-attribute-map.xml && \
    #wget https://docs.shib.ncsu.edu/federation/ncsu_federation.pem && \
    #mv sample30-attribute-map.xml /etc/shibboleth/attribute-map.xml && \
    #mv ncsu_federation.pem /etc/shibboleth/ncsu_federation.pem  
    #Refer to https://docs.shib.ncsu.edu/docs/ for initial setup.  Once the appropriate files have been created, download them and re-copy them on container build to maintain keys
    #The helpdesk will need the file generated from https://yourserver.ncsu.edu/Shibboleth.sso/Metadata to add this system to the shib registry
#    COPY ./etc/shibboleth/sp-key.pem /etc/shibboleth/sp-key.pem
#    COPY ./etc/shibboleth/sp-cert.pem /etc/shibboleth/sp-cert.pem
#    COPY ./etc/shibboleth/ncsu_federation.pem /etc/shibboleth/ncsu_federation.pem
#    COPY ./etc/shibboleth/attribute-map.xml /etc/shibboleth/attribute-map.xml
#    COPY ./etc/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml
 #SSL   
    RUN openssl genrsa -out localhost.key 2048
    #RUN openssl req -new -key localhost.key -out localhost.csr -subj "/C=US/ST=NC/O=Midwood/OU=Midwood/CN=local.midwood.com" -addext "subjectAltName=DNS:local.midwood.com"
    RUN openssl req -new -key localhost.key -out localhost.csr -subj "/C=US/ST=NC/O=Midwood/OU=Midwood/CN=localhost" -addext "subjectAltName=DNS:localhost"
    RUN openssl x509 -req -days 1095 -in localhost.csr -signkey localhost.key -out localhost.crt
    RUN mv localhost.crt /etc/pki/tls/certs/ && \
    mv localhost.key /etc/pki/tls/private && \
    mv localhost.csr /etc/pki/tls/private
    COPY ./etc/php.d/20-openssl.ini /etc/php.d/20-openssl.ini
    COPY ./etc/pki/tls/certs/cacert.crt /etc/pki/tls/certs/cacert.crt
#Httpd
    COPY ./etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
    COPY ./etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf
    COPY ./etc/httpd/conf.d/sites.conf /etc/httpd/conf.d/sites.conf    
#End Httpd

#User settings
    #COPY ./user/.bashrc /root/.bashrc

RUN rm /etc/httpd/conf.modules.d/10-h2.conf
RUN rm /etc/httpd/conf.modules.d/10-proxy_h2.conf
COPY ./etc/odbcinst.ini /etc/odbcinst.ini
RUN chmod 664 /etc/odbcinst.ini

# -----------------------------------------------------------------------------
# Set ports
# -----------------------------------------------------------------------------
EXPOSE 80 443

CMD /usr/sbin/php-fpm && /usr/sbin/httpd -DFOREGROUND

#CMD /usr/sbin/shibd && v /usr/sbin/httpd -DFOREGROUND

#Full build, does not use cache
#docker build --no-cache --pull -t centos .

#Rebuild using cache
#docker build -t centos .

#Run container
#docker run -p 80:80 -p 443:443 -v C:/webapp:/var/www/html -v C:/dbobj:/opt/dbobj --cap-add SYS_ADMIN --hostname local.advancement-services.ncsu.edu --name ncsuas centos

#Remove container
#docker rm ncsuas

#Attach a shell
#docker exec -it ncsuas bash