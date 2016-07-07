<?php

# This script is useful if you've added an exiftool field mapping and would like to update RS fields with the original file information 
# for all your resources.

include "../../include/db.php";
include_once "../../include/general.php";
include "../../include/resource_functions.php";
// include "./rsfs_functions.php";

$rid=intval(getvalescaped("r", false));

$path = get_resource_path ($rid, true,"",true );
$data = get_resource_data($rid);
$fields = get_resource_field_data($rid);

$resourceData = array();

$resourceData['id'] = $rid;

foreach ($fields as $field) {
	
	if ($field['name'] == 'originalfilename') {
		$resourceData['filename'] = $field['value'];
	}

	if ($field['name'] == 'originalfilename') {
		$resourceData['filename'] = $field['value'];
	}
}

$resourceData['size'] = intval($data['file_size']);

echo json_encode($resourceData);