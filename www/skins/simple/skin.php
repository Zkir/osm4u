<?php
#==================================================
# Шаблон страницы для z-site :)
# (с) Zkir, 2008
#==================================================

# Используется класс TZSitePage
# В нем должны быть объявлены переменные:
# $title -   Заголовок страницы;
# $header -  Заголовок  (H1);
# $content - содержимое ;

  if(!isset($this))
    {
      die ("Содержимое страницы не определено");
    }
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>
      <?php
        echo $this->title;
      ?>
     </title>
    <meta http-equiv="Content-Type"   content="text/html; charset=UTF-8">
  </head>

  </head>
  <body style="width:100%">
 

<?php
  echo $this->content;
?>
<p>
</p>
<HR/>
  <center>
    osm4u.ru<BR/>
    <small>
      &copy; Карты — участники проекта <a href="http://openstreetmap.org">OpenStreetMap</a>,
     по лицензии <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>.<br /> 	
    </small>
  </center>
</body>
</HTML>

