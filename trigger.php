<?php

/* GET args:
* c[omponent]=[fiteagle]
*/

/** 
* configuration
*/
$app_config = array(
	'fiteagle' => array( 'state_file' => "/tmp/fiteagle_module-ci-ok.txt"),
	'omn' => array( 'state_file' => "/tmp/fiteagle_module-ci-ok.txt"),
	'integration' => array( 'state_file' => "/tmp/fiteagle_integration-ok.txt"),
	'integration-src' => array('ignore' => 1)
);

//print_r($_REQUEST);

if (isset($_REQUEST['component'])){
	$component = $_REQUEST['component'];
}else if (isset($_REQUEST['c'])){
	$component = $_REQUEST['c'];
}else{
	http_response_code(404);
	echo "Unknown component\n";
	exit();
}

if (!empty($component) && !empty($app_config[$component])) 
{
	//	$text = date("c\n");
	$text = time() . "\n";
	if (isset($app_config[$component]['state_file']))
	{
		if (!file_exists($app_config[$component]['state_file'])){
			file_put_contents($app_config[$component]['state_file'],$text);
			echo "OK\n";
		}else{
			echo "OK; already triggered\n";
		}
	}
	elseif (isset($app_config[$component]['ignore']))
	{
		echo "OK; Ignored\n";
	}
	else
	{
		http_response_code(500);
		echo "config error!";
	}
}
