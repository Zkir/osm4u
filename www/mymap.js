//*********************************************************************************************************
// Скрипт отображения карты и пои
// Для osm4u
// (c) zkir 2011, CC-BY-SA 2.0
//*********************************************************************************************************

//=======================================================================================
//Это конструктор POI, он выбирает данные из некой ноды (?) XML
//=======================================================================================
function FetchNodeValue(f_child)
	{
	  var NodeValue="";
		 try{ 
                NodeValue=f_child.firstChild.nodeValue;
                //NodeValue=f_child.firstChild.textContent ;
                
              }  
              catch(err){
                NodeValue="";
              }
      return NodeValue
	}
//Конструктор	
function PoiInfo(f_child,PoiTypeNamePl) 
{
	
	
    var PoiName="";
    var Lat=0;
    var Lon=0;
  //В этом цикле мы перебираем ноды xml, относящиеся к данному пои
  do
    {
    	//Выбираем имя узла и в соответствии с этим выполняем необходимое действие
		switch (f_child.nodeName)
		{
			//Если это заголовок — оформляем как заголовок
			case "OSM_ID":
    		  this.OsmID=f_child.firstChild.nodeValue;
    		  break;

			//Если это описание, оформляем как описание
			case "NAME":
			  PoiName="";
			  try{ 
                PoiName=f_child.firstChild.nodeValue;
              }  
              catch(err){
                PoiName="";
              }
			  break;
			case "COORD":
              try{
               	Lat= f_child.getElementsByTagName("LAT")[0].firstChild.nodeValue;
               	Lon= f_child.getElementsByTagName("LON")[0].firstChild.nodeValue;
              }
              catch(err){
                throw('Координаты дома '+PoiName+ ' не заданы');
              }
        	  break;
            case "DESCRIPTION1":
			  try{ 
                this.Description1=f_child.firstChild.nodeValue;
              }  
              catch(err){
                this.Description1="";
              }
			  break;  
			case "ADDRESS3":
			  try{ 
                this.Address3=f_child.firstChild.nodeValue;
              }  
              catch(err){
                this.Address3="";
              }
			  break;
			case "WEBSITE":
			  try{ 
                this.WebSite=f_child.firstChild.nodeValue;
              }  
              catch(err){
                this.WebSite="";
              }
			  break;
			case "PHONE":
			  this.Phone=FetchNodeValue(f_child);
			  break;   
			case "OPENING_HOURS":
			  this.OpeningHours=FetchNodeValue(f_child);
			  break;  
			      
		}
 	    //Устанавливаем следующий узел
		f_child = f_child.nextSibling;
	    
  } while (f_child) ;


  this.PoiName = PoiName;
  this.Lat = Lat;
  this.Lon = Lon;
  this.PoiTypeNamePl =PoiTypeNamePl;
  
  //Функции
  this.GetJOSMLinkByID=GetJOSMLinkByID;
  this.GetOSMLinkByID=GetOSMLinkByID;
  this.FillInfoWindow=FillInfoWindow;
}
//=======================================================================================
//Это фукция заполнения информационного окна для POI
//=======================================================================================
function FillInfoWindow()
{
  var Text="";
  Text = "<b>"+this.PoiName + "</b><BR/>";
  Text = Text + this.Address3 + "<BR/>";
  //Text = Text +'<P>Категория: <a href="#">' +CurrentCategoryName + '</a></P>';
  Text = Text +'<P>Категория: <a href="#">' +this.PoiTypeNamePl + '</a></P>';

  if (this.Description1!='') {
    Text = Text + this.Description1 + "<BR/>";
  }
  //Text = Text + this.OsmID + "<BR/>";
  if (this.Phone!='') {
    Text = Text + '<P><img src="/img/phone.gif"/> '+this.Phone +'</P>';
  }
  if (this.WebSite!='') {
    Text = Text + '<P><img src="/img/www.gif" /> <a href="'+this.WebSite+'" target="_blank">'+this.WebSite+'</a> </P>';
  }
  if (this.OpeningHours!='') {
    Text = Text +'<P><img src="/img/work_time.png" /> '+ this.OpeningHours +'</P>';
  }
  Text = Text + '<a href="'+this.GetJOSMLinkByID()+'" target="josm"><img src="/img/josm.png" align="right" style="padding-bottom:2px"/></a>';
  Text = Text + '<a href="'+this.GetOSMLinkByID()+'" target="_blank">Показать в OSM</a> <BR/>';
  
  Text = Text + '<div style="display: none;"><iframe name="josm"></iframe></div>';

  return Text;
}

