
 Primitive module for configure users in Clickhouse database using _sql mode_. Until recently users in Clickhouse were configured via _xml file_, which doesn't allow fine configuring permissions, like in mysql or postgresql. In fresh versions Clickhouse allows you to configure users through the familiar _sql mode_.

* `clickhouse.config` - create users.xml (https://clickhouse.com/docs/en/operations/settings/settings-users/). Create only super account with option `access_management: 1`.
* `clickhouse.users` - create users using sql mode (https://clickhouse.com/docs/en/operations/access-rights/#access-control). This state run simple self-written clickhouse module.

*  _Clickhouse_ module requires `clickhouse-driver` python package for his work.

* Sync execution modules from _salt://_modules_ to minion:
You must place _clickhouse.py_ here:

```sh
/etc/salt/master.d/f_defaults.conf:
...
file_roots:
  base:
  - /srv/salt/base
  ...

master# ls -1 /srv/salt/base/_modules/
clickhouse.py

```
`salt-call saltutil.sync_modules` - copy self-written module from salt master to salt minion.
default minion cachedir - `/var/cache/salt/minion` (https://docs.saltproject.io/en/3000/ref/configuration/minion.html#cachedir)
On minion clickhouse module will be located here (debian-based OS):

```sh
minion# ls -1 /var/cache/salt/minion/extmods/modules/
clickhouse.py
```

* How to understand what rights current users needs (thank's our programmers :) ):
```sh
select
       initial_user,
       user,
       arrayFilter(x -> notEmpty(x), groupUniqArray(query_kind)) op,
       arrayDistinct(arrayFlatten(groupUniqArray(databases))) db
from system.query_log
where notEmpty(user)
GROUP BY initial_user, user;
```
This query can provide information for migration from xml to user mode in existing Clickhouse installation.


| initial_user |	user |	op |
| ------------ | ----- | --- |
|user1 |	user1 |	['SELECT','INSERT'] |
|user2 |	user2 | ['SELECT'] |
|user3 |	user3 |	['SELECT','SHOW','INSERT'] |
|user4 |	user4 |	['SELECT','INSERT'] |
|user5 |	user5 |	['INSERT'] |
