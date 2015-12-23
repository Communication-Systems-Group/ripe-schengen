<?php

include 'settings.php';
include_once 'CheckrouteDatabase.php';

// path to RIPE Atlas measurement API
define('ATLAS_MEASUREMENT_API_PATH', 'https://atlas.ripe.net/api/v1/measurement');

class TracerouteMeasurement
{
    var $id;
    var $target;
    var $description;
    var $protocol;
    var $probe_asn;
    var $is_public;
    
    // Konstruktor
    public function __construct($target, $description, $protocol, $probe_asn)
    {
        $this->id = NULL;
        $this->target = $target;
        $this->description = $description;
        $this->protocol = $protocol;
        $this->probe_asn = $probe_asn;
    }

    // startet eine neue Messung ueber die RIPE ATLAS API
    public function add()
    {
        $this->start();
        $this->write_to_db();
    }
 
    // startet eine neue Messung ueber die RIPE ATLAS API
    public function start($campaign_id)
    {
        # API-Aufruf zusammenbasteln
        /*
        $cmd_start = '
        curl --dump-header - -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d \'{
         "definitions": [
           {
            "target": "8.8.8.8",
            "af": 4,
            "timeout": 4000,
            "description": "Traceroute measurement Test",
            "protocol": "ICMP",
            "resolve_on_probe": false,
            "packets": 3,
            "size": 48,
            "paris": 0,
            "destination_option_size": 0,
            "hop_by_hop_option_size": 0,
            "type": "traceroute",
            "firsthop": 1,
            "maxhops": 32,
            "dontfrag": false
           }
          ],
          "probes": [
           {
            "type": "area",
            "value": "WW",
            "requested": 50
           }
          ],
          "is_oneoff": true
        }\' https://atlas.ripe.net/api/v1/measurement/?key=YOUR_KEY_HERE
        */

        # API-Aufruf zusammenbasteln
		
		/*
		$current_unix_timestamp = time();
		$starttime = $current_unix_timestamp + 30;
		$endtime = $current_unix_timestamp + 90;
		*/
		
        $cmd_start = 'curl -s -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d \'';
        $cmd_start = $cmd_start.'{ "definitions": [ { "target": "'.$this->target.'", "description": "'.$this->description.'", "type": "traceroute", "af": 4, "protocol": "'.$this->protocol.'", "is_oneoff": true } ], ';
        $cmd_start = $cmd_start.'"probes": [ { "requested": 1, "type": "asn", "value": "'.$this->probe_asn.'" } ] }';
        $cmd_start = $cmd_start.'\' https://atlas.ripe.net/api/v1/measurement/?key='.RIPE_ATLAS_API_KEY_CREATE;

        echo 'Request sent:<br>';
        echo $cmd_start;
        exec($cmd_start, $result_start);
        
        echo '<br><br>';
        echo 'Answer received:<br>';
        echo '<pre>';
        print_r($result_start);
        echo '</pre>';

        echo '<br><br>';
        
        // das zurueckgegebene Antwort-JSON-Objekt (hat Form {"measurements":[2923074]}) dekodieren
        $result_start_json = json_decode($result_start[0], true);
        if ($result_start_json == NULL) {
            echo 'Error: parsing of JSON string returned for measurement start failed. '.$result_start[0];
			return 'parsing error';
        }
        elseif (!empty($result_start_json[error])) {
			if ($result_start_json[error][message] == 'target: This target cannot be resolved') {
				echo 'not resolved';
				echo '<br/>';
				return 'not resolved';
			} else if ($result_start_json[error][message] == "__all__: Your selected ASN is not covered by our network.") {
				echo 'not covered';
				echo '<br/>';
				return 'not covered';
			} else if ($result_start_json[error][message] == "[u'We do not allow more than 10 concurrent measurements to the same target.']") {
				echo 'too many';
				echo '<br/>';
				return 'too many';
			} else {
				echo 'Error: '.$result_start_json['error']['message'].' <br/>('.$result_start[0].')';
				return 'other error';
			}
            #{"error":{"message":"target: This target cannot be resolved","code":104}}
            #{"error":{"message":"__all__: Your selected ASN is not covered by our network.","code":104}}
			#{"error":{"message":"[u'We do not allow more than 10 concurrent measurements to the same target.']","code":104}}
			#{"error":{"message":"__all__: Unacceptable ASN defined: \"Array\"","code":104}}
			#{"error":{"message":"protocol: Select a valid choice. 1133 is not one of the available choices.","code":104}}
			#{"error":{"message":"value: This field is required.","code":104}
        }
        else {
            #{"measurements":[2923074]}
            $this->id = $result_start_json['measurements'][0];
            echo 'Measurement successfully started with id '.$this->id.'...';

			# write result of start command to db
			echo 'Writing measurement ID ' . $this->id . ' to db...';
			echo '<br/>';

			// create and check connection
			$link = CheckrouteDatabase::connect();

			// write information on new measurement to database
			$stmt = mysqli_prepare($link, "INSERT INTO TracerouteMeasurement (id, address_family, protocol, probe_selection_type, probe_asn, number_of_probes_requested, response_timeout, number_of_packets, packet_size, hops_max, paris_variations, designated_target) VALUES (?, 4, ?, 'asn', ?, 1, 4000, 3, 48, 32, 16, ?)");
			if ($stmt === false) {
				trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
			}
			$bind = mysqli_stmt_bind_param($stmt, "ssss", $this->id, $this->protocol, $this->probe_asn, $this->target);
			if ($bind === false) {
				trigger_error('Error: Bind of parameter failed. ', E_USER_ERROR);
			}
			$exec = mysqli_stmt_execute($stmt);
			if ($exec === false) {
				trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
			}
			
			// tie new measurement to measurement campaign
			$stmt = mysqli_prepare($link, "INSERT INTO Campaign_has_Measurement (id_campaign, id_measurement) VALUES (?, ?)");
			if ($stmt === false) {
				trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
			}
			$bind = mysqli_stmt_bind_param($stmt, "ss", $campaign_id, $this->id);
			if ($bind === false) {
				trigger_error('Error: Bind of parameter failed. ', E_USER_ERROR);
			}
			$exec = mysqli_stmt_execute($stmt);
			if ($exec === false) {
				trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
			}
			
			// TODO: nur ausführen, falls beide Teile erfolgreich sind
			
			// close database connection
			CheckrouteDatabase::close($link);
			
			return $this->id;
			
        }

	}
  
