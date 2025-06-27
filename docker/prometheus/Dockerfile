FROM prom/prometheus:v3.4.2@sha256:3b1d5be5c3eef4f027665ddaa3b1a7de8a58d96a0a6de5dd45629afd267ecaf0

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
