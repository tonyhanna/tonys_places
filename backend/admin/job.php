<?php

session_start();
require_once("../places/function.php");

function redirectMsg($msg) {
	$url = "index.php";
	if (isset($_GET["redirect"])) {
		$url = $_GET["redirect"];
	}
	if (strpos($url, "?") !== FALSE) {
		$url .= "&msg=$msg";
	} else {
		$url .= "?msg=$msg";
	}	
	header("location: $url");
}
function deleteFile($file) {
	if (file_exists($file)) {
		unlink($file);
	}
}

if (!isset($_SESSION["admin_login"])) {
	die("Access denied");
}
if (!isset($_REQUEST["action"])) {
	die("Error parameter");
}
$action = $_REQUEST["action"];

/** input validated, connecting database **/
require_once("../places/config.php");
mysql_connect($dbhost, $dbuser, $dbpass) or die("Cannot connect mysql");
mysql_select_db($dbname) or die("Database doesn't exist");

if ($action == "do_change_access") {
	checkParameters(Array("fsId","access"), Array());
    $fsId = escapeSql($_REQUEST['fsId']);
    $access = escapeSql($_REQUEST['access']);
    $result = mysql_query("UPDATE users SET access='$access' WHERE fs_id='$fsId'");
    if ($result){
        echo 1;
	} else {
        echo 0;
	}	
} 
else if ($action == "do_delete_access"){
    checkParameters(Array('fsId'));
    $fsId = escapeSql($_REQUEST['fsId']);
    $result = mysql_query("DELETE FROM users WHERE fs_id='$fsId'");
    redirectMsg('User has been deleted');
}
else if ($action == "do_changedevice"){
    checkParameters(Array('old_udid','udid','name','access'));
    $oldUdid = escapeSql($_REQUEST['old_udid']);
    $udid = escapeSql($_REQUEST['udid']);
    $name = escapeSql($_REQUEST['name']);
    $access = (int)$_REQUEST['access'];
    if ($oldUdid != "" && $oldUdid != $udid){
        mysql_query("DELETE FROM admin_devices WHERE udid='$oldUdid'");
    }
    $result = mysql_query("REPLACE INTO admin_devices (udid,name,access) VALUES ('$udid','$name',$access)");
    if ($result){
        redirectMsg('Device has been updated');
    } else {
        redirectMsg('Error updating device. '.mysql_error());
    }
} else if ($action == "do_deletedevice"){
    checkParameters(Array('udid'));
    $udid = escapeSql($_REQUEST['udid']);
    mysql_query("DELETE FROM admin_devices WHERE udid='$udid'");
    redirectMsg('Device has been deleted');
}
else {
	die("Wrong parameter");
}
?>