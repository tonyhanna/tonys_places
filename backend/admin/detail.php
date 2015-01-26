<?php

require_once("../places/config.php");
require_once("../places/function.php");
mysql_connect($dbhost, $dbuser, $dbpass) or die("Cannot connect mysql");
mysql_select_db($dbname) or die("Database doesn't exist");
    
session_start();
if ($_SESSION["admin_login"] != 1){
    die("Access denied");
}
    
if ($_GET["udid"]){
    $udid = escapeSql($_GET["udid"]);
} else {
    $udid = "";
}
$top = urlencode($_GET["top"]);

if (!empty($udid)){
    $result = mysql_query("SELECT * FROM admin_devices WHERE udid='$udid'");
    if (!$result) die("Device not found");
    $row = mysql_fetch_assoc($result);
} else {
    $row = Array('udid'=>'', 'name'=>'', 'access'=>1);
}

?>
<html>
	<head>
		<link rel="stylesheet" type="text/css" href="../css/admin.css" />
	</head>
	<body>
		<div id="action">
			<div>
				<form method="post" action="job.php?action=do_changedevice&old_udid=<?=$udid?>&redirect=<?=$top?>">
                <table>
                    <tr><td>Name:</td><td><input type="text" size="40" name="name" value="<?=$row['name']?>"/></td></tr>
                    <tr><td>UDID:</td><td><input type="text" size="40" name="udid" value="<?=$row['udid']?>"/></td></tr>
                    <tr><td>Admin:</td><td><select name="access"><option value="1" <?=$row['access']==1?'selected':''?>>Yes</option><option value="0" <?=$row['access']==0?'selected':''?>>No</option></select></td></tr>
					<tr><td colspan="2"><input type="submit" value="Submit"/></td></tr>
                </table>
				</form>
			</div>
            <div><a href="job.php?action=do_deletedevice&udid=<?=$udid?>&redirect=<?=$top?>"><button>Delete device</button></a></div>
		</div>
	</body>
</html>