//=======================================================================================
//Получение ссылки на объект в osm
//=======================================================================================
function GetOSMLinkByID()
{
  var url="";
  var temp = new Array();
  var osmtype="";
  
  temp = this.OsmID.split(':');
  
  switch(temp[0])
  {
    case 'N':
      osmtype='node';
      break;
    case 'W':
      osmtype='way';
      break;
    case 'R':
      osmtype='relation';
      break;
    default:
      throw('Неверный тип объекта');
   }
   
  url="http://www.openstreetmap.org/browse/"+osmtype+"/"+temp[1];
  return url;
}
//=======================================================================================
//Получение ссылки для JOSM
//=======================================================================================
function GetJOSMLinkByID()
{
  var url="";
  var temp = new Array();
  var osmtype="";
  
  temp = this.OsmID.split(':');
  
  switch(temp[0])
  {
    case 'N':
      osmtype='node';
      break;
    case 'W':
      osmtype='way';
      break;
    case 'R':
      osmtype='relation';
      break;
    default:
      throw('Неверный тип объекта');
   }

  var Lat= parseFloat(this.Lat);
  var Lon= parseFloat(this.Lon);
  var delta=0.001;	  
  
  //url="http://localhost:8111/import?url="+url;
  url='http://localhost:8111/load_and_zoom?top='+(Lat+delta) +'&bottom='+(Lat-delta)+'&left='+(Lon-delta)+'&right='+(Lon+delta)+'&select='+osmtype+temp[1]; 
  return url;	
}


//=======================================================================================
// Обработка щелчка по маркеру
//=======================================================================================
function doClick (latlng) {
  map.setCenter(latlng);
  map.openInfoWindow(latlng, this.FillInfoWindow(), {maxWidth: 200});
}

 
function doClick1(lat,lon)
{       	 
  var el=document.getElementById('ttt');
  var delta=0.0002;

  //pstr = "http://localhost:8111/import?url=http://openstreetmap.org/api/0.6/way/XXXX/full";
  pstr ="http://localhost:8111/load_and_zoom?top="+(lat+delta)+"&bottom="+(lat-delta)+"&left="+(lon-delta)+"&right="+(lon+delta)+"";

      //document.write(pstr);

      el.src = pstr;

}
//*****************************************************************************************************************
//Заполнение рубрикатора
//*****************************************************************************************************************
function PoiTypeInfo(f_child) 
{
    
  //В этом цикле мы перебираем ноды xml, относящиеся к данному пои
  do
    {
  	  	 
    	//Выбираем имя узла и в соответствии с этим выполняем необходимое действие
		switch (f_child.nodeName)
		{
		    //Если это описание, оформляем как описание
			case "NAME":
			  this.PoiTypeName=FetchNodeValue(f_child);
			  break;
			case "NAME_PL":
			  this.PoiTypeNamePl=FetchNodeValue(f_child);
			  break;
			case "MP_TYPE":
			  this.MpType=FetchNodeValue(f_child);
			  break;  
		}
	 //Устанавливаем следующий узел
	 f_child = f_child.nextSibling;

  } while (f_child) ;
 
  //Функции
}


