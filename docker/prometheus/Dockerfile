FROM prom/prometheus:v3.4.0@sha256:78ed1f9050eb9eaf766af6e580230b1c4965728650e332cd1ee918c0c4699775

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
