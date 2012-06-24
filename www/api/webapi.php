<?PHP

/* =============================================================================
  Osm4u, (c) Zkir 2012
==============================================================================*/
//Коды сообщений об ошибках в секции ERS
//  
define("ERRL_INFOMESSAGE",0);
define("ERRL_WARNING",1);
define("ERRL_BUSINESS_ERROR",2);
define("ERRL_INTERNAL_ERROR",3);

//КОДЫ ОШИБОК
define("ERR_OPERATION_COMPLETED",0);
define("ERR_UNKNOWN_OPERATION",1);
define("ERR_POI_ADDED",2);
define("ERR_INVALID_LOGIN_PASSWORD",3);
define("ERR_INVALID_VALUE_OF_INPUT_PARAMETER",4);

require_once("settings.php");
header('Content-Type: text/xml; charset="windows-1251"');


//Получим хмл. Если надо, раскодируем из base 64   
$xmlmsg=$_POST[xmlmsg];
if ($_POST[base64]!='')
{ $xmlmsg=base64_decode($xmlmsg);}

$RequestXml=simplexml_load_string($xmlmsg);


//echo  XML_node('REQUEST', iconv('WINDOWS-1251', 'UTF-8', $xmlmsg));
$operation=$RequestXml->attributes()->operation;

//Создадим ответный xml. Он его структура стандартная, одинаковая для всех операций
$ResponseXml = new SimpleXMLElement('<?xml version="1.0" encoding="utf-8"?><RESPONSE><ERS></ERS><DTA></DTA></RESPONSE>');

//Откроем соединение с базой.
$gOsm4u_connect=mssql_connect($g_DB_Server, $g_DB_User,$g_DB_Password) or exit("Не удалось соединиться с сервером");       
$gOsm4u_db=mssql_select_db("[1gb_osm4u]", $gOsm4u_connect) or exit("Не удалось выбрать БД");

//Проверим пользователя (это и есть получение контекста).
$UserId=CheckUserAutorization($RequestXml); 
if (($UserId=='') and ($operation!="UserIn") )
{
	AddError($ResponseXml, ERRL_BUSINESS_ERROR, ERR_INVALID_LOGIN_PASSWORD, 'Неправильные логин/пароль'); 
}
else
{

switch ($operation)
{
	case "UserIn":
		UserIn($RequestXml,$ResponseXml);
		break;
	case "UserCheck":
		UserCheck($RequestXml,$ResponseXml);
		break;
	case "PoiOut":
	    PoiOut($RequestXml,$ResponseXml);
		break;
	case "CategoryOut":
	    CategoryOut($RequestXml,$ResponseXml);
		break;		
	case "PoiIn":	
		PoiIn($UserId, $RequestXml,$ResponseXml);
		break;	
	case "CommentIn":
	    CommentIn($UserId, $RequestXml,$ResponseXml);
		break;		
	default:
	    AddError($ResponseXml,ERRL_BUSINESS_ERROR, ERR_UNKNOWN_OPERATION, 'Неизвестная операция');
	    break;
}	
}

echo $ResponseXml->asXML();

// отключение от БД
mssql_close($gOsm4u_connect);

//============================================================================================================
// Разные полезные функции
//============================================================================================================

//Экранирование спецсимволов xml
function XML_node($key,$value)
{
	$t1=str_replace('&','&amp;',$value);
	$t1=str_replace('<','&lt;',$t1);
	$t1=str_replace('>','&gt;',$t1);

	$tmp="<".$key.">".trim($t1)."</".$key.">\n";
	return $tmp;
}
//Экранирование апострофа в строках для mssql
function sql_str($str)
{
  return str_replace("'","''",$str)	;
}
//Проверка емейла на соответствие шаблону.
function ValidEmail($email) {

  if ($email=="") { return false; }
  $domain = @explode("@",$email);
  $domain = @$domain[1];

  return (!eregi("^([a-zA-Z0-9~\._-]{2,})(@{1}[a-zA-Z0-9~\._-]{2,})(\.{1}[a-zA-Z]{2,4})$",$email)) ? false : true ;
}

