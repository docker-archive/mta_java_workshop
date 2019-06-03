FROM docker.elastic.co/logstash/logstash-oss:7.1.1

COPY config/logstash.yml /usr/share/logstash/config/logstash.yml
COPY pipeline/logstash.conf /usr/share/logstash/pipeline/logstash.conf

# ENTRYPOINT ["logstash"]
# CMD ["-f", "/usr/share/logstash/pipeline/logstash.conf"]