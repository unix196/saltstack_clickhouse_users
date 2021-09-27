{% from 'clickhouse/map.jinja' import clickhouse %}

{# receive credentials for connect to CH from vault #}
{% set admin = "super_user" %}
{% set password = salt['vault'].read_secret("clickhouse/users/super_user", "password") %}
{# or you can specify password for connect to CH in plain text #}

{#
clickhouse_databases:
  module.run:
    - clickhouse.databases:
      - host: localhost
      - user: {{ admin }}
      - password: {{ password }}
      - port: {{ clickhouse.config.port }}
#}

{% for user, user_properties in clickhouse.config.users.users.sql.items() %}

clickhouse_user_create_{{ user }}:
  module.run:
    - clickhouse.user_create:
      - username: {{ user }}
      - password_hash: {{ user_properties.password_sha256_hex }}
      - profile: {{ user_properties.profile }}
      - host: localhost
      - user: {{ admin }}
      - password: {{ password }}
      - port: {{ clickhouse.config.port }}

  {% if user_properties.databases_privileges is defined %}
  {% for database, privileges in user_properties.databases_privileges.items() %}


  {% if privileges.downgrade_privileges is defined and privileges.downgrade_privileges == True %}
revoke_all_privileges-{{ user }}:
  module.run:
    - clickhouse.revoke_privileges:
      - username: {{ user }}
      - host: localhost
      - user: {{ admin }}
      - password: {{ password }}
      - port: {{ clickhouse.config.port }}
  {% endif %}

"clickhouse_privileges_grant_for_{{ user }}_to_{{ database.split('.')[0] }}":
  module.run:
    - clickhouse.privileges_grant:
      - username: {{ user }}
      - database_grant: "{{ database }}"
      - grant: {{ privileges.present }}
      - host: localhost
      - user: {{ admin }}
      - password: {{ password }}
      - port: {{ clickhouse.config.port }}

  {% endfor %}
  {% endif %}

{% endfor %}

{#
clickhouse_users:
  module.run:
    - clickhouse.user_list:
      - host: localhost
      - user: {{ admin }}
      - password: {{ password }}
      - port: {{ clickhouse.config.port }}
#}
