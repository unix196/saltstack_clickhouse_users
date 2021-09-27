{% from 'clickhouse/map.jinja' import clickhouse %}

clickhouse-group:
  group.present:
    - name: {{ clickhouse.group }}

clickhouse-user:
  user.present:
    - name: {{ clickhouse.user }}
    - uid: {{ clickhouse.uid }}
    - shell: /bin/bash
    - groups:
        - {{ clickhouse.group }}
    - require:
      - group: clickhouse-group

clickhouse-log-dir:
  file.directory:
    - name: {{ clickhouse.log_dir }}
    - user: {{ clickhouse.user }}
    - group: {{ clickhouse.group }}
    - makedirs: True
    - require:
        - user: clickhouse-user

clickhouse-database-dir:
  file.directory:
    - name: {{ clickhouse.database_dir }}
    - user: {{ clickhouse.user }}
    - group: {{ clickhouse.group }}
    - makedirs: True
    - dir_mode: 775
    - require:
        - user: clickhouse-user

file-users.xml:
  file.managed:
    - name:       {{ clickhouse.config_dir }}/users.xml
    - source:     salt://clickhouse/files/clickhouse-server/users.xml
    - user:       {{ clickhouse.user }}
    - group:      {{ clickhouse.group }}
    - makedirs:   True
    - mode:       664
    - template:   jinja
    - require:
        - user: clickhouse-user

{# https://github.com/saltstack/salt/issues/24099 #}
docker-users.xml:
  module.run:
    - docker.copy_to:
      - name: 'clickhouse'
      - source:      '/etc/clickhouse-server/users.xml'
      - dest:        '/etc/clickhouse-server/users.xml'
      - overwrite:   'False'
      - exec_driver: 'docker-exec'
    - onchanges:
      - file: file-users.xml
    - onlyif:
      - docker inspect -f {% raw %} "{{.State.Running}}" {% endraw %} {{ clickhouse.docker.container.name }}
