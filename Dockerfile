FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y dist-upgrade \
    && apt-get -y install python3-pip uwsgi python3-venv sudo python3-dev libyaml-dev \
    libsasl2-dev libldap2-dev nginx uwsgi-plugin-python3 uwsgi-plugin-gevent-python3 libssl-dev libffi-dev  \
    && rm -rf /var/cache/apt/archives/*

WORKDIR /home/iris
RUN useradd -m -s /bin/bash iris

COPY docker/daemons /home/iris/daemons
COPY src /home/iris/source/src
COPY setup.py /home/iris/source/setup.py
COPY README.md /home/iris/source/README.md

RUN chown -R iris:iris /home/iris /var/log/nginx /var/lib/nginx \
    && sudo -Hu iris mkdir -p /home/iris/var/log/uwsgi /home/iris/var/log/nginx /home/iris/var/run /home/iris/var/relay \
    && sudo -Hu iris python3 -m venv /home/iris/env \
    && sudo -Hu iris /bin/bash -c 'source /home/iris/env/bin/activate && cd  /home/iris/source  && pip install .'

EXPOSE 16648

# uwsgi runs nginx. see uwsgi.yaml for details
#CMD ["/usr/bin/uwsgi", "--yaml", "/home/iris-relay/daemons/uwsgi.yaml:prod"]
CMD ["sudo", "-EHu", "iris-relay", "bash", "-c", "source /home/iris-relay/env/bin/activate && python -u /home/iris-relay/entrypoint.py"]

