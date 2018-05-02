# Laravel中的Facede
Facades（读音：/fəˈsäd/ ）为应用程序的 服务容器 中可用的类提供了一个「静态」接口。Laravel 自带了很多 Facades ，可以访问绝大部分 Laravel 的功能。Laravel Facades 实际上是服务容器中底层类的「静态代理」，它提供了简洁而富有表现力的语法，甚至比传统的静态方法更具可测试性和扩展性。
```
use Hash;


Hash::make($value);
```
## class_alias函数
为类创造别名  config/app.php中的aliases
```
return [
    'aliases' => [
        'Hash' => Illuminate\Support\Facades\Hash::class
    ]
];
```
## 重载
PHP所提供的"重载"（overloading）是指动态地"创建"类属性和方法。我们是通过魔术方法（magic methods）来实现的。
在对象中调用一个不可访问方法时，__call() 会被调用。
在静态上下文中调用一个不可访问方法时，__callStatic() 会被调用。
## Illuminate\Support\Facades\Hash类
```
namespace Illuminate\Support\Facades;

/**
 * @see \Illuminate\Hashing\BcryptHasher
 */
class Hash extends Facade
{
    /**
     * Get the registered name of the component.
     *
     * @return string
     */
    protected static function getFacadeAccessor()
    {
        return 'hash';
    }
}
```
## Facade类
```
    /**
     * Handle dynamic, static calls to the object.
     *
     * @param  string  $method
     * @param  array   $args
     * @return mixed
     *
     * @throws \RuntimeException
     */
    public static function __callStatic($method, $args)
    {
        $instance = static::getFacadeRoot();

        if (! $instance) {
            throw new RuntimeException('A facade root has not been set.');
        }

        return $instance->$method(...$args);
    }

    /**
     * Get the root object behind the facade.
     *
     * @return mixed
     */
    public static function getFacadeRoot()
    {
        return static::resolveFacadeInstance(static::getFacadeAccessor());
    }

    /**
     * Resolve the facade root instance from the container.
     *
     * @param  string|object  $name
     * @return mixed
     */
    protected static function resolveFacadeInstance($name)
    {
        if (is_object($name)) {
            return $name;
        }

        if (isset(static::$resolvedInstance[$name])) {
            return static::$resolvedInstance[$name];
        }

        return static::$resolvedInstance[$name] = static::$app[$name];
    }

```
## BcryptHasher类
```
namespace Illuminate\Hashing;

use RuntimeException;
use Illuminate\Contracts\Hashing\Hasher as HasherContract;

class BcryptHasher implements HasherContract
{
    /**
     * Default crypt cost factor.
     *
     * @var int
     */
    protected $rounds = 10;

    /**
     * Hash the given value.
     *
     * @param  string  $value
     * @param  array   $options
     * @return string
     *
     * @throws \RuntimeException
     */
    public function make($value, array $options = [])
    {
        $hash = password_hash($value, PASSWORD_BCRYPT, [
            'cost' => $this->cost($options),
        ]);

        if ($hash === false) {
            throw new RuntimeException('Bcrypt hashing not supported.');
        }

        return $hash;
    }
}

```
## 注册hash服务
```
namespace Illuminate\Hashing;

use Illuminate\Support\ServiceProvider;

class HashServiceProvider extends ServiceProvider
{
    /**
     * Indicates if loading of the provider is deferred.
     *
     * @var bool
     */
    protected $defer = true;

    /**
     * Register the service provider.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton('hash', function () {
            return new BcryptHasher;
        });
    }

    /**
     * Get the services provided by the provider.
     *
     * @return array
     */
    public function provides()
    {
        return ['hash'];
    }
}
```
```
\Hash::make('password');
app('hash')->make('password');
app()['hash']->make('password');
\App::make('hash')->make('password');
```
## Cache的Facade
```
\Cache::get('a', 'default');
```
按照上面的例子应该是实例化CacheManager然后调用get方法 但实际上没有这个方法
```
    /**
     * Dynamically call the default driver instance.
     *
     * @param  string  $method
     * @param  array   $parameters
     * @return mixed
     */
    public function __call($method, $parameters)
    {
        return $this->store()->$method(...$parameters);
    }

    /**
     * Get a cache store instance by name.
     *
     * @param  string|null  $name
     * @return mixed
     */
    public function store($name = null)
    {
        $name = $name ?: $this->getDefaultDriver();


        return $this->stores[$name] = $this->get($name);
    }

    /**
     * Get the default cache driver name.
     *
     * @return string
     */
    public function getDefaultDriver()
    {
        return $this->app['config']['cache.default'];
    }

    /**
     * Attempt to get the store from the local cache.
     *
     * @param  string  $name
     * @return \Illuminate\Contracts\Cache\Repository
     */
    protected function get($name)
    {
        return isset($this->stores[$name]) ? $this->stores[$name] : $this->resolve($name);
    }

    /**
     * Resolve the given store.
     *
     * @param  string  $name
     * @return \Illuminate\Contracts\Cache\Repository
     *
     * @throws \InvalidArgumentException
     */
    protected function resolve($name)
    {
        $config = $this->getConfig($name);

        if (is_null($config)) {
            throw new InvalidArgumentException("Cache store [{$name}] is not defined.");
        }

        if (isset($this->customCreators[$config['driver']])) {
            return $this->callCustomCreator($config);
        } else {
            $driverMethod = 'create'.ucfirst($config['driver']).'Driver';

            if (method_exists($this, $driverMethod)) {
                return $this->{$driverMethod}($config);
            } else {
                throw new InvalidArgumentException("Driver [{$config['driver']}] is not supported.");
            }
        }
    }

    /**
     * Create an instance of the file cache driver.
     *
     * @param  array  $config
     * @return \Illuminate\Cache\FileStore
     */
    protected function createFileDriver(array $config)
    {
        return $this->repository(new FileStore($this->app['files'], $config['path']));
    }

    /**
     * Create a new cache repository with the given implementation.
     *
     * @param  \Illuminate\Contracts\Cache\Store  $store
     * @return \Illuminate\Cache\Repository
     */
    public function repository(Store $store)
    {
        $repository = new Repository($store);

        if ($this->app->bound(DispatcherContract::class)) {
            $repository->setEventDispatcher(
                $this->app[DispatcherContract::class]
            );
        }

        return $repository;
    }
```
## Repository类
```
    /**
     * Retrieve an item from the cache by key.
     *
     * @param  string  $key
     * @param  mixed   $default
     * @return mixed
     */
    public function get($key, $default = null)
    {
        if (is_array($key)) {
            return $this->many($key);
        }

        $value = $this->store->get($this->itemKey($key));

        // If we could not find the cache value, we will fire the missed event and get
        // the default value for this cache value. This default could be a callback
        // so we will execute the value function which will resolve it if needed.
        if (is_null($value)) {
            $this->event(new CacheMissed($key));

            $value = value($default);
        } else {
            $this->event(new CacheHit($key, $value));
        }

        return $value;
    }
```
## 参考
laravel文档facede说明(https://laravel-china.org/docs/laravel/5.5/facades#facades-vs-dependency-injection)

无driver的facade博客(https://alanstorm.com/laravel_facades/)

有driver的facade博客(https://alanstorm.com/laravel_service_manager_indirection/)
