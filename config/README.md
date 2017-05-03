Meza configuration directories
==============================

/opt/conf-meza/secret
---------------------

Contains secret information about environments managed by meza. This includes the list of hosts for each environment (IP addresses and what they're assigned to) as well as passwords and other secret information.

* `monolith`: This is the only special name with any real significance. It means a single server configured with all groups on the controlling machine. It is special because attempting to deploy a `monolith` environment if one doesn't already exist will generate the monolith environment. All other environments need to be set up prior to attempting to deploy them
* `prod`: Production environment
* `stage`: Staging environment
* `test`: Test environment
* `dev`: A


/opt/conf-meza/public
---------------------

This contains non-secret information about environments. This includes TBD.


/opt/.deploy-meza/public
------------------------

A copy of `/opt/conf-meza/public` (confirm perfect copy? Doesn't include `.git` for speed purposes) which is accessible to app servers regardless of whether the app server is the controller (`/opt/conf-meza/public` is only present on the controller).


/opt/meza/config/core
---------------------

Core configuration for meza. This shouldn't be edited, but can be overridden in the above directories. May get renamed `/opt/meza/config` or `/opt/meza/core.conf` or something since there's not really anything else in `/opt/meza/config` currently (besides this file).
