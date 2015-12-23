<?php

include 'settings.php';
include_once 'CheckrouteDatabase.php';

class MeasurementCampaign
{
    var $id;
    var $name;
    var $description;
    
    // Konstruktor
    public function __construct($id, $name, $description)
    {
        $this->id = $id;
        $this->name = $name;
        $this->description = $description;
    }

    // returns an array with all IDs of the measurements belonging to the campaign
    public function get_measurement_ids()
    {
		// create and check connection
        $link = CheckrouteDatabase::connect();

        // query all measurements associated with a given measurement campaign
        $stmt = mysqli_prepare($link, "SELECT id_measurement FROM Campaign_has_Measurement WHERE id_campaign = ? ORDER BY id_measurement ASC");
        if ($stmt) {
            mysqli_stmt_bind_param($stmt, "s", $this->id);
            mysqli_stmt_execute($stmt);
            mysqli_stmt_bind_result($stmt, $result);

            $measurements_of_campaign = array();
            while (mysqli_stmt_fetch($stmt)) {
                $measurements_of_campaign[] = $result;
            }
            mysqli_stmt_close($stmt);
        }

        // close database connection
        mysqli_close($link);
        
        return $measurements_of_campaign;
    }

    // returns an array with all IDs of the measurements belonging to the campaign
    public function get_number_of_measurements()
    {
        return count($this->get_measurement_ids());
    }

    // returns an array with all measurement campaigns available in the database
    public static function get_all_campaigns()
    {        
        // create and check connection
        $link = CheckrouteDatabase::connect();

        // query all available measurement campaigns
        $stmt = mysqli_prepare($link, "SELECT x.id, x.name, x.description, COUNT(y.id_measurement) AS 'number_of_measurements' FROM MeasurementCampaign AS x, Campaign_has_Measurement AS y WHERE x.id = y.id_campaign GROUP BY x.id");
        if ($stmt) {
            mysqli_stmt_execute($stmt);
            //mysqli_stmt_bind_result($stmt, $result_sql);

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
