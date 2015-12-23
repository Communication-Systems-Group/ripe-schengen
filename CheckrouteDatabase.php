<?php

include 'settings.php';

class CheckrouteDatabase
{

    // create and check connection to database
    public static function connect()
    {
        // create and check connection
        $link = mysqli_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME);
        if (mysqli_connect_errno()) {
            printf("Connect failed: %s\n", mysqli_connect_error());
            exit();
        }

        // set character set to UTF-8
        if (!mysqli_set_charset($link, "utf8")) {
            printf("Error loading UTF-8 character set: %s\n", mysqli_error($link));
            exit();
        }
		
        return $link;
    }

    // create and check connection to database
    public static function close($link)
    {
        // close connection
		mysqli_close($link);
    }

}
 
?>
