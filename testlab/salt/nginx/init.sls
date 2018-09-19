# Package Directory

/local/softwares:
  file:
    - directory
    - user: root
    - group: root
    - makedirs: True


{% for files in ('libgd3_2.1.1-4ubuntu0.16.04.10_amd64.deb','libxpm4_1%3a3.5.11-1ubuntu0.16.04.1_amd64.deb','libvpx3_1.5.0-2ubuntu1_amd64.deb','nginx-core_1.10.3-0ubuntu0.16.04.2_amd64.deb','nginx-common_1.10.3-0ubuntu0.16.04.2_all.deb','nginx_1.10.3-0ubuntu0.16.04.2_all.deb') %}
copy_nginx_packages_{{ files }}:
  file.managed:
    - name: /local/softwares/{{ files }}
    - source: salt://{{ files }}
    - user: root
    - group: root
    - mode: 755

installing_packages_{{ files }}:
  cmd.run:
    - cwd: /local/softwares
    - name: 'dpkg -i {{ files }}'

{% endfor %}

