<?php

/* GET args:
* c[omponent]=[fiteagle]
*/

/** 
* configuration
*/
$app_config = array(
	'fiteagle' => array( 'state_file' => "/tmp/fiteagle_module-ci-ok.txt"),
	'integration' => array( 'state_file' => "/tmp/fiteagle_integration-ok.txt")
);

if (isset($_REQUEST['component'])){
	$component = $_REQUEST['component'];
}else if (isset($_REQUEST['c'])){
	$component = $_REQUEST['c'];
}else{
	http_response_code(404);
	echo "Unknown component\n";
	exit();
}

if (!empty($component) && $component=="fiteagle") 
{
	//	$text = date("c\n");
	$text = time() . "\n";
	if (isset($app_config[$component]['state_file']))
	{
		file_put_contents($app_config[$component]['state_file'],$text);
		echo "OK\n";
	}
	else
	{
		http_response_code(500);
		echo "config error!";
	}
}
