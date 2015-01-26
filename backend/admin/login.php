<?php

session_start();

if ($_SESSION["admin_login"] == 1) {
	header("location: index.php");
}

if (isset($_POST["username"]) && $_POST["password"]){
	$username = $_POST["username"];
	$password = $_POST["password"];
	if ($username == "admin" && $password == "t0n1pl2c3s"){
		$_SESSION["admin_login"] = 1;
		header("location: index.php");
	}
}

include "header.php";
?>
<div id="login-container">
    <div id="failed_login">
        <div id="message">
            <?php
            if (false){
                echo "<img alt='' src='".base_url().
                    "assets/images/alert_sign.gif' width='24px' height='20px' /> &nbsp; Invalid login!";
            } ?>
        </div>
    </div>
    <div id="menu_login">
        <form name="member-login" action="login.php" method="post">
        <h2 class="mem">Tony Places Administrator</h2>
            <label>Username</label>
            <input type="text" name="username" />
            <label>Password</label>
            <input type="password" name="password" />

            <p class="div"></p>
            <input type="submit" name="login" value="" class="login" />
        </form>
    </div>
</div>
<?php
include "footer.php";
?>