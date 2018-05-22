FROM registry.access.redhat.com/rhoar-nodejs/nodejs-8:latest

USER root
RUN mkdir -p /opt/webssh2
WORKDIR /opt/webssh2
COPY . /opt/webssh2
RUN npm install --production
EXPOSE 2222
CMD npm start
