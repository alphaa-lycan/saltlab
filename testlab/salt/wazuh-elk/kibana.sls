{% set es_config = pillar.get('elasticsearch_config', []) %}

kibana_repo:
  pkgrepo.managed:
    - name: deb https://artifacts.elastic.co/packages/6.x/apt stable main
    - file: /etc/apt/sources.list.d/elastic-6.x.list
    - key_url: salt://elasticsearch-6/files/elasticsearch.key

kibana_install:
  pkg.installed:
    - name: kibana=6.2.4

{% if not salt['file.directory_exists' ]('/usr/share/kibana/plugins/wazuh') %}
kibana_config:
  cmd.run:
    - name: 'sudo -u kibana /usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/wazuhapp/wazuhapp-3.3.1_6.2.4.zip'
    - require:
      - pkg: kibana_install
{% else %}
  cmd.run:
    - name: echo "Wazuh-plugin already installed"
{% endif %}

kibana_nodejs:
  cmd.run:
    - name: 'export NODE_OPTIONS="--max-old-space-size=3072"'
    - require:
      - pkg: kibana_install

kibana_file:
  file.managed:
    - name: /etc/kibana/kibana.yml
    - source: salt://wazuh-elk/files/kibana.yml
    - user: kibana
    - group: kibana
    - template: jinja
    - context: {
        KIBANA: {{ es_config.kibana }}
  }
    - require:
      - pkg: kibana_install

kibana_service:
  service.running:
    - name: kibana
    - enable: True
    - require:
      - pkg: kibana_install

