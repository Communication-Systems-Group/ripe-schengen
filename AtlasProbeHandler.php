<?php

require('CheckrouteDatabase.php');
ini_set("max_execution_time", 10000);

// path to Atlas probes webpage
define('ATLAS_PROBE_LIST_PATH', 'https://atlas.ripe.net/probes');

class AtlasProbeHandler
{

    // get list of RIPE Atlas probes
    public static function download_probe_list()
    {		
        # create and execute curl request to first list page on RIPE Atlas website
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, ATLAS_PROBE_LIST_PATH . '/?public=1');
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
        $str = curl_exec($ch);
        curl_close($ch);

        # instantiate DOM parser object
        $dom = new DOMDocument();
        @$dom->loadHTML($str);

        # parse total number of probes in list
        $finder_totals = new DomXPath($dom);
        $node_totals = $finder_totals->query('//div[@class="totals"]');
        if($node_totals == NULL) {
            echo "Error: Information on total number of items in RIPE Atlas probes list could not be found.";
            return NULL;
        }
        $totals_info = $node_totals->item(0)->nodeValue;
        $pattern_numbers = '/\d+/';
        preg_match_all($pattern_numbers, $totals_info, $totals_numbers);
		echo 'Number of RIPE Atlas probes in list: ' . $totals_numbers[0][1];
		echo '<br/>';
		
        $finder_pagination = new DomXPath($dom);
        $node_pagination = $finder_pagination->query('//div[@class="pagination text-center col-md-12"]');
        if($node_pagination == NULL) {
            echo 'Error: Information on pagination of RIPE Atlas probes list could not be found.';
			echo '<br/>';
            return NULL;
        }
        $pagination_info = $node_pagination->item(0)->getElementsByTagName('span')->item(0)->nodeValue;
        preg_match_all($pattern_numbers, $pagination_info, $pagination_numbers);
		$number_of_pages = $pagination_numbers[0][1];
		echo 'Number of pages of RIPE Atlas probes list: ' . $number_of_pages;
		echo '<br/><br/>';

		// create and check connection
        $link = CheckrouteDatabase::connect();

