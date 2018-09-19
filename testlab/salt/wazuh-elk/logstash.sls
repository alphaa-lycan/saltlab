{% set es_config = pillar.get('elasticsearch_config', []) %}
logstash_repo:
  pkgrepo.managed:
    - name: deb https://artifacts.elastic.co/packages/6.x/apt stable main
    - file: /etc/apt/sources.list.d/elastic-6.x.list
    - key_url: salt://elasticsearch-6/files/elasticsearch.key

logstash_install:
  pkg.installed:
    - name: logstash=1:6.2.4-1

logstash_config:
  file.managed:
    - name: /etc/logstash/conf.d/01-wazuh.conf
    - source: salt://wazuh-elk/files/01-wazuh.conf
    - user: logstash
    - group: logstash
    - template: jinja
    - context: {
        EL_HOSTS: {{ es_config.elastic_hosts }}
  }
    - require:
      - pkg: logstash=1:6.2.4-1

logstash_service:
  service.running:
    - name: logstash
    - enable: True
    - require:
      - pkg: logstash_install
    - watch:
      - file: logstash_config