//Добавление ошибок в список ошибок
function AddError($ResponseXml,$errtype,$errcode,$errdesc)
{

  $errmsg=$ResponseXml->ERS->addChild('ERROR');
  $errmsg->addChild('TYPE', $errtype);
  $errmsg->addChild('CODE', $errcode);
  $errmsg->addChild('DESCR', $errdesc);
}

//***************************************************************************************************
// Операции обмена xml
//***************************************************************************************************
//===================================================================================================
//Проверка подлинности пользователя
//===================================================================================================
//"Получение контекста"
function CheckUserAutorization($RequestXml)
{
  global $gOsm4u_connect;	  
  //Нужно проверить авторизацию и получить гуид пользователя
  //Проверка пользователя и пароля
  $Login=$RequestXml->CTX->USER;
  $Password=$RequestXml->CTX->PASSWORD;
        
  $strsql="SELECT convert(nvarchar(50),[ID]) FROM [USER] WHERE [EMAIL]='".sql_str($Login)."' AND [PASSWORD]='".sql_str($Password)."'";
   //echo $strsql;
  $result=mssql_query($strsql, $gOsm4u_connect);     // выполнение SQL-запроса
  $row = mssql_fetch_array($result);
  $UserId=$row[0];
  
  if ($UserId!='')
  {//Запишем, что пользоваетель был в системе
    $strsql="UPDATE [USER] SET LAST_ACTIVE_DATE=CURRENT_TIMESTAMP  WHERE [ID]='".sql_str($UserId)."' ";
    $result=mssql_query($strsql, $gOsm4u_connect);    
  }    
   
  return $UserId;
  	
}
//===================================================================================================
//Выдача Классификатора (CategoryOut)
//===================================================================================================
function CategoryOut($RequestXml,$ResponseXml)
{
  global $gOsm4u_connect;
  
  
  $strsql='select CATEGORY, POI_TYPE.NAME,NAME_PL,POI_TYPE.MP_TYPE from POI_CATEGORIES
           inner join POI_TYPE on POI_TYPE.MP_TYPE=POI_CATEGORIES.MP_TYPE 
           order by CATEGORY,NAME_PL ';    // строка с SQL-запросом
      
  $result=mssql_query($strsql, $gOsm4u_connect);     // выполнение SQL-запроса

    
  $cat_name="";
  while (($row = mssql_fetch_array($result))) 
    { 
      if ($cat_name!= $row['CATEGORY'])
      {
      	
        $cat_name= $row['CATEGORY'];
        
        $catnode=$ResponseXml->DTA->addChild('CATEGORY');
        
        $catnode->addChild('NAME', $cat_name);
      }
      
      $poitypenode=$catnode->addChild('POITYPE');
      
      $poitypenode->addChild('NAME',$row['NAME']);
      $poitypenode->addChild('NAME_PL',$row['NAME_PL']);
      $poitypenode->addChild('MP_TYPE',$row['MP_TYPE']);
      
      
    } 
    
  
  mssql_free_result($result);	



  AddError($ResponseXml, ERRL_INFOMESSAGE, ERR_OPERATION_COMPLETED, 'Операция завершилась успешно' );
  return;
}

