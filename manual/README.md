`meza deploy` can be run to:

1. Initially install everything
1. Continue installing if an error occurs during install
   
   This happens ~2.5% of the time due to connections failing (e.g. git failures) and ~2.5% of the time due to some Parsoid restart issue that has only been seen in Travis Continuous Integration builds, not locally (I think). Ref [Issue #604](https://github.com/enterprisemediawiki/meza/issues/604)
1. To apply changes after modifying configuration
1. To apply changes after pulling a new version of meza (e.g. cd /opt/meza && sudo git fetch origin && sudo git reset --hard origin/master)
1. Maybe more scenarios

Perhaps another way to say it is that meza uses Ansible's way of thinking about things: instead of each step being in the form "install X" it is in the form "ensure X is installed'. The former cannot be performed more than once, but the latter can (aka [idempotency](http://restcookbook.com/HTTP%20Methods/idempotency/))

See [Meza Commands](manual/commands.md) for more detail on using meza.
