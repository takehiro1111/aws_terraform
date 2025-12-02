FROM prom/prometheus:v3.8.0@sha256:d936808bdea528155c0154a922cd42fd75716b8bb7ba302641350f9f3eaeba09

WORKDIR /etc/prometheus
COPY conf/prometheus.yml prometheus.yml
# COPY conf/alertmanager.yml alertmanager.yml
COPY conf/alert_rules.yml alert_rules.yml

CMD [ "--config.file=/etc/prometheus/prometheus.yml","--storage.tsdb.path=/prometheus" ]
