#!/bin/sh
#
# Config variables for saml.sh
# put at /opt/meza/config/local/saml-setup-config.sh


# saml_admin
saml_admin="John Doe"

# saml_admin_email
saml_password="password"

# saml_admin_email
saml_admin_email="you@example.com"

# idp_entity_id
idp_entity_id="https://auth.example.com"

# sign_on_url
sign_on_url="https://auth.example.com/saml/login"

# logout_url:
logout_url="https://auth.example.com/saml/logout"

# cert_fingerprint
cert_fingerprint="23580923AEF6759B97E98797F9777AD9D967FC97"

# sp_entity_id: your application's fully qualified domain name
sp_entity_id="https://app.example.com"

# name_id_policy
name_id_policy="urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"

# username_attr: attribute your IdP uses for user ID
username_attr="userid"

# realname_attr: attribute your IdP uses for a user's full name
realname_attr="fullname"

# email_attr: attribute your IdP uses for a user's email address
email_attr="email"
