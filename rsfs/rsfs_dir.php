<?php

# This script is useful if you've added an exiftool field mapping and would like to update RS fields with the original file information 
# for all your resources.

include "../../include/db.php";
include_once "../../include/general.php";
include "../../include/resource_functions.php";
// include "./rsfs_functions.php";

$dir=getvalescaped("dir", '/');


echo $dir;