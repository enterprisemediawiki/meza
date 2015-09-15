<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Meza1 Wikis</title>

    <!-- Bootstrap -->
    <!-- <link rel="stylesheet" href="bootstrap-3.3.5/css/bootstrap.min.css"> -->

    <!-- Optional theme -->
    <!-- <link rel="stylesheet" href="bootstrap-3.3.5/css/bootstrap-theme.min.css"> -->

    <!-- Application CSS -->
    <!-- <link rel="stylesheet" href="main.css"> -->

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

  </head>
  <body>
  	<h1>Meza1 Wikis</h1>
  	<p>Below are all the wikis currently installed on this server.</p>
  	<ul>
<?php

	$wikis = array_slice( scandir( '/var/www/meza1/htdocs/wikis' ), 2 );

	foreach( $wikis as $wiki ) {
		echo "<li><a href='$wiki'>$wiki</a></li>";
	}

?>

    <!-- jQuery and jQuery UI -->
    <!-- <script src="jquery.min.js"></script> -->
    <!-- <script src="jquery-ui/jquery-ui.min.js"></script> -->

    <!-- Bootstrap JS -->
    <!-- <script src="bootstrap-3.3.5/js/bootstrap.min.js"></script> -->

    <!-- Main application JS file -->
    <!-- <script src="mult.js"></script> -->
	</ul>
  </body>
</html>