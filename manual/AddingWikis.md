# Adding Wikis

This manual explains how to add wikis to your meza install. There are two methods for adding wikis:

1. Creating a new wiki from scratch
2. Importing one or more wikis

## Creating a new wiki

To create a new wiki you use the `create-wiki.sh` script.

```bash
sudo bash create-wiki.sh
```

This script will then ask for three inputs:

1. *MySQL root password*: The password for your MySQL root user
2. *Wiki ID*: This is an alphanumeric identifier for your wiki. It will be used in the URL (like `http://example.com/yourID`), and throughout the server configuration. It should be something short and simple. For example, if you're creating a wiki for your Human Resources department, a good wiki ID would be "hr". All lowercase is preferred.
3. *Wiki Name*: This should be a more descriptive title for your wiki. It still should not be too long, though. For the same example you may choose "Human Resources Wiki" or "HR Wiki"

### Creating a wiki user

With a new wiki, you'll probably want to create a new user. In the following example, you would be creating the user "Jdoe" on the wiki with the ID "mywiki" and the password "mypassword". Once your user account is set up, this user's password can be modified using Mediawiki's user profile page in the user settings.

```bash
WIKI=mywiki php mezaCreateUser.php --username=Jdoe --password=mypassword
```

## Importing existing wikis

To import one more more existing wikis you use the `import-wikis.sh` script.

```bash
sudo bash import-wikis.sh
```

This script will ask for two inputs:

1. *Import directory*: The directory where all your files for import are located. See below for more details.
2. *MySQL root password*: The password for your MySQL root user

### Creating the import directory

Your import directory should be called something like "wikis" and should have directories within it each named with a wiki identifier. So if you had wikis for your Human Resources (hr), Sales (sales) and Engineering (eng) departments, you may have a setup like this:

```
wikis
	hr
	sales
	eng
```

If you have this directory in root's user directory, you would enter `/root/wikis/` for step 1 above. Note that using `~/wikis/` doesn't seem to work, but if you're using a user other than root with sudo rights you could use `/home/username/wikis/`.

Each of these identifiers will be used throughout meza, but the place you'll notice it most is in your URLs. For example, your Engineering Department's wiki may be at `https://example.com/eng`.

Within each of these directories you put each wiki's information. This includes the `images` directory and a `wiki.sql` file to build your database, as well as an optional `config` directory. The `eng` directory may look like this:

```
eng
	images
	config
		logo.png
		favicon.ico
		preLocalSettings.php
		postLocalSettings.php
	wiki.sql
```

The `images` directory should be directly copied from your current wiki.

The contents of `config` are as follows:

* `logo.png` is the image that is displayed in the top-right of your wiki.
* `favicon.ico` is the wikis [favicon](https://en.wikipedia.org/wiki/Favicon).
* `preLocalSettings.php` has some meza-specific configuration variables in it. If you don't already have this file, let the install process generate one for you.
* `postLocalSettings.php` will also be auto-generated. It contains any settings specific to this particular wiki, different from your other wikis. Ideally it should be blank (keep all your wikis configured the same way).

The `wiki.sql` file is what will build your database. You can generate this file by running the `mysqldump` command on your current wiki. The command may look something like: `mysqldump -u my_username -p my_database > /path/to/your/output/file.sql`

### Transferring your files to your wiki

To transfer files to your server you can use SCP (or PSCP on Windows):

```
(p)scp -r /path/to/your/wiki/imports user@example.com:/home/user/wikis
```

### Using an import config file

If you don't want to enter prompts during import (e.g. if you're scripting your import), you'll want to use a config file. That file needs to be located at `/opt/meza/config/local/import-config.sh`. An example file can be found at [config/template/import-config.sh](../config/template/import-config.sh). Moving that file to `config/local` and modifying the values is all that is required. Then running `sudo bash /opt/meza/scripts/import-wikis.sh` will recognize the config file and use your values.


## Importing wikis directly from another server

This process can be used to import wikis from some types of servers. The authors of this script have only tested it where the remote server is running Windows.

1. `cd /opt/meza/config/local`
2. Create `config/local/import-config.sh` by doing one of the following:
  1. `sudo cp /opt/meza/config/template/import-config.example.sh ./import-config.sh` and editing the file
  2. `sudo vi import-config.sh` and pasting in your pre-built config
3. `cd /opt/meza/scripts`
4. `sudo bash import-remote-wikis.sh`. You should only need to enter your username and password for the remote server if you filled `import-config.sh`


## Making a wiki the "primary" wiki

A wiki can be setup as the "primary" wiki. This means that all other wikis will use its user and interwiki tables. If all wikis are related, and are going to have similar users, you should do this. To make one wiki the primary wiki simply add a file called "primewiki" to the `config/local` directory:

```bash
cd /opt/meza/config/local
echo "wiki-id" > primewiki
```

In this example "wiki-id" is the ID of the wiki you want to be primary.

Note that if you run `unifyUserTables.php` on a set of wikis that do not share user and interwiki tables, the script will automatically setup the `primewiki` file for you. To run `unifyUserTables.php` perform the following:

```bash
WIKI=anywiki php /opt/meza/scripts/unifyUserTables.php --prime-wiki=anotherwiki
```

In this case above you need to specify any existing wiki at the beginning. This is simply so LocalSettings.php will load properly. Any of your existing wikis will do. After the `--prime-wiki=` add the wiki ID of the wiki you want to be prime.
