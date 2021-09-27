
clickhouse:
  docker:
    image:
      name: yandex/clickhouse-server
  config:
    port: 9000
    users:
      profiles:
        default:
          legacy_column_name_of_tuple_literal: 1
          load_balancing: in_order
        read:
          readonly: 1
        graphite:
          log_queries: 1
      users:
        xml:
          super_user:
            password_sha256_hex: 65e84be33532fb784c48129675f9eff3a682b27168c0ea744b2cf58ee02337c5 {# https://clickhouse.com/docs/en/operations/settings/settings-users/ #}
            networks:
              ips: ['::/0']
            profile: default
            quota: default
            access_management: 1
        sql:
          user1:
            password_sha256_hex: 65e84be33532fb784c48129675f9eff3a682b27168c0ea744b2cf58ee02337c5
            networks:
              ips: ['::/0']
            profile: default
            quota: default
            databases_privileges:
              "*.*":
                present: SHOW DATABASES, dictGet
              "test_db1.*":
                {# downgrade_privileges: True #}
                present: ALL
              "tmp.*":
                present: ALL
          user2:
            password_sha256_hex: 65e84be33532fb784c48129675f9eff3a682b27168c0ea744b2cf58ee02337c5
            networks:
              ips: ['::/0']
            profile: default
            quota: default
            databases_privileges:
              "*.*":
                present: SHOW DATABASES, dictGet, SOURCES
              "test_db2.*":
                present: ALL
              "test_db3.table_1":
                present: SELECT
