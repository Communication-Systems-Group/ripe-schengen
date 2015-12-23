<?php

class ZipDownloader
{

    public static function temporary_zip_download($url, $temp_filename_base, $temp_path = '')
    {
        // path to save temporary zip file
        $temporary_file_path = $target;

        // construct temporary file name for downloaded zip file
        $timestamp = time();
        $current_year = date("Y", $timestamp);
        $current_month = date("m", $timestamp);
        $current_day = date("d", $timestamp);
        $current_hour = date("H", $timestamp);
        $current_minute = date("i", $timestamp);
        $current_second = date("s", $timestamp);
        $temp_file_name = $temp_filename_base . '_' . $current_year . '-' . $current_month . '-' . $current_day . '_' . $current_hour . $current_minute . $current_second;
        
        // create handle to local temporary file copy
        $temp_file_handle = fopen($temp_path . $temp_file_name, 'wb');
        
        // prepare and execute download using curl
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_FILE, $temp_file_handle);
        curl_setopt($ch, CURLOPT_HEADER, false);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_exec($ch);
        
        // close file handle for temporary copy
        fclose($temp_file_handle);
        
        // check whether download was successful
        $info = curl_getinfo($ch);
        $download_successful = false;
        if($info['http_code'] == 200) {
            $download_successful = true;
            $success_message = 'Download successful.';
        }
        else {
            $success_message = 'Error: Download of ZIP file failed.';
        }
        
        // create result array
        $result_array = array();
        $result_array['successful'] = $download_successful;
        $result_array['success_message'] = $success_message;
        $result_array['temp_file_name'] = $temp_file_name;
        $result_array['total_time'] = $info['total_time']; // total time for download
        $result_array['size_download'] = $info['size_download']; // download size
        
        return $result_array;
    }

}
 
?>
