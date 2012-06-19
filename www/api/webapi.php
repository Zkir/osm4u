<?PHP

/* =============================================================================
  Osm4u, (c) Zkir 2012
==============================================================================*/
//Коды сообщений об ошибках в секции ERS
//
define("ERR_INFOMESSAGE",0);
define("ERR_WARNING",1);
define("ERR_BUSINESS_ERROR",2);
define("ERR_INTERNAL_ERROR",3);

require_once("settings.php");
header('Content-Type: text/xml; charset="windows-1251"');


//Получим хмл. Если надо, раскодируем из base 64
$xmlmsg=$_POST[xmlmsg];
if ($_POST[base64]!='')
{ $xmlmsg=base64_decode($xmlmsg);}

$xml=simplexml_load_string($xmlmsg);


//echo  XML_node('REQUEST', iconv('WINDOWS-1251', 'UTF-8', $xmlmsg));
$operation=$xml->attributes()->operation;

if ($operation=='UserIn')
  $ResponseXml=UserIn($xml);

if ($operation=='UserCheck')
  $ResponseXml=UserCheck($xml);

echo $ResponseXml->asXML();

//Экранирование спецсимволов xml
function XML_node($key,$value)
{
	$t1=str_replace('&','&amp;',$value);
	$t1=str_replace('<','&lt;',$t1);
	$t1=str_replace('>','&gt;',$t1);

	$tmp="<".$key.">".trim($t1)."</".$key.">\n";
	return $tmp;
}

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

//Собственно User In
function UserIn($RequestXml)
{
  global $g_DB_Server, $g_DB_User,$g_DB_Password;
  $ResponseXml = new SimpleXMLElement('<?xml version="1.0" encoding="utf-8"?><RESPONSE><ERS></ERS><DTA></DTA></RESPONSE>');
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
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'Логин не задан');
           return $ResponseXml;
           };

        if (ValidEmail($User->EMAIL)!=True)
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'Неправильный формат адреса электронной почты');
           return $ResponseXml;
        };

        if ($User->PASSWORD=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'Пароль не задан'); return $ResponseXml;};
        if ($User->FIRSTNAME=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'Имя не задано'); return $ResponseXml;};
        if ($User->LASTNAME=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'Фамилия не задана'); return $ResponseXml;};
        if ($User->GENDER=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'Пол не задан'); return $ResponseXml;};

        /* Подключение к серверу БД: */
        $connect=mssql_connect($g_DB_Server, $g_DB_User,$g_DB_Password) or exit("Не удалось соединиться с сервером");
        
        /* Выбор БД: */
        $db=mssql_select_db("[1gb_osm4u]", $connect) or exit("Не удалось выбрать БД");
        
        //Проверим, есть ли уже такой пользователь - логин должен быть уникальным
        
         $strsql="SELECT COUNT(*) FROM [USER] WHERE EMAIL='".$User->EMAIL."'";
         $result=mssql_query($strsql, $connect);     // выполнение SQL-запроса
         $row = mssql_fetch_array($result);
         
         if ($row[0]>0)
         	 {AddError($ResponseXml,ERR_BUSINESS_ERROR ,3,'Такой пользователь уже существует'); return $ResponseXml;};
         
         
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

      AddError($ResponseXml,ERR_INTERNAL_ERROR,1,'Операция редактирования пользователя не поддерживается');
      return $ResponseXml;
    }
  }

  AddError($ResponseXml, ERR_INFOMESSAGE, 0, 'Операция завершилась успешно' );
  return $ResponseXml;
}
//Проверка пользоваетеля
function UserCheck($RequestXml)
{
  global $g_DB_Server, $g_DB_User,$g_DB_Password;
  $ResponseXml = new SimpleXMLElement('<?xml version="1.0" encoding="utf-8"?><RESPONSE><ERS></ERS><DTA></DTA></RESPONSE>');

  /* Подключение к серверу БД: */
  $connect=mssql_connect($g_DB_Server, $g_DB_User,$g_DB_Password) or exit("Не удалось соединиться с сервером");
        
  /* Выбор БД: */
  $db=mssql_select_db("[1gb_osm4u]", $connect) or exit("Не удалось выбрать БД");
        
  //Проверка пользователя и пароля
  $Login=$RequestXml->CTX->USER;
  $Password=$RequestXml->CTX->PASSWORD;
        
   $strsql="SELECT COUNT(*) FROM [USER] WHERE [EMAIL]='".$Login."' AND [PASSWORD]='".$Password."'";
   //echo $strsql;
   $result=mssql_query($strsql, $connect);     // выполнение SQL-запроса
   $row = mssql_fetch_array($result);
         
   if ($row[0]==0)
     {
      AddError($ResponseXml,ERR_BUSINESS_ERROR ,4,'Неправильные логин/пароль'); 
      return $ResponseXml;
     };
         
   AddError($ResponseXml, ERR_INFOMESSAGE, 0, 'Операция завершилась успешно' );
   return $ResponseXml;
}
?>