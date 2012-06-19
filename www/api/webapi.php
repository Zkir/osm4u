<?PHP

/* =============================================================================
  Osm4u, (c) Zkir 2012
==============================================================================*/
//���� ��������� �� ������� � ������ ERS
//
define("ERR_INFOMESSAGE",0);
define("ERR_WARNING",1);
define("ERR_BUSINESS_ERROR",2);
define("ERR_INTERNAL_ERROR",3);

require_once("settings.php");
header('Content-Type: text/xml; charset="windows-1251"');


//������� ���. ���� ����, ����������� �� base 64
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

//������������� ������������ xml
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

//���������� ������ � ������ ������

function AddError($ResponseXml,$errtype,$errcode,$errdesc)
{

  $errmsg=$ResponseXml->ERS->addChild('ERROR');
  $errmsg->addChild('TYPE', $errtype);
  $errmsg->addChild('CODE', $errcode);
  $errmsg->addChild('DESCR', $errdesc);
}

//���������� User In
function UserIn($RequestXml)
{
  global $g_DB_Server, $g_DB_User,$g_DB_Password;
  $ResponseXml = new SimpleXMLElement('<?xml version="1.0" encoding="utf-8"?><RESPONSE><ERS></ERS><DTA></DTA></RESPONSE>');
  //���� ������ - ��������� ������� ������
  //���� ��� ������ - ��������� ������ � ����.

  //�������
  // 1. ��������� ����� ������������� ����� �����.
  //  ����� ��������� ������������, � �������� ������ ID
  // 2. ������������� ������������ ����� ��� ����
  // 3. �������� ������ ����� ���� ������ ����

  //������.
  //1.������� ����������.

  foreach ($RequestXml->DTA->USER as $User)
  {
    if($User->ID=='')
    {
      //����� ������������
      //�������� ��� �������� ������

        if ($User->EMAIL=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'����� �� �����');
           return $ResponseXml;
           };

        if (ValidEmail($User->EMAIL)!=True)
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'������������ ������ ������ ����������� �����');
           return $ResponseXml;
        };

        if ($User->PASSWORD=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'������ �� �����'); return $ResponseXml;};
        if ($User->FIRSTNAME=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'��� �� ������'); return $ResponseXml;};
        if ($User->LASTNAME=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'������� �� ������'); return $ResponseXml;};
        if ($User->GENDER=='')
          {AddError($ResponseXml,ERR_BUSINESS_ERROR ,2,'��� �� �����'); return $ResponseXml;};

        /* ����������� � ������� ��: */
        $connect=mssql_connect($g_DB_Server, $g_DB_User,$g_DB_Password) or exit("�� ������� ����������� � ��������");
        
        /* ����� ��: */
        $db=mssql_select_db("[1gb_osm4u]", $connect) or exit("�� ������� ������� ��");
        
        //��������, ���� �� ��� ����� ������������ - ����� ������ ���� ����������
        
         $strsql="SELECT COUNT(*) FROM [USER] WHERE EMAIL='".$User->EMAIL."'";
         $result=mssql_query($strsql, $connect);     // ���������� SQL-�������
         $row = mssql_fetch_array($result);
         
         if ($row[0]>0)
         	 {AddError($ResponseXml,ERR_BUSINESS_ERROR ,3,'����� ������������ ��� ����������'); return $ResponseXml;};
         
         
        //������� ������ ������������
        $strsql="INSERT INTO [USER] ([ID],[DATE_OF_REGISTRATION],[EMAIL],[PASSWORD],".
                "[FIRST_NAME],[LAST_NAME] ,[DATE_OF_BIRTH],".
                "[GENDER] ,[RANK]  ,[POINTS] ,[STATUS]) ".
                "VALUES (NEWID(), CURRENT_TIMESTAMP,'".$User->EMAIL."','".$User->PASSWORD."','".$User->FIRSTNAME."','".$User->LASTNAME."','".$User->DATEOFBIRTH."','M',0,0,'' )";
        
        $strsql=iconv("UTF-8","windows-1251",$strsql);
        $result=mssql_query($strsql, $connect);     // ���������� SQL-�������
       
    }
    else
    {
    //�������������� ������� ������������

      AddError($ResponseXml,ERR_INTERNAL_ERROR,1,'�������� �������������� ������������ �� ��������������');
      return $ResponseXml;
    }
  }

  AddError($ResponseXml, ERR_INFOMESSAGE, 0, '�������� ����������� �������' );
  return $ResponseXml;
}
//�������� �������������
function UserCheck($RequestXml)
{
  global $g_DB_Server, $g_DB_User,$g_DB_Password;
  $ResponseXml = new SimpleXMLElement('<?xml version="1.0" encoding="utf-8"?><RESPONSE><ERS></ERS><DTA></DTA></RESPONSE>');

  /* ����������� � ������� ��: */
  $connect=mssql_connect($g_DB_Server, $g_DB_User,$g_DB_Password) or exit("�� ������� ����������� � ��������");
        
  /* ����� ��: */
  $db=mssql_select_db("[1gb_osm4u]", $connect) or exit("�� ������� ������� ��");
        
  //�������� ������������ � ������
  $Login=$RequestXml->CTX->USER;
  $Password=$RequestXml->CTX->PASSWORD;
        
   $strsql="SELECT COUNT(*) FROM [USER] WHERE [EMAIL]='".$Login."' AND [PASSWORD]='".$Password."'";
   //echo $strsql;
   $result=mssql_query($strsql, $connect);     // ���������� SQL-�������
   $row = mssql_fetch_array($result);
         
   if ($row[0]==0)
     {
      AddError($ResponseXml,ERR_BUSINESS_ERROR ,4,'������������ �����/������'); 
      return $ResponseXml;
     };
         
   AddError($ResponseXml, ERR_INFOMESSAGE, 0, '�������� ����������� �������' );
   return $ResponseXml;
}
?>