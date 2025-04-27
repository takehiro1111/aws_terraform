FROM prom/prometheus:v3.3.0@sha256:339ce86a59413be18d0e445472891d022725b4803fab609069110205e79fb2f1

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
