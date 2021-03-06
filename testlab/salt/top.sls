base:
  'master':
    - dnsmasq
  'apache*':
    - nginx
  'roles:common':
    - match: pillar
    - common
  'roles:wazuh-elk':
    - match: pillar
    - wazuh-elk
  'roles:java8':
    - match: pillar
    - java8
