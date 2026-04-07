FROM prom/prometheus:v3.11.1@sha256:759ea6db49103737f2a6f420b0d1632062d8ad99dec086c76db605fd0bf23e15

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
