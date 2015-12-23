<?php
require('TracerouteMeasurement.php');

#if(empty($_POST['target'])) {
$target = $_POST['target'];
$description = $_POST['description'];
$protocol = $_POST['protocol'];
$target_asn = $_POST['target_asn'];

$example = new TracerouteMeasurement($target, $description, $protocol, $target_asn);
$example->add();
echo '\nStatus: ';
echo $example->get_status();
$example->write_to_db();

# Timeout des PHP-Skripts vermeiden
#ini_set("max_execution_time", "somevalueinsecs");

?>
