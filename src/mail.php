<?php
  if ($_SERVER["REQUEST_METHOD"] === "POST") {
    
    if ($_POST["name"] && $_POST["email"] && $_POST["message"]) {
      $success = mail("Tommy@whim.dk",
        "[".$_SERVER["HTTP_HOST"]."] ".$_POST["subject"],
        $_POST["name"]." <".$_POST["email"]."> skriver:\n\n".$_POST["message"]);
      if ($success) {
        header("Location: thankyou");
        $header = "Success!";
        $message = "The mail was sent!";
      } else {
        $header = "Error!";
        $message = "Something went wrong.. The message was not sent..";
      }
    } else {
      $header = "Sorry";
      $message = "You need to fill out all fields..";
    }
  } else {
    header("Bad request", true, 400);
    die("<h1>Bad Request</h1><p>Accepting POST requests only");
  }
?>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><?=$header?> - Messenger</title>
  </head>
  <body>
    <article>
      <h2><?=$header?></h2>
      <p><?=$message?></p>
      <script> document.write('<a href="javascript:history.back()">&larr;Go back</a>'); </script>
    </article>
  </body>
</html>