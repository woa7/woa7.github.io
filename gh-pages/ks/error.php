<?php
  $dir = dirname($_SERVER["REQUEST_URI"]);
  $req = basename($_SERVER["REQUEST_URI"]);

  function replace($config, $release, $arch="", $remove_packages=array()) {
    global $dir, $part_names;
    if ($arch=="") {
      $arch = $_SERVER["HTTP_X_ANACONDA_ARCHITECTURE"];
      if ($arch=="" or $arch=="i586" or $arch=="i686") $arch="i386";
    }
    if ($release=="") {
      if ($_REQUEST["release"]) {
        $release=$_REQUEST["release"];
      } else {
        $release=15;
      }
    }
    if (is_numeric("$release")) {
      $testing = "";
    } else {
      $testing = "test/";
    }
    if ($arch=="x86_64") {
      $lurl = "fedora/releases/$testing$release/Fedora/$arch/os";
    } else {
      $lurl = "fedora/releases/$testing$release/Fedora/$arch/os";
    }
    # try to guess, if it's a rawhide/devel
    $rawhide = FALSE;
    if ($config != "centos") {
      $rf = @fopen("http://ftp.upjs.sk/fedora/releases/$testing$release/Fedora/$arch/os", "r");
      if (!$rf) {
        $lurl = "fedora/development/$release/$arch/os/";
        $rawhide = TRUE;
      } else {
        fclose($rf);
      }
    }
    header("Content-type: text/plain", TRUE, 200);
    $section = "";
    $f = fopen("$config", "r");
    while (!feof($f)) {
      $row = fgets($f, 4096);
      # sections
      if (preg_match("/^% if /", "$row")) {
        $section = substr($row, 5, -1);
        continue;
      } else if (preg_match("/^% endif/", "$row")) {
        $section = "";
        continue;
      }
      if ("$section" and ("$section" != "$config")) {
        continue;
      }
      # replaces
      $row = preg_replace(";/i[35]86/;", "/$arch/", "$row");
      $row = preg_replace(";/f[0-9]{2} ;", "/$lurl ", "$row");
      $row = preg_replace(";fedora[0-9]{2} ;", "fedora$release ", "$row");
      $row = preg_replace(";/[0-9]{2}/;", "/$testing$release/", "$row");
      $row = preg_replace(";(http://$_SERVER[HTTP_HOST])$dir/$config;", "\$1$_SERVER[REQUEST_URI]", "$row");
      if ($rawhide) {
        $row = preg_replace(";/releases/$release/Fedora/;", "/development/$release/", "$row");
      }
      #if ($rawhide or $testing) {
      #  # no updates for rawhide/devel/testing
      #  if (preg_match(";pub/fedora/linux/updates;", "$row")) $row = "#$row";
      #  if (preg_match(";fedora/updates/;", "$row")) $row = "#$row";
      #}
      # remove packages, which are not present on current media
      foreach($remove_packages as $key) {
        if (trim("$row")=="$key") $row="#$row";
      }
      echo "$row";
    }
    fclose($f);
  }

  preg_match('/^(xen|pc|fedora|centos|desktop|)(|64_)([0-9]+|auto)(|-Alpha|-Beta|-Preview)$/', "$req", $matches);
  $config = "$matches[1]";
  if ("$config"=="") $config="fedora";
  $remove_packages = array();
  $release = "$matches[3]$matches[4]";
  if ($release=="auto") {
    if (preg_match('|^anaconda/[0-9]+\.[0-9]+$|', $_SERVER["HTTP_USER_AGENT"])) {
      $release = preg_replace('|^anaconda/([0-9]+)\.[0-9]+$|', '$1',
                              $_SERVER["HTTP_USER_AGENT"]);
    }
    #if ($_SERVER["X-ANACONDS-SYSTEM-RELEASE"]=="CentOS") {
    #}
  }
  echo "# system: $config, release: $release\n";
  if ("$matches[2]"=="64_") {
    replace("$config", "$release", "x86_64", $remove_packages);
  } else {
    replace("$config", "$release", "", $remove_packages);
  }
?>