function CategoryInfo(f_child) 
{
	this.PoiTypes=[];
    
  //В этом цикле мы перебираем ноды xml, относящиеся к данному пои
  do
    {
  	  	//Выбираем имя узла и в соответствии с этим выполняем необходимое действие
		switch (f_child.nodeName)
		{
		    //Если это описание, оформляем как описание
			case "NAME":
			  this.CategoryName=FetchNodeValue(f_child);
			  break;
			case "POITYPE":
			  this.PoiTypes.push(new PoiTypeInfo(f_child.firstChild));
			  break;
			      
		}
	f_child = f_child.nextSibling;

  } while (f_child) ;
 
  //Функции
}
//Получение списка категорий с сервера
function GetCategories()
{
  var Cats=[];	
  var xmlhttp = getXmlHttp1();
  xmlhttp.open('GET', '/categories.xml', false);
  xmlhttp.send(null);
  if(xmlhttp.status != 200) 
  {
  	  throw ("Невозможно получить список рубрик");
  }	  
  var doc = xmlhttp.responseXML.documentElement;
  
  var items = doc.getElementsByTagName("CATEGORY");
    
  for (var i = 0; i < items.length; i++)
    {
	  //Отсчитываем с первого дочернего узла
	  var f_child = items[i].firstChild;
	  
	  
	  aCategoryInfo = new CategoryInfo(f_child);
      	
      Cats.push(aCategoryInfo);
      

    }//кц
  
	
	return Cats;
}

//=======================================================================================
//Рубрикатор
//=======================================================================================
//Заполнение рубрикатора
function FillCategories(){
  
  var CatDiv=document.getElementById("categories");
  CatDiv.innerHTML='<b>Рубрикатор</b><BR>';
  CatDiv.innerHTML=  CatDiv.innerHTML +'<ul>';
  for (var i = 0; i < Categories.length; i++)
  {
 	 CatDiv.innerHTML=CatDiv.innerHTML+'<li><a href="#" onclick="ProcessCategoryClick(Categories['+i+']);">'+Categories[i].CategoryName+'</a></li>';
  }
  CatDiv.innerHTML=CatDiv.innerHTML+'</ul>';
}

//обработка щелчка по рубрикатору - раскрытие рубрик.
function ProcessCategoryClick(aCategory)
{
  var CatDiv=document.getElementById("categories");
  CatDiv.innerHTML='<P><a href="#" onclick="FillCategories()">Назад к списку рубрик</a></P>';
  CatDiv.innerHTML=CatDiv.innerHTML + '<p><b>'+aCategory.CategoryName+'</b></p>';
  
  CurrentCategoryName=aCategory.CategoryName;
  CatDiv.innerHTML=  CatDiv.innerHTML +'<ul>';
  for (var i = 0; i < aCategory.PoiTypes.length; i++)
  {
 	 CatDiv.innerHTML=CatDiv.innerHTML+'<li><a href="#" onclick="ProcessPoiTypeClick(\''+aCategory.PoiTypes[i].MpType+'\',\''+aCategory.PoiTypes[i].PoiTypeNamePl+'\');">'+aCategory.PoiTypes[i].PoiTypeNamePl+'</a></li>';
  }
  CatDiv.innerHTML=  CatDiv.innerHTML +'</ul>';
  return false;
}

//=======================================================================================
//Самая интересная функция - проставление маркеров, по щелчку на ветке дерева
//=======================================================================================

function ProcessPoiTypeClick(MpType,PoiTypeNamePl) {
  // (1) создать объект для запроса к серверу
  var req = getXmlHttp1()  

  // (2)
  var statusElem = document.getElementById('header') 

  req.onreadystatechange = function() {  
  // onreadystatechange активируется при получении ответа сервера
    if (req.readyState == 4) { 
      // если запрос закончил выполняться
      //statusElem.innerHTML = req.statusText // показать статус (Not Found, ОК..)
      if(req.status == 200) { 
        // если статус 200 (ОК) - выдать ответ пользователю
        var POIs=GetPOI(req.responseXML.documentElement,PoiTypeNamePl);
         
        AddPoiLayer(POIs);
        statusElem.innerHTML=CurrentCategoryName+'->'+PoiTypeNamePl+ ' (найдено '+POIs.length+' шт.)';
        //alert("Ответ сервера получен ");
      }
      else{
        // тут можно добавить else с обработкой ошибок запроса
        statusElem.innerHTML = 'Ошибка! '+req.statusText ;
      }
    }
  }
// (3) задать адрес подключения


  req.open('GET', '/getdata.xml?MpType='+MpType, true);  


  // объект запроса подготовлен: указан адрес и создана функция onreadystatechange
  // для обработки ответа сервера
  // (4)
  req.send(null);  // отослать запрос
  // (5)
  statusElem.innerHTML = 'Идет загрузка...'

}


