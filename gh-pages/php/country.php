<?php
  header("Content-type: text/plain");
  echo "#!ipxe\n\n";
  $country = geoip_country_code_by_name($_SERVER["REMOTE_ADDR"]);
  if (!$country) {
    $country = "us";
  }
  echo "set country $country\n";
?>
