<?PHP
  require_once("settings.php");

  header('Content-Type: text/xml; charset="windows-1251"');
  /* Подключение к серверу БД: */
  $connect=mssql_connect($g_DB_Server, $g_DB_User,$g_DB_Password)or exit("Не удалось соединиться с сервером");

  /* Выбор БД: */
  $db=mssql_select_db("[1gb_osm4u]", $connect) or exit("Не удалось выбрать БД");
//  $strsql="SELECT * FROM POI WHERE MP_TYPE='0xF101'";    // строка с SQL-запросом
  $strsql="SELECT * FROM POI WHERE MP_TYPE='".$_GET[MpType]."'";
  $result=mssql_query($strsql, $connect);     // выполнение SQL-запроса

    
  echo '<?xml version="1.0" encoding="windows-1251"?>'."\n";
  echo "<POILIST>\n";
  
  while (($row = mssql_fetch_array($result))) 
    { 
      echo "  <POI>\n";
      // echo(iconv('UCS-2LE', 'UTF-8', $row['NAME']));
      echo "    ".XML_node('NAME',$row['NAME']);
      echo "    <OSM_ID>".$row['OSM_ID']."</OSM_ID>\n"; 
      echo "    <MP_TYPE>".$row['MP_TYPE']."</MP_TYPE>\n"; 
      echo "    <COORD>\n";
      echo "      <LAT>".$row['LAT']."</LAT>\n";
      echo "      <LON>".$row['LON']."</LON>\n";
      echo "    </COORD>\n";
      echo "    <DESCRIPTION1>".trim($row['DESCRIPTION1'])."</DESCRIPTION1>\n"; 
      echo "    <DESCRIPTION2>".trim($row['DESCRIPTION2'])."</DESCRIPTION2>\n"; 
      echo "    ".XML_node("ADDRESS1", $row['ADDRESS1']); 
      echo "    ".XML_node("ADDRESS2", $row['ADDRESS2']); 
      echo "    ".XML_node("ADDR_STREET", $row['ADDR_STREET']);
      echo "    ".XML_node("ADDR_HOUSENUMBER", $row['ADDR_HOUSENUMBER']); 
      echo "    ".XML_node("PHONE",$row['PHONE']);
      echo "    ".XML_node("WEBSITE",$row['WEBSITE']); 
      echo "    ".XML_node("OPENING_HOURS",$row['OPENING_HOURS']);
      
      //Для обратной совместимости.
       $addr3=trim($row['ADDR_STREET']);
       if ($addr3=='') $addr3='<улица не задана>';
       $addr3=$addr3.', '.$row['ADDR_HOUSENUMBER'];
       echo "    ".XML_node("ADDRESS3", $addr3); 
      
      echo "  </POI>\n";
    } 
    
  //echo "Всего записей в базе: ".$row[0];
  
  echo "</POILIST>\n";
  
  mssql_free_result($result);	
  mssql_close($connect); // отключение от БД
  
function XML_node($key,$value)
{   
	$t1=str_replace('&','&amp;',$value);
	$t1=str_replace('<','&lt;',$t1);
	$t1=str_replace('>','&gt;',$t1);
	
	$tmp="<".$key.">".trim($t1)."</".$key.">\n";
	return $tmp;
}  
?>