ansible-firewalld-role
=========

**This role was adapted from https://github.com/FlatKey/ansible-firewalld-role commit 34bd5db4**

Allows you to configure firewalld.

Config options:
* default zone
* interface of a zone
* source of a zone
* service rules
* port rules
* rich rules

Requirements
------------

Tested on RHEL 7 and CentOS 7 only.

Ansible 2.0 or above

Role Variables
--------------
**It is not necessary to use all these variable blocks, you can use only the config options you really need.**


The following variable is used to define the default zone of firewalld:

```
    default_zone: (optional, default: public)
```

---

The following variables are used to define the interface of a zone:

```
    firewalld_zone_interface:
      public: (required, e.g. eth0)
```

---

The following variables are used to define the source of a zone:

```
    firewalld_zone_source:
      public:
        source: (required, e.g. "192.168.1.0/24")
        state: (optional, only values: enabled|disabled, default: enabled)
        permanent: (optional, only values: true|false, default: true)
        immediate: (optional, only values: true|false, default: true)
```

---

The following variables are used to define a service rule:

```
    firewalld_service_rules:
      service:
        state: (optional, only values: enabled|disabled, default: enabled)
        zone: (optional, default: public)
        permanent: (optional, only values: true|false, default: true)
        immediate: (optional, only values: true|false, default: true)
```

---

The following variables are used to define a port rule:

```
    firewalld_port_rules:
      name:
        port: (required, port or port range)
        protocol: (optional, only values: tcp|udp, default: tcp)
        state: (optional, only values: enabled|disabled, default: enabled)
        zone: (optional, default: public)
        permanent: (optional, only values: true|false, default: true)
        immediate: (optional, only values: true|false, default: true)
```

---

The following variables are used to define a rich rule:

```
    firewalld_rich_rules:
      name:
        rule: (required, a complete rule in firewalld rich language)
        state: (optional, only values: enabled|disabled, default: enabled)
        zone: (optional, default: public)
        permanent: (optional, only values: true|false, default: true)
        immediate: (optional, only values: true|false, default: true)
```

Handlers
--------

These are the handlers that are defined in this role:

* restart firewalld

Example Playbook
----------------

```
    - hosts: server
      become: yes
      become_user: root
      become_method: su
      roles:
        - ansible-firewalld-role
      vars:
        default_zone: public
        firewalld__zone_interface:
          public: eth0
          internal: eth1
        firewalld_zone_source:
          trusted:
            source: "192.168.1.0/24"
            state: enabled
            permanent: true
            immediate: true
        firewalld_service_rules:
          ssh:
            state: enabled
            zone: public
            permanent: true
            immediate: true
        firewalld_port_rules:
          smtp:
            port: 25
            protocol: tcp
            state: enabled
            zone: public
            permanent: true
            immediate: true
        firewalld_rich_rules:
          ftp_audit:
            rule: 'rule service name="ftp" audit limit value="1/m" accept'
            state: enabled
            zone: public
            permanent: true
            immediate: true
```

License
-------

MIT