//===================================================================================================
//Вввод, ака регистрация пользователей (User In)
//===================================================================================================
function UserIn($RequestXml, $ResponseXml)
{
  global $g_DB_Server, $g_DB_User,$g_DB_Password;
  //Наша задача - проверить входные данные
  //Если все хорошо - сохранить данные в базу.

  //Правила
  // 1. Создавать новых пользователей может любой.
  //  Новым считается пользователь, у которого пустое ID
  // 2. Редактировать пользователь может сам себя
  // 3. Получить данные можно тоже только свои

  //Начало.
  //1.Провека валидности.

  foreach ($RequestXml->DTA->USER as $User)
  {
    if($User->ID=='')
    {
      //Новый пользователь
      //Проверим что значения заданы

        if ($User->EMAIL=='')
          {AddError($ResponseXml,ERRL_BUSINESS_ERROR ,2,'Логин не задан');
           return $ResponseXml;
           };

        if (ValidEmail($User->EMAIL)!=True)
          {AddError($ResponseXml,ERRL_BUSINESS_ERROR ,2,'Неправильный формат адреса электронной почты');
           return $ResponseXml;
        };

        if ($User->PASSWORD=='')
          {AddError($ResponseXml,ERRL_BUSINESS_ERROR ,2,'Пароль не задан'); return $ResponseXml;};
        if ($User->FIRSTNAME=='')
          {AddError($ResponseXml,ERRL_BUSINESS_ERROR ,2,'Имя не задано'); return $ResponseXml;};
        if ($User->LASTNAME=='')
          {AddError($ResponseXml,ERRL_BUSINESS_ERROR ,2,'Фамилия не задана'); return $ResponseXml;};
        if ($User->GENDER=='')
          {AddError($ResponseXml,ERRL_BUSINESS_ERROR ,2,'Пол не задан'); return $ResponseXml;};

        /* Подключение к серверу БД: */
        $connect=mssql_connect($g_DB_Server, $g_DB_User,$g_DB_Password) or exit("Не удалось соединиться с сервером");
        
        /* Выбор БД: */
        $db=mssql_select_db("[1gb_osm4u]", $connect) or exit("Не удалось выбрать БД");
        
        //Проверим, есть ли уже такой пользователь - логин должен быть уникальным
        
         $strsql="SELECT COUNT(*) FROM [USER] WHERE EMAIL='".$User->EMAIL."'";
         $result=mssql_query($strsql, $connect);     // выполнение SQL-запроса
         $row = mssql_fetch_array($result);
         
         if ($row[0]>0)
         	 {AddError($ResponseXml,ERRL_BUSINESS_ERROR ,3,'Такой пользователь уже существует'); return $ResponseXml;};
         
         
        //Вставка нового пользователя
        $strsql="INSERT INTO [USER] ([ID],[DATE_OF_REGISTRATION],[EMAIL],[PASSWORD],".
                "[FIRST_NAME],[LAST_NAME] ,[DATE_OF_BIRTH],".
                "[GENDER] ,[RANK]  ,[POINTS] ,[STATUS]) ".
                "VALUES (NEWID(), CURRENT_TIMESTAMP,'".$User->EMAIL."','".$User->PASSWORD."','".$User->FIRSTNAME."','".$User->LASTNAME."','".$User->DATEOFBIRTH."','M',0,0,'' )";
        
        $strsql=iconv("UTF-8","windows-1251",$strsql);
        $result=mssql_query($strsql, $connect);     // выполнение SQL-запроса
       
    }
    else
    {
    //Редактирование старого пользователя

      AddError($ResponseXml,ERRL_INTERNAL_ERROR,1,'Операция редактирования пользователя не поддерживается');
      return $ResponseXml;
    }
  }

  AddError($ResponseXml, ERRL_INFOMESSAGE, ERR_OPERATION_COMPLETED, 'Операция завершилась успешно' );
  return $ResponseXml;
}

