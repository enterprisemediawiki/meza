<?php

# Debug
// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);

# hack to prevent notice of undefined constant NS_MAIN from files matching
# /opt/.deploy-meza/public/preLocalSettings.d/*.php
define("NS_MAIN", "");

# set timezone to prevent warnings when using strtotime()
date_default_timezone_set('America/Chicago');

# how many days of data should we display?
if( isset($_REQUEST['days']) && $_REQUEST['days'] > 0 ){
    $daysOfData = $_REQUEST['days'];
} else {
    $daysOfData = 1; // default
}

# ceiling value to keep outlier values from skewing y axis
# currently only used for avg_response_time
# remember that avg_response_time is later divided by 100
$ceiling = 110;
$load_ceiling = $ceiling / 100;
$avg_response_time_ceiling = $ceiling * 100;

// get config vars from config.php
require_once '/opt/.deploy-meza/config.php';
$username = $wiki_app_db_user_name;
$password = $wiki_app_db_user_pass;
$dbname = $m_logging_db_name;
$servername = $m_logging_db_host;

$dbtable = "performance";


$query = "SELECT
            DATE_FORMAT( datetime, '%Y-%m-%d %H:%i:%s' ) AS ts,
            LEAST(loadavg1, $load_ceiling) as loadavg1,
            LEAST(loadavg5, $load_ceiling) as loadavg5,
            LEAST(loadavg15, $load_ceiling) as loadavg15,
            memorypercentused,
            mysql,
            es,
            memcached,
            parsoid,
            apache,
            jobs
        FROM $dbtable
        WHERE DATE_FORMAT(datetime, '%Y-%m-%d') >= DATE_FORMAT(NOW(), '%Y-%m-%d') - INTERVAL $daysOfData DAY;";

$mysqli = mysqli_connect("$servername", "$username", "$password", "$dbname");

$res = mysqli_query($mysqli, $query);

# Format query results
$data = array();
$variables = array("1-min Load Avg"=>"loadavg1",
    "5-min Load Avg"=>"loadavg5",
    "15-min Load Avg"=>"loadavg15",
    "Total Memory % Used"=>"memorypercentused",
    "MySQL"=>"mysql",
    "Elasticsearch"=>"es",
    "Memcached"=>"memcached",
    "Parsoid"=>"parsoid",
    "Apache"=>"apache",
    "Jobs"=>"jobs");

// Get max value of jobs, to be used for normalization
while( $row = mysqli_fetch_assoc($res) ){

    $jobsTemp[] = floatval($row['jobs']);

}
$maxJobsValue = max($jobsTemp);
// for small number of jobs, normalize to 100
if( $maxJobsValue < 100 ){ $maxJobsValue = 100; }

mysqli_data_seek($res, 0);

// Now pull all the data from the query results and scale as necessary
while( $row = mysqli_fetch_assoc($res) ){

    list($ts, $loadavg1, $loadavg5, $loadavg15, $memorypercentused, $mysql, $es, $memcached, $parsoid, $apache, $jobs
        ) = array($row['ts'], $row['loadavg1'], $row['loadavg5'], $row['loadavg15'], $row['memorypercentused'],
        $row['mysql'], $row['es'], $row['memcached'], $row['parsoid'], $row['apache'], $row['jobs']);

    foreach( $variables as $varname => $varvalue ){

        if( substr($varvalue,0,4) == "load"){
            $tempdata[$varvalue][] = array(
                'x' => strtotime($ts) * 1000,       // e.g. from 20160624080000 to 1384236000000
                'y' => floatval($$varvalue) * 100,  // e.g. from 0.1 to 10
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


/*
*
* Add data from wiretap
*
*/

# Get list of wiki databases
$database = array();
$query = "SELECT DISTINCT SCHEMA_NAME AS `database`
    FROM information_schema.SCHEMATA
    WHERE  SCHEMA_NAME NOT IN ('information_schema', 'performance_schema', 'mysql', 'meza_server_log')
    ORDER BY SCHEMA_NAME;";

$mysqli = mysqli_connect("$servername", "$username", "$password", "$dbname");

$res = mysqli_query($mysqli, $query);

while( $row = mysqli_fetch_assoc($res) ){

    $database[] = $row['database'];

}

mysqli_close($mysqli);

# Build mega query using array of databases
$query = "SELECT
        converted_ts AS ts,
        COUNT(converted_ts) AS hits,
        LEAST(ROUND(AVG(response_time),0), $avg_response_time_ceiling) AS avg_response_time
    FROM
        ( ";

$firstdbdone = false;
foreach( $database as $db ){
    if( $firstdbdone == true ){
        $query .= "UNION ALL ";
    } else { $firstdbdone = true; }

    $query .= "SELECT
                hit_timestamp,
                DATE_FORMAT(CONVERT_TZ(hit_timestamp, '+00:00', @@global.time_zone), '%Y-%m-%d %H:%i:%s') AS converted_ts,
                response_time
            FROM $db.wiretap
            WHERE DATE_FORMAT(CONVERT_TZ(hit_timestamp, '+00:00', @@global.time_zone), '%Y-%m-%d') >= DATE_FORMAT(NOW(), '%Y-%m-%d') - INTERVAL $daysOfData DAY ";
}

$query .= ")a
    GROUP BY DATE_FORMAT(CONVERT_TZ(hit_timestamp, '+00:00', @@global.time_zone), '%Y-%m-%d %H:%i')
    ORDER BY converted_ts ASC
    ;";

$mysqli = mysqli_connect("$servername", "$username", "$password", "$dbname");

$res = mysqli_query($mysqli, $query);

$variables = array("Hits"=>"hits",
    "Average Response Time (ds)"=>"avg_response_time");
while( $row = mysqli_fetch_assoc($res) ){

    list($ts, $hits, $avg_response_time) = array($row['ts'], $row['hits'], $row['avg_response_time']);

    foreach( $variables as $varname => $varvalue ){

        if( $varvalue == "avg_response_time"){
            $tempdata[$varvalue][] = array(
                'x' => strtotime($ts) * 1000,       // e.g. from 20160624080000 to 1384236000000
                'y' => floatval($$varvalue) / 100,  // e.g. from 624 to 6.24 (deciseconds)
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
    <title>Meza Server Performance</title>
    <link rel="stylesheet" href="css/nv.d3.css" />
</head>
<body>
	<?php echo $html; ?>

	<script type='application/javascript' src='js/jquery-3.1.0.min.js'></script>
	<script type='application/javascript' src='js/d3.js'></script>
	<script type='application/javascript' src='js/nv.d3.js'></script>
	<script type='application/javascript' src='js/server-performance.nvd3.js'></script>
</body>
</html>

