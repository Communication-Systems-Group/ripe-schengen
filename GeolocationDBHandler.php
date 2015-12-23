<?php

include_once 'CheckrouteDatabase.php';
include_once 'ZipDownloader.php';

/*

http://download.db-ip.com/free/dbip-country-2015-11.csv.gz

*/


class GeolocationDBHandler
{

    // get geolocation data (ip to country mapping) from ip2location
    public static function get_geolocation_data_ip2location($keep_temporary_file = false)
    {
        // path and filename of source files at ip2location
        define('IP2LOCATION_PATH', 'http://download.ip2location.com/lite/IP2LOCATION-LITE-DB1.CSV.ZIP');
        define('IP2LOCATION_CSV_FILENAME', 'IP2LOCATION-LITE-DB1.CSV');
        
        // todo: check whether there is (maybe) not enough memory
        
        // download temporary copy of ip2location zip file
        $temporary_file_path = '';
        $zip_download = ZipDownloader::temporary_zip_download(IP2LOCATION_PATH, 'Ip2location-lite-db1', '');
        echo $zip_download['success_message'] . '<br />';
        
        // read content of csv file in temporary zip file (if download successful)
        if($zip_download['successful']) {
            echo 'Total time for download: ' . $zip_download['total_time'] . '<br />';
            echo 'Size of downloaded file: ' . $zip_download['size_download'] . '<br />';
            $zip_handle = new ZipArchive();
            if ($zip_handle->open($temporary_file_path . $zip_download['temp_file_name'])) {
                $csv_file_handle = $zip_handle->getStream(IP2LOCATION_CSV_FILENAME);
                if(!$csv_file_handle) {
                    exit('Error: could not read CSV file within ZIP file.<br />');
                }
                
                // put data into an array
                $geolocation_data = array();
                while (($data = fgetcsv($csv_file_handle, 0, ',', '"')) !== false) {
                    if (count($data) !== 4) {
                        exit('Error: CSV file structure faulty.');
                    }
                    $new_entry = array();
					//if (!(intval($data[0]) == 0 && intval($data[1]) == 16777215) && !(intval($data[0]) == 16777216 && intval($data[1]) == 16777471) && !(intval($data[0]) == 2147483647 && intval($data[1]) == 2147483647)) { // filter out reserved addresses
					    $new_entry['ip_from'] = floatval($data[0]);
                        $new_entry['ip_to'] = floatval($data[1]);
					    if ($data[2] == '-') {
					    	$new_entry['country'] = NULL;
					    } else {
					    	$new_entry['country'] = $data[2];
					    }
					    $new_entry['assigning_rir'] = NULL;
					    $new_entry['assigning_date'] = NULL;
                        $geolocation_data[] = $new_entry;
					//}
                }
                fclose($csv_file_handle);
                echo 'Data successfully extracted: ' . count($geolocation_data) . ' lines.<br />';
                
            } else {
                echo 'Error: Could not open downloaded temporary copy of ZIP file.<br />';
            }

            // delete temporary zip file if specified by parameter
            if(!$keep_temporary_file) {
                unlink($temporary_file_path . $zip_download['temp_file_name']);
            }
        }
        
        return $geolocation_data;
    }

