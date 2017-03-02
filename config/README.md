Meza configuration directories
==============================

/opt/meza/config/env
--------------------

Not yet setup here. Currently in `/opt/meza/ansible/env`. This is the location of secure configuration items for one or more environments. These may be named anything, but typical names include:

* `monolith`: This is the only special name with any real significance. It means a single server configured with all groups on the controlling machine. It is special because attempting to deploy a `monolith` environment if one doesn't already exist will generate the monolith environment. All other environments need to be set up prior to attempting to deploy them
* `prod`: Production environment
* `stage`: Staging environment
* `test`: Test environment
* `dev`: A


/opt/meza/config/local_control
------------------------------



/opt/meza/config/local_app
--------------------------



/opt/meza/config/i18n
---------------------



/opt/meza/config/baselines
--------------------------


