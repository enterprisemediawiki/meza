<?php

# Debug
// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);

# hack to prevent notice of undefined constant NS_MAIN from /opt/meza/config/local/preLocalSettings_allWikis.php
define("NS_MAIN", "");

# set timezone
date_default_timezone_set('America/Chicago');

# how many days of data should we display?
if( isset($_REQUEST['days']) && $_REQUEST['days'] > 0 ){
    $daysOfData = $_REQUEST['days'];
} else {
    $daysOfData = 360; // default
}

# ceiling value to keep outlier values from skewing y axis
$ceiling = 100;

require_once "/opt/meza/config/local/preLocalSettings_allWikis.php";
$username = $wgDBuser;
$password = $wgDBpassword;

$servername = "localhost";
$dbname = "server";
$dbtable = "opt_space";

$query = "SELECT
            DATE_FORMAT( datetime, '%Y-%m-%d' ) AS ts,
            space_total,
            space_used,
            (space_total - space_used) AS space_available
        FROM $dbtable
        WHERE DATE_FORMAT(datetime, '%Y-%m-%d') >= DATE_FORMAT(NOW(), '%Y-%m-%d') - INTERVAL $daysOfData DAY
        GROUP BY ts;";

$mysqli = mysqli_connect("$servername", "$username", "$password", "$dbname");

$res = mysqli_query($mysqli, $query);

# Format query results
$data = array();
$variables = array(
    "Space Total"=>"space_total",
    "Space Used"=>"space_used",
    "Space Available"=>"space_available"
    );

// Get max value of space_total, to be used for normalization
while( $row = mysqli_fetch_assoc($res) ){

    $spaceTemp[] = floatval($row['space_total']);

}
$maxSpaceValue = max($spaceTemp);
// for small number of jobs, normalize to 100
if( $maxSpaceValue < 100 ){
    $maxSpaceValue = 100;
}

mysqli_data_seek($res, 0);

// Now pull all the data from the query results and scale as necessary
while( $row = mysqli_fetch_assoc($res) ){

    list($ts, $space_total, $space_used, $space_available
        ) = array($row['ts'], $row['space_total'], $row['space_used'], $row['space_available']);

    foreach( $variables as $varname => $varvalue ){

        if( substr($varvalue,0,5) == "space" ){
            $tempdata[$varvalue][] = array(
                'x' => strtotime($ts) * 1000,       // e.g. from 20160624080000 to 1384236000000
                'y' => (floatval($$varvalue) / 1000) / 1000,  // e.g. from 0.1 to 10
            );
        } else if( $varvalue == "jobs"){
            $tempdata[$varvalue][] = array(
                'x' => strtotime($ts) * 1000,                 // e.g. from 20160624080000 to 1384236000000
                'y' => floatval($$varvalue) * 100 / $maxJobsValue,  // e.g. from 4683 to some value between 0-100 relative to max
            );
        } else {
            $tempdata[$varvalue][] = array(
                'x' => strtotime($ts) * 1000,   // e.g. from 20160624080000 to 1384236000000
                'y' => floatval($$varvalue),    // e.g. 10
            );
        }

        // $tempdata[$varvalue][] = array(
        //     'x' => strtotime($ts) * 1000,   // e.g. from 20160624080000 to 1384236000000
        //     'y' => floatval($$varvalue),    // e.g. 10
        // );

    }

}

mysqli_close($mysqli);


foreach( $variables as $varname => $varvalue ){

    $data[] = array(
        'key'       => $varname,                // e.g. loadavg1
        'values'    => $tempdata[$varvalue],    // e.g. {"x":1384236000000,"y":0.1},{"x":1384256000000,"y":0.2},etc
    );
}


//*
*
* Add data for usage rate trend
*
*/

$numDays = 7;

$prevValue = $data[2]["values"][$numDays]["y"] - $data[2]["values"][0]["y"];

for( $i = $numDays; $i < count($data[2]["values"]); $i++ ){
        
        $value = $data[2]["values"][$i]["y"] - $data[2]["values"][$i - $numDays]["y"];

        if( $value > 0 ){ 
                $value = $prevValue;
        } else {
                $prevValue = $value;
        }

        $tempratedata[] = array(
                'x'     => $data[2]["values"][$i]["x"],
                'y'     => $value,
        );

}


$data[] = array(
        'key'           => "Usage Growth Rate (per week)",
        'values'        => $tempratedata,
);


/*
*
* Produce page
*
*/

$html = '';
$html .= '<div id="server-performance-plot"><svg height="400px"></svg></div>';
$html .= "<script type='text/template-json' id='server-performance-data'>" . json_encode( $data ) . "</script>";

?><!DOCTYPE HTML>
<html>
<head>
    <meta charset="utf-8">
    <title>Meza Server Space</title>
    <link rel="stylesheet" href="css/nv.d3.css" />
</head>
<body><!--

 --></body>
</html>

<?php
echo $html;
?>

<script type='application/javascript' src='js/jquery-3.1.0.min.js'></script>
<script type='application/javascript' src='js/d3.js'></script>
<script type='application/javascript' src='js/nv.d3.js'></script>
<script type='application/javascript' src='js/server-performance.nvd3.js'></script>
