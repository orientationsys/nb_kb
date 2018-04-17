# 什么是API
<p>API（Application Programming Interface,应用程序编程接口）是一些预先定义的函数，目的是提供应用程序与开发人员基于某软件或硬件得以访问一组例程的能力，而又无需访问源码，或理解内部工作机制的细节。</p>
<p>通俗的讲API就类似于一个黑盒，你不需要知道它具体是怎么实现的，你只需要把它需要的参数给它，接收它返回的参数。</p>

# 为什么要使用API
<p>对于web开发来说，随着互联网技术的发展，现在的网站架构基本都由原来的后端渲染，变成了前端渲染、前后端分离的形态，而且前端技术和后端技术在各自的道路上越走越远。前端和后端的唯一联系，变成了API接口</p>

# RESTful API
<p>既然API是如此的重要，那么要如何设计API呢？RESTful API是目前比较成熟的一套互联网应用程序的API设计理论</p>
<p><a href="http://www.ruanyifeng.com/blog/2014/05/restful_api">http://www.ruanyifeng.com/blog/2014/05/restful_api</a></p>

# API文档
<p>既然API是用来联系后端和前端的，那么现在后端的API已经写完了，那么前端的开发人员要怎么去调用呢?</p>
<p>这个时候就需要写出一个API文档了。</p>
<p>1. 写在doc或者readme.md中。</p>
<p>2. 使用API文档生成工具，例如swagger。<p>

# 如何使用swagger
<p>1. Intall。使用composer, 具体用法可以在<a href="https://github.com/DarkaOnLine/L5-Swagger">github</a>中查看。</p>
<p>2. 配置入口.</p>

```javascript
/**
 * @SWG\Swagger(
 *     basePath="/api/v1/",
 *     schemes={"http", "https"},
 *     @SWG\Info(
 *         version="1.0.0",
 *         title="L5 Swagger API title",
 *         description="L5 Swagger API description",
 *     )
 * )
 */
```
<p>3. GET请求</p>

```javascript
/**
 * @SWG\GET(
 *     path="/dashboard/get_property",
 *     tags={"landlord"},
 *     summary="landlord get single property",
 *     produces={"application/json"},
 *     @SWG\Parameter(
 *         name="ref",
 *         in="path",
 *         type="string",
 *         description="property's ref",
 *         required=true,
 *     ),
 *     @SWG\Response(
 *         response=200,
 *         description="success"
 *     ),
 *     @SWG\Response(
 *         response=400,
 *         description="unexpected error, error info in jsonData['error']"
 *     )
 * )
 */
```

<p>4. POST请求</p>

```php
/**
 * @SWG\POST(
 *     path="/dashboard/add_property_image",
 *     tags={"landlord"},
 *     summary="property images, image type in ['jpg', 'png','jpeg']",
 *     produces={"application/json"},
 *     @SWG\Parameter(
 *         name="ref",
 *         in="formData",
 *         type="integer",
 *         description="property ref",
 *         required=true,
 *     ),
 *     @SWG\Parameter(
 *         name="file_name",
 *         in="formData",
 *         type="string",
 *         description="image name",
 *         required=true,
 *     ),
 *     @SWG\Response(
 *         response=200,
 *         description="success, url:image page, id:image id"
 *     ),
 *     @SWG\Response(
 *         response=400,
 *         description="unexpected error, error info in jsonData['error']"
 *     )
 * )
 */
```