//===================================================================================================
//Проверка пользоваетеля
//===================================================================================================
function UserCheck($RequestXml,$ResponseXml)
{
  //Здесь пока ничего не делается, а должна выдаваться информация о текущем юзере.
         
   AddError($ResponseXml, ERRL_INFOMESSAGE, 0, 'Операция завершилась успешно' );
   return $ResponseXml;
}
//===================================================================================================
//Выдача ПОИ  (PoiOut)
//===================================================================================================
function PoiOut($RequestXml,$ResponseXml)
{
  global $gOsm4u_connect;
  
 // $strsql="SELECT * FROM POI WHERE MP_TYPE='0xF102'";    // строка с SQL-запросом
  $strsql="SELECT TOP 200 * FROM POI WHERE LAT>".$RequestXml->DTA->MINLAT." AND LAT<".$RequestXml->DTA->MAXLAT." AND LON>".$RequestXml->DTA->MINLON." AND LON<".$RequestXml->DTA->MAXLON." ";
  //echo $strsql;
    
  
  $result=mssql_query($strsql, $gOsm4u_connect);     // выполнение SQL-запроса

    
  //Цикл по возвращенным записям
  while (($row = mssql_fetch_array($result))) 
    { 
    	
       $poinode=$ResponseXml->DTA->addChild('POI');
       
       $poinode->addChild('NAME', $row['NAME']);
       $poinode->addChild('OSM_ID',$row['OSM_ID'] );
       $poinode->addChild('MP_TYPE',$row['MP_TYPE'] );
       $coordnode=$poinode->addChild('COORD');
       $coordnode->addChild('LAT',$row['LAT'] );
       $coordnode->addChild('LON', $row['LON'] );
       $poinode->addChild('DESCRIPTION1', $row['DESCRIPTION1']);
       $poinode->addChild('DESCRIPTION2', $row['DESCRIPTION2']);
       $poinode->addChild('ADDRESS1', $row['ADDRESS1']);
       $poinode->addChild('ADDRESS2', $row['ADDRESS2']);
       $poinode->addChild('ADDRESS3', $row['ADDRESS3']);
       $poinode->addChild('PHONE', $row['PHONE']);
       $poinode->addChild('WEBSITE', $row['WEBSITE']);
       $poinode->addChild('OPENING_HOURS',$row['OPENING_HOURS'] );
    } 
    
  mssql_free_result($result);	
   
  AddError($ResponseXml, ERRL_INFOMESSAGE, ERR_OPERATION_COMPLETED, 'Операция завершилась успешно' );
  return;
}

//===================================================================================================
//Вввод пои в систему (POI In)
//===================================================================================================
function PoiIn($UserId, $RequestXml, $ResponseXml)
{
  global $gOsm4u_connect;
  
  //Цикл по ПОИ в хмл
  foreach ($RequestXml->DTA->POI as $Poi)
  {
  	//Проверим, есть ли уже такое пои в базе 
    $strsql="SELECT COUNT(*) FROM [POI] WHERE ID='".sql_str($Poi->ID)."'";
    $result=mssql_query($strsql, $gOsm4u_connect);     // выполнение SQL-запроса
    $row = mssql_fetch_array($result);
    if($row[0]==0)
    {
      //Новое ПОИ
      
      //1.Провека валидности.
      //(пока пропускаем)   
         
      //Вставка нового ПОИ
         
       $strsql="INSERT INTO [dbo].[POI]".
           "([ID]".
           ",[MODIFIED_DATE]".
           ",[MODIFIED_USER_ID]".
           ",[OSM_ID]".
           ",[OSM_VERSION]".
           ",[OSM_DATE]".
           ",[LAT]".
           ",[LON]".
           ",[MP_TYPE]".
           ",[NAME]".
           ",[ADDRESS1]".
           ",[ADDRESS2]".
           ",[ADDRESS3]".
           ",[DESCRIPTION1]".
           ",[DESCRIPTION2]".
           ",[OPENING_HOURS]".
           ",[PHONE]".
           ",[WEBSITE]".
           ",[WIFI_PRESENT])".
     "VALUES".
           "('".$Poi->ID."'".
           ",CURRENT_TIMESTAMP".
           ",'".$UserId."'".
           ",''".
           ",''".
           ",'1900-01-01'".
           ",'".$Poi->COORD->LAT."'".
           ",'".$Poi->COORD->LON."'".
           ",'".$Poi->MP_TYPE."'".
           ",'".sql_str($Poi->NAME)."'".
           ",'".sql_str($Poi->ADDRESS1)."'".
           ",'".sql_str($Poi->ADDRESS2)."'".
           ",'".sql_str($Poi->ADDRESS3)."'".
           ",'".sql_str($Poi->DESCRIPTION1)."'".
           ",'".sql_str($Poi->DESCRIPTION2)."'".
           ",'".sql_str($Poi->OPENING_HOURS)."'".
           ",'".sql_str($Poi->PHONE)."'".
           ",'".sql_str($Poi->WEBSITE)."'".
           ",0)";
            
      
      $strsql=iconv("UTF-8","windows-1251",$strsql);
      //echo $strsql;
      $result=mssql_query($strsql, $gOsm4u_connect);     // выполнение SQL-запроса
      
      //Нужно еще 
      // * Начислить пользователю балы
      // * Создать уведомление об этом
      // * создать событие
      AddError($ResponseXml, ERRL_INFOMESSAGE, ERR_POI_ADDED, 'Новое место успешно добавлено. Спасибо!' );
    }
    else
    {
    //Редактирование существующего ПОИ

      AddError($ResponseXml,ERRL_INTERNAL_ERROR,1,'Операция редактирования ПОИ пока не поддерживается');
      return;
    }
  }

  AddError($ResponseXml, ERRL_INFOMESSAGE, ERR_OPERATION_COMPLETED, 'Операция завершилась успешно' );
  
  
  return $ResponseXml;
}   

