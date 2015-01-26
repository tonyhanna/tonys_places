<?php

// output image created by GD library
function outputImageGD($im) {
    header("Content-Type: image/jpeg");                  // Set the mime content type appropriately
	header("Cache-Control: max-age=3600; must-revalidate");	// Force cache to lower script access
    imagejpeg($im);        // Spit out the content
}

function escapeSql($s) {
	return mysql_real_escape_string(stripslashes($s));
}

function redirect($url) {
	header("location: $url");
}

function getServerPath($path) {
	$dir = $_SERVER["PHP_SELF"];
	$dir = substr($dir, 0, strrpos($dir, "/"));
	while (substr($path, 0, 2) == "..") {
		$path = substr($path, 2);
		if (strrpos($dir, "/") >= 0){
			$dir = substr($dir, 0, strrpos($dir, "/"));
		} else {
			$dir = "";
		}
		if ($path[0] == "/") {
			$path = substr($path, 1);
		}
	}
	if ($path[0] != "/") { 
		$path = "/".$path;
	}
	$path = "http://".$_SERVER["HTTP_HOST"].$dir.$path;
	return $path;
}

function checkParameters($requests, $files = null) {
	if ($requests) {
		foreach ($requests as $r) {
			if (!isset($_REQUEST[$r])) {
				return_fail("Error parameter ".$r);				
			}
		}
	}
	if ($files) {
		foreach ($files as $f) {
			if (!isset($_FILES[$f])) {
				return_fail("Error parameter ".$f);
			}
		}
	}
}

function return_fail($msg) {
	die("status=0&msg=$msg");
}
function return_fail_json($reason) {
    $result = array('status' => 'error', 'reason' => $reason);
    echo json_encode($result);
	die();
}
    
function return_success($data = null) {
	die("status=1".($data?"&$data":""));
}
function return_success_json($data = Array()) {
	$data["status"] = "success";
	$s = json_encode($data);
	die($s);
}

function disableGPC() {
	if (get_magic_quotes_gpc()) {
		$process = array(&$_GET, &$_POST, &$_COOKIE, &$_REQUEST);
		while (list($key, $val) = each($process)) {
			foreach ($val as $k => $v) {
				unset($process[$key][$k]);
				if (is_array($v)) {
					$process[$key][stripslashes($k)] = $v;
					$process[] = &$process[$key][stripslashes($k)];
				} else {
					$process[$key][stripslashes($k)] = stripslashes($v);
				}
			}
		}
		unset($process);
	}
}

function calculateHash($salt) {
	$params = array_merge($_GET, $_POST);
	if (!isset($params["h"])) {
		return_fail_json("Error: no hash");
	} else {
		$str = $salt;
		$arr = Array();
		
		//sort request by key
		foreach ($params as $k => $v) {
			if ($k != "h") {
				$arr[] = $k;
			}
		}
		sort($arr, SORT_STRING);
		foreach ($arr as $k) {
			$str .= $params[$k];
		}
				
		//sort files by key
		$arr = Array();
		foreach ($_FILES as $k => $v) {
			$arr[] = $k;
		}
		sort($arr, SORT_STRING);
		foreach ($arr as $k) {
			$str .= $_FILES[$k]["name"];
		}
		
		$hash = md5($str);
		if ($hash != $params["h"]) {
			return_fail_json("Error hash: ".$hash);
		}
	}
}

?>