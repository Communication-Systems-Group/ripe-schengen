<?php

require('MeasurementCampaign.php');
require('TracerouteMeasurement.php');
require('ASListHandler.php');

$example = new MeasurementCampaign(333, "Test", "Test");

echo 'Number of measurements for campaign ' . $example->id . ': ' . $example->get_number_of_measurements() . '<br/>';

$measurements_of_campaign = $example->get_measurement_ids();
foreach ($measurements_of_campaign as $measurement_id) {
    echo TracerouteMeasurement::get_status_by_id($measurement_id) . '<br />';
}

?>