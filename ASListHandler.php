<?php

include_once 'CheckrouteDatabase.php';
include_once 'ZipDownloader.php';

/*

http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum2.zip

*/

class ASListHandler
{

    var $status;

    // get ip range to as mapping file from maxmind and save results in database table
    public static function get_as_data_maxmind($keep_temporary_file = false)
    {
        // path and filename of source files at maxmind
        define('MAXMIND_PATH', 'http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum2.zip');
        define('MAXMIND_CSV_FILENAME', 'GeoIPASNum2.csv');
        
        // check whether there is (maybe) enough memory
        echo 'memory_limit = ' . ini_get('memory_limit') . "<br />\n";
        #if () {
        #}

        // download temporary copy of maxmind zip file
        $temporary_file_path = '';
        $zip_download = ZipDownloader::temporary_zip_download(MAXMIND_PATH, 'GeoIPASNum2', '');
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
                $as_data = array();
                while (($data = fgetcsv($csv_file_handle, 0, ',', '"')) !== false) {
                    if (count($data) !== 3) {
                        exit('Error: CSV file structure faulty.');
                    }
                    $new_entry = array();
                    $new_entry['ip_from'] = $data[0];
                    $new_entry['ip_to'] = $data[1];
                    $as_number_and_name = $data[2];
                    $pattern_asn = '/AS\d+/';
                    preg_match($pattern_asn, $as_number_and_name, $parsed_asn);
                    $new_entry['number'] = substr($parsed_asn[0], 2);
                    $pattern_name = '/\s.+/';
                    preg_match($pattern_name, $as_number_and_name, $parsed_name);
                    $new_entry['name'] = substr($parsed_name[0], 1);
                    $as_data[] = $new_entry;
                }
                fclose($csv_file_handle);
                echo 'Data successfully extracted: ' . count($as_data) . ' lines.<br />';
                
            } else {
                echo 'Error: Could not open downloaded temporary copy of ZIP file.<br />';
            }

