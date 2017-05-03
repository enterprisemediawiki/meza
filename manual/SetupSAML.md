Setting up SAML authentication
==============================

## Step 1: Set secret config

Add the following to your secret config. This can be found at `/opt/conf-meza/secret/<env>/group_vars/all.yml` where `<env>` is your environment name (e.g. "monolith" or "production" or whatever you chose). Pick good strong passwords and salt below. See comments.

```yaml
saml_secret:

  # A crypto salt for randomness. This should be random and unique. Use the
  # command below to generate a 32-character random string
  # tr -c -d '0-9a-zA-Z' </dev/urandom | dd bs=32 count=1 2>/dev/null;echo
  salt: <output of command from above>

  # A password to enter the SimpleSamlPhp web interface. Optionally use the
  # 16-character random generator below:
  # tr -c -d '0-9a-zA-Z' </dev/urandom | dd bs=16 count=1 2>/dev/null;echo
  adminpassword: <your strong password>
```

## Step 2: Set public config

Add the following to your public config, located at `/opt/conf-meza/public/vars.yml`. Fill in appropriate values for everything. You'll need to confer with your SAML Identity Provider for correct values.

```yaml
saml_public:

  #
  # MediaWiki
  #

  # SAML attribute provided by IdP (Identity Provider) to map to MediaWiki username
  idp_username_attr: uid

  # SAML attribute provided by IdP to map to MediaWiki real name
  idp_realname_attr: fullname

  # SAML attribute provided by IdP to map to MediaWiki email address
  idp_email_attr: email


  #
  # SAML IdP (identity provider) and SP (service provider) info
  #

  # SP (service provider) ID, which should be the fully qualified domain name
  # of your application
  sp_entity_id: https://yourapp.example.com

  # Constraints on SAML request which may be required by IdP
  name_id_policy: "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"

  # Method to identify your IdP (identity provider). The URL is sufficient
  idp_entity_id: https://auth.example.com

  # URL of your SAML signon service
  single_sign_on_service: https://saml.example.com/signon

  # URL of your SAML logout service. Use signon if you don't have one.
  single_logout_service: https://saml.example.com/signout

  # Cert fingerprint for your saml IdP (identity provider) server. Should be a
  # list to support multiple values.
  cert_fingerprint:
  - "2LK3JWJKL23KLJRWEJKLWKEFWKJEFKWJDLSFJSLK" # old fingerprint
  - "4WTKAGJ34QLWKAEGLKQ4WTEAGKQ34LKWALKQ4WTE" # new fingerprint


  #
  # Other info
  #

  # Contact info for issues with SAML
  technicalcontact_name: Administrator
  technicalcontact_email: admin@example.com
```

## Step 3: Re-deploy

With the new config in place, you need to re-deploy your desired environment:

```
sudo meza deploy <env>
```