    // Get list of all ASNs associated with a given country group (e.g. Schengen)
    public static function get_asns_for_country_group($country_group_id)
    {
		// create and check connection
        $link = CheckrouteDatabase::connect();
		
		// query all ASNs for given country group
        $stmt = mysqli_prepare($link, "SELECT DISTINCT `asn` FROM `AutonomousSystem` WHERE `country_code` IN (SELECT `code_iso_alpha_2` FROM `Country` WHERE `code_iso_alpha_2` IN (SELECT `country_code` FROM `Country_Belongs_To_Country_Group` WHERE `country_group_id` = ?))");
        if ($stmt) {
            mysqli_stmt_bind_param($stmt, "s", $country_group_id);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_bind_result($stmt, $result);

            $result_asn = array();
            while (mysqli_stmt_fetch($stmt)) {
                $result_asn[] = $result;
            }
            mysqli_stmt_close($stmt);
        }		

        // close database connection
		CheckrouteDatabase::close($link);
		
		return $result_asn;
    }


    // Get list of all ASNs associated with a given country group (e.g. Schengen)
    public static function get_asns_with_atlas_probes_for_country_group($country_group_id)
    {
		// create and check connection
        $link = CheckrouteDatabase::connect();
		
		// query all ASNs for given country group
        $stmt = mysqli_prepare($link, "SELECT DISTINCT `asn_v4` FROM `AtlasProbe` WHERE `asn_v4` IS NOT NULL AND `country_code` IS NOT NULL AND `never_connected` = 0 AND `disconnected_or_abandoned` = 0 AND `country_code` IN (SELECT `code_iso_alpha_2` FROM `Country` WHERE `code_iso_alpha_2` IN (SELECT `country_code` FROM `Country_Belongs_To_Country_Group` WHERE `country_group_id` = ?)) ORDER BY `asn_v4` ASC");
        if ($stmt) {
            mysqli_stmt_bind_param($stmt, "s", $country_group_id);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_bind_result($stmt, $result);

            $result_asn = array();
            while (mysqli_stmt_fetch($stmt)) {
                $result_asn[] = $result;
            }
            mysqli_stmt_close($stmt);
        }		

        // close database connection
		CheckrouteDatabase::close($link);
		
		return $result_asn;
    }

    // returns the status of the measurement with the id given as parameter
    public static function get_measurement_data_by_id($measurement_id)
    {
        # create and execute curl request
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, ATLAS_MEASUREMENT_API_PATH . '/' . $measurement_id . '/');
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
        $str = curl_exec($ch);
        curl_close($ch);
		
