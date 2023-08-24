FROM quay.io/openshifthomeroom/workshop-dashboard:5.0.1

USER root

RUN wget https://github.com/noobaa/noobaa-operator/releases/download/v5.12.4/noobaa-operator-v5.12.4-linux-amd64.tar.gz -O /opt/workshop/bin/noobaa && \
    tar -xzvf /opt/workshop/bin/noobaa -C /opt/workshop/bin/ && \
    wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.12.9/openshift-client-linux-4.12.9.tar.gz -P /opt/app-root/src/ && \
    wget https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_amd64 -O /opt/workshop/bin/yq && \
    wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O /usr/local/src/awscliv2.zip && \
    wget https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz -O /usr/local/src/helm.tar.gz && \
    tar -xzf /usr/local/src/helm.tar.gz -C /usr/local/src && \
    mv /usr/local/src/linux-amd64/helm /usr/local/bin && \
    unzip /usr/local/src/awscliv2.zip -d /usr/local/src && \
    /usr/local/src/aws/install -i /usr/local/aws-cli -b /usr/local/bin && \
    rm -rf /usr/local/src/aws* && \
    rm -f /usr/local/src/helm*gz && \
    rm -rf /usr/local/src/linux-amd64 && \
    tar -xzvf /opt/app-root/src/openshift-client-linux-4.12.9.tar.gz -C /opt/workshop/bin/ && \
    rm -f /opt/app-root/src/openshift-client-linux-4.12.9.tar.gz && \
    rm -f /opt/workshop/bin/README.md && \
    ln -s /opt/workshop/bin/noobaa /opt/app-root/bin/noobaa && \
    ln -s /opt/workshop/bin/yq /opt/app-root/bin/yq && \
    chmod +x /opt/workshop/bin/{oc,kubectl,noobaa,yq}

COPY . /tmp/src

RUN wget https://github.com/red-hat-storage/demo-apps/raw/main/packaged/photo-album.tgz && \
    tar -xzvf /opt/app-root/src/photo-album.tgz -C /tmp/src/support/

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

USER 1001

RUN /usr/libexec/s2i/assemble
