<?php

include_once 'TracerouteMeasurement.php';
include_once 'GeolocationDBHandler.php';
include_once 'Analysis.php';

ini_set("max_execution_time", 20000);

/*
$test = GeolocationDBHandler::get_geolocation_data_ip2location();
GeolocationDBHandler::write_geolocation_data_to_db($test, 'ip2location');
*/

/*
$test = GeolocationDBHandler::get_geolocation_data_software77();
GeolocationDBHandler::write_geolocation_data_to_db($test, 'software77');
*/

/*
$test = GeolocationDBHandler::get_geolocation_data_maxmind();
GeolocationDBHandler::write_geolocation_data_to_db($test, 'maxmind');
*/

/*
$ip_address = '192.76.243.2';
$ip_address2 = '125.253.112.0';
$test = Analysis::get_country_of_ip_address($ip_address, 'ip2location');
echo $test;
*/

$ids = array(
3103840,
3103841,
3103842,
3103843,
3103844,
3103845,
3103846,
3103847,
3103848,
3103854,
3103856,
3103857,
3103858,
3103859,
3103860,
3103861,
3103862,
3103863,
3103870,
3103871,
3103872,
3103873,
3103874,
3103875,
3103876,
3103877,
3103878,
3103930,
3103931,
3103932,
3103933,
3103934,
3103935,
3103936,
3103937,
3103938,
3103943,
3103944,
3103945,
3103946,
3103947,
3103948,
3103949,
3103950,
3103951,
3103967,
3103968,
3103969,
3103970,
3103971,
3103972,
3103973,
3103974,
3103975,
3103981,
3103982,
3103983,
3103984,
3103985,
3103986,
3103987,
3103988,
3103989);

foreach ($ids as $current_id) {
	TracerouteMeasurement::download_single_result_measurement_data_by_id($current_id);
}

?>