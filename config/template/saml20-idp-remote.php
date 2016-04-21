<?php
/**
 * SAML 2.0 remote IdP metadata for SimpleSAMLphp.
 *
 * Remember to remove the IdPs you don't use from this file.
 *
 * See: https://simplesamlphp.org/docs/stable/simplesamlphp-reference-idp-remote
 *
 * This file is to be moved to /opt/meza/simplesamlphp/metadata/saml20-idp-remote.php
 * with values filled in by saml.sh script.
 */

$metadata['idp_entity_id'] = array(
    'SingleSignOnService'  => 'sign_on_url',
    'SingleLogoutService'  => 'logout_url',
    'certFingerprint'      => 'cert_fingerprint',
);
