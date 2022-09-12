/usr/sbin/adduser --system  --home /dev/null --gecos "Prometheus Node Exporter" \
        --no-create-home --disabled-password \
        --quiet prometheus-node-exporter || true
