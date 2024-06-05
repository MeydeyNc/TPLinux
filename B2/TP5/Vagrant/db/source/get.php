<html>
<body>

<?php

$host = 'db'; $user = 'meo'; $password = 'dbc'; $db = 'meo';
$conn = new mysqli($host,$user,$password,$db);
if(!$conn) {echo "Erreur de connexion à MSSQL<br />";}

$sql = 'select * from meo where name = ?';
$results = $conn->execute_query($sql, [$_POST["name"]]);
mysqli_close($conn);

if ($results->num_rows === 0) {
  printf("No results for user %s", $_POST["name"]);
} else
{
  foreach ($results as $row) {
      printf("User %s found ! e-mail address : %s\n", $row["name"], $row["email"]);
  }
}
?>

<br><br>
<input type="button" value="Home" onClick="document.location.href='/'" />

</body>
</html> 
