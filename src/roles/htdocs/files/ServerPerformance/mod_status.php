<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Meza Server Status</title>
</head>
<body><?php

	require_once '/opt/.deploy-meza/config.php';

	// if there's a SAML config file, we need to authenticate with SAML, like, now.
	if ( is_file( "$m_deploy/SAMLConfig.php" ) ) {

		// Use SimpleSamlAuth emulator to get user ID
		require_once "$m_htdocs/NonMediaWikiSimpleSamlAuth.php";
		$as = new SimpleSAML_Auth_Simple('default-sp');
		$as->requireAuth();
		$attributes = $as->getAttributes();
		$userID = $attributes[ $saml_idp_username_attr ][0];

		if ( in_array( $userID, $server_admins ) ) {
			echo "<h1>Welcome, $userID</h1>";
			echo file_get_contents( 'http://127.0.0.1:8090/server-status' );
		}
		else {
			header('HTTP/1.0 403 Forbidden');
			echo "You do not have access to this page.";
		}

	}
	else {
		header('HTTP/1.0 403 Forbidden');
		echo "Without SAML configured, meza does not currently allow access to server-status";
	}

?></body>
</html>