        # download data and store to database
		for ($i = 1; $i <= $number_of_pages; $i++) {
			echo 'Downloading information from page ' . $i . '...';
			echo '<br/>';
			// create and execute curl request to current list page on RIPE Atlas website
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, ATLAS_PROBE_LIST_PATH . '/?public=' . $i);
			curl_setopt($ch, CURLOPT_HEADER, 0);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
			curl_setopt($ch, CURLOPT_ENCODING, 'UTF-8');
			$str = utf8_decode(curl_exec($ch));
			curl_close($ch);			
			// create DOMDocument object from curl request answer
			$dom = new DOMDocument();
			@$dom->loadHTML($str);
			// get table with probe information
			$probe_table = $dom->getElementsByTagName('table');
			$probe_table_rows = $probe_table->item(0)->getElementsByTagName('tr');
			// iterate through table rows (leave out the first element because it is the table head)
			for ($k = 1; $k < $probe_table_rows->length; $k++) {
				$probe_table_current_columns = $probe_table_rows->item($k)->getElementsByTagName('td');			
				$probe_id = $probe_table_current_columns->item(0)->nodeValue;
				$asn_v4 = $probe_table_current_columns->item(1)->nodeValue;
				if (empty($asn_v4)) {
					$asn_v4 = NULL;
				}
				$asn_v6 = $probe_table_current_columns->item(2)->nodeValue;
				if (empty($asn_v6)) {
					$asn_v6 = NULL;
				}
				//echo 'Country name: ' . $probe_table_current_columns->item(3)->getElementsByTagName('span')->item(0)->getAttribute('title') . '<br/>';			
				$country_code = strtoupper(substr($probe_table_current_columns->item(3)->getElementsByTagName('span')->item(0)->getAttribute('class'), 5, 2));
				if (empty($country_code)) {
					$country_code = NULL;
				}
				$description = trim($probe_table_current_columns->item(4)->nodeValue);
				if (empty($description)) {
					$description = NULL;
				}
				$connection_status = $probe_table_current_columns->item(5)->getElementsByTagName('i')->item(0)->getAttribute('title');
				if ($connection_status == 'Never Connected') {
					$never_connected = 1;
					$disconnected_or_abandoned = NULL;
				} else {
					$never_connected = 0;
					if ($connection_status == 'Disconnected') {
						$disconnected_or_abandoned = 1;
					} else {
						$disconnected_or_abandoned = 0;
					}
				}
				
				// get current date
				$current_date = date('Y-m-d');
				
				// write result to database
				$stmt = mysqli_prepare($link, "INSERT INTO AtlasProbe (probe_id, asn_v4, asn_v6, country_code, description, is_public, never_connected, disconnected_or_abandoned, last_update) VALUES (?, ?, ?, ?, ?, 1, ?, ?, ?)");
				if ($stmt === false) {
					trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
				}
				$bind = mysqli_stmt_bind_param($stmt, "ssssssss", $probe_id, $asn_v4, $asn_v6, $country_code, $description, $never_connected, $disconnected_or_abandoned, $current_date);
				if ($bind === false) {
					trigger_error('Error: Bind of parameters failed. ', E_USER_ERROR);
				}
				$exec = mysqli_stmt_execute($stmt);
				if ($exec === false) {
					trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
				}			
			}
		}

        // close database connection
        mysqli_close($link);
        
        return true;
    }
	
    // download details for a RIPE Atlas probe specified by its probe ID
    public static function update_probe_list()
	{
		// create and check connection
        $link = CheckrouteDatabase::connect();

		// delete all current entries of Atlas probes in database
		echo 'Deleting current database entries...';
		echo '<br/>';
        $stmt = mysqli_prepare($link, "DELETE FROM `AtlasProbe` WHERE 1");
        if ($stmt) {
            mysqli_stmt_execute($stmt);
            mysqli_stmt_close($stmt);
        }		

        // close database connection
        mysqli_close($link);
		
		echo 'Starting update...';
		echo '<br />';
		AtlasProbeHandler::download_probe_list();
		
	}

    // download details for a RIPE Atlas probe specified by its probe ID
    public static function download_probe_details($probe_id)
    {
		// create and check connection
        $link = CheckrouteDatabase::connect();
		
        # create and execute curl request to first list page on RIPE Atlas website
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, ATLAS_PROBE_LIST_PATH . '/' . $probe_id . '/');
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
        $str = curl_exec($ch);
        curl_close($ch);

        # instantiate DOM parser object
        $dom = new DOMDocument();
        @$dom->loadHTML($str);

		// get all tables in webpage
		$probe_table = $dom->getElementsByTagName('table');
		
		// first table in page contains data on architecture, firmware version and router type
		$probe_general_info_table = $probe_table->item(0)->getElementsByTagName('tr');
		$architecture = trim($probe_general_info_table->item(1)->getElementsByTagName('td')->item(1)->nodeValue);
		if (empty($architecture)) {
			$architecture = NULL;
		}
		$firmware_version = trim($probe_general_info_table->item(2)->getElementsByTagName('td')->item(1)->nodeValue);
		if (empty($firmware_version) || $firmware_version == 'None' || $firmware_version == 'None (None)') {
			$firmware_version = NULL;
		}
		$router_type = trim($probe_general_info_table->item(3)->getElementsByTagName('td')->item(1)->nodeValue);
		if (empty($router_type)) {
			$router_type = NULL;
		}

		echo 'Architecture: ' . $architecture;
		echo '<br />';
		echo 'Firmware Version: ' . $firmware_version;
		echo '<br />';
		echo 'Router Type: ' . $router_type;
		echo '<br />';
		
		// second table in page contains data on IPv4 prefixes
		$probe_ipv4_info_table = $probe_table->item(1)->getElementsByTagName('tr');
		$prefix_ipv4 = trim($probe_ipv4_info_table->item(0)->getElementsByTagName('td')->item(1)->nodeValue);
		if (empty($prefix_ipv4) || $prefix_ipv4 == 'None') {
			$prefix_ipv4 = NULL;
		}

		echo 'Prefix IPv4: ' . $prefix_ipv4;
		echo '<br />';

		// third table in page contains data on IPv6 prefixes
		$probe_ipv6_info_table = $probe_table->item(2)->getElementsByTagName('tr');
		$prefix_ipv6 = trim($probe_ipv6_info_table->item(0)->getElementsByTagName('td')->item(1)->nodeValue);
		if (empty($prefix_ipv6) || $prefix_ipv6 == 'None') {
			$prefix_ipv6 = NULL;
		}
	
		echo 'Prefix IPv6: ' . $prefix_ipv6;
		echo '<br />';
	
		$finder_firmware = new DomXPath($dom);
        $node_firmware = $finder_firmware->query('//div[@class="firmware"]');
        if($node_firmware == NULL) {
            echo 'Error: Firmware information on the RIPE Atlas probe with ID ' . $probe_id . ' could not be found.';
			echo '<br/>';
            return NULL;
        }
        $firmware = trim($node_firmware->item(0)->getElementsByTagName('div')->item(1)->nodeValue);
		if (empty($firmware_version)) {
			$firmware_version = NULL;
		}

		$finder_architecture = new DomXPath($dom);
        $node_architecture = $finder_architecture->query('//div[@class="architecture"]');
        if($node_architecture == NULL) {
            echo 'Error: Architecture information on the RIPE Atlas probe with ID ' . $probe_id . ' could not be found.';
			echo '<br/>';
            return NULL;
        }
        $architecture = trim($node_architecture->item(0)->getElementsByTagName('div')->item(1)->nodeValue);
		if (empty($architecture)) {
			$architecture = NULL;
		}

		$finder_mac_address = new DomXPath($dom);
        $node_mac_address = $finder_mac_address->query('//div[@class="mac"]');
        if($node_mac_address == NULL) {
            echo 'Error: MAC address information on the RIPE Atlas probe with ID ' . $probe_id . ' could not be found.';
			echo '<br/>';
            return NULL;
        }
        $mac_address = trim($node_mac_address->item(0)->getElementsByTagName('div')->item(1)->nodeValue);
		if (empty($mac_address)) {
			$mac_address = NULL;
		}

		echo 'Architecture: ' . $architecture;
		echo '<br />';
		echo 'Firmware Version: ' . $firmware_version;
		echo '<br />';
		echo 'MAC Address: ' . $mac_address;
		echo '<br />';
		
		// latitude and longitude information is in last script element in page
		$scripts = $dom->getElementsByTagName('script');
		$position_script = $scripts->item(27)->nodeValue;		
        $pattern_latitude_longitude = '/-?\d+\.\d+/';
        preg_match_all($pattern_latitude_longitude, $position_script, $latitude_longitude_result);
		$latitude = $latitude_longitude_result[0][0];
		$longitude = $latitude_longitude_result[0][1];		
		if (empty($latitude)) {
			$latitude = NULL;
		}
		if (empty($longitude)) {
			$longitude = NULL;
		}
		echo 'Latitude: ' . $latitude;
		echo '<br />';
		echo 'Longitude: ' . $longitude;
		echo '<br />';

		//TODO: optional: check probe id, asn etc.
		
		// get current date
		$current_date = date('Y-m-d');
				
		// write result to database
		$stmt = mysqli_prepare($link, "UPDATE `AtlasProbe` SET `ipv4_prefix`=?,`ipv6_prefix`=?, `architecture`=?, `firmware_version`=?, `router_type`=?, `mac_address`=?, `latitude`=?, `longitude`=?, `last_update`=? WHERE `probe_id` = ?");
		if ($stmt === false) {
			trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
		}
		$bind = mysqli_stmt_bind_param($stmt, "ssssssssss", $prefix_ipv4, $prefix_ipv6, $architecture, $firmware_version, $router_type, $mac_address, $latitude, $longitude, $current_date, $probe_id);
		if ($bind === false) {
			trigger_error('Error: Bind of parameters failed. ', E_USER_ERROR);
		}
		$exec = mysqli_stmt_execute($stmt);
		if ($exec === false) {
			trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
		}
		
        // close database connection
        mysqli_close($link);
    }

    // get list of RIPE Atlas probe numbers stored in database
    public static function get_all_probe_numbers()
    {
		// create and check connection
        $link = CheckrouteDatabase::connect();

		// query all probe IDs from database
        $stmt = mysqli_prepare($link, "SELECT `probe_id` FROM `AtlasProbe` ORDER BY `probe_id` ASC");
        if ($stmt) {
            mysqli_stmt_execute($stmt);
            mysqli_stmt_bind_result($stmt, $result_sql);

            $result = array();
            while (mysqli_stmt_fetch($stmt)) {
                $result[] = $result_sql;
            }
            mysqli_stmt_close($stmt);
        }		

        // close database connection
        mysqli_close($link);
		
		return $result;
    }

    // get list of RIPE Atlas active probe numbers stored in database; active means here: not never connected, not disconnected, not abandoned
    public static function get_active_probe_numbers()
    {
		// create and check connection
        $link = CheckrouteDatabase::connect();

		// query all probe IDs from database
        $stmt = mysqli_prepare($link, "SELECT `probe_id` FROM `AtlasProbe` WHERE `never_connected` = 0 AND `disconnected_or_abandoned` = 0 ORDER BY `probe_id` ASC");
        if ($stmt) {
            mysqli_stmt_execute($stmt);
            mysqli_stmt_bind_result($stmt, $result_sql);

            $result = array();
            while (mysqli_stmt_fetch($stmt)) {
                $result[] = $result_sql;
            }
            mysqli_stmt_close($stmt);
        }		

        // close database connection
        mysqli_close($link);
		
		return $result;
    }
    
}
 
?>
