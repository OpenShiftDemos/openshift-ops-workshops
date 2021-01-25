FROM quay.io/openshifthomeroom/workshop-dashboard:4.2.2

USER root

RUN wget https://github.com/noobaa/noobaa-operator/releases/download/v5.6.0/noobaa-linux-v5.6.0 -O /opt/workshop/bin/noobaa && \
    wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.3/openshift-client-linux-4.6.3.tar.gz -P /opt/app-root/src/ && \
    tar -xzvf /opt/app-root/src/openshift-client-linux-4.6.3.tar.gz -C /opt/workshop/bin/ && \
    rm -f /opt/workshop/bin/README.md && \
    ln -s /opt/workshop/bin/noobaa /opt/app-root/bin/noobaa && \
    chmod +x /opt/workshop/bin/{oc,kubectl,noobaa}

COPY . /tmp/src

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

USER 1001

RUN /usr/libexec/s2i/assemble
