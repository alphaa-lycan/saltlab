base:
  'master':
    - dnsmasq
  'apache*':
    - nginx
  'salt-minion*':
    - java8
    - wazuh-elk
    - wazuh-elk.logstash
    - wazuh-elk.htpasswd
