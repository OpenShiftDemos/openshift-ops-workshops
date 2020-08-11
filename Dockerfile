FROM registry.fedoraproject.org/fedora:32

RUN dnf -y install npm nodejs

RUN mkdir -m 0777 -p /srv

COPY ./ /srv/

RUN chown -R 1001:0 /srv

RUN npm -g install gulp

WORKDIR /srv

RUN npm install

EXPOSE 3000 3001

ENTRYPOINT ["gulp"]
