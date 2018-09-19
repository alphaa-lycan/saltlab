sector: INDIA
timezone: Asia/Kolkata

hosts:
  salt-minion:        10.154.223.196

roles:
  - common
  - java8
  - wazuh-elk

elasticsearch_config:
  cluster_name:       wazuh-elk
  path_data:          /cryptfs/elasticsearch/data
  path_log:           /var/log/elasticsearch
  unicast_hosts:      ["10.154.223.196","10.154.223.244"]
  elastic_hosts:      ["10.154.223.196:9200","10.154.223.244:9200"]
  kibana:             10.154.223.196
  min_master_nodes:   1

server:
  enabled: true
  user:
    username1:
      enabled: true
      password: magicunicorn
      htpasswd: htpasswd-site1
    username2:
      enabled: true
      password: magicunicorn

