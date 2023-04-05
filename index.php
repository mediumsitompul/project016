<?php
  define("DB_HOST", "192.168.100.100:6607");
  define("DB_USER", "pqr");
  define("DB_PASSWORD", "Pensi2021");
  define("DB_NAME", "db_pagination");
  $connect=mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);

    if($connect) {
    $sql='
    SELECT userId, id, title, body
    FROM t_restapi_insert
    ORDER by userId, id asc
    ';

    $query=mysqli_query($connect, $sql);
    $results=array();

    while($row=mysqli_fetch_assoc($query)) {
      $results[]=$row;
    }
    //echo json_encode($results);
    echo json_encode( $results, JSON_NUMERIC_CHECK );
}
?>
