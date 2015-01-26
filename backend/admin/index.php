<?php
require_once("../places/config.php");
mysql_connect($dbhost, $dbuser, $dbpass) or die("Cannot connect mysql");
mysql_select_db($dbname) or die("Database doesn't exist");

session_start();

if ($_SESSION["admin_login"] != 1){
	header("location: login.php");
} else {

include "header.php";

/* ============= functions ============= */

function echo_page($p, $label) {
	global $sort, $view, $page;
	if ($p == $page)
		echo "<span class='current'>$label</span>";
	else
		echo "<span><a href='index.php?view=$view&sort=$sort&page=$p'>$label</a></span>";
}
function echo_pagination() {
	global $page, $count_gallery, $page_interval;
	$max_page = ceil($count_gallery / $page_interval);
	if ($max_page > 1){
		echo_page(1, "First");
		if (min($page-1,$max_page-2) > 2)
			echo "<span>...</span>";
		for ($i=max(min($max_page-2,$page-1),2); $i<=min(max(3,$page+1),$max_page-1); $i++){
			echo_page($i, $i);
		}
		if (max(3,$page+1) < $max_page-1)
			echo "<span>...</span>";
		echo_page($max_page, "Last");
	}
}
function sort_link($s) {
	global $sort, $view, $page;
	if ($sort == $s) {
		return "<a href='index.php?view=$view&sort=$s&page=$page' style='color:white'>$s</a>";		
	} else {
		return "<a href='index.php?view=$view&sort=$s&page=$page'>$s</a>";
	}
}

/* ============== read parameters ================ */

$view = $_GET["view"];
if ($view != "devices") $view = "access";

$page = 1;
$page_interval = 50;
//if (isset($_GET["interval"]))
//	$page_interval = $_GET["interval"];
if (isset($_GET["page"]))
	$page = $_GET["page"];
$page_query = "LIMIT ".($page_interval * ($page-1)).",$page_interval"; 

$sort = $_GET["sort"];
if ($sort != "name") $sort = "access";
if ($sort == "name"){
	$sort_query = "ORDER BY name, access DESC";
} else if ($sort == "access") {
	$sort_query = "ORDER BY access DESC, name";
}
if ($view == "access"){
	$sort_string = "sorted by ". sort_link("access") ." | ". sort_link("name");
} else if ($view == "devices"){
    $sort_string = "sorted by ". sort_link("access") ." | ". sort_link("name");
}

/* ================ fetch data ================ */


$result = mysql_query("SELECT count(*) as c FROM users");
$row = mysql_fetch_assoc($result);
$count_users = $row["c"];
$result = mysql_query("SELECT count(*) as c FROM admin_devices");
$row = mysql_fetch_assoc($result);
$count_devices = $row["c"];
    
if ($view == "access") {
	$count_gallery = $count_users;
	$result = mysql_query("SELECT * FROM users $sort_query $page_query");
	$title = "User access";
} else if ($view == "devices"){
    $count_gallery = $count_devices;
    $result = mysql_query("SELECT * FROM admin_devices $sort_query $page_query");
    $title = "Devices";
}

/* ================= display subheader ================ */

?>
<div id="wrapper">

<div id="menu">
    <div><a href="index.php?view=access">User access (<?=$count_users?>)</a></div>
    <div><a href="index.php?view=devices">Devices (<?=$count_devices?>)</a></div>
    <div><a href="logout.php">Logout</a></div>
</div>
<br/><br/>
<div id="title"><?=$title." ".$sort_string?><span class="pagination"><?php echo_pagination(); ?></span></div>
<?php if ($_GET["msg"]){ ?>
<div id="message"><?=$_GET["msg"]?></div>
<?php } ?>
<br style="clear: both;" />
<div id="content">
	<?php
	
	/* =================== display content ==================== */
	
	if ($view == "access") {
		
		if (mysql_num_rows($result) == 0) {
			echo "<span style='color:white'>No users</span>";
		}
        ?>
        <script type="text/javascript">
        function changeAccess(select){
            var id = $(select).attr('id').substr(7);
            var access = $(select).val();
            $.ajax({
                url: 'job.php?action=do_change_access&fsId='+id+'&access='+access,
                success: function(data) {
                   
                }
            });
        }
        </script>
        <table class="list">
        <tr><th>Name</th><th>Access</th><th></th></tr>
        <?php
		while ($row = mysql_fetch_assoc($result)) {	
			?>
            <tr>
                <td><?=$row["name"]?></td>
                <td><select id="access_<?=$row['fs_id']?>" onchange="changeAccess(this);">
                    <option value="allow" <?=($row['access']=='allow')?'selected':''?>>Allow</option>
                    <option value="deny" <?=($row['access']=='deny')?'selected':''?>>Deny</option>
                    <option value="pending" <?=($row['access']=='pending')?'selected':''?>>Pending</option>
                </select></td>
                <td><a onclick="return confirm('Are you sure to delete user <?=$row['name']?>?')" href="job.php?action=do_delete_access&fsId=<?=$row['fs_id']?>&top=<?=$_SERVER['REQUEST_URI']?>"><button>Delete</button></a></td>
            </tr>
			<?php
        }
        ?>
        </table>
        <?php
		
    } else if ($view == "devices"){
        
        if (mysql_num_rows($result) == 0) {
            echo "<span style='color:white'>No devices</span>";
        }
        ?>
        <a class="fancy" href="detail.php?top=<?=$_SERVER['REQUEST_URI']?>"><button>Add new device</button></a>
        <table class="list">
        <tr><th>Name</th><th>UDID</th><th>Admin</th></tr>
        <?php
            while ($row = mysql_fetch_assoc($result)) {	
                ?>
        <tr>
        <td><a class="fancy" href="detail.php?udid=<?=$row['udid']?>&top=<?=$_SERVER['REQUEST_URI']?>"><?=$row["name"]?></a></td>
        <td><?=$row["udid"]?></td>
        <td><?=$row["access"]==1?"Yes":"No"?></td>
        </tr>
        <?php
            }
            ?>
        </table>
        <?php
    }
	?>
</div>
<br style="clear: both;" />
<div class="bar">
	&nbsp;<span class="pagination"><?php echo_pagination(); ?></span>
</div>

<br style="clear: both;" />

</div>

<script type="text/javascript">
var thumbs = [];
var i = 0;

/* Apply fancybox to multiple items */
var fancy_width = 400;
var fancy_height = 200;
$("#content a.fancy").fancybox({
	'hideOnContentClick' : false,
	'hideOnOverlayClick' : false,
	'width'			: 	fancy_width, 
	'height' 		: 	fancy_height,
	'autoScale'		: 	false,
	'transitionIn'	:	'fade',
	'transitionOut'	:	'fade',
	'speedIn'		:	400, 
	'speedOut'		:	200, 
	'overlayShow'	:	true,
	'padding'		: 	0,
	'padding'		: 	0,
	'centerOnScroll': 	true,
	'autoDimension'	: 	false,
	'onComplete' : function() {
		 $('#fancybox-wrap').width(fancy_width);
		 $('#fancybox-wrap').height(fancy_height);

		$('#fancybox-content').width(fancy_width);
		 $('#fancybox-content').height(fancy_height);
		 
		$('#fancybox-content > div').width(fancy_width);
		 $('#fancybox-content > div').height(fancy_height);
	}	
});

</script>
</div>
<?php
include "footer.php";

}
?>