//=======================================================================================
//Получение массива POI
//=======================================================================================
function GetPOI(doc,PoiTypeNamePl)
{

  var POIs=[];  
  var items = doc.getElementsByTagName("POI");
  
  for (var i = 0; i < items.length; i++)
    {
	  //Отсчитываем с первого дочернего узла
	  var f_child = items[i].firstChild;
      POIs.push( new PoiInfo(f_child,PoiTypeNamePl));
    }
    
  
  return POIs;
}

function AddPoiLayer(POIs)
{
       	  
 
    var PoiName="";
    var HouseLat=0;
    var HouseLon=0;

    var Lat0=0.0;
    var Lon0=0.0;
    var intLen=POIs.length;

    var markers = [];
    
    //Cнесем старый слой 
    //delete clusterer;
    map.clearOverlays();
    //if (clusterer!=null) 
      //map.removeOverlay(clusterer);
    
    for (var i = 0; i < intLen; i++)
    {
	  
	  
	  aPoiInfo = POIs[i];

	  PoiName=aPoiInfo.PoiName;
	  HouseLat=aPoiInfo.Lat;
      HouseLon=aPoiInfo.Lon;
      
      Lat0=Lat0+parseFloat(HouseLat);
      Lon0=Lon0+parseFloat(HouseLon);
      	

      markers.push(new CM.Marker(new CM.LatLng(HouseLat, HouseLon),{title: PoiName}));
      map.addOverlay(markers[i]);
      CM.Event.addListener(markers[i], 'click', doClick, aPoiInfo);


    }//кц по точкам
    

    Lat0=Lat0/intLen;
    Lon0=Lon0/intLen;
    //document.write("<p>"+ " " +  Lat0+ " " + Lon0+"</p>");

    map.setCenter(new CM.LatLng(Lat0,Lon0), 8);


    //clusterer = new CM.MarkerClusterer(map, {clusterRadius: 40,maxZoomLevel:10});
    //clusterer.addMarkers(markers);
   return intLen;
}
//=======================================================================================
//Это основной блок кода
//=======================================================================================
//Beginning
try{	
	
  var CurrentCategoryName="";	
  var aCurrentPoiType=null;
  var Categories=GetCategories();
  FillCategories();
  
  var cloudmade = new CM.Tiles.OpenStreetMap.Mapnik();
  var map = new CM.Map('WebMap', cloudmade);
  var clusterer=null;
  
  var topRight = new CM.ControlPosition(CM.TOP_RIGHT, new CM.Size(50, 20));
  map.addControl(new CM.LargeMapControl());
  map.addControl(new CM.ScaleControl());

  map.setCenter(new CM.LatLng(55.75,37.6), 8); 
 
 // AddPoiLayer('0xF202');
    
} //блока try

  catch(err){
  document.write("<p>Ошибка выполнения: "+err+"</p>"); 
  //alert(err);
           

}  



 //---------------Вспомогательная фукция получения XMLHTTP----------------------------------    

    function getXmlHttp(){

    var xmlhttp;

    try {

      xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");

    } catch (e) {

      try {

        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");

      } catch (E) {

        xmlhttp = false;

      }

    }

    if (!xmlhttp && typeof XMLHttpRequest!='undefined') {

      xmlhttp = new XMLHttpRequest();

    }

      return xmlhttp;

    }

    

  function getXmlHttp1() {

  if (typeof XMLHttpRequest == 'undefined') {

    XMLHttpRequest = function() {

      try { return new ActiveXObject("Msxml2.XMLHTTP.6.0"); }

        catch(e) {}

      try { return new ActiveXObject("Msxml2.XMLHTTP.3.0"); }

        catch(e) {}

      try { return new ActiveXObject("Msxml2.XMLHTTP"); }

        catch(e) {}

      try { return new ActiveXObject("Microsoft.XMLHTTP"); }

        catch(e) {}

      document.write("This browser does not support XMLHttpRequest");  

      throw new Error("This browser does not support XMLHttpRequest.");

    };

  }

  return new XMLHttpRequest();

}
