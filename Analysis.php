<?php

include_once 'CheckrouteDatabase.php';

class Analysis
{

    // returns countrx for a given ip address
    public static function get_country_of_ip_address($ipv4_address, $source)
    {
		$ipv4_address_integer = ip2long($ipv4_address);
		
		echo $ipv4_address;
		echo '<br/>';
		echo $ipv4_address_integer;
		
        // create and check connection
        $link = CheckrouteDatabase::connect();

        // query all available measurement campaigns
        $stmt = mysqli_prepare($link, "SELECT country_code FROM IPRange_belongs_to_Country WHERE ip_from <= ? AND ip_to >= ? AND source = ?");
        if ($stmt) {
            mysqli_stmt_bind_param($stmt, "sss", $ipv4_address_integer, $ipv4_address_integer, $source);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_bind_result($stmt, $result);

            $result_asn = array();
            while (mysqli_stmt_fetch($stmt)) {
                $result_asn[] = $result;
            }
            mysqli_stmt_close($stmt);
        }

        // close database connection
        mysqli_close($link);
        
        return $result;
    }
	
	// SELECT `hop_number`, `from_ip`, `roundtrip_time1`, `roundtrip_time2`, `roundtrip_time3`, `ttl`, `is_timeout` FROM `TracerouteHop` WHERE `id_measurement` = 3103931 AND `result_number` = 1

// ca. 0.8 sec; enthält nur hops ohne timeout:
//SELECT x.`hop_number`, x.`from_ip`, y.`country_code`, x.`roundtrip_time1`, x.`roundtrip_time2`, x.`roundtrip_time3`, x.`ttl`, x.`is_timeout` FROM `TracerouteHop` AS x, `IPRange_belongs_to_Country` AS y WHERE x.`id_measurement` = 3103931 AND x.`result_number` = 1 AND y.`ip_from` <= x.`from_ip` AND y.`ip_to` >= x.`from_ip` AND y.`source` = 'ip2location' ORDER BY x.`hop_number` ASC;

}

?>
