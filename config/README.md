Meza configuration directories
==============================

/opt/meza/config/local-secret
-----------------------------

Contains secret information about environments managed by meza. This includes the list of hosts for each environment (IP addresses and what they're assigned to) as well as passwords and other secret information.

* `monolith`: This is the only special name with any real significance. It means a single server configured with all groups on the controlling machine. It is special because attempting to deploy a `monolith` environment if one doesn't already exist will generate the monolith environment. All other environments need to be set up prior to attempting to deploy them
* `prod`: Production environment
* `stage`: Staging environment
* `test`: Test environment
* `dev`: A


/opt/meza/config/local-public
-----------------------------

This contains non-secret information about environments. This includes TBD.


/opt/meza/config/local_app
--------------------------



/opt/meza/config/i18n
---------------------



/opt/meza/config/baselines
--------------------------


