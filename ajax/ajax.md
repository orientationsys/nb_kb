AJAX = Asynchronous JavaScript and XML（异步的 JavaScript 和 XML）。

ajax是与服务器交换数据并更新部分网页的艺术，在不重新加载整个页面的情况下。

像我们常用的 $ajax、axios、fly 都是封装好的ajax 所以不接触原生的写法 就不了解它是什么原理。

1、创建 XMLHttpRequest 对象
  
  XMLHttpRequest是ajax的基础 所有的现代主流浏览器(ie7+/Firefox/Chrome/Safari/Opera)都支持XMLHttpRequest 对象，唯独ie5 ie6 使用ActiveXObject，任性，没办法。所以为了应对现在所有的现代浏览器,首先检查是否支持XMLHttpRequest，如果不支持就创建ActiveXObject。

      let xml_http;
      
      if (window.XMLHttpRequest) {

        xml_http = new XMLHttpRequest();
      } else {

        xml_http = new ActiveXObject("Microsoft.XMLHTTP");
      }

2、XMLHttpRequest 对象用于和服务器交换数据。

向服务器发送请求我们使用 XMLHttpRequest 对象的 open() 和 send() 方法：

    xlm_http.open(method,url,async);

      method : 请求的类型 get 或者 post

      url ：路径

      async: true(异步)或者flase(同步)

    Xml_send(string);

      string 就是向服务器发送的数据 仅限post请求

      如果是get请求的话 在url里面带参数

如果发送表单那样的post的数据的话 使用 setRequestHeader() 来添加 HTTP 头。然后在 send() 方法中规定您希望发送的数据

    xmlhttp.open("POST","api",true);
    xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    xmlhttp.send("name=yyy&pwd=xxx");

3、处理基于响应的业务

ajax指的是异步 JavaScript 和 XML（Asynchronous JavaScript and XML）。

XMLHttpRequest 对象如果要用于ajax的话，其open()方法的 async 参数必须设置为 true。然后在规定的onreadystatechange事件中的就绪状态时执行的函数

onreadystatechange是一个存储函数,每当 readyState 属性改变时，就会调用该函数。

readyState存有 XMLHttpRequest 的状态。从 0 到 4 发生变化.

    0: 请求未初始化

    1: 服务器连接已建立

    2: 请求已接收

    3: 请求处理中

    4: 请求已完成，且响应已就绪

status 状态码

以上三个是XMLHttpRequest重要的三个属性
假设我们 等待请求完成 且成功后处理的一个业务逻辑

    xmlhttp.onreadystatechange=function()
      {
      if (xmlhttp.readyState==4 && xmlhttp.status==200)
        {
          console.log(nice);
        }
      }
    
注意 因为readyState有五个状态 所以
onreadystatechange事件被触发 five 次，对应着readyState的每个变化。


Do you want to continue your study, or do you want to stop here！

Please make your choice！

Game Over!













