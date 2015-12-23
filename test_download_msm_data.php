<?php

include_once 'TracerouteMeasurement.php';
include_once 'MeasurementCampaign.php';

ini_set("max_execution_time", 2000);

/*
$test1 = TracerouteMeasurement::get_status_by_id(3102248);
$test2 = TracerouteMeasurement::get_measurement_data_by_id(3102248);
print_r($test1);
echo '<br/><br/>';
print_r($test2);
*/

$msm_id1 = 3102248;
$msm_id2 = 3103931;

$test3 = TracerouteMeasurement::get_result_data_by_id($msm_id2);
echo '<pre>'; print_r($test3); echo '</pre>';
echo '<br/><br/>';

$test4 = TracerouteMeasurement::download_single_result_measurement_data_by_id($msm_id2);
echo '<pre>'; print_r($test4); echo '</pre>';
echo '<br/><br/>';

/*
$campaign_id = 14;
$myCampaign = new MeasurementCampaign($campaign_id, 'Test', 'Test');
$measurement_id_list = $myCampaign->get_measurement_ids();
echo '<br/>';
echo 'Number of measurements for campaign ' . $campaign_id . ': ' . $myCampaign->get_number_of_measurements();
echo '<br/>';

foreach ($measurement_id_list as $measurement_id) {
	TracerouteMeasurement::download_start_stop_time_by_id($measurement_id);
}

echo 'Download of start and stop data complete.';
*/

?>