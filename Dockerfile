FROM quay.io/openshifthomeroom/workshop-dashboard:5.0.1

USER root

RUN wget https://github.com/noobaa/noobaa-operator/releases/download/v5.7.0/noobaa-linux-v5.7.0 -O /opt/workshop/bin/noobaa && \
    wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.7.16/openshift-client-linux-4.7.16.tar.gz -P /opt/app-root/src/ && \
    tar -xzvf /opt/app-root/src/openshift-client-linux-4.7.16.tar.gz -C /opt/workshop/bin/ && \
    rm -f /opt/workshop/bin/README.md && \
    ln -s /opt/workshop/bin/noobaa /opt/app-root/bin/noobaa && \
    chmod +x /opt/workshop/bin/{oc,kubectl,noobaa}

COPY . /tmp/src

RUN wget https://github.com/red-hat-storage/demo-apps/raw/main/packaged/photo-album.tgz && \
    tar -xzvf /opt/app-root/src/photo-album.tgz -C /tmp/src/support/

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

USER 1001

RUN /usr/libexec/s2i/assemble
