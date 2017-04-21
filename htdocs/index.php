<?php

// if there's a SAML config file, we need to authenticate with SAML, like, now.
if ( is_file("/opt/meza/config/core/app-ansible/SAMLConfig.php") ) {
	require_once __DIR__ . '/NonMediaWikiSimpleSamlAuth.php';
}

require_once "WikiBlender/index.php";