    // get geolocation data (ip to country mapping) from software77
    public static function get_geolocation_data_software77($keep_temporary_file = false)
    {
        // path and filename of source files at ip2location
        define('SOFTWARE77_PATH', 'http://software77.net/geo-ip/?DL=2');
        define('SOFTWARE77_CSV_FILENAME', 'IpToCountry.csv');
        
        // download temporary copy of software77 zip file
        $temporary_file_path = '';
        $zip_download = ZipDownloader::temporary_zip_download(SOFTWARE77_PATH, 'Software77-IpToCountry', '');
        echo $zip_download['success_message'] . '<br />';
        
        // read content of csv file in temporary zip file (if download successful)
        if($zip_download['successful']) {
            echo 'Total time for download: ' . $zip_download['total_time'] . '<br />';
            echo 'Size of downloaded file: ' . $zip_download['size_download'] . '<br />';
            $zip_handle = new ZipArchive();
            if ($zip_handle->open($temporary_file_path . $zip_download['temp_file_name'])) {
                $csv_file_handle = $zip_handle->getStream(SOFTWARE77_CSV_FILENAME);
                if(!$csv_file_handle) {
                    exit('Error: could not read CSV file within ZIP file.<br />');
                }
                
                // put data into an array
                $geolocation_data = array();
				
                while (($data = fgetcsv($csv_file_handle, 0, ',', '"')) !== false) {
					if (!(substr($data[0], 0, 1) == '#')) { // leave out header rows
                        if (count($data) !== 7) {
                            exit('Error: CSV file structure faulty.');
                        }
						
						if($data[2] != "iana") { // entries with 'iana' in this field are reserved address spaces
							$new_entry = array();
							$new_entry['ip_from'] = floatval($data[0]);
							$new_entry['ip_to'] = floatval($data[1]);
							if ($data[4] == 'ZZ' || $data[4] == 'AP') {
								$new_entry['country'] = NULL;
							} else {
								$new_entry['country'] = $data[4];
							}
							if ($data[2] == 'ripencc') {
								$new_entry['assigning_rir'] = 'RIPE NCC';
							} else {
								$new_entry['assigning_rir'] = strtoupper($data[2]);
							}
							if ($data[3] == 0) {
								$new_entry['assigning_date'] = NULL;
							} else {
								$new_entry['assigning_date'] = date("Y-m-d", $data[3]);
							}
							$geolocation_data[] = $new_entry;
						}
					}
                }
                fclose($csv_file_handle);
                echo 'Data successfully extracted: ' . count($geolocation_data) . ' lines.<br />';
                
            } else {
                echo 'Error: Could not open downloaded temporary copy of ZIP file.<br />';
            }

            // delete temporary zip file if specified by parameter
            if(!$keep_temporary_file) {
                unlink($temporary_file_path . $zip_download['temp_file_name']);
            }
        }
        
        return $geolocation_data;
    }
	
	
    // get geolocation data (ip to country mapping) from maxmind (GeoLite)
    public static function get_geolocation_data_maxmind($keep_temporary_file = false)
    {
        // path and filename of source files at ip2location
        define('MAXMIND_PATH', 'http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip');
        define('MAXMIND_CSV_FILENAME', 'GeoIPCountryWhois.csv');
        
        // download temporary copy of maxmind GeoLite zip file
        $temporary_file_path = '';
        $zip_download = ZipDownloader::temporary_zip_download(MAXMIND_PATH, 'Maxmind-GeoLite-GeoIPCountry', '');
        echo $zip_download['success_message'] . '<br />';
        
        // read content of csv file in temporary zip file (if download successful)
        if($zip_download['successful']) {
            echo 'Total time for download: ' . $zip_download['total_time'] . '<br />';
            echo 'Size of downloaded file: ' . $zip_download['size_download'] . '<br />';
            $zip_handle = new ZipArchive();
            if ($zip_handle->open($temporary_file_path . $zip_download['temp_file_name'])) {
                $csv_file_handle = $zip_handle->getStream(MAXMIND_CSV_FILENAME);
                if(!$csv_file_handle) {
                    exit('Error: could not read CSV file within ZIP file.<br />');
                }
                
                // put data into an array
                $geolocation_data = array();
                while (($data = fgetcsv($csv_file_handle, 0, ',', '"')) !== false) {
                    if (count($data) !== 6) {
                        exit('Error: CSV file structure faulty.');
                    }
					$new_entry = array();
					$new_entry['ip_from'] = floatval($data[2]);
					$new_entry['ip_to'] = floatval($data[3]);
					if ($data[4] == 'A1' || $data[4] == 'A2' || $data[4] == 'AP') {
						// A1 stands for "Anonymous Proxy"
						// A2 stands for "satellite provider"
						// AP stands for "Asia/Pacific Region"
						$new_entry['country'] = NULL;
					} else {
						$new_entry['country'] = $data[4];
					}
					$new_entry['assigning_rir'] = NULL;
					$new_entry['assigning_date'] = NULL;
					$geolocation_data[] = $new_entry;
                }
                fclose($csv_file_handle);
                echo 'Data successfully extracted: ' . count($geolocation_data) . ' lines.<br />';
                
            } else {
                echo 'Error: Could not open downloaded temporary copy of ZIP file.<br />';
            }

            // delete temporary zip file if specified by parameter
            if(!$keep_temporary_file) {
                unlink($temporary_file_path . $zip_download['temp_file_name']);
            }
        }
        
        return $geolocation_data;
    }

	// ....
	public static function write_geolocation_data_to_db($geolocation_data, $source)
    {
        // create and check connection
        $link = CheckrouteDatabase::connect();

        // write all entries in AS list to database
        foreach ($geolocation_data as $geolocation_entry) {
            $stmt = mysqli_prepare($link, "INSERT INTO IPRange_belongs_to_Country (ip_from, ip_to, country_code, assigning_rir, assigning_date, source) VALUES (?, ?, ?, ?, ?, ?)");
            if ($stmt === false) {
                trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
            }
            $bind = mysqli_stmt_bind_param($stmt, "ssssss", $geolocation_entry['ip_from'], $geolocation_entry['ip_to'], $geolocation_entry['country'], $geolocation_entry['assigning_rir'], $geolocation_entry['assigning_date'], $source);
            if ($bind === false) {
                trigger_error('Error: Bind of parameters failed. ', E_USER_ERROR);
            }
            $exec = mysqli_stmt_execute($stmt);
            if ($exec === false) {
				print_r($geolocation_entry);
                trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
            }
        }

        // close database connection
		CheckrouteDatabase::close($link);
    }

}
 
?>
