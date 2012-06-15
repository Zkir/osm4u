<?PHP
  require_once("settings.php");

  header('Content-Type: text/xml; charset="windows-1251"');
  /* ����������� � ������� ��: */
  $connect=mssql_connect($g_DB_Server, $g_DB_User,$g_DB_Password)or exit("�� ������� ����������� � ��������");

  /* ����� ��: */
  $db=mssql_select_db("[1gb_osm4u]", $connect) or exit("�� ������� ������� ��");
  $strsql='select CATEGORY, POI_TYPE.NAME,NAME_PL,POI_TYPE.MP_TYPE from POI_CATEGORIES
           inner join POI_TYPE on POI_TYPE.MP_TYPE=POI_CATEGORIES.MP_TYPE 
           order by CATEGORY,NAME_PL ';    // ������ � SQL-��������
  $result=mssql_query($strsql, $connect);     // ���������� SQL-�������

    
  echo '<?xml version="1.0" encoding="windows-1251"?>'."\n";
  echo "<CATEGORYLIST>\n";
  $cat_name="";
  while (($row = mssql_fetch_array($result))) 
    { 
      if ($cat_name!= $row['CATEGORY'])
      {
      	if ($cat_name!="") echo "  </CATEGORY>\n";
        $cat_name= $row['CATEGORY'];
        echo "  <CATEGORY>\n";
        echo "    <NAME>".$cat_name."</NAME>\n";
      }
      
      
      echo "    <POITYPE>\n";
      echo "      <NAME>".$row['NAME']."</NAME>\n";
      echo "      <NAME_PL>".$row['NAME_PL']."</NAME_PL>\n";
      echo "      <MP_TYPE>".$row['MP_TYPE']."</MP_TYPE>\n";
      echo "    </POITYPE>\n";
      
      
    } 
    
  if ($cat_name!="") echo "  </CATEGORY>\n";
  
  echo "</CATEGORYLIST>\n";
  
  mssql_free_result($result);	
  mssql_close($connect); // ���������� �� ��
?>