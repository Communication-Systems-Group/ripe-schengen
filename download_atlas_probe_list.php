<?php

require('AtlasProbeHandler.php');
ini_set("max_execution_time", 30000);

/*
AtlasProbeHandler::update_probe_list();
*/

$probe_list = AtlasProbeHandler::get_all_probe_numbers();

//foreach($probe_list as $probe) {
for ($i = 0; $i < 1000; $i++) {
	AtlasProbeHandler::download_probe_details($probe_list[$i]);
}

?>