            // delete temporary zip file if specified by parameter
            if(!$keep_temporary_file) {
                unlink($temporary_file_path . $temporary_file_name);
            }
        }

        #for ($i = count($as_data) - 1; $i > 230677; $i--) {
        #    echo $as_data[$i]['ip_from'] . ' // ' . $as_data[$i]['ip_to'] . ' // ' . $as_data[$i]['number'] . ' // ' . $as_data[$i]['name'] . '<br />';
        #}

        /*
for ($i = 0; $i < count($as_data); $i++) {
    if ($as_data[$i]['number'] == NULL) {
        echo 'Fehler: ' . $i . '<br />';
        echo $as_data[$i - 1]['number'] . '<br />';
        echo $as_data[$i]['name'] . '<br />';
        echo $as_data[$i + 1]['number'] . '<br />';
    }
}
        */
        
        return $as_data;    
    }

    // returns an array with all autonomous systems of a certain country given as parameter
    public static function get_country_data_hurricane_electric($country_code)
    {
        # create and execute curl request to Hurricane Electric website
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($curl, CURLOPT_HEADER, false);
        curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($curl, CURLOPT_URL, 'bgp.he.net/country/'.$country_code);
        curl_setopt($curl, CURLOPT_REFERER, 'bgp.he.net');
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
        curl_setopt($curl, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.125 Safari/533.4");
        $str = curl_exec($curl);
        curl_close($curl);

        # instantiate DOM parser object
        $dom = new DOMDocument();
        @$dom->loadHTML($str);

        # parse table with AS data
        $table_asns = $dom->getElementById('asns');
        if($table_asns == NULL) {
            //die("Error: Table with AS information could not be found.");
            echo "Error: Table with AS information could not be found.";
            return NULL;
        }
        $table_asns_body = $table_asns->getElementsByTagName('tbody');
        $table_asns_rows = $table_asns_body->item(0)->getElementsByTagName('tr');        
        #echo 'Found ' . $table_asns_rows->length . ' rows...';
        
        # create array with row data
        $asn_list = array();
        foreach ($table_asns_rows as $row) {
            $new_entry = array();
            $cols = $row->getElementsByTagName('td');
            $str2 = substr($str, 4);
            $new_entry['number'] = substr($cols->item(0)->nodeValue, 2);
            $new_entry['name'] = $cols->item(1)->nodeValue;
            $new_entry['country'] = $country_code;
            $asn_list[] = $new_entry;
        }
        
        return $asn_list;
    }

    // returns an array with all autonomous systems of a certain country given as parameter
    public static function get_as_data_cidr()
    {
        # path of source files at for CIDR
        define('CIDR_URL', 'http://www.cidr-report.org/as2.0/autnums.html');
        // alternative url: http://bgp.potaroo.net/cidr/autnums.html

        # create and execute curl request to CIDR website
        $cmd_get = 'curl ' . CIDR_URL;
        exec($cmd_get, $result_get);

        # check if empty
        if($result_get == NULL) {
            echo "Error: Response was empty.";
        }
        
        # parse html and write to array
        $as_list = array();
        foreach($result_get as $line){
            if (substr($line, 0, 2) === "<a") {
                // get asn with regexp
                $pattern_asn = '/AS\d+/';
                preg_match($pattern_asn, $line, $parsed_asn);
                $asn = substr($parsed_asn[0], 2);
                
                // get country with regexp
                $pattern_country = '/,[A-Z][A-Z]\z/';
                preg_match($pattern_country, $line, $parsed_country);               
                $country_code = substr($parsed_country[0], 1, 2);
                
                // get name with regexp
                $pattern_name = '/>\s.+/';
                preg_match($pattern_name, $line, $parsed_name);
                $name = substr(substr($parsed_name[0], 2), 0, -3);
                
                // write row into array
                $new_entry = array();
                $new_entry['number'] = $asn;
                $new_entry['name'] = $name;
                $new_entry['country'] = $country_code;
                $as_list[] = $new_entry;
                
            }
            elseif (substr($line, 0, 2) === "<I") {
                // todo: get date of last modification
            }
        }
        
        echo 'Successfully loaded and parsed data. Found ' . count($as_list) . ' rows.<br />';
        return $as_list;
    }

    // ....
    public static function update_all_as_data()
    {
        /* update HE */
        foreach ($country_list as $country) {
            $myarray = ASListHandler::get_country_data_hurricane_electric($country);
            if ($myarray != NULL) {
                ASListHandler::write_as_list_to_db($myarray, 'HE');
                echo 'Successfully wrote date for country ' . $country . ' to database.<br/>';
            } else {
                echo 'No information found for country ' . $country . '.<br/>';    
            }
        }
        
        /* update Maxmind */
        $mydata = ASListHandler::get_as_data_maxmind();
        // duplikate herausfiltern
        $as_list = array();
        foreach ($mydata as $val) {
            $as_list[$val['number']] = $val;
        }
        ASListHandler::write_as_list_to_db($as_list, 'Maxmind');
        
        /* update CIDR */



    }

    public static function write_as_list_to_db($as_list, $source)
    {
        // create and check connection
        $link = CheckrouteDatabase::connect();

        // write all entries in AS list to database
        foreach ($as_list as $as_entry) {
            $as_number = $as_entry['number'];
            if ($as_entry['name'] == NULL) {
                $as_name = '?? (n/a) ??';
            } else {
                $as_name = $as_entry['name'];
            }
            if (array_key_exists('country', $as_entry)) {
                $as_country_code = $as_entry['country'];
            } else {
                $as_country_code = NULL;
            }
            $as_source = $source;

            $stmt = mysqli_prepare($link, "INSERT INTO AutonomousSystem (asn, name, owner, country_code, registration_date, source) VALUES (?, ?, NULL, ?, NULL, ?)");
            if ($stmt === false) {
                trigger_error('Error: Insert statement failed. ' . htmlspecialchars(mysqli_error($mysqli)), E_USER_ERROR);
            }
            $bind = mysqli_stmt_bind_param($stmt, "ssss", $as_number, $as_name, $as_country_code, $as_source);
            if ($bind === false) {
                trigger_error('Error: Bind of parameters failed. ', E_USER_ERROR);
            }
            $exec = mysqli_stmt_execute($stmt);
            if ($exec === false) {
                trigger_error('Error: execution of statement failed. ' . htmlspecialchars(mysqli_stmt_error($stmt)), E_USER_ERROR);
            }
        }

        // close database connection
        mysqli_close($link);
    }
    
}
 
?>
