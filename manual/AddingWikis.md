# Adding Wikis

This manual explains how to add wikis to your meza install. There are two methods for adding wikis:

1. Creating a new wiki from scratch
2. Importing one or more wikis

## Creating a new wiki

To create a new wiki, perform the following where `<env>` is your environment name (probably `monolith`):

```bash
sudo meza create wiki <env>
```

This script will then ask for three inputs:

2. *Wiki ID*: This is an alphanumeric identifier for your wiki. It will be used in the URL (like `http://example.com/yourID`), and throughout the server configuration. It should be something short and simple. For example, if you're creating a wiki for your Human Resources department, a good wiki ID would be "hr". All lowercase is preferred.
3. *Wiki Name*: This should be a more descriptive title for your wiki. It still should not be too long, though. For the same example you may choose "Human Resources Wiki" or "HR Wiki"

### Creating a wiki user

With a new wiki, you'll probably want to create a new user. In the following example, you would be creating the user "Jdoe" on the wiki with the ID "mywiki" and the password "mypassword". Once your user account is set up, this user's password can be modified using Mediawiki's user profile page in the user settings. See MediaWiki's docs for [createAndPromote.php](https://www.mediawiki.org/wiki/Manual:CreateAndPromote.php) for more info.

```bash
WIKI=mywiki php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --bureaucrat --sysop --custom-groups=Contributor Jdoe mypassword
```

## Importing existing wikis

Importing wikis is done by either defining servers as sources for import files, or by positioning files on your server in the correct location, then simply running `sudo meza deploy <env>`.

### Importing wikis directly from another server

*This documentation requires more info here*, but some info can be found in [Pull Request #547](https://github.com/enterprisemediawiki/meza/pull/547) and [Issue #548](https://github.com/enterprisemediawiki/meza/issues/548).

### Creating the import directory

If you would like to manually put files on your server to be used in an import, you'll need to put those files in the correct location in `/opt/data-meza/backups`. *This documentation requires more info here*. To get an idea of how the directory should look, try backing up your Demo Wiki by running `sudo meza backup <env>` and then looking at the directory structure.

### Transferring your files to your wiki

To transfer files to your server you can use SCP (or PSCP on Windows):

```
(p)scp -r /path/to/your/wiki/imports user@example.com:/home/user/wikis
```

## Making a wiki the "primary" wiki

A wiki can be setup as the "primary" wiki. This means that all other wikis will use its user and interwiki tables. If all wikis are related, and are going to have similar users, you should do this. To make one wiki the primary wiki edit your configuration:

```yaml
primary_wiki_id: big
```

In this example the wiki with ID "big", and thus database name "wiki_big", is being defined as the primary wiki. This statement can be added to any configuration YAML file, but the recommended is `/opt/conf-meza/public/public.yml`.

## Unify user tables

*WARNING: Test user-unification extensively before performing in production"

If you run `unifyUserTables.php` on a set of wikis that do not share user and interwiki tables, the script will automatically setup the `primewiki` file for you (FIXME: this probably is not true anymore). To run `unifyUserTables.php` perform the following:

```bash
WIKI=anywiki php /opt/meza/src/scripts/unifyUserTables.php --prime-wiki=anotherwiki
```

In this case above you need to specify any existing wiki at the beginning. This is simply so LocalSettings.php will load properly. Any of your existing wikis will do. After the `--prime-wiki=` add the wiki ID of the wiki you want to be prime.
