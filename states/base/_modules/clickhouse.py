
# -*- coding: utf-8 -*-

import logging
from clickhouse_driver import Client
log = logging.getLogger(__name__)

def databases(host,user,password,database="default",port=9000):
    """
    Return list of databases.
    Required arguments: host, user,password
    host - address CH
    user - user for auth on CH
    password - password for auth on CH
    Example command for run from CLI:
    salt-call clickhouse.databases "host=localhost" "user=SOME_USER" "password=SOME_PASSW"
    """
    client = Client(host,user=user,password=password, database=database,port=port)
    query = client.execute('SHOW DATABASES')
    return query


def user_list(host,user,password,database="default",port=9000):
    """
    Return list of users
    Required arguments: host, user,password
    host - address CH
    user - user for auth on CH
    password - password for auth on CH
    Example command for run from CLI:
    salt-call clickhouse.databases "host=localhost" "user=SOME_USER" "password=SOME_PASSW"
    """
    client = Client(host,user=user,password=password, database=database,port=port)
    query = client.execute('SHOW USERS')
    return query


def user_create(username,password_hash,profile,host,user,password,database="default",port=9000):
    """
    Create user in Clickhouse database
    Required arguments: username, password_hash, profile, host, user, password
    host - address CH
    user - user for auth on CH
    password - password for auth on CH
    username - user, which need create
    password_hash - password hash for new user (https://clickhouse.tech/docs/en/operations/settings/settings-users/#user-namepassword)
    profile - settings profile for user (https://clickhouse.tech/docs/en/operations/settings/settings-profiles/)
    """
    client = Client(host,user=user,password=password, database=database,port=port)
    sql_query = "CREATE USER IF NOT EXISTS {} IDENTIFIED WITH sha256_hash BY '{}' SETTINGS PROFILE '{}'"
    query = client.execute(sql_query.format(username,password_hash,profile))
    if query == []:
        return  "OK: successful create user"


def privileges_grant(username,database_grant,grant,host,user,password,database="default",port=9000):
    """
    Add grants to user in Clickhouse
    Required arguments: username, database_grant, grant, host, user,password
    host - address CH
    user - user for auth on CH
    password - password for auth on CH
    username - user for which we assign rights
    database_grant  - template in format database.table ("test2.*")
    grant - which rights add to user (SELECT, INSERT/etc)

    """
    client = Client(host,user=user,password=password, database=database,port=port)
    sql_query = "GRANT {} ON {} TO {}"
    query = client.execute(sql_query.format(grant,database_grant,username))
    if query == []:
        return  "OK: successful grant privileges to user"



def revoke_privileges(username,host,user,password,database="default",port=9000):
    """
    Revoke all grants
    Required arguments: username, database_grant, grant, host, user,password
    host - address CH
    user - user for auth on CH
    password - password for auth on CH
    username - user for which we revoke rights
    """
    client = Client(host,user=user,password=password, database=database,port=port)
    sql_query = "REVOKE ALL PRIVILEGES  ON *.* FROM {}"
    query = client.execute(sql_query.format(username))
    if query == []:
        return  "OK: successful revoke privileges from user"
