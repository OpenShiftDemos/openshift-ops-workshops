FROM centos:7

RUN yum -y install epel-release && \
  yum -y install httpie jq perl openssh-clients nss_wrapper gettext && \
  yum clean all && \
  rm -rf /var/cache/yum

WORKDIR /opt
ENTRYPOINT /opt/script.sh
ADD ./resty /opt/resty
ADD ./script.sh /opt/script.sh

RUN chmod g+x /opt/* && chmod g+w /opt