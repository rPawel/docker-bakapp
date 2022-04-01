FROM rpawel/ubuntu:focal

RUN add-apt-repository ppa:duplicity-team/duplicity-release-git && \
    apt-get -q -y update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
     mysql-server duply expect python3-pip && \
    pip install b2sdk && \
    mkdir -p /root/.duply/b2 && chmod -R 700 /root/.duply

ADD .duply/b2/conf /root/.duply/b2/conf
ADD entrypoint.sh /
ADD backup.sh /

RUN chmod 755 /entrypoint.sh /backup.sh

ENTRYPOINT ["/usr/bin/bash","/entrypoint.sh"]