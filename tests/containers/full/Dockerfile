FROM enterprisemediawiki/meza:pre-yum
LABEL MAINTAINER James Montalvo
ENV container=docker

RUN git clone -b master https://github.com/enterprisemediawiki/meza /opt/meza
# COPY . /opt/meza

RUN bash /opt/meza/src/scripts/getmeza.sh --skip-conn-check

RUN meza setup env monolith --fqdn="INSERT_FQDN" --db_pass=1234 --private_net_zone=public

RUN echo "" >> /opt/conf-meza/secret/monolith/secret.yml \
	&& echo "docker_skip_tasks: true" >> /opt/conf-meza/secret/monolith/secret.yml

RUN meza deploy monolith