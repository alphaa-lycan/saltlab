{% set TIMEZONE = salt['pillar.get']('timezone', 'Asia/Kolkata') %}

set_timezone:
  timezone.system:
    - name: {{ TIMEZONE }}

{% for host, ip in salt['pillar.get']('host', {}).items() %}
{{ host }}:
  host.present:
    - ip: {{ ip }}

{% endfor %}
