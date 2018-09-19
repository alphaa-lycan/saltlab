{% set es_config = pillar.get('elasticsearch_config', []) %}

#{% from "wazuh-elk/map.jinja" import es_config with context %}

elasticsearch6_repo:
  pkgrepo.managed:
    - name: deb https://artifacts.elastic.co/packages/6.x/apt stable main
    - file: /etc/apt/sources.list.d/elasticsearch-6.x.list
    - key_url: salt://wazuh-elk/files/elasticsearch.key

elasticsearch6_install:
  pkg.installed:
    - name: elasticsearch=6.2.4


elasticsearch6_config:
  file.managed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - source: salt://wazuh-elk/files/elasticsearch.yml
    - user: elasticsearch
    - group: elasticsearch
    - mode: 665
    - template: jinja
    - require:
      - pkg: elasticsearch=6.2.4
      - file: elasticsearch6_data_dir
    - context: {
        CLUSTER_NAME:                {{ es_config.cluster_name }},
        NODE_NAME:                   {{ salt['pillar.get']('machine_name', grains['id']) }},
        PATH_DATA:                   {{ es_config.path_data }},
        PATH_LOGS:                   {{ es_config.path_log }},
        {% if grains['machine_role'] is defined %}
          MACHINE_IP: {{ salt['grains.get']('ip4_interfaces:eth0', ['127.0.1.1'])|first() }},
        {% else %}
          MACHINE_IP: {{ salt['grains.get']('fqdn_ip4', ['127.0.1.1'])|first() }},
        {% endif %}
        UNICAST_HOSTS:               {{ es_config.unicast_hosts }},
        MIN_MASTER_NODES:            {{ es_config.min_master_nodes }}

    }

elasticsearch6_data_dir:
  file.directory:
    - name: {{ es_config.path_data }}
    - makedirs: True
    - user: elasticsearch
    - group: elasticsearch
    - mode: 755

elasticsearch6_privileges:
  cmd.run:
    - name: "chown -R elasticsearch:elasticsearch {{ es_config.path_data }}"
    - require:
      - pkg: elasticsearch=6.2.4

elasticsearch6_log_dir:
  file.directory:
    - name: {{ es_config.path_log }}
    - makedirs: True
    - user: elasticsearch
    - group: elasticsearch
    - mode: 755

elasticsearch-log4j:
  file.managed:
    - name: /etc/elasticsearch/log4j2.properties
    - source:
      - salt://wazuh-elk/files/log4j2.properties
    - template: jinja
    - makedirs: True
    - mode: 664
    - watch:
      - pkg: elasticsearch6_install

elasticsearch-jvm:
  file.managed:
    - name: /etc/elasticsearch/jvm.options
    - source:
      - salt://wazuh-elk/files/jvm.options
    - template: jinja
    - makedirs: True
    - mode: 664
    - watch:
      - pkg: elasticsearch6_install


elasticsearch6_service:
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - pkg: elasticsearch=6.2.4
    - watch:
      - file: elasticsearch6_config
      - file: elasticsearch6_data_dir
      - file: elasticsearch6_log_dir
      - file: elasticsearch-log4j
      - file: elasticsearch-jvm
      - cmd: elasticsearch6_privileges
