
<h1>理解oAuth2.0</h1>
 1. 需求
 假设： 有一个"云冲印"的网站，可以将用户储存在Google的照片，冲印出来。用户为了使用该服务，必须让"云冲印"读取自己储存在Google上的照片。
 问题是只有得到用户的授权，Google才会同意"云冲印"读取这些照片。那么，"云冲印"怎样获得用户的授权呢？

传统方法是，用户将自己的Google用户名和密码，告诉"云冲印"，后者就可以读取用户的照片了。这样的做法有以下几个严重的缺点。

（1）"云冲印"为了后续的服务，会保存用户的密码，这样很不安全。

（2）Google不得不部署密码登录，而我们知道，单纯的密码登录并不安全。

（3）"云冲印"拥有了获取用户储存在Google所有资料的权力，用户没法限制"云冲印"获得授权的范围和有效期。

（4）用户只有修改密码，才能收回赋予"云冲印"的权力。但是这样做，会使得其他所有获得用户授权的第三方应用程序全部失效。

（5）只要有一个第三方应用程序被破解，就会导致用户密码泄漏，以及所有被密码保护的数据泄漏。

OAuth（开放授权）是一个开放标准，允许用户让第三方应用访问该用户在某一网站上存储的私密的资源（如照片，视频，联系人列表），而无需将用户名和密码提供给第三方应用。

 2. 专有名词

（1） Third-party application：第三方应用程序，本文中又称"客户端"（client），即上一节例子中的"云冲印"。

（2）HTTP service：HTTP服务提供商，本文中简称"服务提供商"，即上一节例子中的Google。

（3）Resource Owner：资源所有者，本文中又称"用户"（user）。

（4）User Agent：用户代理，本文中就是指浏览器。

（5）Authorization server：认证服务器，即服务提供商专门用来处理认证的服务器。

（6）Resource server：资源服务器，即服务提供商存放用户生成的资源的服务器。它与认证服务器，可以是同一台服务器，也可以是不同的服务器。

3.OAuth 2.0的运行流程

（A）用户打开客户端以后，客户端要求用户给予授权。

（B）用户同意给予客户端授权。

（C）客户端使用上一步获得的授权，向认证服务器申请令牌。

（D）认证服务器对客户端进行认证以后，确认无误，同意发放令牌。

（E）客户端使用令牌，向资源服务器申请获取资源。

（F）资源服务器确认令牌无误，同意向客户端开放资源。

3.以微信为例


<img src="https://res.wx.qq.com/op_res/D0wkkHSbtC6VUSHX4WsjP5ssg5mdnEmXO8NGVGF34dxS9N1WCcq6wvquR4K_Hcut">

步骤：

第一步：请求CODE

第三方使用网站应用授权登录前请注意已获取相应网页授权作用域（scope=snsapi_login），则可以通过在PC端打开以下链接：

https://open.weixin.qq.com/connect/qrconnect?appid=APPID&redirect_uri=REDIRECT_URI&response_type=code&scope=SCOPE&state=STATE#wechat_redirect
若提示“该链接无法访问”，请检查参数是否填写错误，如redirect_uri的域名与审核时填写的授权域名不一致或scope不为snsapi_login。

第二步：通过code获取access_token

通过code获取access_token

https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code

第三步：通过access_token调用接口，获取用户基本数据资源或帮助用户实现基本操作。

获取access_token后，进行接口调用，有以下前提：

1. access_token有效且未超时；
2. 微信用户已授权给第三方应用帐号相应接口作用域（scope）


return array(

	//'配置项'=>'配置值'
	'APPID'=>'xxxxxxx',
	'SECRET'=>'xxxxx',
	'REDIRECT_URI'=>'http://www.xxxx.cn/index.php/Home/Login/auth',
 
);


//获取code跳转

function get_code($state)
{

    $param['appid'] = C('APPID'); //AppID
    $param ['redirect_uri'] = C('REDIRECT_URI'); //获取code后的跳转地址
    $param ['response_type'] = 'code'; //不用修改
    $param ['scope'] =  'snsapi_userinfo';//'snsapi_userinfo';//'snsapi_base'; //不用修改
    $param ['state'] = $state; //可在行定义该参数
    
    $url = 'https://open.weixin.qq.com/connect/oauth2/authorize?' . http_build_query($param) . '#wechat_redirect';
    
    //redirect ( $url );
    header('Location: '.$url);
}

//获取网页授权access_token，此access_token非普通的access_token，
//详情请看微信公众号开发者文档


function get_access_token(){

    $param ['appid'] = C('APPID'); //AppID
    $param ['secret'] = C('SECRET'); //AppSecret
    $param ['code'] = $_GET['code'];
    $param ['grant_type'] = 'authorization_code';
    	
    $url = 'https://api.weixin.qq.com/sns/oauth2/access_token?'.http_build_query($param);
   
    $content = file_get_contents($url);
    $content = json_decode ( $content, true );
	//var_dump($content);
	//exit;
    if (! empty ( $content ['errmsg'] )) {
       return false;
    }
    
    return $content;
}

//通过授权获取用户信息, $content 是数组类型

function get_userinfo_by_auth($content){

     $url = 'https://api.weixin.qq.com/sns/userinfo?access_token='.$content ['access_token'].
     '&openid='.$content ['openid'].'&lang=zh_CN';
	 $user = file_get_contents($url);
     $user = json_decode($user, true);
     
     return $user;
}

//微信授权登录 LoginController

	public function auth(){
			
		$state = 'test';//该字符串是获取code时自定义的参数。
	    if(I('get.state') != $state){//获取code
	        get_code($state); //调用function.php中定义的get_code函数，$state是链接自带参数的 
	        
	    }else{
	        //获取code之后	    
	        //获取access_token;
	      $content = get_access_token(); 
	       
	       //获取用户信息
	       $u = get_userinfo_by_auth($content); //$user是保存用户信息的一位数组
	       $user=array(
		   		'openid'=>$u['openid'],
		   		'sex'=>$u['sex'],
		   		'nickname'=>$u['nickname'],
		   		'imgurl'=>$u['headimgurl'],		   		
		   );
     var_dump($user);
 }

