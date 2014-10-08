<?php
  # $url = $_GET["url"];
  # $width = intval($_GET["width"]);
  # $height = intval($_GET["height"]);
  $url = substr(".".$_SERVER["REQUEST_URI"], strlen(dirname(".".$_SERVER["PHP_SELF"])));
  if (substr($_SERVER["HTTP_REFERER"], -12) === "?quickresize") {
    header("Location: http://whim.dk".$url);
    die("Redirecting to production");
  }
  if (
    strtolower(substr($url, -4)) !== ".jpg" &&
    strtolower(substr($url, -5)) !== ".jpeg" &&
    strtolower(substr($url, -4)) !== ".gif" &&
    strtolower(substr($url, -4)) !== ".png"
  ) {
    header(404);
    die("<h1>not found!</h1>");
  }
  $sfile = substr($url,1);
  $sdir = dirname($sfile);
  if (!is_dir($sdir)) {
    mkdir($sdir);
  }
  $file = dirname($sdir)."/".basename($sfile);
  $size = explode("x", basename($sdir));
  $width = intval($size[0]);
  $height = intval($size[1]);
  $inkjet = substr(basename($sdir), -1) === "p";
  
  
  // Resize
  $im = imagecreatefromstring(file_get_contents($file));
  if ($inkjet) {
    require_once("inkjet_functions.php");
    $k = max($width/imagesx($im), $height/imagesy($im));
    if ($k == 0) { $k=1; }; $k *= 3;
    $sim = imagecreatetruecolor(imagesx($im)*$k, imagesy($im)*$k);
    imagecopyresampled( $sim, $im, 0, 0, 0, 0, imagesx($sim), imagesy($sim), imagesx($im), imagesy($im));
    $im = floyd_steinberg($sim, "images/cmyk_palette.gif");
  }
  $k = max($width/imagesx($im), $height/imagesy($im));
  if ($k == 0) { $k=1; }
  $sim = imagecreatetruecolor(imagesx($im)*$k, imagesy($im)*$k);
  imagealphablending($sim, false);
  imagesavealpha($sim, true);
  imagecopyresampled( $sim, $im, 0, 0, 0, 0, imagesx($sim), imagesy($sim), imagesx($im), imagesy($im));
  
  // Crop
  if ($width && $height) {
    $im = $sim;
    $sim = imagecreatetruecolor($width, $height);
    imagealphablending($sim, false);
    imagesavealpha($sim, true);
    imagecopyresampled( $sim, $im, 0, 0, (imagesx($im)-imagesx($sim))/2, (imagesy($im)-imagesy($sim))/2, imagesx($sim), imagesy($sim), imagesx($sim), imagesy($sim));
  }
  
  if ($inkjet) {
    inkjet_streaks($sim, 20);
  }
  
  if (stristr($sfile, ".jpg")) {
    imagejpeg($sim, $sfile);
    header("Content-Type: image/jpeg");
    readfile($sfile);
  } else {
    imagepng($sim, $sfile);
    header("Content-Type: image/png");
    readfile($sfile);
  }
?>