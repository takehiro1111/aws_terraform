FROM prom/prometheus:v3.3.1@sha256:e2b8aa62b64855956e3ec1e18b4f9387fb6203174a4471936f4662f437f04405

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
