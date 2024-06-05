<html>
<body>

Hellooooooooooooo <?php echo $_POST["name"]; ?> 🐈
<br>
Your email address is: <?php echo $_POST["email"]; ?>
<br>
Everything has been sent to database !  (maybe it will work, or maybe it will explode because you didn't configure the database :( )

<?php

$host = 'db'; $user = 'meo'; $password = 'dbc'; $db = 'meo';
$conn = new mysqli($host,$user,$password,$db);
if(!$conn) {echo "Erreur de connexion à MSSQL<br />";}

$sql = 'INSERT INTO meo (name, email) VALUES (?, ?)';
$conn->execute_query($sql, [$_POST["name"], $_POST["email"]]);
mysqli_close($conn);

?>
<br><br>
<input type="button" value="Home" onClick="document.location.href='/'" />
</body>
</html> 
