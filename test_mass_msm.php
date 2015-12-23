<?php

include 'settings.php';
require('TracerouteMeasurement.php');
ini_set("max_execution_time", 100000);

//$asn_list = array(137, 224, 250, 286, 288, 375, 513, 517, 553, 559, 565, 679, 680, 711, 719, 760, 764, 766, 775, 776, 777, 781, 789, 790, 1101, 1103, 1104, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1120, 1124, 1125, 1126, 1128, 1132, 1133, 1134, 1136, 1140, 1142, 1145, 1147, 1161);
//$asn_list2 = array(1101, 1103, 1104, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1120, 1124, 1125, 1126, 1128, 1132, 1133, 1134, 1136, 1140, 1142, 1145, 1147, 1161);
$asn_list3 = array(224,250,251,260,286,513,553,559,680,719,766,790,1101,1103,1109,1113,1120,1124,1128,1133);
//137,158,174,

$liste_schengen_atlas_asns = TracerouteMeasurement::get_asns_with_atlas_probes_for_country_group(10);
echo count($liste_schengen_atlas_asns);
echo '<br/><br/>';

$target = '192.76.243.2';
$campaign_id = 14;
$protocol_list = array('ICMP', 'UDP', 'TCP');

// create array with scheduled measurements
foreach ($asn_list3 as $target_asn) {
	$scheduled[$target_asn]['ICMP'] = true;
	$scheduled[$target_asn]['UDP'] = true;
	$scheduled[$target_asn]['TCP'] = true;
	//$scheduled[$target_asn] = $protocol_list;
	$scheduled[$target_asn]['key'] = $target_asn;
}
echo '<pre>'; print_r($scheduled); echo '</pre>';

$currently_running = array();
$not_covered = array();
$error = array();
$successfully_completed = array();

while (!empty($scheduled)) {
	
	// check whether a measurement can be started
	while (count($currently_running) == 9) {
		// query all currently running measurements whether they have stopped
		for ($i = 0; $i < 9; $i++) {
			$current_measurement_id = $currently_running[$i];
			$status = TracerouteMeasurement::get_status_by_id($current_measurement_id);
			if ($status == 'Stopped') {
				// delete measurement id from list of currently running measurements
				unset($currently_running[$i]);
				// add measurement id to list of successfully completed measurements
				$successfully_completed[] = $current_measurement_id;
			}
		}
	}
	
	// get next target asn (and delete from list of scheduled measurements at the same time)
	$next_target_asn_array = array_pop($scheduled);
	$next_target_asn = $next_target_asn_array['key'];
	if ($next_target_asn_array['ICMP'] || $next_target_asn_array['UDP'] || $next_target_asn_array['TCP']) {
		// get next protocol for measurement
		if ($next_target_asn_array['ICMP']) {
			$next_protocol = 'ICMP';
			$next_target_asn_array['ICMP'] = false;
		} else if ($next_target_asn_array['UDP']) {
			$next_protocol = 'UDP';
			$next_target_asn_array['UDP'] = false;		
		} else {
			$next_protocol = 'TCP';
			$next_target_asn_array['TCP'] = false;
		}
		
		// add remaining array back to list of scheduled measurements
		$scheduled[$next_target_asn] = $next_target_asn_array;

		// setup new measurement
		$description = 'Traceroute Measurement (' . $next_protocol . ') from ASN' . $next_target_asn . ' for campaign ' . $campaign_id;
		$example = new TracerouteMeasurement($target, $description, $next_protocol, $next_target_asn);
		$answer = $example->start($campaign_id);
	
		// check answer
		if ($answer == 'not covered') {
			// delete from list of scheduled measurements (all protocols)
			unset($scheduled[$target_asn]);
			// add to list of networks not covered
			$not_covered[] = $target_asn;
		} else if ($answer == 'too many') {
			sleep(1);
		} else if ($answer == 'other error') {
			// add to error list
			$error[] = $current_asn;
		} else {
			// add to currently running measurements
			$currently_running[] = $answer;
			// delete from list of scheduled measurements
			#unset($scheduled[$target_asn][$protocol]);
		}
	} else {
		unset($scheduled[$next_target_asn]);
	}
	echo '<br/>';
	echo '========================================================================================================';
	echo '<br/>';
}

echo 'Scheduled: ';
echo '<br/>';
echo '<pre>'; print_r($scheduled); echo '</pre>';
echo 'Not covered: ';
echo '<br/>';
echo '<pre>'; print_r($not_covered); echo '</pre>';
echo 'Error: ';
echo '<br/>';
echo '<pre>'; print_r($error); echo '</pre>';
echo 'Successfully completed: ';
echo '<br/>';
echo '<pre>'; print_r($successfully_completed); echo '</pre>';

?>