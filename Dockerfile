FROM ubuntu:20.10

RUN apt-get update && apt-get -y dist-upgrade \
    && apt-get -y install python3-pip uwsgi python3-venv sudo python3-dev libyaml-dev \
    libsasl2-dev libldap2-dev nginx uwsgi-plugin-python3  python3-pip python3-setuptools libssl-dev libffi-dev  \
    mysql-client \
    && rm -rf /var/cache/apt/archives/*

RUN useradd -m -s /bin/bash iris-relay

WORKDIR /home/iris-relay

COPY docker/daemons /home/iris-relay/daemons
COPY src /home/iris-relay/src
COPY setup.py /home/iris-relay/setup.py
COPY README.md /home/iris-relay/README.md

COPY . /home/iris-relay
COPY ops/config/systemd /etc/systemd/system
COPY ops/daemons /home/iris-relay/daemons
COPY ops/daemons/uwsgi-docker.yaml /home/iris-relay/daemons/uwsgi.yaml
COPY db /home/iris-relay/db
COPY configs /home/iris-relay/config
COPY healthcheck.py /tmp/status
COPY ops/entrypoint.py /home/iris-relay/entrypoint.py

RUN chown -R iris-relay:iris-relay /home/iris-relay /var/log/nginx /var/lib/nginx \
    && sudo -Hu iris-relay mkdir -p /home/iris-relay/var/log/uwsgi /home/iris-relay/var/log/nginx /home/iris-relay/var/run /home/iris-relay/var/relay \
    && sudo -Hu iris-relay python3 -m venv /home/iris-relay/env \
#    && sudo -Hu iris-relay /bin/bash -c 'source /home/iris-relay/env/bin/activate && python3 /home/iris-relay/setup.py install'
    && sudo -Hu iris-relay /bin/bash -c 'source /home/iris-relay/env/bin/activate && python3 -m pip install -U pip wheel && python3 /home/iris-relay/setup.py install'

EXPOSE 16648

# uwsgi runs nginx. see uwsgi.yaml for details
#CMD ["/usr/bin/uwsgi", "--yaml", "/home/iris-relay/daemons/uwsgi.yaml:prod"]
CMD ["sudo", "-EHu", "iris-relay", "bash", "-c", "source /home/iris-relay/env/bin/activate && python -u /home/iris-relay/entrypoint.py"]