        $result_get_data_json = json_decode($str, true);
        return $result_get_data_json;
    }

    // Download data on start time and stop time of a measurement and update database entry accordingly
    public static function download_start_stop_time_by_id($measurement_id)
    {
		$result_get_data_json = TracerouteMeasurement::get_measurement_data_by_id($measurement_id);
		
		/*
        $description = $result_get_data_json[description];
        $address_family = $result_get_data_json[af];
		if ($result_get_data_json[proto_tcp]) {
			$protocol = "TCP";
		} else {
			$protocol = $result_get_data_json[protocol];
		}
		*/
		
        $creation_time_unix = $result_get_data_json[creation_time];
		$start_time_unix = $result_get_data_json[start_time];
        $stop_time_unix = $result_get_data_json[stop_time];

		$creation_time = date("Y-m-d H:i:s", $creation_time_unix);
		$start_time = date("Y-m-d H:i:s", $start_time_unix);
		$stop_time = date("Y-m-d H:i:s", $stop_time_unix);
		
		/*
        $response_timeout = $result_get_data_json[response_timeout];
        $paris = $result_get_data_json[paris];
        $packets = $result_get_data_json[packets];
        $port = $result_get_data_json[port];
        $size = $result_get_data_json[size];
        $maxhops = $result_get_data_json[maxhops];
		
        $number_of_probes_involved = $result_get_data_json[participant_count];
		
        $target_address = $result_get_data_json[dst_addr];
        $target_asn = $result_get_data_json[dst_asn];
        $target_name = $result_get_data_json[dst_name];
		
		echo $description;
		echo '<br/>';
		echo $address_family;
		echo '<br/>';
		echo $protocol;
		echo '<br/>';
		echo $creation_time;
		echo '<br/>';
        echo $start_time;
		echo '<br/>';
		echo $stop_time;
		echo '<br/>';
		*/

		// create and check connection
        $link = CheckrouteDatabase::connect();

		// write information on new measurement to database
		$stmt = mysqli_prepare($link, "UPDATE `TracerouteMeasurement` SET `creation_time`=?, `start_time`=?, `end_time`=? WHERE `id` = ?");
		if ($stmt === false) {
			trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
		}
		$bind = mysqli_stmt_bind_param($stmt, "ssss", $creation_time, $start_time, $stop_time, $measurement_id);
		if ($bind === false) {
			trigger_error('Error: Bind of parameter failed. ', E_USER_ERROR);
		}
		$exec = mysqli_stmt_execute($stmt);
		if ($exec === false) {
			trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
		}
		
        // close database connection
		CheckrouteDatabase::close($link);

    }

    // returns the status of the measurement with the id given as parameter
    public static function get_status_by_id($measurement_id)
    {
		$result_get_data_json = TracerouteMeasurement::get_measurement_data_by_id($measurement_id);
        return $result_get_data_json[status][name];
    }

    public static function get_result_data_by_id($measurement_id)
    {
        # create and execute curl request		
		$url = ATLAS_MEASUREMENT_API_PATH . '/' . $measurement_id . '/result/';
		
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		//curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows NT 6.1; rv:33.0) Gecko/20100101 Firefox/33.0");
		//curl_setopt($ch, CURLOPT_MAXREDIRS, 10);
		//curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 9);
		//curl_setopt($ch, CURLOPT_REFERER, $url);
		//curl_setopt($ch, CURLOPT_TIMEOUT, 60);
		//curl_setopt($ch, CURLOPT_AUTOREFERER, true);
		//curl_setopt($ch, CURLOPT_ENCODING, 'gzip,deflate');
		$data = curl_exec($ch);
		$status = curl_getinfo($ch);
		curl_close($ch);
		//echo $status['http_code'];
		//echo $status['redirect_url'];
        
        $result = json_decode($data, true);
		return $result;
    }

    // Download data on Atlas probe ID of a measurement and update database entry accordingly
    public static function download_single_result_measurement_data_by_id($measurement_id)
    {
		$data = TracerouteMeasurement::get_result_data_by_id($measurement_id);

		// create and check connection
        $link = CheckrouteDatabase::connect();
		
		// get ID of source probe of this measurement and write it to the database
		$atlas_probe_id = $data[0][prb_id];
		$stmt = mysqli_prepare($link, "UPDATE `TracerouteMeasurement` SET `probe_number`=? WHERE `id` = ?");
		if ($stmt === false) {
			trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
		}
		$bind = mysqli_stmt_bind_param($stmt, "ss", $atlas_probe_id, $measurement_id);
		if ($bind === false) {
			trigger_error('Error: Bind of parameter failed. ', E_USER_ERROR);
		}
		$exec = mysqli_stmt_execute($stmt);
		if ($exec === false) {
			trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
		}
		
		foreach ($data[0][result] as $traceroute_hop) {
			$hop_number = $traceroute_hop[hop];
			$traceroute_hop[result][0][from];

			if (empty($traceroute_hop[error])) {
				// check whether current hop was a timeout (in at least one execution)
				if ($traceroute_hop[result][0][x] == '*' || $traceroute_hop[result][1][x] == '*' || $traceroute_hop[result][2][x] == '*') {
					$is_timeout = 1;
					$is_varying = NULL;
					$hop_from = NULL;
					$time_to_live = NULL;
					$size_of_reply = NULL;
					$round_trip_time1 = NULL;
					$round_trip_time2 = NULL;
					$round_trip_time3 = NULL;					
				} else {
					$is_timeout = 0;
					// check whether all three executions of traceroute have the same source for this hop
					if (($traceroute_hop[result][0][from] == $traceroute_hop[result][1][from]) && ($traceroute_hop[result][1][from] == $traceroute_hop[result][2][from])) {
						$has_different_froms = false;
						$hop_from_formatted = $traceroute_hop[result][0][from];
						$hop_from = ip2long($hop_from_formatted);
					} else {
						$has_different_froms = true;
						$hop_from = NULL;
					}
					// check whether all three executions of traceroute have the same TTL for this hop
					if (($traceroute_hop[result][0][ttl] == $traceroute_hop[result][1][ttl]) && ($traceroute_hop[result][1][ttl] == $traceroute_hop[result][2][ttl])) {
						$has_different_ttl = false;
						$time_to_live = $traceroute_hop[result][0][ttl];
					} else {
						$has_different_ttl = true;
						$time_to_live = NULL;
					}
					// check whether all three executions of traceroute have the same reply size for this hop
					if (($traceroute_hop[result][0][size] == $traceroute_hop[result][1][size]) && ($traceroute_hop[result][1][size] == $traceroute_hop[result][2][size])) {
						$has_different_size = false;
						$size_of_reply = $traceroute_hop[result][0][size];
					} else {
						$has_different_size = true;
						$size_of_reply = NULL;
					}
					$round_trip_time1 = $traceroute_hop[result][0][rtt];
					$round_trip_time2 = $traceroute_hop[result][1][rtt];
					$round_trip_time3 = $traceroute_hop[result][2][rtt];
					if ($has_different_froms || $has_different_ttl || $has_different_size) {
						$is_varying = 1;
					} else {
						$is_varying = 0;
					}
				}
				
				// write information on current hop to database
				$stmt = mysqli_prepare($link, "INSERT INTO TracerouteHop (id_measurement, result_number, hop_number, from_ip, roundtrip_time1, roundtrip_time2, roundtrip_time3, size_of_reply, ttl, is_varying, is_timeout, remarks) VALUES (?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)");
				if ($stmt === false) {
					trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
				}
				$bind = mysqli_stmt_bind_param($stmt, "ssssssssss", $measurement_id, $hop_number, $hop_from, $round_trip_time1, $round_trip_time2, $round_trip_time3, $size_of_reply, $time_to_live, $is_varying, $is_timeout);
				if ($bind === false) {
					trigger_error('Error: Bind of parameter failed. ', E_USER_ERROR);
				}
				$exec = mysqli_stmt_execute($stmt);
				if ($exec === false) {
					trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
				}
				
			} else {
				// error in this hop
				echo 'Error in traceroute hop detected: ' . $traceroute_hop[error];

				// write information on current hop to database
				$stmt = mysqli_prepare($link, "INSERT INTO TracerouteHop (id_measurement, result_number, hop_number, from_ip, roundtrip_time1, roundtrip_time2, roundtrip_time3, size_of_reply, ttl, is_varying, is_timeout, remarks) VALUES (?, 1, ?, ?, ?, ?, ?, ?, ?, ?, 0, NULL)");
				if ($stmt === false) {
					trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
				}
				$bind = mysqli_stmt_bind_param($stmt, "sssssssss", $measurement_id, $hop_number, $hop_from, $round_trip_time1, $round_trip_time2, $round_trip_time3, $size_of_reply, $time_to_live, $is_varying);
				if ($bind === false) {
					trigger_error('Error: Bind of parameter failed. ', E_USER_ERROR);
				}
				$exec = mysqli_stmt_execute($stmt);
				if ($exec === false) {
					trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
				}
			}
			
		}
		
        // close database connection
		CheckrouteDatabase::close($link);
	}

    // returns true if a traceroute measurement with a single result contains a hop with a timeout
	// pre: measurement must only contain exactly one result
    public static function measurementContainsTimeoutHop($measurement_id)
    {
		// create and check connection
        $link = CheckrouteDatabase::connect();

		// query all ASNs for given country group
        $stmt = mysqli_prepare($link, "SELECT ");
        if ($stmt) {
            mysqli_stmt_bind_param($stmt, "s", $country_group_id);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_bind_result($stmt, $result);

            $result_asn = array();
            while (mysqli_stmt_fetch($stmt)) {
                $result_asn[] = $result;
            }
            mysqli_stmt_close($stmt);
        }		

        // close database connection
		CheckrouteDatabase::close($link);
		
		return ??
    }

	
}
 
?>