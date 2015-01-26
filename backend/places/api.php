<?php
    
error_reporting(E_ALL ^ E_NOTICE);
    
require_once("config.php");
require_once("function.php");

if ($disable_gpc) {
    disableGPC();
}

if (!isset($_REQUEST["mode"])) {
    return_fail_json("Error parameter");
}
$action = $_REQUEST["mode"];
$exclude_hash = Array("get_face_share");
if ($use_hash && !in_array($action, $exclude_hash)){
    calculateHash("");
}

/** input validated, connecting database **/
mysql_connect($dbhost, $dbuser, $dbpass) or return_fail_json("Cannot connect mysql");
mysql_select_db($dbname) or return_fail_json("Database doesn't exist");

header("Content-type: text/plain");
$EARTH_RADIUS_IN_METERS = 6371 * 1000;
    
if ($action == "searchPoints") {
    checkParameters(Array("latitude","longitude"));
    //testing
    //$userId = escapeSql($_GET['userId']);
    $center_lat = (real)$_GET['latitude'];
    $center_lng = (real)$_GET['longitude'];
    $query = sprintf("SELECT id, places.name, description,category,address, lat, lng, ( 6372 * 1000 * acos( cos( radians('%s') ) * cos( radians( lat ) ) * cos( radians( lng ) - radians('%s') ) + sin( radians('%s') ) * sin( radians( lat ) ) ) ) AS distance FROM places JOIN users_places ON places.id=users_places.place_id JOIN users ON users_places.user_id=users.fs_id WHERE users.access='allow' GROUP BY place_id ORDER BY distance LIMIT 0 , 10", $center_lat, $center_lng, $center_lat);
    $result = mysql_query($query);
    if (!$result) {
        return_fail_json('Invalid Query');
    }
    $counter = 0;
    $results = array();
    while ($row = @mysql_fetch_assoc($result)) {
        $res = array('id'=>$row['id'],'name'=>$row['name'],'category'=>$row['category'],'address'=>$row['address'],'distance'=>$row['distance'],'latitude'=>$row['lat'],'longitude'=>$row['lng']);
        $results[] = $res;
        $counter++;
    }
    //print_r($results);
    $value = array('count'=>$counter,'points'=>$results);
    return_success_json($value);
    mysql_close($connection);
    //echo $query;    
} else if ($action == "addPoint"){
    $fields = Array('id','name','description','category','verified','phone','twitter','address','crossStreet','city','state','postalCode','country','lat','lng');
    checkParameters($fields);
    checkParameters(Array("userId"));
    //checkParameters(Array("userId", "venueId", "name", "description", "category", "latitude", "longitude"));
    $userId = escapeSql($_GET['userId']);
    $cleans = Array();
    $values = Array();
    for ($i=0; $i<count($fields); $i++){
        $f = $fields[$i];
        if ($f == "verified"){
            $cleans[$f] = (int)$_GET[$f];
            $values[] = $cleans[$f];
        } else if ($f == "lat" || $f == "lng"){
            $cleans[$f] = (real)$_GET[$f];
            $values[] = $cleans[$f];
        } else {
            $cleans[$f] = urldecode($_GET[$f]);
            $values[] = "'".escapeSql($cleans[$f])."'";
        }
    }
    //$venueId = escapeSql($_GET['id']);
    //$name = escapeSql($_GET['name']);
    //$description = escapeSql($_GET['description']);
    //$category = escapeSql($_GET['category']);
    //$latitude = (real)$_GET['lat'];
    //$longitude = (real)$_GET['lng'];
    $query = sprintf("REPLACE INTO places (%s) VALUES (%s)", join(',',$fields), join(',',$values));
    $result = mysql_query($query);
    if (!$result) return_fail_json('Invalid Query');
    $query = sprintf("INSERT IGNORE INTO users_places (user_id,place_id) VALUES ('%s','%s')", $userId, $cleans['id']);
    $result = mysql_query($query);
    if (!$result) return_fail_json('Invalid Query');
    $affected = mysql_affected_rows();
    if ($affected > 0){
        $res = array('id'=>$cleans['id'],'name'=>$cleans['name'],'category'=>$cleans['category'],'address'=>$cleans['address'],'distance'=>0,'latitude'=>$cleans['lat'],'longitude'=>$cleans['lng']);
        return_success_json(Array('point'=>$res));
    } else {
        return_success_json(Array());
    }
} 
else if ($action == "removePoint"){
    checkParameters(Array("userId", "venueId"));
    $userId = escapeSql($_GET['userId']);
    $venueId = escapeSql($_GET['venueId']);
    $query = sprintf("DELETE FROM users_places WHERE user_id='%s' && place_id='%s'", $userId, $venueId);
    $result = mysql_query($query);
    if (!$result) return_fail_json('Invalid Query');
    return_success_json(Array());
}
else if ($action == "checkAccess"){
    checkParameters(Array("fsId", "name"));
    $fsId = escapeSql($_GET['fsId']);
    $name = escapeSql($_GET['name']);
    $query = sprintf("SELECT access FROM users WHERE fs_id='%s'", $fsId);
    $result = mysql_query($query);
    if (!$result)
        return_fail_json('Invalid Query');
    if (mysql_num_rows($result) == 0){
        $result = mysql_query(sprintf("INSERT INTO users (fs_id,name,access) VALUES ('%s','%s','%s')", $fsId, $name, 'pending'));
        if (!$result) return_fail_json('Invalid query');
        
        return_success_json(Array('access'=>'pending'));
    } else {
        $row = mysql_fetch_assoc($result);
        return_success_json(Array('access'=>$row['access']));
    }
} 
else if ($action == "checkDeviceAccess"){
    checkParameters(Array("deviceId"));
    $deviceId = escapeSql($_GET['deviceId']);
    $query = sprintf("SELECT * FROM admin_devices WHERE udid='%s' AND access=1", $deviceId);
    $result = mysql_query($query);
    if (!$result) return_fail_json('Invalid Query');
    if (mysql_num_rows($result) == 1){
        return_success_json(Array('access'=>'admin'));
    } else {
        return_success_json(Array('access'=>'public'));
    }
}
else {
    return_fail_json("Mode not specified");
}
    
?>    
    
    