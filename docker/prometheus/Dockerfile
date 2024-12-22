FROM prom/prometheus:v3.0.1@sha256:565ee86501224ebbb98fc10b332fa54440b100469924003359edf49cbce374bd

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
