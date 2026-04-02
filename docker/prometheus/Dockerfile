FROM prom/prometheus:v3.11.0@sha256:dda13e28bf95a5e5ca5b8ed56852006094c1c8e8871d9c9dbeed30aa6e55271f

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
