FROM prom/prometheus:v3.9.0@sha256:3ea2ed3b8cdfe3ff78aa05473a7ad36b916bdf2464c83b06bcd37c1a67620233

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