//===================================================================================================
//Добавление комментов и оценок (Comment In)
// Комментов от одного пользователя может быть сколько угодно, но оценка только одна
//===================================================================================================
function CommentIn($UserId, $RequestXml, $ResponseXml)
{
  global $gOsm4u_connect;
  
  //Цикл по ПОИ в хмл
  foreach ($RequestXml->DTA->COMMENT as $Poi)
  {
  	//Валидация.
  	//есть смысл проверять оценку, что она принадлежит (1,2,3,4,5)
  	switch ($Poi->RATING)
  	{
  		case "1":
  	    case "2":
  	    case "3":
  	    case "4":
  	    case "5":
  	    	break;
  	    default:
  	      AddError($ResponseXml,ERRL_INTERNAL_ERROR, ERR_INVALID_VALUE_OF_INPUT_PARAMETER,'Неправильное значение оценки '.$Poi->RATING);
          return;	
  	}
  	  
  	//Проверим, есть ли уже такая оценка в базе 
    $strsql="SELECT COUNT(*) FROM [GRADE] WHERE POI_ID='".sql_str($Poi->POI_ID)."' AND USER_ID='".sql_str($UserId)."'";
    $result=mssql_query($strsql, $gOsm4u_connect);     // выполнение SQL-запроса
    $row = mssql_fetch_array($result);
    if($row[0]==0)
    {
      //Новая оценка
     
         
      //Вставка новой оценки
         
       $strsql="INSERT INTO [dbo].[GRADE]".
           "([ID]".
           ",[POI_ID]".
           ",[USER_ID]".
           ",[MODIFIED_DATE]".
           ",[GRADE]".
           ")".
     "VALUES". 
           "(NEWID()".
           ",'".sql_str($Poi->POI_ID)."'".
           ",'".sql_str($UserId)."'".
           ",CURRENT_TIMESTAMP".
           ",".$Poi->RATING."".
           ")";
            
      
      $strsql=iconv("UTF-8","windows-1251",$strsql);
      //echo $strsql;
      $result=mssql_query($strsql, $gOsm4u_connect);     // выполнение SQL-запроса
      
    }
    else
    {
    //Редактирование существующей оценки

        $strsql="UPDATE [GRADE]".
                "SET". 
                "[MODIFIED_DATE] = CURRENT_TIMESTAMP".
                ",[GRADE] = ".$Poi->RATING."".
                "WHERE POI_ID='".sql_str($Poi->POI_ID)."' AND USER_ID='".sql_str($UserId)."'";
            
      
      $strsql=iconv("UTF-8","windows-1251",$strsql);
      //echo $strsql;
      $result=mssql_query($strsql, $gOsm4u_connect);     // выполнение SQL-запроса
    }
  }

  AddError($ResponseXml, ERRL_INFOMESSAGE, ERR_OPERATION_COMPLETED, 'Операция завершилась успешно' );
  
  
  return $ResponseXml;
}
?>