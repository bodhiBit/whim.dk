<?php
  function floyd_steinberg($srcim, $palette_file) {
    $errors = array();
    $erridx = 0;
    
    # $destim = imagecreatetruecolor(imagesx($srcim), imagesy($srcim));
    $destim = $srcim;
    $palim = imagecreatefromgif($palette_file);
    
    for($x=0;$x<=imagesx($srcim);$x++) {
      $errors[] = array(
        "red" => 0,
        "green" => 0,
        "blue" => 0
      );
    }
    
    for($y=0;$y<imagesy($srcim);$y++) {
      for($x=0;$x<imagesx($srcim);$x++) {
        $errors[$erridx]["red"] = 0;
        $errors[$erridx]["green"] = 0;
        $errors[$erridx]["blue"] = 0;
        $erridx = ($erridx + 1) % count($errors);
        $err = $errors[$erridx];
        $srcpix = imagecolorsforindex($srcim, imagecolorat($srcim, $x, $y));
        $srcpix["red"]    += $err["red"];
        $srcpix["green"]  += $err["green"];
        $srcpix["blue"]   += $err["blue"];
        $srcpix["red"]    = min(max(0, $srcpix["red"]), 255);
        $srcpix["green"]  = min(max(0, $srcpix["green"]), 255);
        $srcpix["blue"]   = min(max(0, $srcpix["blue"]), 255);
        
        $destpix = imagecolorsforindex($palim, imagecolorclosest($palim, $srcpix["red"], $srcpix["green"], $srcpix["blue"]));
        
        $destcol = imagecolorallocate($destim, $destpix["red"], $destpix["green"], $destpix["blue"]);
        imagesetpixel($destim, $x, $y, $destcol);
        $err["red"]   = ($srcpix["red"]   - $destpix["red"]) / 16;
        $err["green"] = ($srcpix["green"] - $destpix["green"]) / 16;
        $err["blue"]  = ($srcpix["blue"]  - $destpix["blue"]) / 16;
        
        $i = ($erridx+1) % count($errors);
        $errors[$i]["red"]    += $err["red"]    * 7;
        $errors[$i]["green"]  += $err["green"]  * 7;
        $errors[$i]["blue"]   += $err["blue"]   * 7;
        $i = ($erridx+imagesx($srcim)-1) % count($errors);
        $errors[$i]["red"]    += $err["red"]    * 3;
        $errors[$i]["green"]  += $err["green"]  * 3;
        $errors[$i]["blue"]   += $err["blue"]   * 3;
        $i = ($erridx+imagesx($srcim)) % count($errors);
        $errors[$i]["red"]    += $err["red"]    * 5;
        $errors[$i]["green"]  += $err["green"]  * 5;
        $errors[$i]["blue"]   += $err["blue"]   * 5;
        $i = ($erridx+imagesx($srcim)+1) % count($errors);
        $errors[$i]["red"]    += $err["red"]    * 1;
        $errors[$i]["green"]  += $err["green"]  * 1;
        $errors[$i]["blue"]   += $err["blue"]   * 1;
      }
    }
    
    return $destim;
  }
  
  function inkjet_streaks($srcim, $size) {
    # $destim = imagecreatetruecolor(imagesx($srcim), imagesy($srcim));
    $destim = $srcim;
    imagealphablending($destim, false);
    imagesavealpha($destim, true);
    $head = array();
    for($i=0;$i<$size;$i++) {
      $head[] = rand(40, 44);
    }
    
    for($y=0;$y<imagesy($srcim);$y++) {
      $line = $head[$y % count($head)];
      for($x=0;$x<imagesx($srcim);$x++) {
        $srcpix = imagecolorsforindex($srcim, imagecolorat($srcim, $x, $y));
        if ($srcpix["red"] > 250 && $srcpix["green"] > 250 && $srcpix["blue"] > 250) {
          $a = 127;
        } else {
          $a = $line;
        }
        $destcol = imagecolorallocatealpha($destim, $srcpix["red"], $srcpix["green"], $srcpix["blue"], $a);
        imagesetpixel($destim, $x, $y, $destcol);
      }
    }
    return $destim;
  }
?>