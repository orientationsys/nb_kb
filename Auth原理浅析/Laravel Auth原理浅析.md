# Laravel Auth原理浅析

## 概述
Laravel 中实现登录认证非常简单。实际上，几乎所有东西 Laravel 都已经为你配置好了。配置文件位于 config/auth.php，其中包含了用于调整认证服务行为的、文档友好的选项配置。

在底层代码中，Laravel 的认证组件由“guards”和“providers”组成，Guard 定义了用户在每个请求中如何实现认证，例如，Laravel 通过 session guard 来维护 Session 存储的状态和 Cookie。

Provider 定义了如何从持久化存储中获取用户信息，Laravel 底层支持通过 Eloquent 和数据库查询构建器两种方式来获取用户，如果需要的话，你还可以定义额外的 Provider。


* 学院君注：通俗点说，在进行登录认证的时候，要做两件事，一个是从数据库存取用户数据，一个是把用户登录状态保存起来，在 Laravel 的底层实现中，通过 Provider 存取数据，通过 Guard 存储用户认证信息，前者主要和数据库打交道，后者主要和 Session 打交道（API 例外）。

## 原理解读
```
 php artisan make:auth 

 // Http/Controllers/Auth/LoginController　使用了　AuthenticatesUsers 

其中　下面这三个方法诠释了登录逻辑的全部。

    public function login(Request $request)
    {
    	//字段验证
        $this->validateLogin($request);
        // 登录次数验证 ThrottlesLogins trait 默认5次
        if ($this->hasTooManyLoginAttempts($request)) {
            $this->fireLockoutEvent($request);
            return $this->sendLockoutResponse($request);
        }
        // 这里尝试登录系统，
        if ($this->attemptLogin($request)) {
            return $this->sendLoginResponse($request);
        }
        $this->incrementLoginAttempts($request);
        return $this->sendFailedLoginResponse($request);
    }
    protected function attemptLogin(Request $request)
    {
        return $this->guard()->attempt(
            $this->credentials($request), $request->has('remember')
        );
    }

    protected function guard()
    {
        return Auth::guard();
    }
```
控制器会去寻找Auth::guard(), 那这个Auth::guard()是个什么东西呢，
首先　Auth 是系统的单例，原型在
```
Illuminate\Auth\AuthManager;
```

```
 public function __construct($app)
    {
        $this->app = $app;

        $this->userResolver = function ($guard = null) {
            return $this->guard($guard)->user();
        };
    }
    // Auth::guard();就是调用了这个方法。
    public function guard($name = null)
    {
        // 首先查找$name, 没有就使用默认的驱动，
        $name = $name ?: $this->getDefaultDriver();
        // 意思就是要实例化出这个驱动并且返回，
        return isset($this->guards[$name])
                    ? $this->guards[$name]
                    : $this->guards[$name] = $this->resolve($name);
    }

　　　
    // 默认的驱动是从配置文件里面读取的，/config/auth.php　default配置项
    public function getDefaultDriver()
    {
        return $this->app['config']['auth.defaults.guard'];
    }
　　
　　 // 这里是构造Auth-guard驱动
　　 protected function resolve($name)
    {
        $config = $this->getConfig($name);
        if (is_null($config)) {
            throw new InvalidArgumentException("xxx");
        }
        // 这里是如果你自己实现的驱动就返回
        if (isset($this->customCreators[$config['driver']])) {
            return $this->callCustomCreator($name, $config);
        }
        // 这里是系统默认两个类分别是 
       // session 和 token 这里主要讲 sessionGuard .
        $driverMethod = 'create'.ucfirst($config['driver']).'Driver';
        //createTokenDriver  method
        if (method_exists($this, $driverMethod)) {
            return $this->{$driverMethod}($name, $config);
        }
        throw new InvalidArgumentException("xxx");
    }

    public function createSessionDriver($name, $config)
    {
        $provider = $this->createUserProvider($config['provider']);

        $guard = new SessionGuard($name, $provider, $this->app['session.store']);

        // When using the remember me functionality of the authentication services we
        // will need to be set the encryption instance of the guard, which allows
        // secure, encrypted cookie values to get generated for those cookies.
        if (method_exists($guard, 'setCookieJar')) {
            $guard->setCookieJar($this->app['cookie']);
        }

        if (method_exists($guard, 'setDispatcher')) {
            $guard->setDispatcher($this->app['events']);
        }

        if (method_exists($guard, 'setRequest')) {
            $guard->setRequest($this->app->refresh('request', $guard, 'setRequest'));
        }

        return $guard;
    }
```


也就是说终归到底，Auth::guard(), 在默认配置里面是给我反回了一个sessionGuard .

```
namespace Illuminate\Auth;
class SessionGuard{

    public function attempt(array $credentials = [], $remember = false)
    {
        // 这里触发　试图登录事件，此时还没有登录
        $this->fireAttemptEvent($credentials, $remember);
        $this->lastAttempted = 
        $user = $this->provider->retrieveByCredentials($credentials);

        // 这里会调用hasValidCredentials，其实就是验证用户名和密码的一个过程
        if ($this->hasValidCredentials($user, $credentials)) {
            // 如果验证通过了，就调用login方法 .
            $this->login($user, $remember);
            return true;
        }
        // 否则就触发登录失败事件，返回假
        $this->fireFailedEvent($user, $credentials);
        return false;
    }
    // 这里是登录用户的操作，就是说调用这个方法已经是合法用户了，必须是一个
　　// AuthenticatableContract 的实例 .
    public function login(AuthenticatableContract $user, 
    $remember = false)
    {
        // 直接更新session,这里就是把session存起来，session的键在该方法的
        // getName() 里边，
        $this->updateSession($user->getAuthIdentifier());
        if ($remember) {
            $this->ensureRememberTokenIsSet($user);
            $this->queueRecallerCookie($user);
        }
　　　　　// 触发登录事件，已经登录了这个时候，
        $this->fireLoginEvent($user, $remember);
        // 将user对象保存到sessionGuard , 后续的类访问Auth::user();直接拿到
        $this->setUser($user);
    }
    // 这里就是经常使用到的 Auth::user()了，具体如何返回看AuthManager里面的
    // __call
    public function user()
    {
        if ($this->loggedOut) {
            return;
        }
        if (! is_null($this->user)) {
            return $this->user;
        }
        // 这里读取session拿到user的id　，
        $id = $this->session->get($this->getName());
        $user = null;
        // 如果拿到了id ,查找到该user
        if (! is_null($id)) {
            if ($user = $this->provider->retrieveById($id)) {
                $this->fireAuthenticatedEvent($user);
            }
        }
        $recaller = $this->recaller();
        if (is_null($user) && ! is_null($recaller)) {
            $user = $this->userFromRecaller($recaller);
            if ($user) {
                $this->updateSession($user->getAuthIdentifier());

                $this->fireLoginEvent($user, true);
            }
        }
        return $this->user = $user;
    }
    // 这里就直接返回用户id了，
    public function id()
    {
        if ($this->loggedOut) {
            return;
        }
        return $this->user()
                    ? $this->user()->getAuthIdentifier()
                    : $this->session->get($this->getName());
    }
}
```
大致流程就是这样子
```
//伪代码
$input = $request()->only(['username' ,'password']);

if(Auth::guard("session")->attempt($input)){
  // 登录成功
}else{
  // 登录失败
}
```

## 相关链接
* Laravel Auth 原理浅析：[https://zhuanlan.zhihu.com/p/27669540/](https://zhuanlan.zhihu.com/p/27669540)
* Laravel 5.6 文档：[http://laravelacademy.org/post/8900.html](http://laravelacademy.org/post/8900.html)
